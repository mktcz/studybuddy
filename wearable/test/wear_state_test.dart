import 'package:flutter_test/flutter_test.dart';
import 'package:studybuddy_wear/wear_state.dart';

Map<String, Object?> status({
  bool permission = true,
  bool supported = true,
  bool active = false,
  String? hsiJson,
  String? error,
  String phase = 'focus',
  int? startedAtMs,
  int? durationSec,
  String? timerJson,
}) {
  return {
    'permissionGranted': permission,
    'heartRateSupported': supported,
    'sensorAvailable': true,
    'active': active,
    'phase': phase,
    'hsiJson': hsiJson,
    'lastQuality': 'high',
    'error': error,
    'startedAtMs': startedAtMs,
    'durationSec': durationSec,
    'timerJson': timerJson,
  };
}

void main() {
  group('WearState.fromMap', () {
    test('a granted, idle watch is ready', () {
      final state = WearState.fromMap(status());
      expect(state.phase, WearPhase.idle);
      expect(state.heading, 'Ready');
      expect(state.detail, 'Start a session from your phone.');
    });

    test('a missing permission blocks', () {
      final state = WearState.fromMap(status(permission: false));
      expect(state.phase, WearPhase.blocked);
      expect(state.heading, 'Heart rate needed');
    });

    test('an unsupported sensor blocks', () {
      final state = WearState.fromMap(status(supported: false));
      expect(state.phase, WearPhase.blocked);
      expect(state.heading, 'Sensor unavailable');
    });

    test('an error blocks and surfaces its message', () {
      final state = WearState.fromMap(status(error: 'Sensor detached'));
      expect(state.phase, WearPhase.blocked);
      expect(state.heading, 'Needs attention');
      expect(state.detail, 'Sensor detached');
    });

    test('a running capture is active', () {
      final state = WearState.fromMap(status(active: true));
      expect(state.phase, WearPhase.active);
      expect(state.heading, 'Focus');
    });

    test('a readiness scan is labelled as one', () {
      final state = WearState.fromMap(status(active: true, phase: 'readiness'));
      expect(state.isReadiness, isTrue);
      expect(state.heading, 'Readiness scan');
    });

    test('authoritative HSI axes are parsed from the phone relay', () {
      final state = WearState.fromMap(
        status(
          active: true,
          hsiJson: '{"timestamp_ms":1000,"axes":{"focus":{"value":0.72,"confidence":0.8}}}',
        ),
      );
      expect(state.hsiAxes['focus']?.value, .72);
      expect(state.hsiAxes['focus']?.confidence, .8);
    });

    test('zero-confidence relayed axes are ignored', () {
      final state = WearState.fromMap(
        status(
          active: true,
          hsiJson:
              '{"timestamp_ms":1000,"axes":{"focus":{"value":0,"confidence":0},"capacity":{"value":0.5,"confidence":0}}}',
        ),
      );
      expect(state.hsiAxes, isEmpty);
    });
  });

  group('timing', () {
    final started = DateTime(2026, 8, 19, 10);
    final now = started.add(const Duration(minutes: 24, seconds: 13));

    WearState active({int? durationSec = 3600}) => WearState.fromMap(
      status(
        active: true,
        startedAtMs: started.millisecondsSinceEpoch,
        durationSec: durationSec,
      ),
    );

    test('elapsed is measured from the capture start', () {
      expect(active().elapsedAt(now), const Duration(minutes: 24, seconds: 13));
    });

    test('progress is a fraction of the planned duration', () {
      expect(active().progressAt(now), closeTo(1453 / 3600, 1e-6));
    });

    test('progress clamps rather than exceeding one when running over', () {
      final over = started.add(const Duration(hours: 2));
      expect(active().progressAt(over), 1.0);
    });

    test('an open-ended session has no progress to show', () {
      expect(active(durationSec: null).progressAt(now), isNull);
    });

    test('elapsed is zero before a start time arrives', () {
      expect(
        WearState.fromMap(status(active: true)).elapsedAt(now),
        Duration.zero,
      );
    });

    test('phone pause intervals reconcile elapsed time', () {
      final pausedAt = started.add(const Duration(minutes: 10));
      final state = WearState.fromMap(
        status(
          active: true,
          startedAtMs: started.millisecondsSinceEpoch,
          durationSec: 3600,
          timerJson:
              '{"session_id":null,"started_at_ms":${started.millisecondsSinceEpoch},"planned_seconds":3600,"paused_seconds":60,"paused_at_ms":${pausedAt.millisecondsSinceEpoch},"paused":true}',
        ),
      );
      expect(state.paused, isTrue);
      expect(state.elapsedAt(now), const Duration(minutes: 9));
    });

    test('watch acknowledgement remains canonical when phone clock differs', () {
      final phoneClockStart = started.add(const Duration(hours: 4));
      final state = WearState.fromMap(
        status(
          active: true,
          startedAtMs: started.millisecondsSinceEpoch,
          durationSec: 3600,
          timerJson:
              '{"session_id":null,"started_at_ms":${phoneClockStart.millisecondsSinceEpoch},"planned_seconds":3600,"paused_seconds":0,"paused":false}',
        ),
      );
      expect(state.startedAt, started);
      expect(state.elapsedAt(now), const Duration(minutes: 24, seconds: 13));
    });
  });
}
