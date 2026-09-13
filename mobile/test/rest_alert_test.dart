import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studybuddy/app/providers.dart';
import 'package:studybuddy/data/database.dart';
import 'package:studybuddy/domain/enums.dart';
import 'package:studybuddy/domain/session_nudges.dart';
import 'package:studybuddy/domain/study_logic.dart';
import 'package:studybuddy/features/focus/focus_controller.dart';
import 'package:studybuddy/features/state/hsi_engine.dart';
import 'package:studybuddy/features/state/hsi_providers.dart';
import 'package:studybuddy/features/state/rest_alert_host.dart';

import 'fake_biosignal_service.dart';

class _Gateway implements HumanStateGateway {
  final statesController = StreamController<StateSample>.broadcast();

  @override
  Stream<StateSample> get states => statesController.stream;

  @override
  Stream<HsiStatus> get statuses => const Stream.empty();

  @override
  StateSample? get latest => null;

  @override
  HsiStatus get status => const HsiStatus(phase: HsiPhase.ready);

  @override
  bool get ready => true;

  @override
  bool get consented => true;

  @override
  Future<IntegrationHealth> initialize() async => health();

  @override
  Future<IntegrationHealth> health() async =>
      const IntegrationHealth(phase: HsiPhase.ready);

  @override
  Future<String?> setConsent(StudyConsentChoice choice) async => null;

  @override
  Future<String?> startCoreSession(Duration planned) async => 'core-1';

  @override
  Future<CoreCaptureResult> stopCoreSession() async =>
      const CoreCaptureResult();

  @override
  void pushHeartRate(
    DateTime at,
    double bpm, {
    SignalOrigin origin = SignalOrigin.wearableReal,
  }) {}

  @override
  void pushRr(
    DateTime at,
    double rrIntervalMs, {
    SignalOrigin origin = SignalOrigin.wearableReal,
  }) {}

  @override
  Future<IngestionSnapshot> ingestionStatus() async =>
      const IngestionSnapshot();

  @override
  Future<IngestionSnapshot> flushIngestion() async => const IngestionSnapshot();

  @override
  void recordStudyMetric(
    String name,
    DateTime at, {
    double? value,
    Map<String, String> tags = const {},
  }) {}

  @override
  Future<String?> generateTakeaway(String prompt) async => null;

  @override
  String sanitizedDiagnostics() => '{}';

  @override
  Future<void> wipeLocalData() async {}

  @override
  Future<void> dispose() async => statesController.close();
}

StateSample _window(int minute, {double stress = .8, double? arousal}) {
  return StateSample(
    at: DateTime(2026, 9, 3, 9).add(Duration(minutes: minute)),
    origin: SignalOrigin.wearableReal,
    stress: stress,
    arousal: arousal,
    stressConfidence: .9,
    arousalConfidence: arousal == null ? null : .9,
  );
}

void main() {
  late AppDatabase db;
  late _Gateway gateway;
  late ProviderContainer container;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    gateway = _Gateway();
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        hsiEngineProvider.overrideWithValue(gateway),
        biosignalServiceFactoryProvider.overrideWithValue(
          FakeBiosignalService.new,
        ),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  Future<void> startFocus() async {
    await db.upsertSubject(
      SubjectsCompanion.insert(
        id: 'subject-1',
        name: 'History',
        accentIndex: const Value(1),
        createdAt: DateTime.now(),
      ),
    );
    final subject = (await db.findSubject('subject-1'))!;
    await container
        .read(focusControllerProvider.notifier)
        .start(subject: subject, planned: const Duration(minutes: 25));
  }

  test('two abnormal windows surface a rest alert', () {
    container.read(restAlertControllerProvider);
    final rest = container.read(restAlertControllerProvider.notifier);
    final first = _window(1);
    final second = _window(2);
    rest.ingest(first, now: first.at);
    rest.ingest(second, now: second.at);
    expect(
      container.read(restAlertControllerProvider)?.kind,
      RestAlertKind.highStress,
    );
  });

  test('dismiss clears the pending alert', () {
    container.read(restAlertControllerProvider);
    final rest = container.read(restAlertControllerProvider.notifier);
    final first = _window(1);
    final second = _window(2);
    rest.ingest(first, now: first.at);
    rest.ingest(second, now: second.at);
    rest.dismiss();
    expect(container.read(restAlertControllerProvider), isNull);
  });

  test('take a break pauses an active focus session', () async {
    await startFocus();
    expect(container.read(focusControllerProvider).running, isTrue);
    container.read(restAlertControllerProvider);
    final rest = container.read(restAlertControllerProvider.notifier);
    final first = _window(1);
    final second = _window(2);
    rest.ingest(first, now: first.at);
    rest.ingest(second, now: second.at);
    await rest.takeBreak();
    expect(container.read(focusControllerProvider).running, isFalse);
    expect(container.read(restAlertControllerProvider), isNull);
  });

  test('take a break does not resume a paused session', () async {
    await startFocus();
    await container.read(focusControllerProvider.notifier).togglePause();
    expect(container.read(focusControllerProvider).isActive, isTrue);
    expect(container.read(focusControllerProvider).running, isFalse);
    container.read(restAlertControllerProvider);
    final rest = container.read(restAlertControllerProvider.notifier);
    final first = _window(1);
    final second = _window(2);
    rest.ingest(first, now: first.at);
    rest.ingest(second, now: second.at);
    await rest.takeBreak();
    expect(container.read(focusControllerProvider).running, isFalse);
  });

  test('suppression holds hide the warning surface', () {
    final suppression = container.read(restAlertSuppressionProvider.notifier);
    expect(container.read(restAlertSuppressionProvider), 0);
    suppression.acquire();
    expect(container.read(restAlertSuppressionProvider), 1);
    suppression.release();
    expect(container.read(restAlertSuppressionProvider), 0);
  });

  test('suppression skips ingest and does not present later', () {
    container.read(restAlertControllerProvider);
    final rest = container.read(restAlertControllerProvider.notifier);
    container.read(restAlertSuppressionProvider.notifier).acquire();
    final first = _window(1);
    final second = _window(2);
    rest.ingest(first, now: first.at);
    rest.ingest(second, now: second.at);
    expect(container.read(restAlertControllerProvider), isNull);
    container.read(restAlertSuppressionProvider.notifier).release();
    expect(container.read(restAlertControllerProvider), isNull);
    final third = _window(3);
    final fourth = _window(4);
    rest.ingest(third, now: third.at);
    rest.ingest(fourth, now: fourth.at);
    expect(
      container.read(restAlertControllerProvider)?.kind,
      RestAlertKind.highStress,
    );
  });

  testWidgets('dialog offers Take a break and Dismiss', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          hsiEngineProvider.overrideWithValue(gateway),
          biosignalServiceFactoryProvider.overrideWithValue(
            FakeBiosignalService.new,
          ),
        ],
        child: const MaterialApp(
          home: RestAlertHost(child: Scaffold(body: Text('shell'))),
        ),
      ),
    );
    final scope = ProviderScope.containerOf(tester.element(find.text('shell')));
    final first = _window(1);
    final second = _window(2);
    scope
        .read(restAlertControllerProvider.notifier)
        .ingest(first, now: first.at);
    scope
        .read(restAlertControllerProvider.notifier)
        .ingest(second, now: second.at);
    await tester.pump();
    await tester.pump();
    expect(find.text(NudgeEngine.restCopy), findsOneWidget);
    expect(find.text(NudgeEngine.restDisclaimer), findsOneWidget);
    expect(find.text('Take a break'), findsOneWidget);
    expect(find.text('Dismiss'), findsOneWidget);
    await tester.tap(find.text('Dismiss'));
    await tester.pumpAndSettle();
    expect(find.text(NudgeEngine.restCopy), findsNothing);
  });
}
