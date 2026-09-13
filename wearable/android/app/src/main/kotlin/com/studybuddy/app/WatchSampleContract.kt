package com.studybuddy.app

import org.json.JSONArray
import org.json.JSONObject

data class WatchSample(
    val timestampMs: Long,
    val bpm: Double,
    val rrIntervalMs: Double?,
    val accuracy: String,
) {
    fun toJson(): JSONObject = JSONObject().apply {
        put("timestamp_ms", timestampMs)
        put("bpm", bpm)
        if (rrIntervalMs != null && rrIntervalMs.isFinite() && rrIntervalMs > 0.0) {
            put("rr_interval_ms", rrIntervalMs)
        } else {
            put("rr_interval_ms", JSONObject.NULL)
        }
        put("accuracy", accuracy)

        put("t", timestampMs)
    }
}

internal object WatchSampleContract {
    const val SCHEMA_VERSION = 1

    fun metrics(
        active: ActiveCapture,
        frame: Boolean,
        synthetic: Boolean,
        preset: String? = null,
        seed: Int? = null,
    ): JSONObject = JSONObject().apply {
        val frameCount = if (frame) active.frameAcceptedSamples else active.acceptedSamples
        val frameTotal = if (frame) active.frameHrTotal else active.hrTotal
        val mean = if (frameCount > 0 && frameTotal > 0.0) frameTotal / frameCount else null
        val dropped = (active.totalSamples - active.acceptedSamples).coerceAtLeast(0)
        put("schema_version", SCHEMA_VERSION)
        put("signal_source", if (synthetic) "wearable_synthetic_test" else "wearable_real")
        put("total_samples", active.totalSamples)
        put("accepted_samples", active.acceptedSamples)
        put("accepted_samples_total", active.acceptedSamples)
        put("accepted_rr_total", active.acceptedRrSamples)
        put("accepted_rr_samples", active.acceptedRrSamples)
        put("dropped_samples_total", dropped)
        put("frame_sample_count", frameCount)
        put("frame_hr_mean_bpm", mean ?: JSONObject.NULL)
        if (frame && active.frameSamples.isNotEmpty()) {
            put(
                "samples",
                JSONArray().apply {
                    active.frameSamples.forEach { put(it.toJson()) }
                },
            )
        }
        put("sample_count", frameCount)
        put("hr_mean_bpm", mean ?: JSONObject.NULL)
        put("start_ms", if (frame) active.frameFirstAcceptedMs else active.firstAcceptedMs)
        put("end_ms", if (frame) active.frameLastAcceptedMs else active.lastAcceptedMs)
        put(
            "coverage_seconds",
            if (active.firstAcceptedMs != null && active.lastAcceptedMs != null) {
                ((active.lastAcceptedMs!! - active.firstAcceptedMs!!) / 1_000.0).coerceAtLeast(0.0)
            } else 0.0,
        )
        put("mean_hr_bpm", mean ?: JSONObject.NULL)
        put("accuracy_high", active.qualityCounts["high"] ?: 0)
        put("accuracy_medium", active.qualityCounts["medium"] ?: 0)
        put("accuracy_low", active.qualityCounts["low"] ?: 0)
        put("accuracy_no_contact", active.qualityCounts["no_contact"] ?: 0)
        put("accuracy_unreliable", active.qualityCounts["unreliable"] ?: 0)
        put("accuracy_unknown", active.qualityCounts["unknown"] ?: 0)
        if (synthetic) {
            put("preset", preset ?: JSONObject.NULL)
            put("effective_seed", seed ?: JSONObject.NULL)
            put("provenance", "watch_synthetic")
        }
    }
}
