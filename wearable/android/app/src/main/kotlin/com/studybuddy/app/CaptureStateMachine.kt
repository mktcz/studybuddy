package com.studybuddy.app

enum class CaptureLifecycle {
    IDLE,
    STARTING,
    RUNNING,
    STOPPING,
    FINISHED,
    ;

    companion object {
        fun fromPersisted(raw: String?): CaptureLifecycle =
            entries.firstOrNull { it.name == raw } ?: IDLE
    }
}

data class CaptureCommandResult(
    val accepted: Boolean,
    val phase: CaptureLifecycle,
    val generation: Int = 0,
    val sessionId: String? = null,
    val emitTerminalOnRecover: Boolean = false,
)


class CaptureStateMachine {
    var phase: CaptureLifecycle = CaptureLifecycle.IDLE
        private set
    var sessionId: String? = null
        private set
    var generation: Int = 0
        private set

    fun start(newSessionId: String): CaptureCommandResult {
        if (newSessionId.isBlank()) {
            return CaptureCommandResult(false, phase)
        }
        if (phase == CaptureLifecycle.STARTING ||
            phase == CaptureLifecycle.RUNNING ||
            phase == CaptureLifecycle.STOPPING
        ) {
            return CaptureCommandResult(false, phase, generation, sessionId)
        }
        generation += 1
        sessionId = newSessionId
        phase = CaptureLifecycle.STARTING
        return CaptureCommandResult(true, phase, generation, sessionId)
    }

    fun belongsTo(token: Int, candidateSessionId: String?): Boolean {
        if (token != generation) return false
        if (candidateSessionId != null && candidateSessionId != sessionId) return false
        return phase == CaptureLifecycle.STARTING || phase == CaptureLifecycle.RUNNING
    }

    fun markRunning(token: Int): CaptureCommandResult {
        if (token != generation || phase != CaptureLifecycle.STARTING) {
            return CaptureCommandResult(false, phase, generation, sessionId)
        }
        phase = CaptureLifecycle.RUNNING
        return CaptureCommandResult(true, phase, generation, sessionId)
    }

    fun stop(requestedSessionId: String?, token: Int): CaptureCommandResult {
        if (token != generation) {
            return CaptureCommandResult(false, phase, generation, sessionId)
        }
        if (!requestedSessionId.isNullOrBlank() && requestedSessionId != sessionId) {
            return CaptureCommandResult(false, phase, generation, sessionId)
        }
        if (phase == CaptureLifecycle.IDLE ||
            phase == CaptureLifecycle.FINISHED ||
            phase == CaptureLifecycle.STOPPING
        ) {
            return CaptureCommandResult(false, phase, generation, sessionId)
        }
        phase = CaptureLifecycle.STOPPING
        return CaptureCommandResult(true, phase, generation, sessionId)
    }

    fun finish(token: Int): CaptureCommandResult {
        if (token != generation || phase != CaptureLifecycle.STOPPING) {
            return CaptureCommandResult(false, phase, generation, sessionId)
        }
        phase = CaptureLifecycle.FINISHED
        sessionId = null
        phase = CaptureLifecycle.IDLE
        return CaptureCommandResult(true, CaptureLifecycle.FINISHED, generation)
    }

    fun recover(persisted: CaptureLifecycle, expired: Boolean): CaptureCommandResult {
        if (persisted == CaptureLifecycle.IDLE || persisted == CaptureLifecycle.FINISHED) {
            phase = CaptureLifecycle.IDLE
            sessionId = null
            return CaptureCommandResult(false, phase)
        }
        val hadSession = sessionId
        val token = generation
        phase = CaptureLifecycle.IDLE
        sessionId = null
        return CaptureCommandResult(
            accepted = true,
            phase = phase,
            generation = token,
            sessionId = hadSession,
            emitTerminalOnRecover = expired ||
                persisted == CaptureLifecycle.STARTING ||
                persisted == CaptureLifecycle.RUNNING ||
                persisted == CaptureLifecycle.STOPPING,
        )
    }

    fun restoreIdentity(sessionId: String?, generation: Int, phase: CaptureLifecycle) {
        this.sessionId = sessionId
        this.generation = generation
        this.phase = phase
    }
}
