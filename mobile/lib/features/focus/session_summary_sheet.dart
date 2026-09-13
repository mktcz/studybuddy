import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui/ui.dart';

import '../../app/providers.dart';
import '../../data/database.dart';
import '../../domain/session_insights.dart';
import '../../domain/study_logic.dart';
import '../state/axis_style.dart';
import '../state/hsi_providers.dart';
import '../state/rest_alert_host.dart';


class SessionSummarySheet extends ConsumerStatefulWidget {
  const SessionSummarySheet({super.key, required this.sessionId});

  final String sessionId;

  static Future<void> show(BuildContext context, String sessionId) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => RestAlertSuppressionScope(
        child: SessionSummarySheet(sessionId: sessionId),
      ),
    );
  }

  @override
  ConsumerState<SessionSummarySheet> createState() =>
      _SessionSummarySheetState();
}

class _SessionSummarySheetState extends ConsumerState<SessionSummarySheet> {
  _SummaryData? _data;
  String? _takeaway;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    final db = ref.read(databaseProvider);
    final session = await db.findSession(widget.sessionId);
    if (session == null || !mounted) return;
    final windows = await db.hsiWindowsFor(widget.sessionId);
    final pageEvents = await db.pageEventsFor(widget.sessionId);
    final source = session.sourceId == null
        ? null
        : await db.findSource(session.sourceId!);

    final samples = [
      for (final window in windows)
        StateSample(
          at: window.at,
          origin: window.signalOrigin,
          focus: window.focus,
          focusConfidence: window.focusConfidence,
          capacity: window.capacity,
          capacityConfidence: window.capacityConfidence,
          arousal: window.arousal,
          arousalConfidence: window.arousalConfidence,
          stress: window.stress,
          stressConfidence: window.stressConfidence,
          quality: window.quality,
          hsiVersion: window.hsiVersion,
        ),
    ];

    final insights = pageInsights(
      windows: samples,
      events: [
        for (final event in pageEvents) (page: event.page, at: event.at),
      ],
    );
    final headline = headlinePages(insights);
    final mean = weightedStateMean(samples);
    final takeaway = sessionTakeaway(
      focused: Duration(minutes: session.focusedMinutes),
      planned: Duration(minutes: session.plannedMinutes),
      mean: mean,
      windows: samples,
      stressedPages: headline.stressed,
    );

    if (!mounted) return;
    setState(() {
      _data = _SummaryData(
        session: session,
        mean: mean,
        focusTrace: [for (final sample in samples) sample.focus],
        stressTrace: [for (final sample in samples) sample.stress],
        stressedPages: headline.stressed,
        focusedPages: headline.focused,
        sourceTitle: source?.title,
      );
      _takeaway = takeaway;
    });

    unawaited(_upgradeTakeaway(session, mean, headline.stressed));
  }


  Future<void> _upgradeTakeaway(
    Session session,
    StateSample? mean,
    PageInsight? stressedPages,
  ) async {
    final facts = <String>[
      '${session.focusedMinutes} of ${session.plannedMinutes} planned '
          'minutes focused',
      if (mean?.focus != null) 'mean focus ${(mean!.focus! * 100).round()}/100',
      if (mean?.stress != null)
        'mean stress ${(mean!.stress! * 100).round()}/100',
      if (stressedPages != null)
        'stress ran highest on ${stressedPages.pageLabel} of their reading',
    ];
    final syni = await ref
        .read(hsiEngineProvider)
        .generateTakeaway(
          'A student just finished a study session: ${facts.join('; ')}. '
          'Reply with exactly one short, encouraging, concrete takeaway '
          'sentence for them. No preamble, no quotes.',
        );
    if (syni != null && mounted) setState(() => _takeaway = syni);
  }

  @override
  Widget build(BuildContext context) {
    final data = _data;
    if (data == null) {
      return const SizedBox(
        height: 240,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    final session = data.session;
    final sb = context.sb;
    final meanBars = data.mean == null
        ? const <StateBarData>[]
        : stateBarsFor(context, data.mean!);
    final hasTrace = data.focusTrace.any((value) => value != null);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          SbSpace.gutter,
          SbSpace.lg,
          SbSpace.gutter,
          SbSpace.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Eyebrow('Session complete'),
                      const SizedBox(height: SbSpace.xxs),
                      Text(
                        SbFormat.minutes(session.focusedMinutes),
                        style: context.text.displaySmall,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: SbSpace.xs),
                  child: Text(
                    'of ${session.plannedMinutes} min',
                    style: context.text.bodyMedium?.copyWith(color: sb.muted),
                  ),
                ),
              ],
            ),
            const SizedBox(height: SbSpace.lg),

            if (meanBars.isNotEmpty) ...[
              StateBars(bars: meanBars),
              const SizedBox(height: SbSpace.lg),
            ] else ...[
              Text(
                'Nothing was measured this time — check your watch is on '
                'your wrist and connected.',
                style: context.text.bodyMedium,
              ),
              const SizedBox(height: SbSpace.lg),
            ],

            if (hasTrace) ...[
              _TraceRow(
                label: axisStyle(context, 'Focus').label,
                values: data.focusTrace,
                color: axisStyle(context, 'Focus').color,
              ),
              const SizedBox(height: SbSpace.sm),
              _TraceRow(
                label: axisStyle(context, 'Stress').label,
                values: data.stressTrace,
                color: axisStyle(context, 'Stress').color,
              ),
              const SizedBox(height: SbSpace.lg),
            ],

            if (data.stressedPages case final stressed?)
              _ReadingLine(
                text:
                    'Stress ran highest on ${stressed.pageLabel}'
                    '${data.sourceTitle == null ? '' : ' of ${data.sourceTitle}'}.',
                color: axisStyle(context, 'Stress').color,
              ),
            if (data.focusedPages case final focusedRange?)
              _ReadingLine(
                text: 'Focus held strongest on ${focusedRange.pageLabel}.',
                color: axisStyle(context, 'Focus').color,
              ),
            if (data.stressedPages != null || data.focusedPages != null)
              const SizedBox(height: SbSpace.lg),

            if (_takeaway case final takeaway?) ...[
              Text(
                takeaway,
                style: context.text.bodyMedium?.copyWith(color: sb.muted),
              ),
              const SizedBox(height: SbSpace.lg),
            ],

            FilledButton(
              onPressed: () => Navigator.pop(context),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(44),
              ),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryData {
  const _SummaryData({
    required this.session,
    required this.mean,
    required this.focusTrace,
    required this.stressTrace,
    required this.stressedPages,
    required this.focusedPages,
    required this.sourceTitle,
  });

  final Session session;
  final StateSample? mean;
  final List<double?> focusTrace;
  final List<double?> stressTrace;
  final PageInsight? stressedPages;
  final PageInsight? focusedPages;
  final String? sourceTitle;
}

class _TraceRow extends StatelessWidget {
  const _TraceRow({
    required this.label,
    required this.values,
    required this.color,
  });

  final String label;
  final List<double?> values;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(width: 84, child: Text(label, style: context.text.bodyMedium)),
        Expanded(
          child: SparkLine(values: values, color: color, height: 28),
        ),
      ],
    );
  }
}

class _ReadingLine extends StatelessWidget {
  const _ReadingLine({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: SbSpace.xxs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          ),
          const SizedBox(width: SbSpace.xs),
          Expanded(child: Text(text, style: context.text.bodyMedium)),
        ],
      ),
    );
  }
}
