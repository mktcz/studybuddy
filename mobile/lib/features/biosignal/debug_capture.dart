import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../domain/study_logic.dart';
import '../focus/focus_controller.dart';
import '../state/ambient_measurement.dart';
import '../state/hsi_engine.dart';
import '../state/hsi_providers.dart';
import '../state/rest_alert_host.dart';
import '../state/watch_hsi_relay.dart';
import 'bio_reading.dart';
import 'biosignal_service.dart';
import 'watch_sample_push.dart';


class DebugCaptureController {
  DebugCaptureController(this.ref);

  final Ref ref;
  BiosignalService? _bio;
  StreamSubscription<BioReading>? _readings;
  StreamSubscription<StateSample>? _states;
  HumanStateGateway? _gateway;
  String? _sessionId;
  bool _running = false;
  bool _holdsExclusive = false;
  bool _holdsRestSuppression = false;

  Future<void> handle(Map<Object?, Object?> args) async {
    if (!kDebugMode) return;
    final action = args['action'] as String? ?? '';
    if (action.endsWith('DEBUG_CAPTURE_STOP') || action == 'stop') {
      await stop(sessionId: args['session_id'] as String?);
      return;
    }
    if (action.endsWith('DEBUG_CAPTURE_START') || action == 'start') {
      final sessionId = args['session_id'] as String?;
      if (sessionId == null || sessionId.isEmpty) return;
      final durationSec = (args['duration_sec'] as num?)?.toInt() ?? 180;
      final windowLabel = args['window_label'] as String? ?? 'readiness_debug';
      await start(
        sessionId: sessionId,
        planned: Duration(seconds: durationSec.clamp(1, 24 * 60 * 60)),
        windowLabel: windowLabel,
      );
    }
  }

  Future<void> start({
    required String sessionId,
    required Duration planned,
    String windowLabel = 'readiness_debug',
  }) async {
    if (!kDebugMode) return;
    if (_running && _sessionId == sessionId) return;
    if (_running) await stop();
    if (ref.read(focusControllerProvider).isActive) {
      debugPrint('debug capture refused: a focus session is already active');
      return;
    }

    final ambient = ref.read(ambientMeasurementProvider);
    final hsi = ref.read(hsiEngineProvider);
    final bio = ref.read(biosignalServiceFactoryProvider)();
    try {
      await ambient.acquireExclusive();
      _holdsExclusive = true;
      ref.read(restAlertSuppressionProvider.notifier).acquire();
      _holdsRestSuppression = true;
      if (!hsi.ready) {
        throw StateError('Synheart Core or wearable consent is not ready.');
      }
      _running = true;
      _sessionId = sessionId;
      _bio = bio;
      _gateway = hsi;
      _states = hsi.states.listen((sample) {
        if (_sessionId != sessionId) return;
        unawaited(ref.read(watchHsiRelayProvider).send(sessionId, sample));
      });
      await hsi.startCoreSession(planned);
      _readings = bio.readings.listen((reading) {
        if (_sessionId != sessionId) return;
        hsi.feedWatchReading(reading);
      });
      await bio.start(
        sessionId: sessionId,
        planned: planned,
        windowLabel: windowLabel,
      );
    } catch (error) {
      debugPrint('debug capture failed to start: $error');
      await stop(sessionId: sessionId);
    } finally {
      if (_bio != bio) await bio.dispose();
    }
  }

  Future<void> stop({String? sessionId}) async {
    final expected = _sessionId;
    if (sessionId != null &&
        expected != null &&
        sessionId.isNotEmpty &&
        sessionId != expected) {
      return;
    }
    final bio = _bio;
    final id = expected;
    final gateway = _gateway;
    _running = false;
    _sessionId = null;
    _bio = null;
    _gateway = null;
    await _readings?.cancel();
    _readings = null;
    await _states?.cancel();
    _states = null;
    if (bio != null && id != null) await bio.stop(id);
    await gateway?.stopCoreSession();
    await bio?.dispose();
    if (_holdsExclusive) {
      _holdsExclusive = false;
      await ref.read(ambientMeasurementProvider).releaseExclusive();
    }
    if (_holdsRestSuppression) {
      _holdsRestSuppression = false;
      ref.read(restAlertSuppressionProvider.notifier).release();
    }
  }

  Future<void> dispose() => stop();
}

final debugCaptureControllerProvider = Provider<DebugCaptureController>((ref) {
  final controller = DebugCaptureController(ref);
  ref.onDispose(controller.dispose);
  return controller;
});
