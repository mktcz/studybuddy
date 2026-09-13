package com.studybuddy.app

import org.junit.Assert.assertEquals
import org.junit.Test

class WearTransportBackoffTest {
    @Test
    fun retriesWithBoundedExponentialDelays() {
        val backoff = WearTransportBackoff(initialMs = 500L, maxMs = 8_000L)
        assertEquals(500L, backoff.nextDelayMs())
        assertEquals(1_000L, backoff.nextDelayMs())
        assertEquals(2_000L, backoff.nextDelayMs())
        assertEquals(4_000L, backoff.nextDelayMs())
        assertEquals(8_000L, backoff.nextDelayMs())
        assertEquals(8_000L, backoff.nextDelayMs())
        backoff.reset()
        assertEquals(500L, backoff.nextDelayMs())
    }
}
