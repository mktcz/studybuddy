import 'package:flutter_test/flutter_test.dart';
import 'package:studybuddy/domain/enums.dart';
import 'package:studybuddy/domain/session_nudges.dart';
import 'package:studybuddy/domain/study_logic.dart';

final _start = DateTime(2026, 8, 20, 9);

StateSample window(
  int minute, {
  double? stress,
  double? focus,
  double? capacity,
  double? arousal,
  double stressConfidence = .9,
  double focusConfidence = .9,
  double capacityConfidence = .9,
  double arousalConfidence = .9,
  SignalOrigin origin = SignalOrigin.wearableReal,
}) {
  return StateSample(
    at: _start.add(Duration(minutes: minute)),
    origin: origin,
    stress: stress,
    focus: focus,
    capacity: capacity,
    arousal: arousal,
    stressConfidence: stress == null ? null : stressConfidence,
    focusConfidence: focus == null ? null : focusConfidence,
    capacityConfidence: capacity == null ? null : capacityConfidence,
    arousalConfidence: arousal == null ? null : arousalConfidence,
  );
}

void main() {
  const planned = Duration(minutes: 45);

  Nudge? feed(NudgeEngine engine, StateSample sample) => engine.onWindow(
    sample: sample,
    elapsed: sample.at.difference(_start),
    planned: planned,
  );

  group('breakSuggested', () {
    test('fires on three rising stress windows', () {
      final engine = NudgeEngine();
      expect(feed(engine, window(11, stress: .50)), isNull);
      expect(feed(engine, window(12, stress: .58)), isNull);
      final nudge = feed(engine, window(13, stress: .65));
      expect(nudge?.kind, NudgeKind.breakSuggested);
    });

    test('two clearly-high windows are enough on their own', () {
      final engine = NudgeEngine();
      expect(feed(engine, window(11, stress: .80)), isNull);
      expect(
        feed(engine, window(12, stress: .78))?.kind,
        NudgeKind.breakSuggested,
      );
    });

    test('never fires in the first ten minutes', () {
      final engine = NudgeEngine();
      feed(engine, window(2, stress: .50));
      feed(engine, window(3, stress: .60));
      expect(feed(engine, window(4, stress: .70)), isNull);
    });

    test('warm-up confidence still counts by default', () {


      final engine = NudgeEngine();
      feed(engine, window(11, stress: .50, stressConfidence: .2));
      feed(engine, window(12, stress: .60, stressConfidence: .2));
      expect(
        feed(engine, window(13, stress: .70, stressConfidence: .2))?.kind,
        NudgeKind.breakSuggested,
      );
    });

    test('a raised minConfidence gates values out', () {
      final engine = NudgeEngine(minConfidence: .5);
      feed(engine, window(11, stress: .50, stressConfidence: .2));
      feed(engine, window(12, stress: .60, stressConfidence: .2));
      expect(
        feed(engine, window(13, stress: .70, stressConfidence: .2)),
        isNull,
      );
    });

    test('unmeasured windows are ignored entirely', () {
      final engine = NudgeEngine();
      feed(engine, window(11, stress: .50, origin: SignalOrigin.unmeasured));
      feed(engine, window(12, stress: .60, origin: SignalOrigin.unmeasured));
      expect(
        feed(engine, window(13, stress: .70, origin: SignalOrigin.unmeasured)),
        isNull,
      );
    });

    test('a dip in the run resets the pattern', () {
      final engine = NudgeEngine();
      feed(engine, window(11, stress: .50));
      feed(engine, window(12, stress: .40));
      expect(feed(engine, window(13, stress: .65)), isNull);
    });
  });

  group('cooldowns', () {
    test('no two nudges inside the global cooldown', () {
      final engine = NudgeEngine();
      feed(engine, window(11, stress: .50));
      feed(engine, window(12, stress: .58));
      expect(feed(engine, window(13, stress: .65)), isNotNull);

      expect(feed(engine, window(17, stress: .75)), isNull);
    });

    test('the same kind waits for its own longer cooldown', () {
      final engine = NudgeEngine();
      feed(engine, window(11, stress: .50));
      feed(engine, window(12, stress: .58));
      expect(feed(engine, window(13, stress: .66)), isNotNull);

      feed(engine, window(19, stress: .70));
      expect(feed(engine, window(20, stress: .78)), isNull);

      expect(
        feed(engine, window(24, stress: .85))?.kind,
        NudgeKind.breakSuggested,
      );
    });
  });

  group('extendOffered', () {
    test('offers more time near the end of a well-paced session', () {
      final engine = NudgeEngine();
      feed(engine, window(38, focus: .70, stress: .30));
      feed(engine, window(39, focus: .72, stress: .30));
      final nudge = feed(engine, window(41, focus: .71, stress: .32));
      expect(nudge?.kind, NudgeKind.extendOffered);
    });

    test('only near the end, and only once', () {
      final engine = NudgeEngine();
      feed(engine, window(20, focus: .80));
      feed(engine, window(21, focus: .80));
      expect(feed(engine, window(22, focus: .80)), isNull);
      expect(
        feed(engine, window(41, focus: .80))?.kind,
        NudgeKind.extendOffered,
      );
      expect(feed(engine, window(42, focus: .80)), isNull);
    });

    test('high stress suppresses the offer', () {
      final engine = NudgeEngine();
      feed(engine, window(41, focus: .80, stress: .60));
      feed(engine, window(42, focus: .80, stress: .60));
      expect(feed(engine, window(43, focus: .80, stress: .60)), isNull);
    });

    test('accepting consumes the offer for the session', () {
      final engine = NudgeEngine();
      engine.onExtended();
      feed(engine, window(41, focus: .80));
      feed(engine, window(42, focus: .80));
      expect(feed(engine, window(43, focus: .80)), isNull);
    });
  });

  group('wrapUpSuggested', () {
    test('fires when capacity falls well below its session peak', () {
      final engine = NudgeEngine();

      feed(engine, window(16, capacity: .70));
      feed(engine, window(17, capacity: .72));
      feed(engine, window(18, capacity: .71));

      expect(feed(engine, window(24, capacity: .45)), isNull);
      final nudge = feed(engine, window(25, capacity: .40));
      expect(nudge?.kind, NudgeKind.wrapUpSuggested);
    });

    test('only once per session', () {
      final engine = NudgeEngine();
      feed(engine, window(16, capacity: .70));
      feed(engine, window(17, capacity: .72));
      feed(engine, window(18, capacity: .71));
      feed(engine, window(24, capacity: .45));
      expect(feed(engine, window(25, capacity: .40)), isNotNull);
      feed(engine, window(37, capacity: .30));
      expect(feed(engine, window(38, capacity: .28)), isNull);
    });
  });

  group('backOnTrack', () {
    test('confirms recovery after a break suggestion', () {
      final engine = NudgeEngine();
      feed(engine, window(11, stress: .50));
      feed(engine, window(12, stress: .58));
      expect(
        feed(engine, window(13, stress: .66))?.kind,
        NudgeKind.breakSuggested,
      );
      feed(engine, window(18, stress: .42));
      final nudge = feed(engine, window(19, stress: .40));
      expect(nudge?.kind, NudgeKind.backOnTrack);

      feed(engine, window(25, stress: .38));
      expect(feed(engine, window(26, stress: .36)), isNull);
    });

    test('never fires without a preceding break suggestion', () {
      final engine = NudgeEngine();
      feed(engine, window(11, stress: .40));
      expect(feed(engine, window(12, stress: .38)), isNull);
    });
  });

  test('reset clears everything between sessions', () {
    final engine = NudgeEngine();
    feed(engine, window(11, stress: .50));
    feed(engine, window(12, stress: .58));
    expect(feed(engine, window(13, stress: .66)), isNotNull);
    engine.reset();

    feed(engine, window(11, stress: .50));
    feed(engine, window(12, stress: .58));
    expect(feed(engine, window(13, stress: .66)), isNotNull);
  });

  group('rest warning', () {
    RestAlert? rest(
      NudgeEngine engine,
      StateSample sample, {
      String? sessionId = 's1',
      bool focusActive = true,
      DateTime? now,
    }) {
      return engine.onRestWindow(
        sample: sample,
        sessionId: sessionId,
        focusActive: focusActive,
        now: now ?? sample.at,
      );
    }

    test('requires two consecutive positive-confidence windows', () {
      final engine = NudgeEngine();
      expect(rest(engine, window(1, stress: .80)), isNull);
      final alert = rest(engine, window(2, stress: .81));
      expect(alert, isNotNull);
      expect(alert!.kind, RestAlertKind.highStress);
      expect(alert.message, NudgeEngine.restCopy);
    });

    test('fires on abnormal arousal', () {
      final engine = NudgeEngine();
      expect(rest(engine, window(1, arousal: .10)), isNull);
      expect(
        rest(engine, window(2, arousal: .15))?.kind,
        RestAlertKind.abnormalArousal,
      );
    });

    test('ignores zero-confidence and non-finite values', () {
      final engine = NudgeEngine();
      rest(engine, window(1, stress: .90, stressConfidence: 0));
      expect(rest(engine, window(2, stress: .90, stressConfidence: 0)), isNull);
      rest(engine, window(3, stress: double.nan, stressConfidence: .9));
      expect(rest(engine, window(4, stress: .90)), isNull);
    });

    test('dedupes an episode until recovery then honors cooldown', () {
      final engine = NudgeEngine();
      rest(engine, window(1, stress: .80));
      expect(rest(engine, window(2, stress: .80)), isNotNull);
      expect(rest(engine, window(3, stress: .82)), isNull);
      engine.dismissRestAlert();
      expect(rest(engine, window(3, stress: .30)), isNull);
      rest(engine, window(4, stress: .80));
      expect(rest(engine, window(5, stress: .81)), isNull);
      rest(engine, window(8, stress: .80));
      expect(rest(engine, window(9, stress: .81)), isNotNull);
    });

    test('session change keeps the global cooldown', () {
      final engine = NudgeEngine();
      rest(engine, window(1, stress: .80), sessionId: 'a');
      rest(engine, window(2, stress: .80), sessionId: 'a');
      engine.dismissRestAlert();
      rest(engine, window(3, stress: .80), sessionId: 'b');
      expect(rest(engine, window(4, stress: .81), sessionId: 'b'), isNull);
      rest(engine, window(8, stress: .80), sessionId: 'b');
      expect(rest(engine, window(9, stress: .81), sessionId: 'b'), isNotNull);
    });

    test('rejects stale and out-of-order windows', () {
      final engine = NudgeEngine();
      final first = window(1, stress: .80);
      expect(
        rest(engine, first, now: first.at.add(const Duration(minutes: 10))),
        isNull,
      );
      expect(rest(engine, window(2, stress: .81)), isNull);
      expect(rest(engine, window(1, stress: .82)), isNull);
    });

    test('a wide gap resets the consecutive streak', () {
      final engine = NudgeEngine();
      expect(rest(engine, window(1, stress: .80)), isNull);
      expect(rest(engine, window(5, stress: .81)), isNull);
      expect(rest(engine, window(6, stress: .82)), isNotNull);
    });
  });
}
