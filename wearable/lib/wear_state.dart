import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';


enum WearPhase {

  loading,


  blocked,


  idle,


  active,
}


class WearState {
  const WearState({
    required this.phase,
    this.permissionGranted = false,
    this.heartRateSupported = false,
    this.sensorAvailable = false,
    this.active = false,
    this.capturePhase,
    this.hsiAxes = const {},
    this.hsiAt,
    this.nudge,
    this.quality = 'unknown',
    this.sessionId,
    this.startedAt,
    this.plannedSeconds,
    this.pausedSeconds = 0,
    this.pausedAt,
    this.paused = false,
    this.error,
  });

  const WearState.loading() : this(phase: WearPhase.loading);

  factory WearState.failure(Object error) =>
      WearState(phase: WearPhase.blocked, error: error.toString());

  factory WearState.fromMap(Map<Object?, Object?> map) {
    final permission = map['permissionGranted'] == true;
    final supported = map['heartRateSupported'] == true;
    final active = map['active'] == true;
    final error = map['error'] as String?;

    final phase = switch (true) {
      _ when error != null && error.isNotEmpty => WearPhase.blocked,
      _ when !permission => WearPhase.blocked,
      _ when !supported => WearPhase.blocked,
      _ when active => WearPhase.active,
      _ => WearPhase.idle,
    };

    final startedMs = (map['startedAtMs'] as num?)?.toInt();
    final hsi = _parseHsi(map['hsiJson'] as String?);
    final timer = _parseTimer(map['timerJson'] as String?);
    final sessionId = map['sessionId'] as String?;
    final timerMatches =
        timer.sessionId == null || timer.sessionId == sessionId;

    return WearState(
      phase: phase,
      permissionGranted: permission,
      heartRateSupported: supported,
      sensorAvailable: map['sensorAvailable'] == true,
      active: active,
      capturePhase: map['phase'] as String?,
      hsiAxes: hsi.axes,
      hsiAt: hsi.at,
      nudge: active ? _parseNudge(map['nudgeJson'] as String?) : null,
      quality: map['lastQuality'] as String? ?? 'unknown',
      sessionId: sessionId,


      startedAt: startedMs != null
          ? DateTime.fromMillisecondsSinceEpoch(startedMs)
          : timerMatches
          ? timer.startedAt
          : null,
      plannedSeconds: timerMatches && timer.plannedSeconds != null
          ? timer.plannedSeconds
          : (map['durationSec'] as num?)?.toInt(),
      pausedSeconds: timerMatches ? timer.pausedSeconds : 0,
      pausedAt: timerMatches ? timer.pausedAt : null,
      paused: timerMatches && timer.paused,
      error: error,
    );
  }

  final WearPhase phase;
  final bool permissionGranted;
  final bool heartRateSupported;
  final bool sensorAvailable;
  final bool active;


  final String? capturePhase;


  final Map<String, HsiAxis> hsiAxes;
  final DateTime? hsiAt;


  final String? nudge;

  final String quality;
  final String? sessionId;
  final DateTime? startedAt;
  final int? plannedSeconds;
  final int pausedSeconds;
  final DateTime? pausedAt;
  final bool paused;
  final String? error;

  bool get isReadiness =>
      capturePhase != null && capturePhase!.toLowerCase().contains('readiness');

  Duration get planned => Duration(seconds: plannedSeconds ?? 0);

  Duration elapsedAt(DateTime now) {
    final start = startedAt;
    if (start == null) return Duration.zero;
    final livePause = paused && pausedAt != null
        ? now.difference(pausedAt!)
        : Duration.zero;
    final elapsed =
        now.difference(start) - Duration(seconds: pausedSeconds) - livePause;
    return elapsed.isNegative ? Duration.zero : elapsed;
  }


  double? progressAt(DateTime now) {
    final total = plannedSeconds;
    if (total == null || total <= 0) return null;
    return (elapsedAt(now).inSeconds / total).clamp(0.0, 1.0);
  }


  String get heading {
    if (phase == WearPhase.loading) return 'Checking watch';
    if (error != null && error!.isNotEmpty) return 'Needs attention';
    if (!permissionGranted) return 'Heart rate needed';
    if (!heartRateSupported) return 'Sensor unavailable';
    if (active) return isReadiness ? 'Readiness scan' : 'Focus';
    return 'Ready';
  }


  String get detail {
    if (phase == WearPhase.loading) return 'One moment';
    if (error != null && error!.isNotEmpty) return error!;
    if (!permissionGranted) {
      return 'Allow access here, then return to your phone.';
    }
    if (!heartRateSupported) {
      return 'This watch does not report heart rate to Health Services.';
    }
    if (active) {
      return hsiAxes.isEmpty
          ? 'Waiting for Synheart on your phone.'
          : 'Updated from Synheart Core';
    }
    return 'Start a session from your phone.';
  }
}

({
  String? sessionId,
  DateTime? startedAt,
  int? plannedSeconds,
  int pausedSeconds,
  DateTime? pausedAt,
  bool paused,
})
_parseTimer(String? raw) {
  if (raw == null || raw.isEmpty) {
    return (
      sessionId: null,
      startedAt: null,
      plannedSeconds: null,
      pausedSeconds: 0,
      pausedAt: null,
      paused: false,
    );
  }
  try {
    final json = jsonDecode(raw) as Map<String, dynamic>;
    DateTime? at(String key) {
      final value = json[key];
      return value is num && value.toInt() > 0
          ? DateTime.fromMillisecondsSinceEpoch(value.toInt())
          : null;
    }

    return (
      sessionId: json['session_id'] as String?,
      startedAt: at('started_at_ms'),
      plannedSeconds: (json['planned_seconds'] as num?)?.toInt(),
      pausedSeconds: (json['paused_seconds'] as num?)?.toInt() ?? 0,
      pausedAt: at('paused_at_ms'),
      paused: json['paused'] == true,
    );
  } catch (_) {
    return (
      sessionId: null,
      startedAt: null,
      plannedSeconds: null,
      pausedSeconds: 0,
      pausedAt: null,
      paused: false,
    );
  }
}

class HsiAxis {
  const HsiAxis({required this.value, required this.confidence});

  final double value;
  final double confidence;
}


const _nudgeShelfLife = Duration(minutes: 3);

String? _parseNudge(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  try {
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final message = json['message'];
    final atMs = json['at_ms'];
    if (message is! String || message.isEmpty || atMs is! num) return null;
    final at = DateTime.fromMillisecondsSinceEpoch(atMs.toInt());
    if (DateTime.now().difference(at) > _nudgeShelfLife) return null;
    return message;
  } catch (_) {
    return null;
  }
}

({Map<String, HsiAxis> axes, DateTime? at}) _parseHsi(String? raw) {
  if (raw == null || raw.isEmpty) return (axes: const {}, at: null);
  try {
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final encodedAxes = json['axes'];
    final axes = <String, HsiAxis>{};
    if (encodedAxes is Map) {
      for (final entry in encodedAxes.entries) {
        final value = entry.value;
        if (value is! Map) continue;
        final score = value['value'];
        final confidence = value['confidence'];
        if (score is! num) continue;
        final confidenceValue =
            confidence is num ? confidence.toDouble() : 0.0;
        if (!confidenceValue.isFinite || confidenceValue <= 0) continue;
        axes[entry.key.toString()] = HsiAxis(
          value: score.toDouble().clamp(0, 1),
          confidence: confidenceValue.clamp(0, 1),
        );
      }
    }
    final timestamp = json['timestamp_ms'];
    return (
      axes: Map.unmodifiable(axes),
      at: timestamp is num
          ? DateTime.fromMillisecondsSinceEpoch(timestamp.toInt())
          : null,
    );
  } catch (_) {
    return (axes: const {}, at: null);
  }
}


class WearBridge {
  WearBridge();

  static const _channel = MethodChannel('study_buddy/wear');
  static const _pollInterval = Duration(seconds: 2);

  Timer? _timer;
  final _controller = StreamController<WearState>.broadcast();

  Stream<WearState> get states => _controller.stream;

  void start() {
    unawaited(_poll());
    _timer ??= Timer.periodic(_pollInterval, (_) => _poll());
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _poll() async {
    if (_controller.isClosed) return;
    try {
      final raw = await _channel.invokeMapMethod<Object?, Object?>('getStatus');
      if (raw == null || _controller.isClosed) return;
      _controller.add(WearState.fromMap(raw));
    } catch (error) {
      if (!_controller.isClosed) _controller.add(WearState.failure(error));
    }
  }

  Future<bool> requestPermission() async {
    final granted = await _channel.invokeMethod<bool>('requestPermission');
    await _poll();
    return granted ?? false;
  }


  Future<void> requestStop() async {
    await _channel.invokeMethod<void>('requestStop');
    await _poll();
  }

  Future<void> requestPause({required bool paused}) async {
    await _channel.invokeMethod<void>('requestPause', {'paused': paused});
    await _poll();
  }

  Future<void> dispose() async {
    stop();
    await _controller.close();
  }
}
