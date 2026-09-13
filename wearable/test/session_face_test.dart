import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui/ui.dart';
import 'package:studybuddy_wear/wear_state.dart';
import 'package:studybuddy_wear/widgets/session_face.dart';


Future<void> pumpWatch(WidgetTester tester, Widget child) async {
  tester.view
    ..physicalSize = const Size(454, 454)
    ..devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      theme: studyTheme(brightness: Brightness.dark),
      home: child,
    ),
  );
}

WearState activeState({bool withHsi = true, int plannedSec = 3600}) {
  return WearState(
    phase: WearPhase.active,
    permissionGranted: true,
    heartRateSupported: true,
    active: true,
    capturePhase: 'focus',
    hsiAxes: withHsi
        ? const {
            'focus': HsiAxis(value: .72, confidence: .8),
            'capacity': HsiAxis(value: .64, confidence: .7),
          }
        : const {},
    quality: 'high',
    startedAt: DateTime.now().subtract(const Duration(minutes: 24)),
    plannedSeconds: plannedSec,
  );
}

void main() {
  group('SessionFace', () {
    testWidgets('shows elapsed, HSI and both controls', (tester) async {
      await pumpWatch(
        tester,
        SessionFace(
          state: activeState(),
          ambient: false,
          onStop: () async {},
          onTogglePause: () async {},
        ),
      );

      expect(find.text('FOCUS'), findsOneWidget);

      expect(find.byIcon(Icons.center_focus_strong_rounded), findsOneWidget);
      expect(find.text('72'), findsOneWidget);
      expect(find.byIcon(Icons.battery_full_rounded), findsOneWidget);
      expect(find.text('64'), findsOneWidget);
      expect(find.byIcon(Icons.pause_rounded), findsOneWidget);
      expect(find.byIcon(Icons.stop_rounded), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('waits for phone when HSI is unavailable', (tester) async {
      await pumpWatch(
        tester,
        SessionFace(
          state: activeState(withHsi: false),
          ambient: false,
          onStop: () async {},
          onTogglePause: () async {},
        ),
      );

      expect(find.text('Waiting for phone'), findsOneWidget);
    });

    testWidgets('stop invokes the callback once', (tester) async {
      var stops = 0;
      await pumpWatch(
        tester,
        SessionFace(
          state: activeState(),
          ambient: false,
          onStop: () async => stops++,
          onTogglePause: () async {},
        ),
      );

      await tester.tap(find.byIcon(Icons.stop_rounded));
      await tester.pump();
      expect(stops, 1);
    });

    testWidgets('ambient hides the controls', (tester) async {
      await pumpWatch(
        tester,
        SessionFace(
          state: activeState(),
          ambient: true,
          onStop: () async {},
          onTogglePause: () async {},
        ),
      );


      expect(find.byIcon(Icons.pause_rounded), findsNothing);
      expect(find.byIcon(Icons.stop_rounded), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('ambient drops the timer to minute precision', (tester) async {
      await pumpWatch(
        tester,
        SessionFace(
          state: activeState(),
          ambient: true,
          onStop: () async {},
          onTogglePause: () async {},
        ),
      );


      expect(find.text('24m'), findsOneWidget);
      expect(find.textContaining(':'), findsNothing);
    });

    testWidgets('lays out on a small round display without overflowing', (
      tester,
    ) async {
      tester.view
        ..physicalSize = const Size(384, 384)
        ..devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          theme: studyTheme(brightness: Brightness.dark),
          home: SessionFace(
            state: activeState(),
            ambient: false,
            onStop: () async {},
            onTogglePause: () async {},
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('an open-ended session simply shows no arc', (tester) async {
      await pumpWatch(
        tester,
        SessionFace(
          state: WearState(
            phase: WearPhase.active,
            permissionGranted: true,
            heartRateSupported: true,
            active: true,
            capturePhase: 'focus',
            startedAt: DateTime.now(),
          ),
          ambient: false,
          onStop: () async {},
          onTogglePause: () async {},
        ),
      );

      expect(find.byType(ProgressArc), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}
