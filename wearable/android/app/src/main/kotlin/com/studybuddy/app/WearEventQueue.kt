package com.studybuddy.app

import android.content.ContentValues
import android.content.Context
import android.database.sqlite.SQLiteDatabase
import android.database.sqlite.SQLiteOpenHelper
import org.json.JSONArray
import org.json.JSONObject


class WearEventQueue(context: Context) :
    SQLiteOpenHelper(context.applicationContext, "wear_transport.db", null, 1) {
    private val appContext = context.applicationContext

    override fun onCreate(db: SQLiteDatabase) {
        db.execSQL(
            """
            CREATE TABLE events (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              event_key TEXT NOT NULL UNIQUE,
              session_id TEXT NOT NULL,
              payload TEXT NOT NULL,
              created_at_ms INTEGER NOT NULL
            )
            """.trimIndent(),
        )
        db.execSQL("CREATE INDEX idx_events_session_id ON events(session_id, id)")
    }

    override fun onUpgrade(db: SQLiteDatabase, oldVersion: Int, newVersion: Int) = Unit

    @Synchronized
    fun enqueue(event: JSONObject, maximum: Int) {
        writableDatabase.insertWithOnConflict(
            "events",
            null,
            ContentValues().apply {
                put("event_key", eventKey(event))
                put("session_id", event.optString("session_id"))
                put("payload", event.toString())
                put("created_at_ms", System.currentTimeMillis())
            },
            SQLiteDatabase.CONFLICT_IGNORE,
        )
        writableDatabase.execSQL(
            "DELETE FROM events WHERE id NOT IN (SELECT id FROM events ORDER BY id DESC LIMIT ?)",
            arrayOf(maximum),
        )
    }

    @Synchronized
    fun peek(): JSONObject? = readableDatabase.rawQuery(
        "SELECT payload FROM events ORDER BY id LIMIT 1",
        null,
    ).use { cursor ->
        if (!cursor.moveToFirst()) null
        else runCatching { JSONObject(cursor.getString(0)) }.getOrNull()
    }

    @Synchronized
    fun acknowledge(raw: String): Boolean {
        val ack = runCatching { JSONObject(raw) }.getOrNull() ?: return false
        val key = eventKey(ack)
        val head = peek()
        if (head != null && eventKey(head) == key) {
            return writableDatabase.delete("events", "event_key = ?", arrayOf(key)) > 0
        }
        val exists = readableDatabase.rawQuery(
            "SELECT 1 FROM events WHERE event_key = ? LIMIT 1",
            arrayOf(key),
        ).use { it.moveToFirst() }

        return !exists
    }

    @Synchronized
    fun depth(): Int = readableDatabase.rawQuery(
        "SELECT COUNT(*) FROM events",
        null,
    ).use { cursor ->
        if (cursor.moveToFirst()) cursor.getInt(0) else 0
    }

    @Synchronized
    fun oldestCreatedAtMs(): Long? = readableDatabase.rawQuery(
        "SELECT created_at_ms FROM events ORDER BY id LIMIT 1",
        null,
    ).use { cursor ->
        if (!cursor.moveToFirst()) null else cursor.getLong(0)
    }

    @Synchronized
    fun keepOnlySession(sessionId: String): Int {
        return writableDatabase.delete("events", "session_id != ?", arrayOf(sessionId))
    }


    @Synchronized
    fun discardFrames(sessionId: String): Int = writableDatabase.delete(
        "events",
        "session_id = ? AND payload LIKE ?",
        arrayOf(sessionId, "%\"type\":\"session_frame\"%"),
    )

    @Synchronized
    fun isEmpty(): Boolean = readableDatabase.rawQuery(
        "SELECT 1 FROM events LIMIT 1",
        null,
    ).use { !it.moveToFirst() }


    @Synchronized
    fun migrateLegacyOutbox(maximum: Int) {
        val prefs = appContext.getSharedPreferences(WearCaptureService.PREFS, Context.MODE_PRIVATE)
        if (!prefs.contains("pending_events")) return
        val legacy = runCatching { JSONArray(prefs.getString("pending_events", "[]")) }
            .getOrDefault(JSONArray())
        for (i in 0 until legacy.length()) {
            legacy.optJSONObject(i)?.let { enqueue(it, maximum) }
        }
        prefs.edit().remove("pending_events").apply()
    }

    companion object {
        fun eventKey(json: JSONObject): String = buildString {
            append(json.optString("session_id"))
            append('|')
            append(json.optString("type"))
            if (json.has("seq")) {
                append('|')
                append(json.optInt("seq"))
            }
        }
    }
}
