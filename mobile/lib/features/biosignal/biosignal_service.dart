import 'dart:async';

import 'package:synheart_session/synheart_session.dart' as sh;

import '../../domain/enums.dart';
import '../../domain/study_logic.dart';
import 'bio_reading.dart';
import 'sample_deduper.dart';
import 'watch_event_gate.dart';
import 'watch_frame_decoder.dart';


class BiosignalService {
  BiosignalService({sh.SessionChannel? channel})
    : _channel = channel ?? sh.SessionChannel();

  final sh.SessionChannel _channel;
  StreamSubscription<sh.SessionEvent>? _subscription;
  bool _started = false;
  String? _sessionId;
  DateTime? _canonicalStartedAt;
  int? _watchClockOffsetMs;
  WatchEventGate? _gate;
  final _deduper = SampleDeduper();
  int? _lastSeq;
  int _acceptedRrTotal = 0;
  int _droppedSamplesTotal = 0;

  final _readings = StreamController<BioReading>.broadcast();
  final _starts = StreamController<DateTime>.broadcast();
  final _outcome = Completer<BioOutcome>();


  Stream<BioReading> get readings => _readings.stream;


  Stream<DateTime> get canonicalStarts => _starts.stream;


  Future<BioOutcome> get outcome => _outcome.future;


  Future<bool> isWatchReady() async {
    final status = await watchStatus();
    return status != null && status.supported && status.reachable;
  }

  Future<sh.WatchStatus?> watchStatus() => _channel.getWatchStatus();


  Future<void> start({
    required String sessionId,
    required Duration planned,
    String windowLabel = 'focus',
  }) async {
    if (_started) {
      throw StateError('BiosignalService.start called twice');
    }
    _started = true;
    _sessionId = sessionId;
    _gate = WatchEventGate(sessionId);

    final config = sh.SessionConfig(
      mode: sh.SessionMode.focus,


      durationSec: planned.inSeconds,
      sessionId: sessionId,
      windowLabel: windowLabel,
      profile: const sh.ComputeProfile(
        windowSec: 60,
        emitIntervalSec: 5,
        rawEmitIntervalSec: 1,
      ),


      includeRawSamples: false,
    );


    _subscription = _channel.events.listen(
      (event) {
        final gate = _gate;
        if (gate == null) return;
        if (!gate.accept(sessionId: event.sessionId, type: _eventType(event))) {
          return;
        }
        _onEvent(event);
      },
      onError: _onError,
      onDone: _onDone,
    );
    await _channel.startSession(config);
  }

  void _onEvent(sh.SessionEvent event) {
    switch (event) {
      case sh.SessionStarted(:final startedAtMs):
        final receivedAtMs = DateTime.now().millisecondsSinceEpoch;
        final clockSkew = receivedAtMs - startedAtMs;


        _watchClockOffsetMs = clockSkew.abs() > 750 ? clockSkew : 0;
        _canonicalStartedAt = DateTime.fromMillisecondsSinceEpoch(
          startedAtMs + _watchClockOffsetMs!,
        );
        if (!_starts.isClosed) {
          _starts.add(_canonicalStartedAt!);
        }

      case sh.SessionFrame(:final metrics, :final emittedAtMs, :final seq):
        final origin = WatchFrameDecoder.originFromMetrics(metrics);
        final offset =
            _watchClockOffsetMs ??
            (DateTime.now().millisecondsSinceEpoch - emittedAtMs);
        _watchClockOffsetMs ??= offset;
        if (_readings.isClosed) return;
        _lastSeq = seq;
        _acceptedRrTotal = WatchFrameDecoder.acceptedRrTotal(metrics);
        _droppedSamplesTotal = WatchFrameDecoder.droppedSamplesTotal(metrics);


        final samples = WatchFrameDecoder.samples(
          metrics,
          clockOffsetMs: offset,
          sessionId: event.sessionId,
          seq: seq,
        );
        if (samples.isNotEmpty) {
          for (final sample in samples) {
            if (!_deduper.accept(
              sessionId: event.sessionId,
              seq: seq,
              timestampMs: sample.at.millisecondsSinceEpoch,
            )) {
              continue;
            }
            _readings.add(sample);
          }
        } else {
          _readings.add(
            BioReading.fromMetrics(
              metrics,
              origin: origin,
              at: DateTime.fromMillisecondsSinceEpoch(emittedAtMs + offset),
              sessionId: event.sessionId,
              seq: seq,
            ),
          );
        }

      case sh.BiosignalFrame():

        return;

      case sh.SessionSummary(:final metrics):
        _complete(_outcomeFrom(metrics));

      case sh.SessionError(:final code, :final message):
        _complete(
          BioOutcome(
            origin: SignalOrigin.unmeasured,
            errorMessage: _describeError(code, message),
          ),
        );
    }
  }

  BioOutcome _outcomeFrom(Map<String, dynamic> metrics) {
    final count =
        (metrics['accepted_samples_total'] as num?)?.toInt() ??
        (metrics['accepted_samples'] as num?)?.toInt() ??
        (metrics['sample_count'] as num?)?.toInt() ??
        0;
    final rrCount =
        (metrics['accepted_rr_total'] as num?)?.toInt() ??
        (metrics['accepted_rr_samples'] as num?)?.toInt() ??
        _acceptedRrTotal;
    final total = (metrics['total_samples'] as num?)?.toInt() ?? count;
    final dropped =
        (metrics['dropped_samples_total'] as num?)?.toInt() ??
        _droppedSamplesTotal;
    final coverage = (metrics['coverage_seconds'] as num?)?.round() ?? 0;
    final measured = count > 0;

    return BioOutcome(


      origin: measured
          ? WatchFrameDecoder.originFromMetrics(metrics)
          : SignalOrigin.unmeasured,
      acceptedSamples: count,
      acceptedRrSamples: rrCount,
      totalSamples: total,
      droppedSamples: dropped,
      coverageSeconds: coverage,
      accuracyCounts: {
        for (final quality in HeartRateQuality.values)
          quality: (metrics[_metricFor(quality)] as num?)?.toInt() ?? 0,
      },
      watchSessionId: _sessionId,
      startedAt: _canonicalStartedAt,
      lastSeq: _lastSeq,
    );
  }

  static String _eventType(sh.SessionEvent event) => switch (event) {
    sh.SessionStarted() => 'session_started',
    sh.SessionFrame() => 'session_frame',
    sh.BiosignalFrame() => 'biosignal_frame',
    sh.SessionSummary() => 'session_summary',
    sh.SessionError() => 'session_error',
  };

  static String _metricFor(HeartRateQuality quality) => switch (quality) {
    HeartRateQuality.noContact => 'accuracy_no_contact',
    _ => 'accuracy_${quality.name}',
  };

  static String _describeError(sh.SessionErrorCode code, String message) {
    return switch (code) {
      sh.SessionErrorCode.permissionDenied =>
        'The watch needs heart-rate permission. Grant it on the watch, then '
            'start again.',
      sh.SessionErrorCode.sensorUnavailable =>
        'This watch does not expose heart rate to Health Services.',
      sh.SessionErrorCode.lowBattery =>
        'The watch stopped measuring to save battery.',
      sh.SessionErrorCode.osTerminated =>
        'The watch app was stopped by the system.',
      sh.SessionErrorCode.invalidState => message,
    };
  }

  void _onError(Object error) {
    _complete(
      BioOutcome(
        origin: SignalOrigin.unmeasured,
        errorMessage: error.toString(),
      ),
    );
  }

  void _onDone() {


    _complete(const BioOutcome(origin: SignalOrigin.unmeasured));
  }

  void _complete(BioOutcome value) {
    if (!_outcome.isCompleted) _outcome.complete(value);
  }


  Future<BioOutcome> stop(String sessionId) async {
    try {
      await _channel.stopSession(sessionId);
    } catch (_) {


    }
    try {
      return await outcome.timeout(const Duration(seconds: 6));
    } on TimeoutException {
      return const BioOutcome(
        origin: SignalOrigin.unmeasured,
        errorMessage: 'The watch stopped without returning a final summary.',
      );
    }
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    _complete(const BioOutcome(origin: SignalOrigin.unmeasured));
    await _readings.close();
    await _starts.close();
  }
}


StateSample? stateSampleFrom({
  required SignalOrigin origin,
  double? focus,
  double? capacity,
  double? arousal,
  double? stress,
  double? quality,
  DateTime? at,
}) {
  if (focus == null && capacity == null && arousal == null && stress == null) {
    return null;
  }
  return StateSample(
    at: at ?? DateTime.now(),
    origin: origin,
    focus: focus,
    capacity: capacity,
    arousal: arousal,
    stress: stress,
    quality: quality,
  );
}
