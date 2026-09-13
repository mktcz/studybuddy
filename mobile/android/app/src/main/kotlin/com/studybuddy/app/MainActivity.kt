package com.studybuddy.app

import android.app.Activity
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.net.Uri
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.provider.OpenableColumns
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import org.json.JSONObject


class MainActivity : FlutterFragmentActivity() {

    private var pendingResult: MethodChannel.Result? = null
    private var channel: MethodChannel? = null
    private var pendingDebugCapture: Map<String, Any?>? = null

    private val controlReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            val payload = intent?.getStringExtra(WatchControlService.EXTRA_PAYLOAD)
                ?: return
            WatchControlService.takePending(this@MainActivity)
            channel?.invokeMethod("onWatchControl", payload)
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        channel!!.setMethodCallHandler { call, result ->
            when (call.method) {
                "pickPdf" -> pickPdf(result)
                "takePendingWatchControl" ->
                    result.success(WatchControlService.takePending(this))
                "takePendingDebugCapture" -> {
                    val prefs = getSharedPreferences(DEBUG_PREFS, Context.MODE_PRIVATE)
                    val raw = prefs.getString(DEBUG_PENDING_KEY, null)
                    prefs.edit().remove(DEBUG_PENDING_KEY).apply()
                    result.success(raw?.let { JSONObject(it).let(::jsonObjectToMap) })
                }
                "sendHsiToWatch" -> {
                    val payload = JSONObject(call.arguments as? Map<*, *> ?: emptyMap<Any, Any>())
                    WatchControlService.sendHsi(this, payload.toString()) { sent ->
                        runOnUiThread { result.success(sent) }
                    }
                }
                "sendTimerToWatch" -> {
                    val payload = JSONObject(call.arguments as? Map<*, *> ?: emptyMap<Any, Any>())
                    WatchControlService.sendTimer(this, payload.toString()) { sent ->
                        runOnUiThread { result.success(sent) }
                    }
                }
                "sendNudgeToWatch" -> {
                    val payload = JSONObject(call.arguments as? Map<*, *> ?: emptyMap<Any, Any>())
                    WatchControlService.sendNudge(this, payload.toString()) { sent ->
                        runOnUiThread { result.success(sent) }
                    }
                }
                "getWatchDiagnostic" -> {
                    WatchControlService.requestStatus(this)
                    Handler(Looper.getMainLooper()).postDelayed({
                        val raw = WatchControlService.readStatus(this)
                        val map = raw?.let { json ->
                            runCatching { JSONObject(json) }.getOrNull()?.let(::jsonObjectToMap)
                        }
                        result.success(map)
                    }, 1200L)
                }
                else -> result.notImplemented()
            }
        }
        pendingDebugCapture?.let { args ->
            channel?.invokeMethod("onDebugCapture", args)
            pendingDebugCapture = null
        }
    }

    override fun onCreate(savedInstanceState: android.os.Bundle?) {
        super.onCreate(savedInstanceState)
        dispatchDebugCapture(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        dispatchDebugCapture(intent)
    }

    private fun dispatchDebugCapture(intent: Intent?) {
        val action = intent?.getStringExtra(EXTRA_DEBUG_CAPTURE_ACTION) ?: return
        intent.removeExtra(EXTRA_DEBUG_CAPTURE_ACTION)
        val args = hashMapOf<String, Any?>(
            "action" to action,
            "session_id" to intent.getStringExtra("session_id"),
            "duration_sec" to intent.getIntExtra("duration_sec", 180),
            "window_label" to (intent.getStringExtra("window_label") ?: "readiness_debug"),
            "preset" to (intent.getStringExtra("preset") ?: intent.getStringExtra("scenario")),
            "seed" to intent.getIntExtra("seed", 42),
        )


        val encoded = JSONObject(args).toString()
        getSharedPreferences(DEBUG_PREFS, Context.MODE_PRIVATE)
            .edit().putString(DEBUG_PENDING_KEY, encoded).apply()
        val host = channel
        if (host != null) {
            host.invokeMethod("onDebugCapture", args)
        } else {
            pendingDebugCapture = args
        }
    }

    private fun jsonObjectToMap(json: JSONObject): Map<String, Any?> =
        json.keys().asSequence().associateWith { key ->
            jsonToFlutter(if (json.isNull(key)) null else json.get(key))
        }

    private fun jsonToFlutter(value: Any?): Any? = when (value) {
        null, JSONObject.NULL -> null
        is JSONObject -> jsonObjectToMap(value)
        is org.json.JSONArray -> (0 until value.length()).map { jsonToFlutter(value.opt(it)) }
        else -> value
    }

    override fun onStart() {
        super.onStart()
        val filter = IntentFilter(WatchControlService.BROADCAST_ACTION)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            registerReceiver(controlReceiver, filter, Context.RECEIVER_NOT_EXPORTED)
        } else {
            @Suppress("UnspecifiedRegisterReceiverFlag")
            registerReceiver(controlReceiver, filter)
        }
    }

    override fun onStop() {
        runCatching { unregisterReceiver(controlReceiver) }
        super.onStop()
    }

    private fun pickPdf(result: MethodChannel.Result) {
        if (pendingResult != null) {
            result.error("busy", "A picker is already open.", null)
            return
        }
        pendingResult = result

        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
            addCategory(Intent.CATEGORY_OPENABLE)
            type = "application/pdf"
        }

        try {
            startActivityForResult(intent, REQUEST_PICK_PDF)
        } catch (error: Exception) {
            pendingResult = null
            result.error("no_picker", "No file picker is available.", null)
        }
    }

    @Deprecated("Kept for the small native PDF picker bridge.")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode != REQUEST_PICK_PDF) return

        val result = pendingResult ?: return
        pendingResult = null

        val uri = data?.data
        if (resultCode != Activity.RESULT_OK || uri == null) {

            result.success(null)
            return
        }

        try {
            result.success(copyToCache(uri))
        } catch (error: Exception) {
            result.error("copy_failed", error.message, null)
        }
    }


    private fun copyToCache(uri: Uri): Map<String, Any?> {
        val target = File(cacheDir, "import-${System.currentTimeMillis()}.pdf")

        contentResolver.openInputStream(uri).use { input ->
            requireNotNull(input) { "The selected file could not be opened." }
            target.outputStream().use(input::copyTo)
        }

        return mapOf(
            "path" to target.absolutePath,
            "name" to (displayName(uri) ?: "Document").removeSuffix(".pdf"),
            "bytes" to target.length(),
        )
    }

    private fun displayName(uri: Uri): String? =
        contentResolver
            .query(uri, arrayOf(OpenableColumns.DISPLAY_NAME), null, null, null)
            ?.use { cursor -> if (cursor.moveToFirst()) cursor.getString(0) else null }

    companion object {
        const val CHANNEL = "studybuddy/host"
        const val REQUEST_PICK_PDF = 4201
        const val EXTRA_DEBUG_CAPTURE_ACTION = "debug_capture_action"
        private const val DEBUG_PREFS = "debug_capture"
        private const val DEBUG_PENDING_KEY = "pending_command"
    }
}
