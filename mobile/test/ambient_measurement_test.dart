import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studybuddy/app/providers.dart';
import 'package:studybuddy/domain/enums.dart';
import 'package:studybuddy/domain/study_logic.dart';
import 'package:studybuddy/features/state/ambient_measurement.dart';
import 'package:studybuddy/features/state/hsi_engine.dart';
import 'package:studybuddy/features/state/hsi_providers.dart';

import 'fake_biosignal_service.dart';

class _ReadyGateway implements HumanStateGateway {
  int sessions = 0;

  @override
  Stream<StateSample> get states => const Stream.empty();

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
  Future<String?> startCoreSession(Duration planned) async {
    sessions += 1;
    return 'core-$sessions';
  }

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
  Future<void> dispose() async {}
}

void main() {
  test('exclusive hold stops ambient and makes start a no-op', () async {
    final gateway = _ReadyGateway();
    late FakeBiosignalService bio;
    final container = ProviderContainer(
      overrides: [
        hsiEngineProvider.overrideWithValue(gateway),
        biosignalServiceFactoryProvider.overrideWithValue(() {
          bio = FakeBiosignalService();
          return bio;
        }),
      ],
    );
    addTearDown(container.dispose);

    final ambient = container.read(ambientMeasurementProvider);
    await ambient.start();
    await Future<void>.delayed(Duration.zero);
    expect(ambient.active, isTrue);
    expect(bio.started, isTrue);
    expect(gateway.sessions, 1);

    await ambient.acquireExclusive();
    await Future<void>.delayed(Duration.zero);
    expect(ambient.exclusiveHold, isTrue);
    expect(ambient.active, isFalse);

    await ambient.start();
    await Future<void>.delayed(Duration.zero);
    expect(ambient.active, isFalse);
    expect(gateway.sessions, 1);

    await ambient.releaseExclusive();
    expect(ambient.exclusiveHold, isFalse);
  });
}
