import 'package:flutter_test/flutter_test.dart';
import 'package:ui/ui.dart';
import 'package:studybuddy/domain/enums.dart';
import 'package:studybuddy/domain/study_logic.dart';

StateSample sample({
  double? focus,
  double? capacity,
  double? arousal,
  double? sleep,
  double? quality = 0.9,
  double? focusConfidence,
  double? capacityConfidence,
  double? arousalConfidence,
  double? sleepConfidence,
  SignalOrigin origin = SignalOrigin.wearableReal,
}) {
  return StateSample(
    at: DateTime(2026, 8, 19),
    origin: origin,
    focus: focus,
    capacity: capacity,
    arousal: arousal,
    sleep: sleep,
    quality: quality,
    focusConfidence: focusConfidence ?? (focus == null ? null : .9),
    capacityConfidence: capacityConfidence ?? (capacity == null ? null : .9),
    arousalConfidence: arousalConfidence ?? (arousal == null ? null : .9),
    sleepConfidence: sleepConfidence ?? (sleep == null ? null : .9),
  );
}

void main() {
  group('recommendTimer', () {
    test('nothing measured gets the honest neutral default', () {
      final result = recommendTimer();
      expect(result.focusMinutes, 45);
      expect(result.breakMinutes, 10);
      expect(result.readiness, isNull);
      expect(result.usedMeasuredState, isFalse);
    });

    test('low measured readiness gets the short session', () {
      final result = recommendTimer(state: sample(focus: 0.2, capacity: 0.2));
      expect(result.usedMeasuredState, isTrue);
      expect(result.readiness, closeTo(0.2, 1e-9));
      expect(result.focusMinutes, 25);
      expect(result.breakMinutes, 5);
    });

    test('middling measured readiness gets the medium session', () {
      expect(
        recommendTimer(state: sample(focus: 0.5, capacity: 0.5)).focusMinutes,
        45,
      );
    });

    test('high measured readiness gets the long session', () {
      final result = recommendTimer(state: sample(focus: 0.9, capacity: 0.8));
      expect(result.readiness, closeTo(0.85, 1e-9));
      expect(result.focusMinutes, 60);
      expect(result.breakMinutes, 15);
    });

    test('short measured sleep caps the long session at 45 minutes', () {
      final result = recommendTimer(
        state: sample(focus: 0.9, capacity: 0.9, sleep: 0.3),
      );
      expect(result.focusMinutes, 45);
      expect(result.qualifier, isNotNull);
    });

    test('warm-up confidence does not discard the runtime value', () {


      final result = recommendTimer(
        state: sample(
          focus: 0.1,
          capacity: 0.1,
          focusConfidence: .2,
          capacityConfidence: .2,
        ),
      );
      expect(result.usedMeasuredState, isTrue);
      expect(result.focusMinutes, 25);
    });

    test('an unmeasured sample is ignored', () {
      final result = recommendTimer(
        state: sample(
          focus: 0.1,
          capacity: 0.1,
          origin: SignalOrigin.unmeasured,
        ),
      );
      expect(result.usedMeasuredState, isFalse);
    });

    test('a single axis is not enough to count as measured', () {
      final result = recommendTimer(state: sample(focus: 0.1));
      expect(result.usedMeasuredState, isFalse);
    });
  });

  group('weightedStateMean', () {
    test('weights each axis by its own confidence', () {
      final result = weightedStateMean([
        sample(focus: .2, focusConfidence: .25),
        sample(focus: .8, focusConfidence: .75),
      ]);
      expect(result?.focus, closeTo(.65, 1e-9));
      expect(result?.focusConfidence, closeTo(.5, 1e-9));
    });

    test('does not turn missing axes into zero', () {
      final result = weightedStateMean([
        sample(capacity: .7, capacityConfidence: .8),
      ]);
      expect(result?.focus, isNull);
      expect(result?.capacity, closeTo(.7, 1e-9));
    });

    test('synthetic input keeps its label and is fully measured', () {


      final result = weightedStateMean([
        sample(
          focus: .8,
          capacity: .8,
          focusConfidence: .9,
          capacityConfidence: .9,
          origin: SignalOrigin.wearableSyntheticTest,
        ),
      ]);
      expect(result?.origin, SignalOrigin.wearableSyntheticTest);
      expect(result?.isEligible, isTrue);
    });

    test('zero-confidence placeholders are not treated as measured', () {
      final result = weightedStateMean([
        sample(focus: .4, focusConfidence: 0),
        sample(focus: .6, focusConfidence: 0),
      ]);
      expect(result?.focus, isNull);
    });

    test('a zero-confidence sample is not eligible', () {
      final state = sample(
        focus: 0,
        capacity: 0.5,
        focusConfidence: 0,
        capacityConfidence: 0,
      );
      expect(state.availableAxes, isEmpty);
      expect(state.isEligible, isFalse);
      expect(recommendTimer(state: state).usedMeasuredState, isFalse);
    });

    test('low but nonzero confidence still counts as measured', () {
      final state = sample(
        focus: 0.2,
        capacity: 0.2,
        focusConfidence: 0.2,
        capacityConfidence: 0.2,
      );
      expect(state.isEligible, isTrue);
      expect(recommendTimer(state: state).usedMeasuredState, isTrue);
    });

    test('focus outside 0..1 is degenerate and not remapped', () {
      final state = sample(focus: 2.0, focusConfidence: .9, capacity: .5);
      expect(state.focus, 2.0);
      expect(state.focusDegenerate, isTrue);
      expect(state.availableAxes.containsKey('Focus'), isFalse);
      expect(
        axisUnavailableReason(
          axis: 'Focus',
          sample: state,
          hsiWindowCount: 2,
          acceptedRrCount: 10,
        ),
        'degenerate focus',
      );
    });
  });

  group('sbActivityLevel', () {
    test('buckets minutes into the five ramp stops', () {
      expect(sbActivityLevel(0), 0);
      expect(sbActivityLevel(-5), 0);
      expect(sbActivityLevel(1), 1);
      expect(sbActivityLevel(24), 1);
      expect(sbActivityLevel(25), 2);
      expect(sbActivityLevel(49), 2);
      expect(sbActivityLevel(50), 3);
      expect(sbActivityLevel(89), 3);
      expect(sbActivityLevel(90), 4);
      expect(sbActivityLevel(600), 4);
    });
  });

  group('pearson', () {
    test('refuses to report from fewer than seven points', () {
      expect(pearson(<double>[1, 2, 3], <double>[1, 2, 3]), isNull);
    });

    test('finds a perfect positive relationship', () {
      final xs = <double>[1, 2, 3, 4, 5, 6, 7];
      expect(pearson(xs, xs), closeTo(1, 1e-9));
    });

    test('finds a perfect negative relationship', () {
      final xs = <double>[1, 2, 3, 4, 5, 6, 7];
      final ys = xs.reversed.toList();
      expect(pearson(xs, ys), closeTo(-1, 1e-9));
    });

    test('returns null when a series has no variance', () {
      final xs = <double>[1, 2, 3, 4, 5, 6, 7];
      expect(pearson(xs, List<double>.filled(7, 3)), isNull);
    });

    test('returns null on mismatched lengths', () {
      expect(pearson(<double>[1, 2, 3, 4, 5, 6, 7], <double>[1, 2, 3]), isNull);
    });
  });

  group('streakDays', () {
    final today = DateTime(2026, 8, 19);
    DateTime ago(int days) => today.subtract(Duration(days: days));

    test('counts consecutive days back from today', () {
      final byDay = {ago(0): 30, ago(1): 45, ago(2): 20};
      expect(streakDays(byDay, today: today), 3);
    });

    test('a gap ends the streak', () {
      final byDay = {ago(0): 30, ago(1): 45, ago(3): 20};
      expect(streakDays(byDay, today: today), 2);
    });

    test('yesterday still counts so the streak survives the morning', () {
      final byDay = {ago(1): 45, ago(2): 20};
      expect(streakDays(byDay, today: today), 2);
    });

    test('nothing recent is a zero streak', () {
      expect(streakDays({ago(3): 40}, today: today), 0);
    });

    test('empty history is a zero streak', () {
      expect(streakDays(const {}, today: today), 0);
    });
  });

  group('SbFormat', () {
    test('elapsed switches to hours only when needed', () {
      expect(SbFormat.elapsed(const Duration(seconds: 7)), '0:07');
      expect(SbFormat.elapsed(const Duration(minutes: 4, seconds: 7)), '4:07');
      expect(
        SbFormat.elapsed(const Duration(hours: 1, minutes: 4, seconds: 7)),
        '1:04:07',
      );
    });

    test('minutes reads as a human total', () {
      expect(SbFormat.minutes(0), '0m');
      expect(SbFormat.minutes(42), '42m');
      expect(SbFormat.minutes(60), '1h');
      expect(SbFormat.minutes(102), '1h 42m');
    });

    test('an unmeasured value is an em-dash, never a zero', () {
      expect(SbFormat.orUnknown(null), '—');
      expect(SbFormat.orUnknown(0), '0');
      expect(SbFormat.orUnknown(72), '72');
    });
  });

  group('axisUnavailableReason', () {
    test('a measured zero is present, not unavailable', () {
      expect(
        axisUnavailableReason(
          axis: 'Arousal',
          sample: sample(focus: 0.5, capacity: 0.5, arousal: 0),
          hsiWindowCount: 3,
          acceptedRrCount: 20,
        ),
        isNull,
      );
    });
  });
}
