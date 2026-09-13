package com.studybuddy.app

class WearTransportBackoff(
    private val initialMs: Long = 500L,
    private val maxMs: Long = 8_000L,
) {
    private var attempt = 0

    fun nextDelayMs(): Long {
        val shift = attempt.coerceIn(0, 4)
        attempt += 1
        val delay = initialMs * (1L shl shift)
        return delay.coerceIn(initialMs, maxMs)
    }

    fun reset() {
        attempt = 0
    }
}

data class WearTransportSnapshot(
    val queueDepth: Int = 0,
    val oldestEventAgeMs: Long? = null,
    val lastSendAtMs: Long? = null,
    val lastAckAtMs: Long? = null,
    val lastError: String? = null,
)
