import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../app/providers.dart';
import '../../domain/study_logic.dart';
import '../biosignal/bio_reading.dart';
import '../biosignal/biosignal_service.dart';
import '../biosignal/watch_sample_push.dart';
import 'hsi_engine.dart';
import 'hsi_providers.dart';
import 'watch_hsi_relay.dart';


class AmbientMeasurement {
  AmbientMeasurement(this.ref);

  final Ref ref;
  BiosignalService? _bio;
  StreamSubscription<BioReading>? _readings;
  StreamSubscription<StateSample>? _states;
  String? _sessionId;
  HumanStateGateway? _gateway;
  bool _wanted = false;
  int _exclusiveHolds = 0;
  Future<void> _transition = Future.value();


  static const _ambientDuration = Duration(hours: 12);

  bool get active => _bio != null;

  bool get exclusiveHold => _exclusiveHolds > 0;


  Future<void> acquireExclusive() async {
    _exclusiveHolds++;
    _wanted = false;
    return _schedule();
  }

  Future<void> releaseExclusive() async {
    if (_exclusiveHolds > 0) _exclusiveHolds--;
  }

  Future<void> start() async {
    if (_exclusiveHolds > 0) return;
    _wanted = true;
    return _schedule();
  }

  Future<void> _startCurrent() async {
    if (active || _exclusiveHolds > 0) return;
    final hsi = ref.read(hsiEngineProvider);
    if (!hsi.ready) return;
    final bio = ref.read(biosignalServiceFactoryProvider)();
    try {
      if (!await bio.isWatchReady()) return;
      final sessionId = 'ambient_${const Uuid().v4()}';
      _sessionId = sessionId;
      _bio = bio;
      _gateway = hsi;
      _states = hsi.states.listen((sample) {
        if (_sessionId != sessionId) return;
        unawaited(ref.read(watchHsiRelayProvider).send(sessionId, sample));
      });
      await hsi.startCoreSession(_ambientDuration);
      _readings = bio.readings.listen((reading) {
        if (_sessionId != sessionId) return;
        hsi.feedWatchReading(reading);
      });
      await bio.start(
        sessionId: sessionId,
        planned: _ambientDuration,
        windowLabel: 'readiness_home',
      );
    } catch (_) {
      if (_bio == bio) await _stopCurrent();
      rethrow;
    } finally {
      if (_bio != bio) await bio.dispose();
    }
  }

  Future<void> stop() async {
    _wanted = false;
    return _schedule();
  }

  Future<void> _stopCurrent() async {
    final bio = _bio;
    final id = _sessionId;
    final gateway = _gateway;
    _bio = null;
    _sessionId = null;
    _gateway = null;
    await _readings?.cancel();
    _readings = null;
    await _states?.cancel();
    _states = null;
    if (bio != null && id != null) await bio.stop(id);
    await gateway?.stopCoreSession();
    await bio?.dispose();
  }

  Future<void> _schedule() {
    _transition = _transition
        .then((_) async {
          if (_wanted && _exclusiveHolds == 0) {
            await _startCurrent();
          } else {
            await _stopCurrent();
          }
        })
        .catchError((Object _) {});
    return _transition;
  }

  void dispose() {
    _wanted = false;
    _exclusiveHolds = 0;
    unawaited(_schedule());
  }
}

final ambientMeasurementProvider = Provider<AmbientMeasurement>((ref) {
  final value = AmbientMeasurement(ref);
  ref.onDispose(value.dispose);
  return value;
});
