package com.studybuddy.app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent


class DebugCaptureReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (!BuildConfig.DEBUG) return
        val launch = Intent(context, MainActivity::class.java).apply {
            addFlags(
                Intent.FLAG_ACTIVITY_NEW_TASK or
                    Intent.FLAG_ACTIVITY_SINGLE_TOP or
                    Intent.FLAG_ACTIVITY_REORDER_TO_FRONT,
            )
            putExtra(MainActivity.EXTRA_DEBUG_CAPTURE_ACTION, intent.action)
            putExtra("session_id", intent.getStringExtra("session_id"))
            putExtra("duration_sec", intent.getIntExtra("duration_sec", 180))
            putExtra(
                "window_label",
                intent.getStringExtra("window_label") ?: "readiness_debug",
            )
            putExtra(
                "preset",
                intent.getStringExtra("preset")
                    ?: intent.getStringExtra("scenario")
                    ?: "focus",
            )
            putExtra("scenario", intent.getStringExtra("scenario") ?: "focus")
            putExtra("seed", intent.getIntExtra("seed", 42))
        }
        context.startActivity(launch)
    }

    companion object {
        const val ACTION_START = "com.studybuddy.app.DEBUG_CAPTURE_START"
        const val ACTION_STOP = "com.studybuddy.app.DEBUG_CAPTURE_STOP"
    }
}
