import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studybuddy/features/widget/home_widget_service.dart';


Future<void> pumpAsHomeWidget(WidgetTester tester, Widget widget) {
  return tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [widget],
      ),
    ),
  );
}

void main() {
  final today = DateTime(2026, 8, 19);

  group('WidgetGrid', () {
    testWidgets('renders detached, with no MaterialApp or Scaffold above it', (
      tester,
    ) async {
      await pumpAsHomeWidget(
        tester,
        WidgetGrid(
          today: today,
          weeks: 7,
          minutesByDay: {
            for (var i = 0; i < 40; i++)
              today.subtract(Duration(days: i)): i * 4,
          },
        ),
      );


      expect(tester.takeException(), isNull);
      expect(find.byType(WidgetGrid), findsOneWidget);
    });

    testWidgets('takes a bounded size rather than filling the column', (
      tester,
    ) async {
      await pumpAsHomeWidget(
        tester,
        WidgetGrid(today: today, weeks: 7, minutesByDay: const {}),
      );

      final size = tester.getSize(find.byType(WidgetGrid));
      expect(size.width, lessThan(400));
      expect(size.height, lessThan(400));
      expect(size.width, greaterThan(0));
      expect(size.height, greaterThan(0));
    });

    testWidgets('renders an empty history without complaint', (tester) async {
      await pumpAsHomeWidget(
        tester,
        WidgetGrid(today: today, weeks: 7, minutesByDay: const {}),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('the grid fits its box exactly at every week count', (
      tester,
    ) async {


      for (final weeks in [5, 6, 7, 8]) {
        await pumpAsHomeWidget(
          tester,
          WidgetGrid(today: today, weeks: weeks, minutesByDay: const {}),
        );
        expect(
          tester.takeException(),
          isNull,
          reason: '$weeks weeks overflowed',
        );
      }
    });
  });
}
