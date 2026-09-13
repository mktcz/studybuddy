package com.studybuddy.app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import org.json.JSONObject


class SyntheticInjectReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (!BuildConfig.SYNTHETIC_INPUT) return
        when (intent.action) {
            ACTION -> {
                val start = Intent(context, WearCaptureService::class.java).apply {
                    action = WearCaptureService.ACTION_INJECT
                    putExtra(
                        WearCaptureService.EXTRA_SCENARIO,
                        intent.getStringExtra(WearCaptureService.EXTRA_PRESET)
                            ?: intent.getStringExtra(WearCaptureService.EXTRA_SCENARIO)
                            ?: "focus",
                    )
                    putExtra(
                        WearCaptureService.EXTRA_PRESET,
                        intent.getStringExtra(WearCaptureService.EXTRA_PRESET)
                            ?: intent.getStringExtra(WearCaptureService.EXTRA_SCENARIO)
                            ?: "focus",
                    )
                    putExtra(
                        WearCaptureService.EXTRA_SEED,
                        intent.getIntExtra(WearCaptureService.EXTRA_SEED, 42),
                    )
                }
                context.startService(start)
            }
            ACTION_START -> {
                val config = JSONObject()
                    .put("session_id", intent.getStringExtra("session_id") ?: "debug_${System.currentTimeMillis()}")
                    .put("duration_sec", intent.getIntExtra("duration_sec", 180))
                    .put("window_label", intent.getStringExtra("window_label") ?: "readiness_debug")
                    .put(
                        "preset",
                        intent.getStringExtra(WearCaptureService.EXTRA_PRESET)
                            ?: intent.getStringExtra(WearCaptureService.EXTRA_SCENARIO)
                            ?: "focus",
                    )
                    .put("seed", intent.getIntExtra(WearCaptureService.EXTRA_SEED, 42))
                val start = Intent(context, WearCaptureService::class.java).apply {
                    action = WearCaptureService.ACTION_START
                    putExtra(WearCaptureService.EXTRA_CONFIG, config.toString())
                }
                androidx.core.content.ContextCompat.startForegroundService(context, start)
            }
            ACTION_STOP -> {
                context.startService(
                    Intent(context, WearCaptureService::class.java).apply {
                        action = WearCaptureService.ACTION_STOP
                        putExtra("session_id", intent.getStringExtra("session_id"))
                    },
                )
            }
        }
    }

    companion object {
        const val ACTION = "com.studybuddy.app.DEBUG_INJECT"
        const val ACTION_START = "com.studybuddy.app.DEBUG_START"
        const val ACTION_STOP = "com.studybuddy.app.DEBUG_STOP"
    }
}
