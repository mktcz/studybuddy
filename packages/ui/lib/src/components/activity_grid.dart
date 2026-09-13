import 'package:flutter/material.dart';

import '../theme/study_theme.dart';
import '../tokens/spacing.dart';


int sbActivityLevel(int focusedMinutes) {
  if (focusedMinutes <= 0) return 0;
  if (focusedMinutes < 25) return 1;
  if (focusedMinutes < 50) return 2;
  if (focusedMinutes < 90) return 3;
  return 4;
}


class ActivityGrid extends StatelessWidget {
  const ActivityGrid({
    super.key,
    required this.minutesByDay,
    this.weeks = SbSize.activityWeeks,
    this.today,
    this.onDayTap,
    this.gap = SbSize.activityGap,
    this.levelOf = sbActivityLevel,
    this.showTooltips = true,
  });


  final Map<DateTime, int> minutesByDay;


  final int weeks;


  final DateTime? today;

  final void Function(DateTime day, int minutes)? onDayTap;
  final double gap;
  final int Function(int minutes) levelOf;


  final bool showTooltips;

  @override
  Widget build(BuildContext context) {
    final sb = context.sb;
    final anchor = DateUtils.dateOnly(today ?? DateTime.now());


    final end = anchor.add(Duration(days: 7 - anchor.weekday));
    final start = end.subtract(Duration(days: weeks * 7 - 1));

    return LayoutBuilder(
      builder: (context, constraints) {
        final cell = (constraints.maxWidth - gap * (weeks - 1)) / weeks;
        if (!cell.isFinite || cell <= 0) return const SizedBox.shrink();

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(weeks, (week) {
            return Padding(
              padding: EdgeInsets.only(right: week == weeks - 1 ? 0 : gap),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(7, (day) {
                  final date = start.add(Duration(days: week * 7 + day));
                  final minutes = minutesByDay[date] ?? 0;
                  final future = date.isAfter(anchor);

                  return Padding(
                    padding: EdgeInsets.only(bottom: day == 6 ? 0 : gap),
                    child: _Cell(
                      size: cell,


                      color: future
                          ? sb.activity[0].withValues(alpha: .4)
                          : sb.activityLevel(levelOf(minutes)),
                      date: date,
                      minutes: minutes,
                      onTap: (future || minutes == 0 || onDayTap == null)
                          ? null
                          : () => onDayTap!(date, minutes),
                      showTooltip: showTooltips && !future,
                    ),
                  );
                }),
              ),
            );
          }),
        );
      },
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({
    required this.size,
    required this.color,
    required this.date,
    required this.minutes,
    required this.onTap,
    required this.showTooltip,
  });

  final double size;
  final Color color;
  final DateTime date;
  final int minutes;
  final VoidCallback? onTap;
  final bool showTooltip;

  @override
  Widget build(BuildContext context) {
    Widget cell = SizedBox(
      width: size,
      height: size,
      child: ColoredBox(color: color),
    );

    if (onTap != null) {
      cell = GestureDetector(onTap: onTap, child: cell);
    }

    if (showTooltip) {
      cell = Tooltip(
        message: '${_formatDay(date)} · $minutes min',
        child: cell,
      );
    }

    return Semantics(
      label: '${_formatDay(date)}, $minutes minutes focused',
      button: onTap != null,
      child: cell,
    );
  }

  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];


  static String _formatDay(DateTime d) => '${_months[d.month - 1]} ${d.day}';
}
