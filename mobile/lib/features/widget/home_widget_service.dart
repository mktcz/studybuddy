import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'package:ui/ui.dart';

import '../../data/database.dart';


class HomeWidgetService {
  const HomeWidgetService();

  static const _androidName = 'StudyWidgetProvider';
  static const _qualifiedName = 'com.studybuddy.app.StudyWidgetProvider';


  static const _weeks = 26;


  Future<void> refresh({
    required Map<DateTime, int> minutesByDay,
    required List<SubjectSummary> subjects,
    required int todayMinutes,
    required int streak,
  }) async {
    try {
      await Future.wait([
        HomeWidget.saveWidgetData<String>(
          'today',
          SbFormat.minutes(todayMinutes),
        ),
        HomeWidget.saveWidgetData<String>('streak', '$streak'),
      ]);

      await _saveSubjects(subjects);
      await _renderGrid(minutesByDay);

      await HomeWidget.updateWidget(
        androidName: _androidName,
        qualifiedAndroidName: _qualifiedName,
      );
    } catch (error, stack) {

      debugPrint('Home widget refresh failed: $error\n$stack');
    }
  }

  Future<void> _saveSubjects(List<SubjectSummary> subjects) async {


    final top = subjects.take(3).toList();

    for (var i = 0; i < 3; i++) {
      final summary = i < top.length ? top[i] : null;
      await HomeWidget.saveWidgetData<String>(
        'subject_${i}_id',
        summary?.subject.id ?? '',
      );
      await HomeWidget.saveWidgetData<String>(
        'subject_${i}_name',
        summary?.subject.name ?? '',
      );
      await HomeWidget.saveWidgetData<String>(
        'subject_${i}_accent',
        summary == null
            ? ''
            : _hex(SbColors.light.subject(summary.subject.accentIndex)),
      );
    }
  }

  static String _hex(Color color) {
    final argb = color.toARGB32().toRadixString(16).padLeft(8, '0');
    return '#${argb.substring(2)}';
  }

  Future<void> _renderGrid(Map<DateTime, int> minutesByDay) async {
    final path = await HomeWidget.renderFlutterWidget(
      WidgetGrid(minutesByDay: minutesByDay, weeks: _weeks),
      key: 'grid',
      logicalSize: WidgetGrid.sizeFor(_weeks),
      pixelRatio: 3,
    );
    await HomeWidget.saveWidgetData<String>('grid', path);
  }
}


class WidgetGrid extends StatelessWidget {
  const WidgetGrid({
    super.key,
    required this.minutesByDay,
    required this.weeks,
    this.today,
  });


  static const cell = 8.0;
  static const gap = 2.0;
  static const padding = 6.0;


  static Size sizeFor(int weeks) => Size(
    weeks * cell + (weeks - 1) * gap + 2 * padding,
    7 * cell + 6 * gap + 2 * padding,
  );

  final Map<DateTime, int> minutesByDay;
  final int weeks;


  final DateTime? today;

  @override
  Widget build(BuildContext context) {
    final size = sizeFor(weeks);

    return MediaQuery(
      data: const MediaQueryData(),
      child: Theme(
        data: studyTheme(),
        child: SizedBox(
          width: size.width,
          height: size.height,
          child: ColoredBox(
            color: SbPalette.canvas,
            child: Padding(
              padding: const EdgeInsets.all(padding),
              child: ActivityGrid(
                minutesByDay: minutesByDay,
                weeks: weeks,
                today: today,
                gap: gap,
                showTooltips: false,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
