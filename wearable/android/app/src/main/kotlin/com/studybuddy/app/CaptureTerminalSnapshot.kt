package com.studybuddy.app

import org.json.JSONObject


internal data class CaptureTerminalSnapshot(
    val sessionId: String,
    val frameSeq: Int,
    val acceptedHr: Int,
    val acceptedRr: Int,
    val totalSamples: Int,
    val accuracyHigh: Int,
    val accuracyMedium: Int,
    val accuracyLow: Int,
    val accuracyNoContact: Int,
    val accuracyUnreliable: Int,
    val accuracyUnknown: Int,
    val preset: String?,
    val seed: Int?,
    val windowLabel: String,
) {
    val dropped: Int get() = (totalSamples - acceptedHr).coerceAtLeast(0)

    companion object {
        fun from(
            active: ActiveCapture,
            preset: String?,
            seed: Int?,
        ): CaptureTerminalSnapshot = CaptureTerminalSnapshot(
            sessionId = active.sessionId,
            frameSeq = active.sequence,
            acceptedHr = active.acceptedSamples,
            acceptedRr = active.acceptedRrSamples,
            totalSamples = active.totalSamples,
            accuracyHigh = active.qualityCounts["high"] ?: 0,
            accuracyMedium = active.qualityCounts["medium"] ?: 0,
            accuracyLow = active.qualityCounts["low"] ?: 0,
            accuracyNoContact = active.qualityCounts["no_contact"] ?: 0,
            accuracyUnreliable = active.qualityCounts["unreliable"] ?: 0,
            accuracyUnknown = active.qualityCounts["unknown"] ?: 0,
            preset = preset,
            seed = seed,
            windowLabel = active.phase,
        )
    }
}

internal object CaptureStatusJson {
    fun build(
        phase: String,
        live: ActiveCapture?,
        terminal: CaptureTerminalSnapshot?,
        syntheticInput: Boolean,
        permissionGranted: Boolean,
        lastEventAgeMs: Long?,
        terminalSummary: Boolean,
        queueDepth: Int,
        oldestEventAgeMs: Long?,
        lastSendAtMs: Long?,
        lastAckAtMs: Long?,
        lastError: String?,
        minHsiConfidence: Double?,
        preset: String?,
        seed: Int?,
    ): JSONObject {
        val sessionId = live?.sessionId ?: terminal?.sessionId
        val frameSeq = live?.sequence ?: terminal?.frameSeq ?: 0
        val acceptedHr = live?.acceptedSamples ?: terminal?.acceptedHr ?: 0
        val acceptedRr = live?.acceptedRrSamples ?: terminal?.acceptedRr ?: 0
        val dropped = live?.let { (it.totalSamples - it.acceptedSamples).coerceAtLeast(0) }
            ?: terminal?.dropped
            ?: 0
        return JSONObject().apply {
            put("capture_state", phase)
            put("session_id", sessionId ?: JSONObject.NULL)
            put("synthetic_input", syntheticInput)
            put("permission_granted", permissionGranted)
            put("frame_seq", frameSeq)
            put("accepted_hr_total", acceptedHr)
            put("accepted_rr_total", acceptedRr)
            put("dropped_samples_total", dropped)
            put("last_event_age_ms", lastEventAgeMs ?: JSONObject.NULL)
            put("terminal_summary", terminalSummary)
            put("queue_depth", queueDepth)
            put("oldest_event_age_ms", oldestEventAgeMs ?: JSONObject.NULL)
            put("last_send_at_ms", lastSendAtMs ?: JSONObject.NULL)
            put("last_ack_at_ms", lastAckAtMs ?: JSONObject.NULL)
            put("last_error", lastError ?: JSONObject.NULL)
            put("min_hsi_confidence", minHsiConfidence ?: JSONObject.NULL)
            put("window_label", live?.phase ?: terminal?.windowLabel ?: JSONObject.NULL)
            put("accuracy_high", live?.qualityCounts?.get("high") ?: terminal?.accuracyHigh ?: 0)
            put("accuracy_medium", live?.qualityCounts?.get("medium") ?: terminal?.accuracyMedium ?: 0)
            put("accuracy_low", live?.qualityCounts?.get("low") ?: terminal?.accuracyLow ?: 0)
            put("accuracy_no_contact", live?.qualityCounts?.get("no_contact") ?: terminal?.accuracyNoContact ?: 0)
            put("accuracy_unreliable", live?.qualityCounts?.get("unreliable") ?: terminal?.accuracyUnreliable ?: 0)
            put("accuracy_unknown", live?.qualityCounts?.get("unknown") ?: terminal?.accuracyUnknown ?: 0)
            if (syntheticInput) {
                put("preset", preset ?: terminal?.preset ?: JSONObject.NULL)
                put("effective_seed", seed ?: terminal?.seed ?: JSONObject.NULL)
                put("provenance", "watch_synthetic")
            }
        }
    }
}

internal object SyntheticBuildPolicy {
    fun allows(syntheticInput: Boolean, isRelease: Boolean): Boolean =
        !syntheticInput || !isRelease
}
