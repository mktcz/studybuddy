package com.studybuddy.app

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import androidx.core.content.ContextCompat
import com.google.android.gms.wearable.MessageEvent
import com.google.android.gms.wearable.Wearable
import com.google.android.gms.wearable.WearableListenerService
import org.json.JSONObject

class WatchCommandService : WearableListenerService() {
    companion object {
        const val COMMAND_PATH = "/synheart/session/command"
        const val EVENT_PATH = "/synheart/session/event"
        const val STATUS_REQUEST_PATH = "/study_buddy/watch/status/request"
        const val STATUS_PATH = "/study_buddy/watch/status"
        const val EVENT_ACK_PATH = "/study_buddy/watch/ack"
        const val HSI_PATH = "/study_buddy/watch/hsi"
        const val TIMER_PATH = "/study_buddy/watch/timer"
        const val NUDGE_PATH = "/study_buddy/watch/nudge"
    }

    override fun onMessageReceived(event: MessageEvent) {
        when (event.path) {
            COMMAND_PATH -> handleCommand(String(event.data, Charsets.UTF_8))
            STATUS_REQUEST_PATH -> sendStatus(event.sourceNodeId)
            EVENT_ACK_PATH -> handleAck(String(event.data, Charsets.UTF_8))
            HSI_PATH -> handleHsi(String(event.data, Charsets.UTF_8))
            TIMER_PATH -> handleTimer(String(event.data, Charsets.UTF_8))
            NUDGE_PATH -> handleNudge(String(event.data, Charsets.UTF_8))
        }
    }


    private fun handleNudge(raw: String) {
        val json = runCatching { JSONObject(raw) }.getOrNull() ?: return
        val prefs = getSharedPreferences(WearCaptureService.PREFS, MODE_PRIVATE)
        val active = prefs.getString("active_capture", null)
            ?.let { runCatching { JSONObject(it) }.getOrNull() }
        val activeId = active?.optString("session_id")
        if (!activeId.isNullOrEmpty() && json.optString("session_id") != activeId) return
        val current = prefs.getString("last_nudge", null)
            ?.let { runCatching { JSONObject(it) }.getOrNull() }
        if (current != null &&
            json.optLong("at_ms", 0L) <= current.optLong("at_ms", 0L)) return
        prefs.edit().putString("last_nudge", json.toString()).apply()
    }

    private fun handleTimer(raw: String) {
        val json = runCatching { JSONObject(raw) }.getOrNull() ?: return
        val sessionId = json.optString("session_id")
        val active = getSharedPreferences(WearCaptureService.PREFS, MODE_PRIVATE)
            .getString("active_capture", null)
            ?.let { runCatching { JSONObject(it) }.getOrNull() }
        val activeId = active?.optString("session_id")
        if (!activeId.isNullOrEmpty() && sessionId != activeId) return
        val prefs = getSharedPreferences(WearCaptureService.PREFS, MODE_PRIVATE)
        val previous = prefs.getString("timer_state", null)
            ?.let { runCatching { JSONObject(it) }.getOrNull() }
        if (previous != null &&
            json.optLong("sent_at_ms") < previous.optLong("sent_at_ms")) return


        active?.optLong("started_at_ms", 0L)?.takeIf { it > 0L }?.let {
            json.put("started_at_ms", it)
        }
        val sentAt = json.optLong("sent_at_ms", 0L)
        val pausedAt = json.optLong("paused_at_ms", 0L)
        if (sentAt > 0L && pausedAt > 0L) {
            json.put("paused_at_ms", pausedAt + (System.currentTimeMillis() - sentAt))
        }
        val normalized = json.toString()
        prefs.edit().putString("timer_state", normalized).apply()
        if (prefs.getBoolean("active", false)) {
            startService(Intent(this, WearCaptureService::class.java).apply {
                action = WearCaptureService.ACTION_TIMER
                putExtra(WearCaptureService.EXTRA_TIMER, normalized)
            })
        }
    }

    private fun handleHsi(raw: String) {
        val json = runCatching { JSONObject(raw) }.getOrNull() ?: return
        val active = getSharedPreferences(WearCaptureService.PREFS, MODE_PRIVATE)
            .getString("active_capture", null)
            ?.let { runCatching { JSONObject(it) }.getOrNull() }
        val activeId = active?.optString("session_id")
        if (!activeId.isNullOrEmpty() && json.optString("session_id") != activeId) return
        val timestamp = json.optLong("timestamp_ms", 0L)
        val current = getSharedPreferences(WearCaptureService.PREFS, MODE_PRIVATE)
            .getString("last_hsi", null)
            ?.let { runCatching { JSONObject(it) }.getOrNull() }
        if (current != null && timestamp <= current.optLong("timestamp_ms", 0L)) return
        getSharedPreferences(WearCaptureService.PREFS, MODE_PRIVATE)
            .edit()
            .putString("last_hsi", json.toString())
            .apply()
        startService(
            Intent(this, WearCaptureService::class.java).apply {
                action = WearCaptureService.ACTION_FLUSH
            },
        )
    }

    private fun handleAck(raw: String) {
        startService(Intent(this, WearCaptureService::class.java).apply {
            action = WearCaptureService.ACTION_ACK
            putExtra(WearCaptureService.EXTRA_ACK, raw)
        })
    }

    private fun handleCommand(raw: String) {
        val json = runCatching { JSONObject(raw) }.getOrNull() ?: return
        when (json.optString("command")) {
            "start_session" -> {
                val intent = Intent(this, WearCaptureService::class.java).apply {
                    action = WearCaptureService.ACTION_START
                    putExtra(WearCaptureService.EXTRA_CONFIG, raw)
                }
                ContextCompat.startForegroundService(this, intent)
            }
            "stop_session" -> {
                startService(Intent(this, WearCaptureService::class.java).apply {
                    action = WearCaptureService.ACTION_STOP
                    putExtra("session_id", json.optString("session_id"))
                })
            }
        }
    }

    private fun sendStatus(nodeId: String) {
        val prefs = getSharedPreferences(WearCaptureService.PREFS, MODE_PRIVATE)
        val permission = ContextCompat.checkSelfPermission(
            this,
            if (Build.VERSION.SDK_INT >= 36) {
                "android.permission.health.READ_HEART_RATE"
            } else {
                Manifest.permission.BODY_SENSORS
            },
        ) == PackageManager.PERMISSION_GRANTED
        val body = JSONObject().apply {
            put("installed", true)
            put("permissionGranted", permission)
            put("heartRateSupported", prefs.getBoolean("hr_supported", false))
            put("sensorAvailable", prefs.getBoolean("sensor_available", false))
            put("lastQuality", prefs.getString("last_quality", "unknown"))
            put("active", prefs.getBoolean("active", false))
            put("phase", prefs.getString("phase", null))
            put("error", prefs.getString("error", null))
            val status = prefs.getString("capture_status", null)
                ?.let { runCatching { JSONObject(it) }.getOrNull() }
            put("capture_state", status?.optString("capture_state")
                ?: prefs.getString("lifecycle", CaptureLifecycle.IDLE.name))
            put("frame_seq", status?.optInt("frame_seq") ?: 0)
            put("accepted_hr_total", status?.optInt("accepted_hr_total") ?: 0)
            put("accepted_rr_total", status?.optInt("accepted_rr_total") ?: 0)
            put("dropped_samples_total", status?.optInt("dropped_samples_total") ?: 0)
            put("last_event_age_ms", status?.opt("last_event_age_ms"))
            put("synthetic_input", BuildConfig.SYNTHETIC_INPUT)
            put(
                "accuracy_counts",
                JSONObject().apply {
                    put("high", status?.optInt("accuracy_high") ?: 0)
                    put("medium", status?.optInt("accuracy_medium") ?: 0)
                    put("low", status?.optInt("accuracy_low") ?: 0)
                    put("no_contact", status?.optInt("accuracy_no_contact") ?: 0)
                    put("unreliable", status?.optInt("accuracy_unreliable") ?: 0)
                    put("unknown", status?.optInt("accuracy_unknown") ?: 0)
                },
            )
            put("preset", status?.opt("preset"))
            put("effective_seed", status?.opt("effective_seed"))
            put("provenance", status?.opt("provenance"))
            put(
                "transport",
                JSONObject().apply {
                    put("queue_depth", status?.optInt("queue_depth") ?: 0)
                    put("oldest_event_age_ms", status?.opt("oldest_event_age_ms"))
                    put("last_send_at_ms", status?.opt("last_send_at_ms"))
                    put("last_ack_at_ms", status?.opt("last_ack_at_ms"))
                    put("last_error", status?.opt("last_error"))
                },
            )
        }
        Wearable.getMessageClient(this)
            .sendMessage(nodeId, STATUS_PATH, body.toString().toByteArray(Charsets.UTF_8))
        if (prefs.getBoolean("active", false) ||
            WearCaptureService.hasStoredEvents(this)) {
            startService(Intent(this, WearCaptureService::class.java).apply {
                action = WearCaptureService.ACTION_FLUSH
            })
        }
    }
}
