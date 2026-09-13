import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui/ui.dart';

import '../../app/providers.dart';
import '../../data/database.dart';
import '../../domain/enums.dart';
import '../focus/session_summary_sheet.dart';
import '../state/rest_alert_host.dart';


class ActivityScreen extends ConsumerWidget {
  const ActivityScreen({super.key});

  static const path = '/activity';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final byDay = ref.watch(minutesByDayProvider).value ?? const {};
    final sessions = ref.watch(recentSessionsProvider).value ?? const [];
    final streak = ref.watch(streakProvider);
    final todayMinutes = ref.watch(todayMinutesProvider);
    final insight = ref.watch(sevenDayInsightProvider).value;

    final weekMinutes = _lastNDays(byDay, 7);
    final hasAny = byDay.values.any((m) => m > 0);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            SbSpace.gutter,
            SbSpace.xl,
            SbSpace.gutter,
            SbSpace.xxxl,
          ),
          children: [
            Text('Activity', style: context.text.headlineMedium),
            const SizedBox(height: SbSpace.xl),

            StatRow(
              stats: [
                StatColumn(
                  value: SbFormat.minutes(todayMinutes),
                  label: 'today',
                  emphasis: StatEmphasis.large,
                ),
                StatColumn(
                  value: SbFormat.minutes(weekMinutes),
                  label: 'this week',
                  emphasis: StatEmphasis.large,
                ),
                StatColumn(
                  value: '$streak',
                  label: 'day streak',
                  emphasis: StatEmphasis.large,
                ),
              ],
            ),
            const SizedBox(height: SbSpace.xxl),

            const Eyebrow('Seven-day insight'),
            const SizedBox(height: SbSpace.sm),
            _SevenDayInsightView(insight: insight),
            const SizedBox(height: SbSpace.xxl),

            const Eyebrow('Focus trend'),
            const SizedBox(height: SbSpace.sm),
            _FocusTrend(sessions: sessions),
            const SizedBox(height: SbSpace.xxl),

            const Eyebrow('Last 12 weeks'),
            const SizedBox(height: SbSpace.sm),


            ActivityGrid(
              minutesByDay: byDay,
              onDayTap: (day, minutes) => _showDay(context, ref, day),
            ),
            if (!hasAny) ...[
              const SizedBox(height: SbSpace.sm),
              Text('No sessions yet.', style: context.text.bodyMedium),
            ],

            const SizedBox(height: SbSpace.xxl),

            const Eyebrow('Recent sessions'),
            const SizedBox(height: SbSpace.xs),

            if (sessions.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: SbSpace.md),
                child: Text(
                  'Finished sessions show up here.',
                  style: context.text.bodyLarge?.copyWith(
                    color: context.sb.muted,
                  ),
                ),
              )
            else
              for (final (index, session) in sessions.indexed)
                _SessionRow(
                  item: session,
                  divider: index != sessions.length - 1,
                ),
          ],
        ),
      ),
    );
  }

  static int _lastNDays(Map<DateTime, int> byDay, int days) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    var total = 0;
    for (var i = 0; i < days; i++) {
      total += byDay[today.subtract(Duration(days: i))] ?? 0;
    }
    return total;
  }

  static void _showDay(BuildContext context, WidgetRef ref, DateTime day) {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => RestAlertSuppressionScope(child: _DaySheet(day: day)),
    );
  }
}

class _SessionRow extends ConsumerWidget {
  const _SessionRow({required this.item, this.divider = true});

  final SessionListItem item;
  final bool divider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = item.session;
    final subject = item.subject;
    final accent = context.sb.subject(subject?.accentIndex ?? 0);

    return HairlineRow(
      onTap: () => SessionSummarySheet.show(context, session.id),
      divider: divider,
      leading: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
      ),
      title: Text(subject?.name ?? 'Subject'),
      subtitle: Text(_subtitle()),
      trailing: Text(
        SbFormat.minutes(session.focusedMinutes),
        style: context.text.titleMedium,
      ),
    );
  }

  String _subtitle() {
    final session = item.session;
    final parts = <String>[
      if (session.endedAt != null) SbFormat.relative(session.endedAt!),
    ];

    if (session.signalOrigin == SignalOrigin.wearableSyntheticTest) {
      parts.add('synthetic test');
    } else if (session.hsiWindowCount > 0) {
      parts.add('${session.hsiWindowCount} HSI windows');
    } else if (session.signalOrigin == SignalOrigin.unmeasured) {
      parts.add('unmeasured');
    }
    parts.add(switch (session.syncState) {
      SyncState.synced => 'synced',
      SyncState.pending || SyncState.syncing => 'sync pending',
      SyncState.failed => 'sync failed',
      SyncState.offlineQueued => 'queued offline',
      SyncState.rejected => 'sync rejected',
      SyncState.localOnly => 'on device',
    });
    if (session.status == SessionStatus.abandoned) {
      parts.add('ended early');
    }
    return parts.join(' · ');
  }
}

class _DaySheet extends ConsumerWidget {
  const _DaySheet({required this.day});

  final DateTime day;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          SbSpace.xl,
          SbSpace.lg,
          SbSpace.xl,
          SbSpace.xl,
        ),
        child: StreamBuilder<List<SessionListItem>>(
          stream: db.watchSessionItemsForDay(day),
          builder: (context, snapshot) {
            final sessions = snapshot.data ?? const <SessionListItem>[];
            final total = sessions.fold<int>(
              0,
              (sum, item) => sum + item.session.focusedMinutes,
            );

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 38,
                    height: 3,
                    decoration: BoxDecoration(
                      color: context.sb.line,
                      borderRadius: SbRadius.pillAll,
                    ),
                  ),
                ),
                const SizedBox(height: SbSpace.xl),
                Eyebrow('${day.day}/${day.month}/${day.year}'),
                const SizedBox(height: SbSpace.xs),
                Text(SbFormat.minutes(total), style: context.text.displaySmall),
                const SizedBox(height: SbSpace.lg),
                for (final (index, session) in sessions.indexed)
                  _SessionRow(
                    item: session,
                    divider: index != sessions.length - 1,
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SevenDayInsightView extends StatelessWidget {
  const _SevenDayInsightView({required this.insight});

  final SevenDayInsight? insight;

  @override
  Widget build(BuildContext context) {
    final value = insight;
    if (value == null || value.completedSessions == 0) {
      return Text(
        'Complete a focus session to begin your seven-day view.',
        style: context.text.bodyMedium,
      );
    }
    final axes = <String>[
      if (value.meanFocus != null) 'Focus ${(value.meanFocus! * 100).round()}',
      if (value.meanStress != null)
        'Stress ${(value.meanStress! * 100).round()}',
    ];
    final correlation = value.focusVsMinutesCorrelation;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${SbFormat.minutes(value.focusedMinutes)} across ${value.completedSessions} completed ${value.completedSessions == 1 ? 'session' : 'sessions'}.',
          style: context.text.bodyLarge,
        ),
        if (axes.isNotEmpty) ...[
          const SizedBox(height: SbSpace.xxs),
          Text(
            'On average: ${axes.join(' · ')} across '
            '${value.measuredSessions} measured '
            '${value.measuredSessions == 1 ? 'session' : 'sessions'}.',
            style: context.text.bodyMedium,
          ),
        ],
        const SizedBox(height: SbSpace.xxs),
        Text(
          correlation == null
              ? 'Patterns appear after seven varying, measured sessions.'
              : '${correlation >= 0 ? 'Higher' : 'Lower'} measured focus '
                    'tended to accompany longer focused time across '
                    '${value.measuredSessions} sessions.',
          style: context.text.bodyMedium?.copyWith(color: context.sb.muted),
        ),
      ],
    );
  }
}


class _FocusTrend extends StatelessWidget {
  const _FocusTrend({required this.sessions});

  final List<SessionListItem> sessions;

  @override
  Widget build(BuildContext context) {
    final values = sessions
        .where(
          (item) =>
              item.session.status == SessionStatus.completed &&
              item.session.signalOrigin != SignalOrigin.unmeasured &&
              item.session.hsiFocus != null,
        )
        .take(14)
        .map((item) => item.session.hsiFocus)
        .toList(growable: false)
        .reversed
        .toList(growable: false);
    if (values.length < 2) {
      return Text(
        'Shows once two measured sessions are complete.',
        style: context.text.bodyMedium?.copyWith(color: context.sb.muted),
      );
    }
    return SparkLine(values: values, height: 48);
  }
}
