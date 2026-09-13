package com.studybuddy.app

import android.Manifest
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.content.pm.ServiceInfo
import android.os.Build
import android.os.IBinder
import android.os.SystemClock
import android.util.Log
import androidx.concurrent.futures.await
import androidx.core.app.NotificationCompat
import androidx.core.app.ServiceCompat
import androidx.core.content.ContextCompat
import androidx.health.services.client.ExerciseUpdateCallback
import androidx.health.services.client.HealthServices
import androidx.health.services.client.MeasureCallback
import androidx.health.services.client.data.Availability
import androidx.health.services.client.data.DataPointContainer
import androidx.health.services.client.data.DataType
import androidx.health.services.client.data.DataTypeAvailability
import androidx.health.services.client.data.DeltaDataType
import androidx.health.services.client.data.ExerciseConfig
import androidx.health.services.client.data.ExerciseLapSummary
import androidx.health.services.client.data.ExerciseType
import androidx.health.services.client.data.ExerciseTrackedStatus
import androidx.health.services.client.data.ExerciseUpdate
import androidx.health.services.client.data.HeartRateAccuracy
import androidx.health.services.client.data.SampleDataPoint
import androidx.health.services.client.endExercise
import androidx.health.services.client.getCapabilities
import androidx.health.services.client.startExercise
import androidx.wear.ongoing.OngoingActivity
import androidx.wear.ongoing.Status
import java.io.File
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.channels.Channel
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import kotlinx.coroutines.runBlocking
import kotlinx.coroutines.withTimeoutOrNull
import org.json.JSONObject


class WearCaptureService : Service() {
    companion object {
        const val PREFS = "study_buddy_wear_capture"
        const val ACTION_START = "com.studybuddy.app.START_CAPTURE"
        const val ACTION_STOP = "com.studybuddy.app.STOP_CAPTURE"
        const val ACTION_FLUSH = "com.studybuddy.app.FLUSH_CAPTURE"
        const val ACTION_ACK = "com.studybuddy.app.ACK_CAPTURE_EVENT"
        const val ACTION_TIMER = "com.studybuddy.app.RECONCILE_TIMER"
        const val ACTION_INJECT = "com.studybuddy.app.INJECT_SYNTHETIC"
        const val EXTRA_CONFIG = "session_config"
        const val EXTRA_ACK = "event_ack"
        const val EXTRA_TIMER = "timer_state"
        const val EXTRA_SCENARIO = "scenario"
        const val EXTRA_PRESET = "preset"
        const val EXTRA_SEED = "seed"
        const val STATUS_FILE = "capture_status.json"

        private const val TAG = "SbCapture"
        private const val CHANNEL_ID = "study_buddy_focus"
        private const val NOTIFICATION_ID = 701
        private const val FRAME_PERIOD_MS = 5_000L
        private const val EXERCISE_FALLBACK_MS = 12_000L
        private const val FLUSH_STUCK_MS = 15_000L
        private const val QUEUE_DRAIN_INTERVAL_MS = 200L
        private const val CAPABILITY_TIMEOUT_MS = 4_000L
        private const val HS_REGISTER_TIMEOUT_MS = 8_000L
        private const val HS_UNREGISTER_TIMEOUT_MS = 4_000L
        private const val DATA_LAYER_SEND_TIMEOUT_MS = 6_000L
        private const val TERMINAL_FLUSH_TIMEOUT_MS = 8_000L
        private val PRODUCTION_QUALITIES = setOf("high", "medium")
        private const val MAX_BUFFERED_EVENTS = 1_000

        fun acknowledgeStoredEvent(context: Context, rawAck: String): Boolean =
            WearEventQueue(context).use { it.acknowledge(rawAck) }

        fun hasStoredEvents(context: Context): Boolean =
            WearEventQueue(context).use { !it.isEmpty() }
    }

    private sealed class CaptureCommand {
        data class Start(val raw: String?) : CaptureCommand()
        data class Stop(val sessionId: String?, val diagnostic: String?) : CaptureCommand()
        data object Flush : CaptureCommand()
        data class Ack(val raw: String?) : CaptureCommand()
        data class Timer(val raw: String?) : CaptureCommand()
        data class Inject(val scenario: String, val seed: Int) : CaptureCommand()
    }

    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.Default)
    private val commands = Channel<CaptureCommand>(Channel.UNLIMITED)
    private val transportCommands = Channel<CaptureCommand>(Channel.UNLIMITED)
    private val machine = CaptureStateMachine()
    private val backoff = WearTransportBackoff()
    private val synthetic = SyntheticBeatSource()
    private val healthClient by lazy { HealthServices.getClient(this) }
    private val eventQueue by lazy { WearEventQueue(this) }
    private val transport by lazy { WearDataLayerTransport(this) }
    private val capturePersistence by lazy { WearCapturePersistence(this) }
    private var measureCallback: MeasureCallback? = null
    private var exerciseCallback: ExerciseUpdateCallback? = null
    private var frameJob: Job? = null
    private var captureWatchdogJob: Job? = null
    private var timeoutJob: Job? = null
    private var syntheticJob: Job? = null
    private var stopSelfJob: Job? = null
    private var capture: ActiveCapture? = null
    private var eventFlushInProgress = false
    private var eventFlushStartedAt = 0L
    private var ackTimeoutJob: Job? = null
    private var lastSendAtMs: Long? = null
    private var lastAckAtMs: Long? = null
    private var lastError: String? = null
    private var lastEventAtMs: Long? = null
    private var terminalSummaryDelivered = false
    private var stopCompleted = false
    private var pendingStartRaw: String? = null
    private var actorStarted = false
    private var terminalSnapshot: CaptureTerminalSnapshot? = null
    private val stateLock = Any()

    override fun onCreate() {
        super.onCreate()
        eventQueue.migrateLegacyOutbox(MAX_BUFFERED_EVENTS)
        createNotificationChannel()
        recoverAfterProcessDeath()
        startActor()
    }

    private fun startActor() {
        if (actorStarted) return
        actorStarted = true
        scope.launch {
            for (command in commands) {
                when (command) {
                    is CaptureCommand.Start -> handleStart(command.raw)
                    is CaptureCommand.Stop -> handleStop(command.sessionId, command.diagnostic)
                    is CaptureCommand.Timer -> reconcileTimer(command.raw)
                    is CaptureCommand.Inject -> handleInject(command.scenario, command.seed)
                    CaptureCommand.Flush, is CaptureCommand.Ack -> Unit
                }
            }
        }


        scope.launch {
            for (command in transportCommands) {
                when (command) {
                    CaptureCommand.Flush -> {
                        val live = synchronized(stateLock) {
                            capture?.takeIf { machine.belongsTo(it.generation, it.sessionId) }
                        }
                        live?.let(::emitMetricFrame)
                        flushPendingEvents()
                        synchronized(stateLock) { writeStatusLocked() }
                    }
                    is CaptureCommand.Ack -> handleAck(command.raw)
                    else -> Unit
                }
            }
        }
    }

    private fun enqueue(command: CaptureCommand) {
        when (command) {
            CaptureCommand.Flush, is CaptureCommand.Ack -> transportCommands.trySend(command)
            else -> commands.trySend(command)
        }
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_START -> enqueue(CaptureCommand.Start(intent.getStringExtra(EXTRA_CONFIG)))
            ACTION_STOP -> enqueue(CaptureCommand.Stop(intent.getStringExtra("session_id"), null))
            ACTION_FLUSH -> enqueue(CaptureCommand.Flush)
            ACTION_ACK -> enqueue(CaptureCommand.Ack(intent.getStringExtra(EXTRA_ACK)))
            ACTION_TIMER -> enqueue(CaptureCommand.Timer(intent.getStringExtra(EXTRA_TIMER)))
            ACTION_INJECT -> enqueue(
                CaptureCommand.Inject(
                    intent.getStringExtra(EXTRA_PRESET)
                        ?: intent.getStringExtra(EXTRA_SCENARIO)
                        ?: "focus",
                    intent.getIntExtra(EXTRA_SEED, 42),
                ),
            )
        }
        return if (capture != null) START_STICKY else START_NOT_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onDestroy() {
        captureWatchdogJob?.cancel()
        timeoutJob?.cancel()
        frameJob?.cancel()
        syntheticJob?.cancel()
        ackTimeoutJob?.cancel()
        runBlocking {
            withTimeoutOrNull(HS_UNREGISTER_TIMEOUT_MS) { unregisterHealthServices() }
        }
        commands.close()
        transportCommands.close()
        scope.coroutineContext[Job]?.cancel()
        super.onDestroy()
    }

    private fun recoverAfterProcessDeath() {
        val restored = restoreActiveCapture() ?: return
        machine.restoreIdentity(restored.sessionId, restored.generation, restored.lifecycle)
        val expired = System.currentTimeMillis() >
            restored.startedAtMs + restored.durationSec * 1_000L + 30_000L
        val recovered = machine.recover(restored.lifecycle, expired)
        if (!recovered.emitTerminalOnRecover) {
            clearActive()
            synchronized(stateLock) {
                lastError = null
                prefs().edit().remove("error").apply()
                writeStatusLocked()
            }
            return
        }


        synchronized(stateLock) {
            lastError = null
            prefs().edit().remove("error").apply()
            capture = restored
        }
        val duration = ((System.currentTimeMillis() - restored.startedAtMs) / 1_000L)
            .coerceAtLeast(0L).toInt()
        emitEvent(
            JSONObject()
                .put("type", "session_summary")
                .put("session_id", restored.sessionId)
                .put("duration_actual_sec", duration)
                .put("metrics", metrics(restored, frame = false)),
        )
        synchronized(stateLock) {
            terminalSnapshot = CaptureTerminalSnapshot.from(
                restored,
                if (BuildConfig.SYNTHETIC_INPUT) synthetic.preset else null,
                if (BuildConfig.SYNTHETIC_INPUT) synthetic.seed else null,
            )
            terminalSummaryDelivered = true
            capture = null
            writeStatusLocked()
        }
        clearActive()
        stopSelf()
    }

    private suspend fun handleStart(raw: String?) {
        val config = runCatching { JSONObject(raw ?: "") }.getOrNull()
        if (config == null) {
            emitError("unknown", "invalid_state", "The phone sent an invalid session configuration.")
            stopSelf()
            return
        }
        if (!hasHeartRatePermission()) {
            emitError(
                config.optString("session_id", "unknown"),
                "permission_denied",
                "Heart-rate permission is not granted on the watch.",
            )
            stopSelf()
            return
        }
        startForegroundImmediately()
        val sessionId = config.optString("session_id")
        val result = machine.start(sessionId)
        if (!result.accepted) {
            val activeId = machine.sessionId
            if (sessionId != activeId && machine.phase == CaptureLifecycle.STOPPING) {
                pendingStartRaw = raw
                return
            }
            Log.w(
                TAG,
                "start rejected while ${machine.phase} session=$activeId incoming=$sessionId",
            )
            capture?.let(::emitMetricFrame)
            enqueue(CaptureCommand.Flush)
            return
        }
        stopSelfJob?.cancel()
        stopCompleted = false
        terminalSummaryDelivered = false
        terminalSnapshot = null
        if (BuildConfig.SYNTHETIC_INPUT) {
            val preset = config.optString("preset").ifBlank {
                config.optString("scenario")
            }
            if (preset.isNotBlank()) synthetic.preset = preset
            if (config.has("seed")) synthetic.seed = config.optInt("seed")
        }
        unregisterHealthServices()
        val active = ActiveCapture(
            sessionId = sessionId,
            phase = config.optString("window_label", "focus"),
            durationSec = config.optInt("duration_sec", 120).coerceAtLeast(1),
            startedAtMs = System.currentTimeMillis(),
            generation = result.generation,
            lifecycle = CaptureLifecycle.STARTING,
        )
        prefs().edit()
            .remove("last_hsi")
            .remove("timer_state")
            .remove("last_hr")
            .remove("last_nudge")
            .apply()
        purgeForeignEvents(active.sessionId)
        synchronized(stateLock) {
            capture = active
            persistActiveLocked(active)
        }
        startForegroundCapture(active)
        emitEvent(
            JSONObject()
                .put("type", "session_started")
                .put("session_id", active.sessionId)
                .put("started_at_ms", active.startedAtMs),
        )
        startHealthServicesCapture(active)
    }

    private suspend fun startHealthServicesCapture(active: ActiveCapture) {
        runCatching {
            val supported = if (prefs().contains("hr_supported")) {
                prefs().getBoolean("hr_supported", false)
            } else {
                withTimeoutOrNull(CAPABILITY_TIMEOUT_MS) {
                    DataType.HEART_RATE_BPM in healthClient.measureClient
                        .getCapabilitiesAsync().await().supportedDataTypesMeasure
                }.also { prefs().edit().putBoolean("hr_supported", it ?: true).apply() }
                    ?: true
            }
            if (!supported) error("Heart-rate measurement is not supported by this watch.")
            if (BuildConfig.DEBUG) {
                Log.i(TAG, "capture start session=${active.sessionId} gen=${active.generation}")
            }
            if (!BuildConfig.SYNTHETIC_INPUT) {
                withTimeoutOrNull(HS_REGISTER_TIMEOUT_MS) {
                    if (active.isReadiness) {
                        startMeasure(active)
                    } else {
                        startExercise(active)
                        armCaptureWatchdog(active)
                    }
                } ?: error("Health Services registration timed out.")
            }
            machine.markRunning(active.generation)
            active.lifecycle = CaptureLifecycle.RUNNING
            persistActive(active)
            if (BuildConfig.SYNTHETIC_INPUT) startSyntheticSource(active)
            scheduleFrames(active)
            scheduleTimeout(active)
            writeStatus()
        }.onFailure { error ->
            Log.e(TAG, "capture failed to start", error)
            handleStop(active.sessionId, error.message ?: "Health Services could not start.")
        }
    }

    private fun handleInject(scenario: String, seed: Int) {
        if (!BuildConfig.SYNTHETIC_INPUT) {
            Log.w(TAG, "synthetic inject rejected: flag is off")
            return
        }
        synchronized(stateLock) {
            synthetic.preset = scenario
            synthetic.seed = seed
        }
        val active = synchronized(stateLock) { capture }
            ?: return
        if (!machine.belongsTo(active.generation, active.sessionId)) return
        startSyntheticSource(active)
        synchronized(stateLock) { writeStatusLocked() }
        Log.i(TAG, "synthetic inject preset=${synthetic.preset} seed=$seed")
    }

    private fun startSyntheticSource(active: ActiveCapture) {
        syntheticJob?.cancel()
        val token = active.generation
        val sessionId = active.sessionId
        syntheticJob = scope.launch {
            var beatIndex = 0
            var timestampMs = System.currentTimeMillis()
            while (machine.belongsTo(token, sessionId)) {
                val beat = synthetic.sampleAt(beatIndex)
                acceptSample(
                    active = active,
                    token = token,
                    timestampMs = timestampMs,
                    bpm = beat.bpm,
                    rrIntervalMs = beat.rrIntervalMs,
                    quality = beat.accuracy,
                )
                val waitMs = synthetic.delayMs(beat)
                timestampMs += waitMs
                delay(waitMs)
                beatIndex += 1
            }
        }
    }

    private fun reconcileTimer(raw: String?) {
        val json = runCatching { JSONObject(raw ?: "") }.getOrNull() ?: return
        val active = capture ?: return
        if (json.optString("session_id") != active.sessionId) return
        active.pausedTotalMs = json.optLong("paused_seconds", 0L) * 1_000L
        active.pauseStartedAtMs = if (json.optBoolean("paused")) {
            json.optLong("paused_at_ms", 0L).takeIf { it > 0L }
        } else null
        persistActive(active)
        scheduleTimeout(active)
    }

    private fun scheduleTimeout(active: ActiveCapture) {
        timeoutJob?.cancel()
        val token = active.generation
        timeoutJob = scope.launch {
            while (machine.belongsTo(token, active.sessionId)) {
                val remaining = active.durationSec * 1_000L -
                    active.focusedElapsedMs(System.currentTimeMillis())
                if (remaining <= 0L) {
                    enqueue(CaptureCommand.Stop(active.sessionId, null))
                    return@launch
                }
                delay(remaining.coerceAtMost(1_000L).coerceAtLeast(250L))
            }
        }
    }

    private fun armCaptureWatchdog(active: ActiveCapture) {
        captureWatchdogJob?.cancel()
        val token = active.generation
        captureWatchdogJob = scope.launch {
            delay(EXERCISE_FALLBACK_MS)
            if (!machine.belongsTo(token, active.sessionId)) return@launch
            if (active.acceptedSamples > 0) return@launch
            Log.w(TAG, "exercise produced nothing usable; falling back to MeasureClient")
            runCatching { unregisterHealthServices() }
            runCatching {
                withTimeoutOrNull(HS_REGISTER_TIMEOUT_MS) { startMeasure(active) }
                    ?: error("MeasureClient registration timed out.")
            }.onFailure { error ->
                enqueue(
                    CaptureCommand.Stop(
                        active.sessionId,
                        error.message ?: "Heart rate could not be measured.",
                    ),
                )
            }
        }
    }

    private fun startMeasure(active: ActiveCapture) {
        val token = active.generation
        val callback = object : MeasureCallback {
            override fun onAvailabilityChanged(
                dataType: DeltaDataType<*, *>,
                availability: Availability,
            ) {
                if (availability is DataTypeAvailability) {
                    val available = availability == DataTypeAvailability.AVAILABLE ||
                        availability == DataTypeAvailability.ACQUIRING
                    prefs().edit().putBoolean("sensor_available", available).apply()
                }
            }

            override fun onDataReceived(data: DataPointContainer) {
                acceptPoints(active, token, data.getData(DataType.HEART_RATE_BPM))
            }
        }
        measureCallback = callback
        healthClient.measureClient.registerMeasureCallback(DataType.HEART_RATE_BPM, callback)
        if (BuildConfig.DEBUG) Log.i(TAG, "MeasureClient callback registered")
    }

    private suspend fun startExercise(active: ActiveCapture) {
        val token = active.generation
        val exerciseClient = healthClient.exerciseClient
        val capabilities = exerciseClient.getCapabilities()
        val exerciseType = when {
            ExerciseType.WORKOUT in capabilities.supportedExerciseTypes -> ExerciseType.WORKOUT
            ExerciseType.MEDITATION in capabilities.supportedExerciseTypes -> ExerciseType.MEDITATION
            else -> error("No compatible long-running exercise type is available.")
        }
        val typeCapabilities = capabilities.getExerciseTypeCapabilities(exerciseType)
        if (DataType.HEART_RATE_BPM !in typeCapabilities.supportedDataTypes) {
            error("Heart rate is unavailable for long-running capture.")
        }
        val callback = object : ExerciseUpdateCallback {
            override fun onRegistered() {
                if (BuildConfig.DEBUG) Log.i(TAG, "exercise callback registered")
            }
            override fun onRegistrationFailed(throwable: Throwable) {
                enqueue(
                    CaptureCommand.Stop(
                        active.sessionId,
                        throwable.message ?: "Exercise callback registration failed.",
                    ),
                )
            }
            override fun onExerciseUpdateReceived(update: ExerciseUpdate) {
                acceptPoints(active, token, update.latestMetrics.getData(DataType.HEART_RATE_BPM))
            }
            override fun onLapSummaryReceived(lapSummary: ExerciseLapSummary) = Unit
            override fun onAvailabilityChanged(dataType: DataType<*, *>, availability: Availability) {
                if (dataType == DataType.HEART_RATE_BPM && availability is DataTypeAvailability) {
                    prefs().edit()
                        .putBoolean("sensor_available", availability == DataTypeAvailability.AVAILABLE)
                        .apply()
                }
            }
        }
        exerciseCallback = callback
        val tracked = exerciseClient.getCurrentExerciseInfoAsync().await()
        if (tracked.exerciseTrackedStatus == ExerciseTrackedStatus.OTHER_APP_IN_PROGRESS) {
            error("Another app is already recording an exercise.")
        }
        exerciseClient.setUpdateCallback(callback)
        if (tracked.exerciseTrackedStatus == ExerciseTrackedStatus.OWNED_EXERCISE_IN_PROGRESS) {
            return
        }
        exerciseClient.startExercise(
            ExerciseConfig(
                exerciseType = exerciseType,
                dataTypes = setOf(DataType.HEART_RATE_BPM),
                isAutoPauseAndResumeEnabled = false,
                isGpsEnabled = false,
                exerciseGoals = emptyList(),
            ),
        )
    }

    private fun acceptPoints(
        active: ActiveCapture,
        token: Int,
        points: List<SampleDataPoint<Double>>,
    ) {
        if (BuildConfig.SYNTHETIC_INPUT) return
        if (!machine.belongsTo(token, active.sessionId)) return
        points.forEach { point ->
            val quality = qualityOf(point)
            val timestampMs = active.epochOffsetMs + point.timeDurationFromBoot.toMillis()
            acceptSample(
                active = active,
                token = token,
                timestampMs = timestampMs,
                bpm = point.value,
                rrIntervalMs = null,
                quality = quality,
            )
        }
    }

    private fun acceptSample(
        active: ActiveCapture,
        token: Int,
        timestampMs: Long,
        bpm: Double,
        rrIntervalMs: Double?,
        quality: String,
    ) {
        var qualityChanged: String? = null
        val writeRejected: Boolean
        synchronized(stateLock) {
            if (!machine.belongsTo(token, active.sessionId)) return
            active.totalSamples += 1
            active.qualityCounts[quality] = (active.qualityCounts[quality] ?: 0) + 1
            if (quality !in PRODUCTION_QUALITIES &&
                !(BuildConfig.SYNTHETIC_INPUT && quality == "low")
            ) {
                writeRejected = true
                lastEventAtMs = System.currentTimeMillis()
                writeStatusLocked()
                return@synchronized
            } else {
                writeRejected = false
            }
            if (!bpm.isFinite() || bpm <= 0.0) return
            active.acceptedSamples += 1
            active.hrTotal += bpm
            active.frameAcceptedSamples += 1
            active.frameHrTotal += bpm
            val rr = rrIntervalMs?.takeIf { it.isFinite() && it > 0.0 }
            if (rr != null) active.acceptedRrSamples += 1
            active.frameSamples.add(
                WatchSample(
                    timestampMs = timestampMs,
                    bpm = bpm,
                    rrIntervalMs = rr,
                    accuracy = quality,
                ),
            )
            active.firstAcceptedMs = active.firstAcceptedMs ?: timestampMs
            active.lastAcceptedMs = timestampMs
            active.frameFirstAcceptedMs = active.frameFirstAcceptedMs ?: timestampMs
            active.frameLastAcceptedMs = timestampMs
            if (active.lastQuality != quality) {
                active.lastQuality = quality
                qualityChanged = quality
            }
            lastEventAtMs = System.currentTimeMillis()
        }
        if (writeRejected) return
        if (qualityChanged != null) {
            prefs().edit()
                .putBoolean("sensor_available", true)
                .putString("last_quality", qualityChanged)
                .apply()
        }
    }

    private fun qualityOf(point: SampleDataPoint<Double>): String {
        val status = (point.accuracy as? HeartRateAccuracy)?.sensorStatus
        return when (status) {
            HeartRateAccuracy.SensorStatus.ACCURACY_HIGH -> "high"
            HeartRateAccuracy.SensorStatus.ACCURACY_MEDIUM -> "medium"
            HeartRateAccuracy.SensorStatus.ACCURACY_LOW -> "low"
            HeartRateAccuracy.SensorStatus.NO_CONTACT -> "no_contact"
            HeartRateAccuracy.SensorStatus.UNRELIABLE -> "unreliable"
            else -> "unknown"
        }
    }

    private fun scheduleFrames(active: ActiveCapture) {
        frameJob?.cancel()
        val token = active.generation
        frameJob = scope.launch {
            val anchor = SystemClock.elapsedRealtime()
            var tick = 1L
            while (machine.belongsTo(token, active.sessionId)) {
                val target = anchor + tick * FRAME_PERIOD_MS
                val wait = target - SystemClock.elapsedRealtime()
                if (wait > 0) delay(wait)
                tick = ((SystemClock.elapsedRealtime() - anchor) / FRAME_PERIOD_MS) + 1
                if (!machine.belongsTo(token, active.sessionId)) break
                emitMetricFrame(active)
            }
        }
    }

    private fun emitMetricFrame(active: ActiveCapture) {
        val event = synchronized(stateLock) {
            val frameMetrics = metrics(active, frame = true)
            val payload = JSONObject()
                .put("type", "session_frame")
                .put("session_id", active.sessionId)
                .put("seq", active.nextSequence())
                .put("emitted_at_ms", System.currentTimeMillis())
                .put("metrics", frameMetrics)
            active.frameAcceptedSamples = 0
            active.frameHrTotal = 0.0
            active.frameFirstAcceptedMs = null
            active.frameLastAcceptedMs = null
            active.frameSamples.clear()
            if (machine.phase == CaptureLifecycle.STARTING ||
                machine.phase == CaptureLifecycle.RUNNING
            ) {
                persistActiveLocked(active)
            }
            payload
        }
        emitEvent(event)
    }

    private suspend fun handleStop(sessionId: String?, diagnostic: String?) {
        val active: ActiveCapture?
        val token: Int
        val result: CaptureCommandResult
        synchronized(stateLock) {
            active = capture
            token = active?.generation ?: machine.generation
            result = machine.stop(sessionId, token)
        }
        if (!result.accepted) return
        if (stopCompleted) return
        timeoutJob?.cancel()
        frameJob?.cancel()
        syntheticJob?.cancel()
        captureWatchdogJob?.cancel()

        active?.lifecycle = CaptureLifecycle.STOPPING
        clearActive()
        withTimeoutOrNull(HS_UNREGISTER_TIMEOUT_MS) { unregisterHealthServices() }
        if (active != null) {
            eventQueue.discardFrames(active.sessionId)
            ackTimeoutJob?.cancel()
            eventFlushInProgress = false
            emitMetricFrame(active)
            if (diagnostic != null) {
                emitError(active.sessionId, "sensor_unavailable", diagnostic)
            }
            val duration = ((System.currentTimeMillis() - active.startedAtMs) / 1_000L)
                .coerceAtLeast(0L).toInt()
            emitEvent(
                JSONObject()
                    .put("type", "session_summary")
                    .put("session_id", active.sessionId)
                    .put("duration_actual_sec", duration)
                    .put("metrics", metrics(active, frame = false).put("diagnostic_error", diagnostic)),
            )
            synchronized(stateLock) {
                terminalSnapshot = CaptureTerminalSnapshot.from(
                    active,
                    if (BuildConfig.SYNTHETIC_INPUT) synthetic.preset else null,
                    if (BuildConfig.SYNTHETIC_INPUT) synthetic.seed else null,
                )
                terminalSummaryDelivered = true
                writeStatusLocked()
            }
            enqueue(CaptureCommand.Flush)
            scheduleStopSelfWhenIdle()
        }
        synchronized(stateLock) {
            capture = null
            machine.finish(token)
            stopCompleted = true
            writeStatusLocked()
        }
        ServiceCompat.stopForeground(this, ServiceCompat.STOP_FOREGROUND_REMOVE)
        val queuedStart = pendingStartRaw
        pendingStartRaw = null
        if (queuedStart != null) {
            handleStart(queuedStart)
        } else if (eventQueue.isEmpty()) {
            stopSelf()
        }
    }

    private fun scheduleStopSelfWhenIdle() {
        stopSelfJob?.cancel()
        stopSelfJob = scope.launch {
            val deadline = SystemClock.elapsedRealtime() + TERMINAL_FLUSH_TIMEOUT_MS
            while (!eventQueue.isEmpty() && SystemClock.elapsedRealtime() < deadline) {
                delay(QUEUE_DRAIN_INTERVAL_MS)
            }
            writeStatus()
            if (capture == null) stopSelf()
        }
    }

    private suspend fun unregisterHealthServices() {
        measureCallback?.let { callback ->
            runCatching {
                healthClient.measureClient
                    .unregisterMeasureCallbackAsync(DataType.HEART_RATE_BPM, callback)
                    .await()
            }
        }
        measureCallback = null
        exerciseCallback?.let { callback ->
            runCatching { healthClient.exerciseClient.endExercise() }
            runCatching {
                healthClient.exerciseClient.clearUpdateCallbackAsync(callback).await()
            }
        }
        exerciseCallback = null
    }

    private fun metrics(active: ActiveCapture, frame: Boolean): JSONObject =
        WatchSampleContract.metrics(
            active,
            frame,
            BuildConfig.SYNTHETIC_INPUT,
            if (BuildConfig.SYNTHETIC_INPUT) synthetic.preset else null,
            if (BuildConfig.SYNTHETIC_INPUT) synthetic.seed else null,
        )

    private fun emitError(sessionId: String, code: String, message: String) {
        synchronized(stateLock) {
            lastError = message
            prefs().edit().putString("error", message).apply()
        }
        emitEvent(
            JSONObject()
                .put("type", "session_error")
                .put("session_id", sessionId)
                .put("code", code)
                .put("message", message),
        )
    }

    private fun emitEvent(event: JSONObject) {
        val sessionId = event.optString("session_id")
        val type = event.optString("type")
        if ((type == "session_summary" || type == "session_error") &&
            capture != null &&
            sessionId != capture?.sessionId
        ) {
            Log.w(TAG, "dropping stale $type for $sessionId")
            return
        }
        lastEventAtMs = System.currentTimeMillis()
        enqueueEvent(event)
        flushPendingEvents()
    }

    private fun enqueueEvent(event: JSONObject) {
        eventQueue.enqueue(event, MAX_BUFFERED_EVENTS)
    }

    private fun purgeForeignEvents(sessionId: String) {
        val dropped = eventQueue.keepOnlySession(sessionId)
        if (dropped == 0) return
        ackTimeoutJob?.cancel()
        eventFlushInProgress = false
        Log.w(TAG, "purged $dropped stale event(s) from other sessions")
    }

    private fun flushPendingEvents() {
        val event = synchronized(stateLock) {
            if (eventFlushInProgress) {
                val stuckFor = SystemClock.elapsedRealtime() - eventFlushStartedAt
                if (stuckFor < FLUSH_STUCK_MS) return
                Log.w(TAG, "outbox flush latched for ${stuckFor}ms; resetting")
                eventFlushInProgress = false
            }
            val next = eventQueue.peek() ?: return
            eventFlushInProgress = true
            eventFlushStartedAt = SystemClock.elapsedRealtime()
            lastSendAtMs = System.currentTimeMillis()
            next
        }
        transport.send(event, DATA_LAYER_SEND_TIMEOUT_MS) { sent ->
            if (!sent) {
                synchronized(stateLock) { lastError = "Data Layer send failed" }
                val delayMs = backoff.nextDelayMs()
                ackTimeoutJob?.cancel()
                ackTimeoutJob = scope.launch {
                    delay(delayMs)
                    synchronized(stateLock) { eventFlushInProgress = false }
                    flushPendingEvents()
                }
                writeStatus()
                return@send
            }
            ackTimeoutJob?.cancel()
            ackTimeoutJob = scope.launch {
                delay(5_000L)
                synchronized(stateLock) { lastError = "ACK timeout" }
                val delayMs = backoff.nextDelayMs()
                delay(delayMs)
                synchronized(stateLock) { eventFlushInProgress = false }
                flushPendingEvents()
            }
        }
        writeStatus()
    }

    private fun handleAck(raw: String?) {
        if (raw == null) return
        if (!acknowledgeStoredEvent(this, raw)) return
        val shouldStop: Boolean
        synchronized(stateLock) {
            lastAckAtMs = System.currentTimeMillis()
            lastError = null
            backoff.reset()
            ackTimeoutJob?.cancel()
            eventFlushInProgress = false
            shouldStop = eventQueue.isEmpty() && capture == null
            if (shouldStop) terminalSummaryDelivered = true
            writeStatusLocked()
        }
        ackTimeoutJob = scope.launch {
            delay(QUEUE_DRAIN_INTERVAL_MS)
            flushPendingEvents()
        }
        if (shouldStop) stopSelf()
    }

    private fun startForegroundCapture(active: ActiveCapture) {
        val intent = PendingIntent.getActivity(
            this,
            0,
            Intent(this, MainActivity::class.java),
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
        )
        val builder = NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(android.R.drawable.ic_media_play)
            .setContentTitle(
                when {
                    active.isDebug -> "Signal debug"
                    active.isReadiness -> "Readiness scan"
                    else -> "Focus in progress"
                },
            )
            .setContentText("Measuring heart rate on your watch")
            .setContentIntent(intent)
            .setOngoing(true)
            .setCategory(NotificationCompat.CATEGORY_WORKOUT)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
        val elapsedSinceStart = (System.currentTimeMillis() - active.startedAtMs)
            .coerceAtLeast(0L)
        val status = Status.Builder()
            .addTemplate("Study Buddy #duration#")
            .addPart(
                "duration",
                Status.StopwatchPart(SystemClock.elapsedRealtime() - elapsedSinceStart),
            )
            .build()
        OngoingActivity.Builder(this, NOTIFICATION_ID, builder)
            .setStaticIcon(android.R.drawable.ic_media_play)
            .setTouchIntent(intent)
            .setStatus(status)
            .build()
            .apply(this)
        ServiceCompat.startForeground(
            this,
            NOTIFICATION_ID,
            builder.build(),
            if (Build.VERSION.SDK_INT >= 34) ServiceInfo.FOREGROUND_SERVICE_TYPE_HEALTH else 0,
        )
    }

    private fun startForegroundImmediately() {
        val intent = PendingIntent.getActivity(
            this,
            0,
            Intent(this, MainActivity::class.java),
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
        )
        val notification = NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(android.R.drawable.ic_media_play)
            .setContentTitle("Study Buddy")
            .setContentText("Preparing watch measurement")
            .setContentIntent(intent)
            .setOngoing(true)
            .setCategory(NotificationCompat.CATEGORY_WORKOUT)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .build()
        ServiceCompat.startForeground(
            this,
            NOTIFICATION_ID,
            notification,
            if (Build.VERSION.SDK_INT >= 34) ServiceInfo.FOREGROUND_SERVICE_TYPE_HEALTH else 0,
        )
    }

    private fun createNotificationChannel() {
        getSystemService(NotificationManager::class.java).createNotificationChannel(
            NotificationChannel(CHANNEL_ID, "Focus capture", NotificationManager.IMPORTANCE_LOW),
        )
    }

    private fun persistActive(active: ActiveCapture) {
        synchronized(stateLock) { persistActiveLocked(active) }
    }

    private fun persistActiveLocked(active: ActiveCapture) {
        capturePersistence.save(active)
        writeStatusLocked()
    }

    private fun restoreActiveCapture(): ActiveCapture? = capturePersistence.restore()

    private fun clearActive() {
        capturePersistence.clear()
    }

    private fun writeStatus() {
        synchronized(stateLock) { writeStatusLocked() }
    }

    private fun writeStatusLocked() {
        val now = System.currentTimeMillis()
        val oldest = eventQueue.oldestCreatedAtMs()
        val body = CaptureStatusJson.build(
            phase = machine.phase.name,
            live = capture,
            terminal = terminalSnapshot,
            syntheticInput = BuildConfig.SYNTHETIC_INPUT,
            permissionGranted = hasHeartRatePermission(),
            lastEventAgeMs = lastEventAtMs?.let { now - it },
            terminalSummary = terminalSummaryDelivered,
            queueDepth = eventQueue.depth(),
            oldestEventAgeMs = oldest?.let { now - it },
            lastSendAtMs = lastSendAtMs,
            lastAckAtMs = lastAckAtMs,
            lastError = lastError,
            minHsiConfidence = minRelayedHsiConfidence(),
            preset = if (BuildConfig.SYNTHETIC_INPUT) synthetic.preset else null,
            seed = if (BuildConfig.SYNTHETIC_INPUT) synthetic.seed else null,
        )
        runCatching { File(filesDir, STATUS_FILE).writeText(body.toString()) }
        prefs().edit()
            .putString("lifecycle", machine.phase.name)
            .putString("capture_status", body.toString())
            .apply()
    }

    private fun minRelayedHsiConfidence(): Double? {
        val axes = prefs().getString("last_hsi", null)
            ?.let { runCatching { JSONObject(it) }.getOrNull() }
            ?.optJSONObject("axes")
            ?: return null
        val confidences = buildMap {
            for (name in listOf("focus", "capacity", "arousal", "stress")) {
                val axis = axes.optJSONObject(name) ?: continue
                if (axis.has("confidence")) put(name, axis.optDouble("confidence"))
            }
        }
        return HsiRelayConfidence.minOfFourAxes(confidences)
    }

    private fun hasHeartRatePermission(): Boolean = ContextCompat.checkSelfPermission(
        this,
        if (Build.VERSION.SDK_INT >= 36) "android.permission.health.READ_HEART_RATE" else Manifest.permission.BODY_SENSORS,
    ) == PackageManager.PERMISSION_GRANTED

    private fun prefs() = getSharedPreferences(PREFS, MODE_PRIVATE)
}
