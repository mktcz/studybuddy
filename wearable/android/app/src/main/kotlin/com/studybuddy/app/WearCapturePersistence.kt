package com.studybuddy.app

import android.content.Context
import android.os.SystemClock
import org.json.JSONObject


internal class WearCapturePersistence(context: Context) {
    private val prefs = context.getSharedPreferences(WearCaptureService.PREFS, Context.MODE_PRIVATE)

    fun save(active: ActiveCapture) {
        prefs.edit()
            .putBoolean("active", active.lifecycle == CaptureLifecycle.STARTING ||
                active.lifecycle == CaptureLifecycle.RUNNING ||
                active.lifecycle == CaptureLifecycle.STOPPING)
            .putString("phase", active.phase)
            .putString("lifecycle", active.lifecycle.name)
            .putString("active_capture", active.toJson().toString())
            .remove("error")
            .apply()
    }

    fun restore(): ActiveCapture? {
        val raw = prefs.getString("active_capture", null) ?: return null
        return runCatching { ActiveCapture.fromJson(JSONObject(raw)) }.getOrNull()
    }

    fun clear() {
        prefs.edit()
            .putBoolean("active", false)
            .remove("phase")
            .putString("lifecycle", CaptureLifecycle.IDLE.name)
            .remove("active_capture")
            .apply()
    }
}

internal data class ActiveCapture(
    val sessionId: String,
    val phase: String,
    val durationSec: Int,
    val startedAtMs: Long,

    val epochOffsetMs: Long = System.currentTimeMillis() - SystemClock.elapsedRealtime(),
    var generation: Int = 0,
    var lifecycle: CaptureLifecycle = CaptureLifecycle.STARTING,
    var sequence: Int = 0,
    var totalSamples: Int = 0,
    var acceptedSamples: Int = 0,
    var acceptedRrSamples: Int = 0,
    var hrTotal: Double = 0.0,
    var frameAcceptedSamples: Int = 0,
    var frameHrTotal: Double = 0.0,
    var frameFirstAcceptedMs: Long? = null,
    var frameLastAcceptedMs: Long? = null,
    val frameSamples: MutableList<WatchSample> = mutableListOf(),
    var firstAcceptedMs: Long? = null,
    var lastAcceptedMs: Long? = null,
    var lastQuality: String = "unknown",
    val qualityCounts: MutableMap<String, Int> = mutableMapOf(),
    var pausedTotalMs: Long = 0L,
    var pauseStartedAtMs: Long? = null,
) {
    val isDebug: Boolean get() = phase.contains("debug", ignoreCase = true)
    val isReadiness: Boolean
        get() = isDebug || phase.contains("readiness", ignoreCase = true)

    fun nextSequence(): Int = sequence++

    fun focusedElapsedMs(nowMs: Long): Long {
        val livePause = pauseStartedAtMs?.let { (nowMs - it).coerceAtLeast(0L) } ?: 0L
        return (nowMs - startedAtMs - pausedTotalMs - livePause).coerceAtLeast(0L)
    }

    fun toJson(): JSONObject = JSONObject().apply {
        put("session_id", sessionId)
        put("phase", phase)
        put("duration_sec", durationSec)
        put("started_at_ms", startedAtMs)
        put("epoch_offset_ms", epochOffsetMs)
        put("generation", generation)
        put("lifecycle", lifecycle.name)
        put("sequence", sequence)
        put("total_samples", totalSamples)
        put("accepted_samples", acceptedSamples)
        put("accepted_rr_samples", acceptedRrSamples)
        put("first_accepted_ms", firstAcceptedMs)
        put("last_accepted_ms", lastAcceptedMs)
        put("last_quality", lastQuality)
        put("quality_counts", JSONObject(qualityCounts as Map<*, *>))
        put("paused_total_ms", pausedTotalMs)
        put("pause_started_at_ms", pauseStartedAtMs)
    }

    companion object {
        fun fromJson(json: JSONObject): ActiveCapture {
            val quality = mutableMapOf<String, Int>()
            val qualityJson = json.optJSONObject("quality_counts") ?: JSONObject()
            qualityJson.keys().forEach { key -> quality[key] = qualityJson.optInt(key) }
            return ActiveCapture(
                sessionId = json.getString("session_id"),
                phase = json.optString("phase", "focus"),
                durationSec = json.optInt("duration_sec", 120),
                startedAtMs = json.optLong("started_at_ms", System.currentTimeMillis()),
                epochOffsetMs = if (json.has("epoch_offset_ms")) {
                    json.optLong("epoch_offset_ms")
                } else {
                    System.currentTimeMillis() - SystemClock.elapsedRealtime()
                },
                generation = json.optInt("generation"),
                lifecycle = CaptureLifecycle.fromPersisted(json.optString("lifecycle")),
                sequence = json.optInt("sequence"),
                totalSamples = json.optInt("total_samples"),
                acceptedSamples = json.optInt("accepted_samples"),
                acceptedRrSamples = json.optInt("accepted_rr_samples"),
                firstAcceptedMs = if (json.isNull("first_accepted_ms")) null
                    else json.optLong("first_accepted_ms"),
                lastAcceptedMs = if (json.isNull("last_accepted_ms")) null
                    else json.optLong("last_accepted_ms"),
                lastQuality = json.optString("last_quality", "unknown"),
                qualityCounts = quality,
                pausedTotalMs = json.optLong("paused_total_ms", 0L),
                pauseStartedAtMs = if (json.isNull("pause_started_at_ms")) null
                    else json.optLong("pause_started_at_ms"),
            )
        }
    }
}
