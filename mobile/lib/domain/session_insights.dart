import 'study_logic.dart';


class PageInsight {
  const PageInsight({
    required this.startPage,
    required this.endPage,
    required this.windowCount,
    this.meanStress,
    this.meanFocus,
  });

  final int startPage;
  final int endPage;


  final int windowCount;

  final double? meanStress;
  final double? meanFocus;

  String get pageLabel =>
      startPage == endPage ? 'page $startPage' : 'pages $startPage–$endPage';
}


List<PageInsight> pageInsights({
  required List<StateSample> windows,
  required List<({int page, DateTime at})> events,
  double minConfidence = 0,
}) {
  if (windows.isEmpty || events.isEmpty) return const [];
  final ordered = [...events]..sort((a, b) => a.at.compareTo(b.at));

  final stressSums = <int, (double, int)>{};
  final focusSums = <int, (double, int)>{};
  final counts = <int, int>{};

  for (final window in windows) {
    int? page;
    for (final event in ordered) {
      if (!event.at.isAfter(window.at)) {
        page = event.page;
      } else {
        break;
      }
    }
    if (page == null) continue;
    counts[page] = (counts[page] ?? 0) + 1;
    void tally(Map<int, (double, int)> sums, double? value, double? conf) {
      if (value == null) return;
      if (minConfidence > 0 && (conf ?? 0) < minConfidence) return;
      final (sum, n) = sums[page!] ?? (0.0, 0);
      sums[page] = (sum + value, n + 1);
    }

    tally(stressSums, window.stress, window.stressConfidence);
    tally(focusSums, window.focus, window.focusConfidence);
  }

  double? meanOf(Map<int, (double, int)> sums, int page) {
    final entry = sums[page];
    return entry == null ? null : entry.$1 / entry.$2;
  }

  final pages = counts.keys.toList()..sort();
  return [
    for (final page in pages)
      PageInsight(
        startPage: page,
        endPage: page,
        windowCount: counts[page]!,
        meanStress: meanOf(stressSums, page),
        meanFocus: meanOf(focusSums, page),
      ),
  ];
}


({PageInsight? stressed, PageInsight? focused}) headlinePages(
  List<PageInsight> insights,
) {
  if (insights.isEmpty) return (stressed: null, focused: null);

  final stressValues = insights
      .where((insight) => insight.meanStress != null)
      .toList(growable: false);
  double? overallStress;
  if (stressValues.isNotEmpty) {
    var weighted = 0.0;
    var count = 0;
    for (final insight in stressValues) {
      weighted += insight.meanStress! * insight.windowCount;
      count += insight.windowCount;
    }
    overallStress = weighted / count;
  }

  PageInsight? best(
    bool Function(PageInsight) qualifies,
    double? Function(PageInsight) score,
  ) {
    final merged = _mergeAdjacent(insights.where(qualifies), score);
    PageInsight? top;
    for (final range in merged) {
      if (range.windowCount < 2) continue;
      if (top == null || (score(range) ?? 0) > (score(top) ?? 0)) top = range;
    }
    return top;
  }

  final stressed = overallStress == null
      ? null
      : best(
          (insight) =>
              insight.meanStress != null &&
              insight.meanStress! >= .55 &&
              insight.meanStress! >= overallStress! + .10,
          (insight) => insight.meanStress,
        );
  final focused = best(
    (insight) => insight.meanFocus != null && insight.meanFocus! >= .60,
    (insight) => insight.meanFocus,
  );
  return (stressed: stressed, focused: focused);
}

List<PageInsight> _mergeAdjacent(
  Iterable<PageInsight> insights,
  double? Function(PageInsight) score,
) {
  final ordered = insights.toList()
    ..sort((a, b) => a.startPage.compareTo(b.startPage));
  final merged = <PageInsight>[];
  for (final insight in ordered) {
    final last = merged.lastOrNull;
    if (last == null || insight.startPage > last.endPage + 1) {
      merged.add(insight);
      continue;
    }
    final totalWindows = last.windowCount + insight.windowCount;
    double? combine(double? a, double? b) {
      if (a == null) return b;
      if (b == null) return a;
      return (a * last.windowCount + b * insight.windowCount) / totalWindows;
    }

    merged[merged.length - 1] = PageInsight(
      startPage: last.startPage,
      endPage: insight.endPage,
      windowCount: totalWindows,
      meanStress: combine(last.meanStress, insight.meanStress),
      meanFocus: combine(last.meanFocus, insight.meanFocus),
    );
  }
  return merged;
}


String sessionTakeaway({
  required Duration focused,
  required Duration planned,
  StateSample? mean,
  required List<StateSample> windows,
  PageInsight? stressedPages,
}) {
  if (stressedPages != null) {
    final label =
        stressedPages.pageLabel[0].toUpperCase() +
        stressedPages.pageLabel.substring(1);
    return '$label took the most out of you — worth a second pass.';
  }

  if (mean?.focus != null && mean!.focus! >= .7) {
    return 'Strong, steady focus throughout — this length works for you.';
  }

  final stress = windows
      .where((window) => window.stress != null)
      .map((window) => window.stress!)
      .toList(growable: false);
  if (stress.length >= 6) {
    final third = stress.length ~/ 3;
    double mean(Iterable<double> values) =>
        values.reduce((a, b) => a + b) / values.length;
    final early = mean(stress.take(third));
    final late = mean(stress.skip(stress.length - third));
    if (late >= early + .15) {
      return 'The last stretch got harder — a shorter block may suit next '
          'time.';
    }
  }

  if (planned > Duration.zero && focused >= planned) {
    return 'You went the full distance. Consistency like this compounds.';
  }
  return 'Another block in the book — every session builds the habit.';
}
