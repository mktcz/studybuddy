import 'package:flutter_test/flutter_test.dart';
import 'package:studybuddy/domain/enums.dart';
import 'package:studybuddy/domain/study_logic.dart';
import 'package:studybuddy/features/biosignal/capture_state_machine.dart';
import 'package:studybuddy/features/biosignal/sample_deduper.dart';
import 'package:studybuddy/features/biosignal/synthetic_beat_fixture.dart';
import 'package:studybuddy/features/biosignal/watch_event_gate.dart';

void main() {
  group('CaptureStateMachine', () {
    test('start, stop, and repeated stop leave idle', () {
      final machine = CaptureStateMachine();
      final start = machine.start('s1');
      expect(start.accepted, isTrue);
      expect(start.phase, CaptureLifecycle.starting);
      expect(machine.markRunning(start.generation).accepted, isTrue);
      expect(machine.phase, CaptureLifecycle.running);

      final sameStart = machine.start('s1');
      expect(sameStart.accepted, isFalse);
      expect(machine.phase, CaptureLifecycle.running);

      final stop = machine.stop('s1', start.generation);
      expect(stop.accepted, isTrue);
      expect(stop.phase, CaptureLifecycle.stopping);
      expect(machine.stop('s1', start.generation).accepted, isFalse);

      expect(machine.finish(start.generation).accepted, isTrue);
      expect(machine.phase, CaptureLifecycle.idle);
      expect(machine.stop('s1', start.generation).accepted, isFalse);
    });

    test('old generation callbacks cannot mutate a still-running session', () {
      final machine = CaptureStateMachine();
      final first = machine.start('old');
      machine.markRunning(first.generation);
      final second = machine.start('new');
      expect(second.accepted, isFalse);
      expect(machine.sessionId, 'old');
      expect(machine.phase, CaptureLifecycle.running);
      expect(machine.belongsTo(first.generation, 'old'), isTrue);
      expect(machine.stop('old', first.generation).accepted, isTrue);
      expect(machine.phase, CaptureLifecycle.stopping);
    });

    test('a different session_id is rejected while capture is active', () {
      final machine = CaptureStateMachine();
      final first = machine.start('live');
      machine.markRunning(first.generation);
      expect(machine.start('other').accepted, isFalse);
      expect(machine.sessionId, 'live');
      machine.stop('live', first.generation);
      expect(machine.start('queued').accepted, isFalse);
      expect(machine.phase, CaptureLifecycle.stopping);
    });

    test('process restart never silently resumes', () {
      final machine = CaptureStateMachine()
        ..start('s1')
        ..markRunning(1);
      machine.sessionId = 's1';
      final recovered = machine.recover(
        CaptureLifecycle.running,
        expired: true,
      );
      expect(recovered.emitTerminalOnRecover, isTrue);
      expect(machine.phase, CaptureLifecycle.idle);
      expect(machine.sessionId, isNull);

      final starting = CaptureStateMachine();
      expect(
        starting
            .recover(CaptureLifecycle.starting, expired: false)
            .emitTerminalOnRecover,
        isTrue,
      );
      expect(starting.phase, CaptureLifecycle.idle);
    });
  });

  group('WatchEventGate', () {
    test('ignores stale terminals and keeps the live session open', () {
      final gate = WatchEventGate('live');
      expect(gate.accept(sessionId: 'old', type: 'session_summary'), isFalse);
      expect(gate.closed, isFalse);
      expect(gate.accept(sessionId: 'live', type: 'session_frame'), isTrue);
      expect(gate.accept(sessionId: 'live', type: 'session_summary'), isTrue);
      expect(gate.closed, isTrue);
      expect(gate.accept(sessionId: 'live', type: 'session_frame'), isFalse);
    });

    test('ACK keys are idempotent on session, type, and seq', () {
      expect(
        watchEventAckKey(sessionId: 's', type: 'session_frame', seq: 3),
        's|session_frame|3',
      );
      expect(
        watchEventAckKey(sessionId: 's', type: 'session_summary'),
        's|session_summary',
      );
    });
  });

  group('TransportBackoff', () {
    test('retries with bounded exponential delays', () {
      final backoff = TransportBackoff(initialMs: 500, maxMs: 8000);
      expect(backoff.nextDelayMs(), 500);
      expect(backoff.nextDelayMs(), 1000);
      expect(backoff.nextDelayMs(), 2000);
      expect(backoff.nextDelayMs(), 4000);
      expect(backoff.nextDelayMs(), 8000);
      expect(backoff.nextDelayMs(), 8000);
      backoff.reset();
      expect(backoff.nextDelayMs(), 500);
    });
  });

  group('SampleDeduper', () {
    test('drops duplicate session/seq/timestamp deliveries', () {
      final deduper = SampleDeduper();
      expect(deduper.accept(sessionId: 's', seq: 1, timestampMs: 10), isTrue);
      expect(deduper.accept(sessionId: 's', seq: 1, timestampMs: 10), isFalse);
      expect(deduper.accept(sessionId: 's', seq: 1, timestampMs: 11), isTrue);
    });
  });

  group('SyntheticBeatFixture', () {
    test('emits deterministic HR and RR without phone-side 60000/bpm', () {
      final fixture = SyntheticBeatFixture(preset: 'focus', seed: 42);
      final first = fixture.sampleAt(0);
      final again = SyntheticBeatFixture(preset: 'focus', seed: 42).sampleAt(0);
      expect(first.bpm, again.bpm);
      expect(first.rrIntervalMs, again.rrIntervalMs);
      expect(first.rrIntervalMs, greaterThan(400));
      expect(first.bpm, isNot(closeTo(60000 / first.rrIntervalMs, 1e-9)));
      expect(
        fixture.sampleAt(30).rrIntervalMs,
        isNot(fixture.sampleAt(0).rrIntervalMs),
      );
    });

    test('timed beats advance by RR, not a fixed 1 Hz clock', () {
      final beats = SyntheticBeatFixture(
        preset: 'focus',
        seed: 42,
      ).timedBeats(count: 8).toList();
      expect(beats, hasLength(8));
      for (var i = 1; i < beats.length; i++) {
        expect(
          beats[i].timestampMs - beats[i - 1].timestampMs,
          beats[i - 1].rrIntervalMs.round(),
        );
      }
      expect(beats[1].timestampMs - beats[0].timestampMs, isNot(1000));
    });
  });

  group('axisUnavailableReason', () {
    test('missing affective axes stay null with an RR reason', () {
      final sample = StateSample(
        at: DateTime(2026, 9, 3),
        origin: SignalOrigin.wearableReal,
        focus: 0.7,
        capacity: 0.6,
        focusConfidence: 0.8,
        capacityConfidence: 0.7,
      );
      expect(sample.arousal, isNull);
      expect(sample.stress, isNull);
      expect(sample.availableAxes.containsKey('Arousal'), isFalse);
      expect(
        axisUnavailableReason(
          axis: 'Arousal',
          sample: sample,
          hsiWindowCount: 2,
          acceptedRrCount: 0,
        ),
        'RR/HRV unavailable',
      );
      expect(
        axisUnavailableReason(
          axis: 'Focus',
          sample: sample,
          hsiWindowCount: 0,
          acceptedRrCount: 0,
        ),
        isNull,
      );
      expect(
        axisUnavailableReason(
          axis: 'Stress',
          sample: null,
          hsiWindowCount: 0,
          acceptedRrCount: 10,
        ),
        'insufficient window',
      );
    });
  });
}
