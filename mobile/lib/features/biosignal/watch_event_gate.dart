class WatchEventGate {
  WatchEventGate(this.activeSessionId);

  final String activeSessionId;
  bool _closed = false;

  bool get closed => _closed;


  bool accept({required String sessionId, required String type}) {
    if (sessionId != activeSessionId) return false;
    if (_closed) return false;
    if (type == 'session_summary' || type == 'session_error') {
      _closed = true;
    }
    return true;
  }
}


String watchEventAckKey({
  required String sessionId,
  required String type,
  int? seq,
}) {
  final buffer = StringBuffer('$sessionId|$type');
  if (seq != null) {
    buffer.write('|$seq');
  }
  return buffer.toString();
}


class TransportBackoff {
  TransportBackoff({this.initialMs = 500, this.maxMs = 8000});

  final int initialMs;
  final int maxMs;
  int _attempt = 0;

  int get attempt => _attempt;

  int nextDelayMs() {
    final shift = _attempt.clamp(0, 4);
    _attempt += 1;
    final delay = initialMs * (1 << shift);
    return delay.clamp(initialMs, maxMs);
  }

  void reset() => _attempt = 0;
}


class TransportDiagnostics {
  const TransportDiagnostics({
    this.queueDepth = 0,
    this.oldestEventAgeMs,
    this.lastSendAtMs,
    this.lastAckAtMs,
    this.lastError,
  });

  final int queueDepth;
  final int? oldestEventAgeMs;
  final int? lastSendAtMs;
  final int? lastAckAtMs;
  final String? lastError;

  bool get empty => queueDepth <= 0;

  factory TransportDiagnostics.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const TransportDiagnostics();
    return TransportDiagnostics(
      queueDepth: (json['queue_depth'] as num?)?.toInt() ?? 0,
      oldestEventAgeMs: (json['oldest_event_age_ms'] as num?)?.toInt(),
      lastSendAtMs: (json['last_send_at_ms'] as num?)?.toInt(),
      lastAckAtMs: (json['last_ack_at_ms'] as num?)?.toInt(),
      lastError: json['last_error']?.toString(),
    );
  }
}
