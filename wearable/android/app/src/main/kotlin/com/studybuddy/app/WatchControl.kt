package com.studybuddy.app

import android.content.Context
import android.content.Intent
import android.util.Log
import com.google.android.gms.wearable.Wearable
import org.json.JSONObject


object WatchControl {

    const val CONTROL_PATH = "/study_buddy/watch/control"

    private const val TAG = "WatchControl"

    fun requestStop(context: Context, sessionId: String?) {
        send(context, "stop", sessionId)
        context.startService(
            Intent(context, WearCaptureService::class.java).apply {
                action = WearCaptureService.ACTION_STOP
                putExtra("session_id", sessionId.orEmpty())
            },
        )
    }


    fun requestPause(context: Context, sessionId: String?, paused: Boolean) {
        send(context, if (paused) "pause" else "resume", sessionId)
    }

    private fun send(context: Context, action: String, sessionId: String?) {
        val payload = JSONObject()
            .apply {
                put("action", action)
                if (!sessionId.isNullOrEmpty()) put("session_id", sessionId)
            }
            .toString()
            .toByteArray(Charsets.UTF_8)

        val messageClient = Wearable.getMessageClient(context)
        Wearable.getNodeClient(context).connectedNodes
            .addOnSuccessListener { nodes ->
                if (nodes.isEmpty()) {
                    if (BuildConfig.DEBUG) Log.i(TAG, "No connected phone for '$action'")
                    return@addOnSuccessListener
                }


                nodes.forEach { node ->
                    messageClient.sendMessage(node.id, CONTROL_PATH, payload)
                        .addOnFailureListener { error ->
                            Log.w(TAG, "Control '$action' to ${node.id} failed", error)
                        }
                }
            }
            .addOnFailureListener { error ->
                Log.w(TAG, "Could not list connected nodes", error)
            }
    }
}
