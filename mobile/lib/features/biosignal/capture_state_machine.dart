enum CaptureLifecycle { idle, starting, running, stopping, finished }

class CaptureCommandResult {
  const CaptureCommandResult({
    required this.accepted,
    required this.phase,
    this.generation = 0,
    this.sessionId,
    this.emitTerminalOnRecover = false,
  });

  final bool accepted;
  final CaptureLifecycle phase;
  final int generation;
  final String? sessionId;
  final bool emitTerminalOnRecover;
}


class CaptureStateMachine {
  CaptureLifecycle phase = CaptureLifecycle.idle;
  String? sessionId;
  int generation = 0;

  CaptureCommandResult start(String newSessionId) {
    if (newSessionId.isEmpty) {
      return CaptureCommandResult(accepted: false, phase: phase);
    }
    if (phase == CaptureLifecycle.starting ||
        phase == CaptureLifecycle.running ||
        phase == CaptureLifecycle.stopping) {
      return CaptureCommandResult(
        accepted: false,
        phase: phase,
        generation: generation,
        sessionId: sessionId,
      );
    }
    generation += 1;
    sessionId = newSessionId;
    phase = CaptureLifecycle.starting;
    return CaptureCommandResult(
      accepted: true,
      phase: phase,
      generation: generation,
      sessionId: sessionId,
    );
  }

  bool belongsTo(int token, String? candidateSessionId) {
    if (token != generation) return false;
    if (candidateSessionId != null && candidateSessionId != sessionId) {
      return false;
    }
    return phase == CaptureLifecycle.starting ||
        phase == CaptureLifecycle.running;
  }

  CaptureCommandResult markRunning(int token) {
    if (token != generation || phase != CaptureLifecycle.starting) {
      return CaptureCommandResult(
        accepted: false,
        phase: phase,
        generation: generation,
        sessionId: sessionId,
      );
    }
    phase = CaptureLifecycle.running;
    return CaptureCommandResult(
      accepted: true,
      phase: phase,
      generation: generation,
      sessionId: sessionId,
    );
  }

  CaptureCommandResult stop(String? requestedSessionId, int token) {
    if (token != generation) {
      return CaptureCommandResult(
        accepted: false,
        phase: phase,
        generation: generation,
        sessionId: sessionId,
      );
    }
    if (requestedSessionId != null &&
        requestedSessionId.isNotEmpty &&
        requestedSessionId != sessionId) {
      return CaptureCommandResult(
        accepted: false,
        phase: phase,
        generation: generation,
        sessionId: sessionId,
      );
    }
    if (phase == CaptureLifecycle.idle ||
        phase == CaptureLifecycle.finished ||
        phase == CaptureLifecycle.stopping) {
      return CaptureCommandResult(
        accepted: false,
        phase: phase,
        generation: generation,
        sessionId: sessionId,
      );
    }
    phase = CaptureLifecycle.stopping;
    return CaptureCommandResult(
      accepted: true,
      phase: phase,
      generation: generation,
      sessionId: sessionId,
    );
  }

  CaptureCommandResult finish(int token) {
    if (token != generation || phase != CaptureLifecycle.stopping) {
      return CaptureCommandResult(
        accepted: false,
        phase: phase,
        generation: generation,
        sessionId: sessionId,
      );
    }
    phase = CaptureLifecycle.finished;
    sessionId = null;
    phase = CaptureLifecycle.idle;
    return CaptureCommandResult(
      accepted: true,
      phase: CaptureLifecycle.finished,
      generation: generation,
    );
  }


  CaptureCommandResult recover(
    CaptureLifecycle persisted, {
    required bool expired,
  }) {
    if (persisted == CaptureLifecycle.idle ||
        persisted == CaptureLifecycle.finished) {
      phase = CaptureLifecycle.idle;
      sessionId = null;
      return CaptureCommandResult(accepted: false, phase: phase);
    }


    final hadSession = sessionId;
    final token = generation;
    phase = CaptureLifecycle.idle;
    sessionId = null;
    return CaptureCommandResult(
      accepted: true,
      phase: phase,
      generation: token,
      sessionId: hadSession,
      emitTerminalOnRecover:
          expired ||
          persisted == CaptureLifecycle.starting ||
          persisted == CaptureLifecycle.running ||
          persisted == CaptureLifecycle.stopping,
    );
  }
}
