package com.studybuddy.app

import org.junit.Assert.assertEquals
import org.junit.Test

class CaptureStatusJsonTest {
    @Test
    fun statusIncludesWindowLabelFromTerminalSnapshot() {
        val terminal = CaptureTerminalSnapshot(
            sessionId = "debug_sim_1",
            frameSeq = 3,
            acceptedHr = 10,
            acceptedRr = 10,
            totalSamples = 10,
            accuracyHigh = 10,
            accuracyMedium = 0,
            accuracyLow = 0,
            accuracyNoContact = 0,
            accuracyUnreliable = 0,
            accuracyUnknown = 0,
            preset = "focus",
            seed = 42,
            windowLabel = "readiness_debug",
        )
        val json = CaptureStatusJson.build(
            phase = "IDLE",
            live = null,
            terminal = terminal,
            syntheticInput = true,
            permissionGranted = true,
            lastEventAgeMs = 10L,
            terminalSummary = true,
            queueDepth = 0,
            oldestEventAgeMs = null,
            lastSendAtMs = null,
            lastAckAtMs = null,
            lastError = null,
            minHsiConfidence = 0.4,
            preset = "focus",
            seed = 42,
        )
        assertEquals("readiness_debug", json.getString("window_label"))
        assertEquals("IDLE", json.getString("capture_state"))
        assertEquals("debug_sim_1", json.getString("session_id"))
    }

    @Test
    fun missingWindowLabelIsNull() {
        val json = CaptureStatusJson.build(
            phase = "IDLE",
            live = null,
            terminal = null,
            syntheticInput = false,
            permissionGranted = true,
            lastEventAgeMs = null,
            terminalSummary = false,
            queueDepth = 0,
            oldestEventAgeMs = null,
            lastSendAtMs = null,
            lastAckAtMs = null,
            lastError = null,
            minHsiConfidence = null,
            preset = null,
            seed = null,
        )
        assertEquals(true, json.isNull("window_label"))
    }
}
