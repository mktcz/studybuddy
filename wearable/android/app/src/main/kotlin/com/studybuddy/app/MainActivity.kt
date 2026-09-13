package com.studybuddy.app

import android.Manifest
import android.content.pm.PackageManager
import android.os.Build
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import android.os.Bundle
import androidx.health.services.client.HealthServices
import androidx.health.services.client.data.DataType
import androidx.wear.ambient.AmbientLifecycleObserver
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject


class MainActivity : FlutterFragmentActivity() {
    companion object {
        private const val CHANNEL = "study_buddy/wear"
        private const val PERMISSION_REQUEST = 4102
        private const val NOTIFICATION_PERMISSION_REQUEST = 4103
    }

    private var pendingPermissionResult: MethodChannel.Result? = null
    private var channel: MethodChannel? = null


    private var heartRateSupported: Boolean? = null

    private val ambientObserver by lazy {
        AmbientLifecycleObserver(
            this,
            object : AmbientLifecycleObserver.AmbientLifecycleCallback {
                override fun onEnterAmbient(
                    ambientDetails: AmbientLifecycleObserver.AmbientDetails,
                ) {
                    channel?.invokeMethod("ambientChanged", true)
                }

                override fun onExitAmbient() {
                    channel?.invokeMethod("ambientChanged", false)
                }

                override fun onUpdateAmbient() {
                    channel?.invokeMethod("ambientChanged", true)
                }
            },
        )
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        lifecycle.addObserver(ambientObserver)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        channel!!.setMethodCallHandler { call, result ->
                when (call.method) {
                    "getStatus" -> readStatus(result)
                    "requestPermission" -> requestHeartRatePermission(result)
                    "requestStop" -> {
                        WatchControl.requestStop(this, currentSessionId())
                        result.success(null)
                    }
                    "requestPause" -> {
                        WatchControl.requestPause(
                            this,
                            currentSessionId(),
                            call.argument<Boolean>("paused") == true,
                        )
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun readStatus(result: MethodChannel.Result) {
        heartRateSupported?.let { supported ->
            result.success(statusMap(hasHeartRatePermission(), supported))
            return
        }

        val permission = hasHeartRatePermission()
        val future = HealthServices.getClient(this).measureClient.getCapabilitiesAsync()
        future
            .addListener(
                {
                    runCatching {
                        val capabilities = future.get()
                        val supported = DataType.HEART_RATE_BPM in capabilities.supportedDataTypesMeasure
                        heartRateSupported = supported
                        val prefs = getSharedPreferences(WearCaptureService.PREFS, MODE_PRIVATE)
                        prefs.edit().putBoolean("hr_supported", supported).apply()
                        result.success(statusMap(permission, supported))
                    }.onFailure { error ->
                        result.error("health_status", error.message, null)
                    }
                },
                ContextCompat.getMainExecutor(this),
            )
    }

    private fun statusMap(permission: Boolean, supported: Boolean): Map<String, Any?> {
        val prefs = getSharedPreferences(WearCaptureService.PREFS, MODE_PRIVATE)
        val capture = activeCapture()
        val timer = prefs.getString("timer_state", null)
            ?.let { runCatching { JSONObject(it) }.getOrNull() }
        return mapOf(
            "permissionGranted" to permission,
            "heartRateSupported" to supported,
            "sensorAvailable" to prefs.getBoolean("sensor_available", false),
            "lastQuality" to prefs.getString("last_quality", "unknown"),
            "active" to prefs.getBoolean("active", false),
            "phase" to prefs.getString("phase", null),
            "capture_state" to prefs.getString("lifecycle", CaptureLifecycle.IDLE.name),
            "error" to prefs.getString("error", null),
            "sessionId" to capture?.optString("session_id"),
            "startedAtMs" to capture?.optLong("started_at_ms")?.takeIf { it > 0 },
            "durationSec" to capture?.optInt("duration_sec")?.takeIf { it > 0 },
            "timerJson" to timer?.toString(),
            "hsiJson" to prefs.getString("last_hsi", null),
            "nudgeJson" to prefs.getString("last_nudge", null),
        )
    }

    private fun requestHeartRatePermission(result: MethodChannel.Result) {
        if (hasHeartRatePermission()) {
            result.success(true)
            return
        }
        pendingPermissionResult = result
        ActivityCompat.requestPermissions(
            this,
            arrayOf(heartRatePermission()),
            PERMISSION_REQUEST,
        )
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray,
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == PERMISSION_REQUEST) {
            pendingPermissionResult?.success(
                grantResults.firstOrNull() == PackageManager.PERMISSION_GRANTED,
            )
            pendingPermissionResult = null
        }


    }

    private fun activeCapture(): JSONObject? {
        val raw = getSharedPreferences(WearCaptureService.PREFS, MODE_PRIVATE)
            .getString("active_capture", null) ?: return null
        return runCatching { JSONObject(raw) }.getOrNull()
    }

    private fun currentSessionId(): String? =
        activeCapture()?.optString("session_id")?.takeIf { it.isNotEmpty() }

    private fun ensureNotificationPermission() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) return
        if (ContextCompat.checkSelfPermission(this, Manifest.permission.POST_NOTIFICATIONS) ==
            PackageManager.PERMISSION_GRANTED
        ) {
            return
        }
        ActivityCompat.requestPermissions(
            this,
            arrayOf(Manifest.permission.POST_NOTIFICATIONS),
            NOTIFICATION_PERMISSION_REQUEST,
        )
    }

    override fun onStart() {
        super.onStart()
        ensureNotificationPermission()
    }

    private fun hasHeartRatePermission(): Boolean =
        ContextCompat.checkSelfPermission(this, heartRatePermission()) ==
            PackageManager.PERMISSION_GRANTED

    private fun heartRatePermission(): String =
        if (Build.VERSION.SDK_INT >= 36) {
            "android.permission.health.READ_HEART_RATE"
        } else {
            Manifest.permission.BODY_SENSORS
        }
}
