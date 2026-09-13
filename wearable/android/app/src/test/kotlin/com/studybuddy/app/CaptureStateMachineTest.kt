package com.studybuddy.app

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class CaptureStateMachineTest {
    @Test
    fun startStopAndRepeatedStopLeaveIdle() {
        val machine = CaptureStateMachine()
        val start = machine.start("s1")
        assertTrue(start.accepted)
        assertEquals(CaptureLifecycle.STARTING, start.phase)
        assertTrue(machine.markRunning(start.generation).accepted)
        assertEquals(CaptureLifecycle.RUNNING, machine.phase)

        val sameStart = machine.start("s1")
        assertFalse(sameStart.accepted)
        assertEquals(CaptureLifecycle.RUNNING, machine.phase)

        val stop = machine.stop("s1", start.generation)
        assertTrue(stop.accepted)
        assertEquals(CaptureLifecycle.STOPPING, stop.phase)
        assertFalse(machine.stop("s1", start.generation).accepted)

        assertTrue(machine.finish(start.generation).accepted)
        assertEquals(CaptureLifecycle.IDLE, machine.phase)
        assertFalse(machine.stop("s1", start.generation).accepted)
    }

    @Test
    fun differentSessionIdDoesNotOverwriteActiveCapture() {
        val machine = CaptureStateMachine()
        val first = machine.start("live")
        machine.markRunning(first.generation)
        val second = machine.start("other")
        assertFalse(second.accepted)
        assertEquals("live", machine.sessionId)
        assertEquals(CaptureLifecycle.RUNNING, machine.phase)
        assertTrue(machine.belongsTo(first.generation, "live"))
        assertFalse(machine.belongsTo(first.generation + 1, "other"))
    }

    @Test
    fun startWhileStoppingIsRejected() {
        val machine = CaptureStateMachine()
        val first = machine.start("live")
        machine.markRunning(first.generation)
        machine.stop("live", first.generation)
        assertFalse(machine.start("queued").accepted)
        assertEquals(CaptureLifecycle.STOPPING, machine.phase)
        assertEquals("live", machine.sessionId)
    }

    @Test
    fun processRestartNeverSilentlyResumes() {
        val machine = CaptureStateMachine()
        val start = machine.start("s1")
        machine.markRunning(start.generation)
        val recovered = machine.recover(CaptureLifecycle.RUNNING, expired = true)
        assertTrue(recovered.emitTerminalOnRecover)
        assertEquals(CaptureLifecycle.IDLE, machine.phase)
        assertEquals(null, machine.sessionId)
    }
}
