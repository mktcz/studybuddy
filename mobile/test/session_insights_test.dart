import 'package:flutter_test/flutter_test.dart';
import 'package:studybuddy/domain/enums.dart';
import 'package:studybuddy/domain/session_insights.dart';
import 'package:studybuddy/domain/study_logic.dart';

final _start = DateTime(2026, 8, 20, 9);

StateSample window(
  int minute, {
  double? stress,
  double? focus,
  double stressConfidence = .9,
  double focusConfidence = .9,
}) {
  return StateSample(
    at: _start.add(Duration(minutes: minute)),
    origin: SignalOrigin.wearableReal,
    stress: stress,
    focus: focus,
    stressConfidence: stress == null ? null : stressConfidence,
    focusConfidence: focus == null ? null : focusConfidence,
  );
}

({int page, DateTime at}) turn(int page, int minute) =>
    (page: page, at: _start.add(Duration(minutes: minute)));

void main() {
  group('pageInsights', () {
    test('assigns each window to the page open when it closed', () {
      final insights = pageInsights(
        windows: [
          window(1, stress: .2),
          window(3, stress: .4),
          window(6, stress: .8),
        ],
        events: [turn(10, 0), turn(11, 5)],
      );
      expect(insights, hasLength(2));
      expect(insights[0].startPage, 10);
      expect(insights[0].windowCount, 2);
      expect(insights[0].meanStress, closeTo(.3, 1e-9));
      expect(insights[1].startPage, 11);
      expect(insights[1].meanStress, closeTo(.8, 1e-9));
    });

    test('windows before the first page event are unattributed', () {
      final insights = pageInsights(
        windows: [window(1, stress: .9), window(6, stress: .2)],
        events: [turn(5, 5)],
      );
      expect(insights, hasLength(1));
      expect(insights.single.windowCount, 1);
      expect(insights.single.meanStress, closeTo(.2, 1e-9));
    });

    test('warm-up confidence values count by default', () {
      final insights = pageInsights(
        windows: [
          window(1, stress: .9, stressConfidence: .2),
          window(2, stress: .3),
        ],
        events: [turn(1, 0)],
      );
      expect(insights.single.windowCount, 2);
      expect(insights.single.meanStress, closeTo(.6, 1e-9));
    });

    test('a raised minConfidence gates values out of the mean', () {
      final insights = pageInsights(
        windows: [
          window(1, stress: .9, stressConfidence: .2),
          window(2, stress: .3),
        ],
        events: [turn(1, 0)],
        minConfidence: .5,
      );
      expect(insights.single.meanStress, closeTo(.3, 1e-9));
    });

    test('empty inputs return no insights', () {
      expect(pageInsights(windows: const [], events: [turn(1, 0)]), isEmpty);
      expect(pageInsights(windows: [window(1)], events: const []), isEmpty);
    });
  });

  group('headlinePages', () {
    test('names an elevated adjacent range with enough evidence', () {
      final insights = pageInsights(
        windows: [
          window(1, stress: .30),
          window(2, stress: .30),
          window(3, stress: .30),
          window(6, stress: .70),
          window(8, stress: .75),
        ],
        events: [turn(1, 0), turn(12, 5), turn(13, 7)],
      );
      final headline = headlinePages(insights);
      expect(headline.stressed, isNotNull);
      expect(headline.stressed!.startPage, 12);
      expect(headline.stressed!.endPage, 13);
      expect(headline.stressed!.windowCount, 2);
    });

    test('one high window never names a page', () {
      final insights = pageInsights(
        windows: [
          window(1, stress: .30),
          window(2, stress: .30),
          window(6, stress: .90),
        ],
        events: [turn(1, 0), turn(12, 5)],
      );
      expect(headlinePages(insights).stressed, isNull);
    });

    test('uniformly high stress is a session property, not a page one', () {
      final insights = pageInsights(
        windows: [
          window(1, stress: .70),
          window(2, stress: .70),
          window(6, stress: .72),
          window(7, stress: .72),
        ],
        events: [turn(1, 0), turn(2, 5)],
      );

      expect(headlinePages(insights).stressed, isNull);
    });

    test('finds the strongest focused range', () {
      final insights = pageInsights(
        windows: [
          window(1, focus: .80),
          window(2, focus: .85),
          window(6, focus: .40),
        ],
        events: [turn(3, 0), turn(4, 5)],
      );
      final headline = headlinePages(insights);
      expect(headline.focused?.startPage, 3);
      expect(headline.focused?.meanFocus, closeTo(.825, 1e-9));
    });
  });

  group('sessionTakeaway', () {
    const planned = Duration(minutes: 45);

    test('stressed pages win over everything else', () {
      final line = sessionTakeaway(
        focused: planned,
        planned: planned,
        mean: window(1, focus: .9),
        windows: [window(1, focus: .9)],
        stressedPages: const PageInsight(
          startPage: 12,
          endPage: 15,
          windowCount: 3,
          meanStress: .7,
        ),
      );
      expect(line, contains('12–15'));
      expect(line, contains('second pass'));
    });

    test('strong mean focus earns its line', () {
      final line = sessionTakeaway(
        focused: const Duration(minutes: 30),
        planned: planned,
        mean: window(1, focus: .8),
        windows: const [],
      );
      expect(line, contains('focus'));
    });

    test('late-rising stress suggests a shorter block', () {
      final line = sessionTakeaway(
        focused: const Duration(minutes: 30),
        planned: planned,
        mean: null,
        windows: [
          for (var i = 0; i < 3; i++) window(i, stress: .3),
          for (var i = 3; i < 6; i++) window(i, stress: .3),
          for (var i = 6; i < 9; i++) window(i, stress: .6),
        ],
      );
      expect(line, contains('shorter block'));
    });

    test('going the distance is worth saying', () {
      final line = sessionTakeaway(
        focused: planned,
        planned: planned,
        mean: null,
        windows: const [],
      );
      expect(line, contains('full distance'));
    });

    test('there is always a fallback line', () {
      final line = sessionTakeaway(
        focused: const Duration(minutes: 10),
        planned: planned,
        mean: null,
        windows: const [],
      );
      expect(line, isNotEmpty);
    });
  });
}
