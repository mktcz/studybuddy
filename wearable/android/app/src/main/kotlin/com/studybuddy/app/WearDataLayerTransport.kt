package com.studybuddy.app

import android.content.Context
import android.os.Handler
import android.os.Looper
import com.google.android.gms.wearable.Wearable
import org.json.JSONObject


class WearDataLayerTransport(context: Context) {
    private val appContext = context.applicationContext
    private val mainHandler = Handler(Looper.getMainLooper())

    fun send(event: JSONObject, timeoutMs: Long = 6_000L, completion: (Boolean) -> Unit) {
        var finished = false
        fun finish(sent: Boolean) {
            if (finished) return
            finished = true
            completion(sent)
        }
        val timeout = Runnable { finish(false) }
        mainHandler.postDelayed(timeout, timeoutMs)
        Wearable.getNodeClient(appContext).connectedNodes
            .addOnSuccessListener { nodes ->
                if (nodes.isEmpty()) {
                    mainHandler.removeCallbacks(timeout)
                    finish(false)
                    return@addOnSuccessListener
                }
                var remaining = nodes.size
                var sent = false
                nodes.forEach { node ->
                    Wearable.getMessageClient(appContext)
                        .sendMessage(
                            node.id,
                            WatchCommandService.EVENT_PATH,
                            event.toString().toByteArray(),
                        )
                        .addOnCompleteListener { task ->
                            sent = sent || task.isSuccessful
                            remaining -= 1
                            if (remaining == 0) {
                                mainHandler.removeCallbacks(timeout)
                                finish(sent)
                            }
                        }
                }
            }
            .addOnFailureListener {
                mainHandler.removeCallbacks(timeout)
                finish(false)
            }
    }
}
