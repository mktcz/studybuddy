package com.studybuddy.app

import android.content.Context
import android.content.Intent
import android.util.Log
import com.google.android.gms.wearable.MessageEvent
import com.google.android.gms.wearable.Wearable
import com.google.android.gms.wearable.WearableListenerService
import org.json.JSONObject


class WatchControlService : WearableListenerService() {

    override fun onMessageReceived(event: MessageEvent) {
        when (event.path) {
            CONTROL_PATH -> handleControl(String(event.data, Charsets.UTF_8))
            EVENT_PATH -> acknowledge(
                event.sourceNodeId,
                String(event.data, Charsets.UTF_8),
            )
            STATUS_PATH -> storeStatus(String(event.data, Charsets.UTF_8))
        }
    }

    private fun storeStatus(raw: String) {
        runCatching { JSONObject(raw) }.getOrNull() ?: return
        getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            .edit()
            .putString(KEY_STATUS, raw)
            .apply()
    }

    private fun handleControl(raw: String) {
        val json = runCatching { JSONObject(raw) }.getOrNull() ?: return
        val action = json.optString("action").takeIf { it.isNotEmpty() } ?: return

        store(this, raw)


        sendBroadcast(
            Intent(BROADCAST_ACTION)
                .setPackage(packageName)
                .putExtra(EXTRA_PAYLOAD, raw)
                .putExtra(EXTRA_ACTION, action),
        )
    }


    private fun acknowledge(nodeId: String, raw: String) {
        val json = runCatching { JSONObject(raw) }.getOrNull() ?: return
        val sessionId = json.optString("session_id").takeIf { it.isNotEmpty() }
            ?: return
        val type = json.optString("type").takeIf { it.isNotEmpty() } ?: return

        val ack = JSONObject()
            .put("session_id", sessionId)
            .put("type", type)
        if (json.has("seq")) ack.put("seq", json.optInt("seq"))

        Wearable.getMessageClient(this)
            .sendMessage(nodeId, EVENT_ACK_PATH, ack.toString().toByteArray(Charsets.UTF_8))
            .addOnSuccessListener { if (BuildConfig.DEBUG) Log.i(TAG, "acked $type seq=${json.opt("seq")}") }
            .addOnFailureListener { e -> Log.w(TAG, "ack failed for $type", e) }
    }

    companion object {
        private const val TAG = "SbWatchAck"
        const val CONTROL_PATH = "/study_buddy/watch/control"


        const val EVENT_PATH = "/synheart/session/event"


        const val EVENT_ACK_PATH = "/study_buddy/watch/ack"
        const val HSI_PATH = "/study_buddy/watch/hsi"
        const val TIMER_PATH = "/study_buddy/watch/timer"
        const val NUDGE_PATH = "/study_buddy/watch/nudge"
        const val STATUS_REQUEST_PATH = "/study_buddy/watch/status/request"
        const val STATUS_PATH = "/study_buddy/watch/status"
        const val BROADCAST_ACTION = "com.studybuddy.app.WATCH_CONTROL"
        const val EXTRA_PAYLOAD = "payload"
        const val EXTRA_ACTION = "action"

        private const val PREFS = "studybuddy_watch"
        private const val KEY_PENDING = "pending_control"
        private const val KEY_STATUS = "watch_status"

        fun requestStatus(context: Context) {
            context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
                .edit()
                .remove(KEY_STATUS)
                .apply()
            Wearable.getNodeClient(context).connectedNodes.addOnSuccessListener { nodes ->
                nodes.forEach { node ->
                    Wearable.getMessageClient(context)
                        .sendMessage(node.id, STATUS_REQUEST_PATH, byteArrayOf())
                }
            }
        }

        fun readStatus(context: Context): String? =
            context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
                .getString(KEY_STATUS, null)

        fun sendHsi(context: Context, raw: String, completion: (Boolean) -> Unit) {
            send(context, HSI_PATH, raw, completion)
        }

        fun sendTimer(context: Context, raw: String, completion: (Boolean) -> Unit) {
            send(context, TIMER_PATH, raw, completion)
        }

        fun sendNudge(context: Context, raw: String, completion: (Boolean) -> Unit) {
            send(context, NUDGE_PATH, raw, completion)
        }

        private fun send(
            context: Context,
            path: String,
            raw: String,
            completion: (Boolean) -> Unit,
        ) {
            Wearable.getNodeClient(context).connectedNodes
                .addOnSuccessListener { nodes ->
                    if (nodes.isEmpty()) {
                        completion(false)
                        return@addOnSuccessListener
                    }
                    var remaining = nodes.size
                    var sent = false
                    nodes.forEach { node ->
                        Wearable.getMessageClient(context)
                            .sendMessage(node.id, path, raw.toByteArray(Charsets.UTF_8))
                            .addOnCompleteListener { task ->
                                sent = sent || task.isSuccessful
                                remaining -= 1
                                if (remaining == 0) completion(sent)
                            }
                    }
                }
                .addOnFailureListener { completion(false) }
        }

        private fun store(context: Context, raw: String) {
            context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
                .edit()
                .putString(KEY_PENDING, raw)
                .apply()
        }


        fun takePending(context: Context): String? {
            val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            val pending = prefs.getString(KEY_PENDING, null) ?: return null
            prefs.edit().remove(KEY_PENDING).apply()
            return pending
        }
    }
}
