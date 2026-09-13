import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui/ui.dart';

Widget host(Widget child, {Size size = const Size(220, 163)}) {
  return MaterialApp(
    theme: studyTheme(),
    home: Scaffold(
      body: Center(
        child: SizedBox(width: size.width, height: size.height, child: child),
      ),
    ),
  );
}

void main() {
  group('SubjectCard', () {


    testWidgets('does not overflow with a long two-line name', (tester) async {
      await tester.pumpWidget(
        host(
          const SubjectCard(
            name: 'Organic Chemistry and Reaction Mechanisms',
            accent: Colors.green,
            sourceCount: 12,
            focusedLabel: '14h 32m',
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('does not overflow at a narrow cell width', (tester) async {
      await tester.pumpWidget(
        host(
          const SubjectCard(
            name: 'Thermodynamics',
            accent: Colors.green,
            sourceCount: 1,
            focusedLabel: '2m',
            active: true,
          ),
          size: const Size(150, 111),
        ),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('says "source" in the singular', (tester) async {
      await tester.pumpWidget(
        host(
          const SubjectCard(
            name: 'Physics',
            accent: Colors.green,
            sourceCount: 1,
            focusedLabel: '5m',
          ),
        ),
      );
      expect(find.text('1 source · 5m'), findsOneWidget);
    });
  });

  group('FocusBar', () {
    testWidgets('fits its declared height and shows an unmeasured state', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          const FocusBar(
            subjectName: 'A subject with a rather long name indeed',
            elapsed: Duration(minutes: 24, seconds: 13),
            running: true,
          ),
          size: const Size(360, 80),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.text('24:13'), findsOneWidget);

      expect(find.text('0'), findsNothing);
    });
  });

  group('ActivityGrid', () {
    testWidgets('lays out without overflowing a narrow container', (
      tester,
    ) async {
      final today = DateTime(2026, 8, 19);
      await tester.pumpWidget(
        host(
          ActivityGrid(
            today: today,
            showTooltips: false,
            minutesByDay: {
              for (var i = 0; i < 40; i++)
                today.subtract(Duration(days: i)): i * 3,
            },
          ),
          size: const Size(300, 200),
        ),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('survives a zero-width parent', (tester) async {
      await tester.pumpWidget(
        host(
          ActivityGrid(minutesByDay: const {}, today: DateTime(2026, 8, 19)),
          size: const Size(0, 200),
        ),
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('theme', () {
    test('light and dark both register the colour extension', () {
      for (final brightness in Brightness.values) {
        final theme = studyTheme(brightness: brightness);
        final colors = theme.extension<SbColors>();
        expect(colors, isNotNull, reason: '$brightness is missing SbColors');
        expect(colors!.subjects, hasLength(8));
        expect(colors.activity, hasLength(5));
      }
    });

    test('dark theme overrides onSurfaceVariant rather than inheriting it', () {


      final theme = studyTheme(brightness: Brightness.dark);
      expect(
        theme.colorScheme.onSurfaceVariant,
        theme.extension<SbColors>()!.muted,
      );
    });
  });
}
