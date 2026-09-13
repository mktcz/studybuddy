import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studybuddy/app/providers.dart';
import 'package:studybuddy/data/database.dart';
import 'package:studybuddy/domain/enums.dart';
import 'package:studybuddy/features/focus/focus_controller.dart';

import 'fake_biosignal_service.dart';

void main() {
  late AppDatabase db;
  late ProviderContainer container;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),


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

  Future<Subject> seedSubject() async {
    await db.upsertSubject(
      SubjectsCompanion.insert(
        id: 'subject-1',
        name: 'Organic Chemistry',
        accentIndex: const Value(2),
        createdAt: DateTime.now(),
      ),
    );
    return (await db.findSubject('subject-1'))!;
  }

  test('start records a running session and exposes it as active', () async {
    final subject = await seedSubject();
    final controller = container.read(focusControllerProvider.notifier);

    await controller.start(
      subject: subject,
      planned: const Duration(minutes: 25),
    );

    final state = container.read(focusControllerProvider);
    expect(state.isActive, isTrue);
    expect(state.subjectName, 'Organic Chemistry');
    expect(state.accentIndex, 2);
    expect(state.running, isTrue);

    final row = await db.findSession(state.sessionId!);
    expect(row, isNotNull);
    expect(row!.status, SessionStatus.running);
    expect(row.endedAt, isNull);
  });

  test('stop completes and marks the session finished', () async {
    final subject = await seedSubject();
    final controller = container.read(focusControllerProvider.notifier);

    await controller.start(
      subject: subject,
      planned: const Duration(minutes: 25),
    );
    final sessionId = container.read(focusControllerProvider).sessionId!;


    await controller.stop().timeout(
      const Duration(seconds: 10),
      onTimeout: () => fail('stop() did not complete within 10s'),
    );

    expect(container.read(focusControllerProvider).isActive, isFalse);

    final row = await db.findSession(sessionId);
    expect(row!.status, SessionStatus.completed);
    expect(row.endedAt, isNotNull);
  });

  test('a second start while one is running is ignored', () async {
    final subject = await seedSubject();
    final controller = container.read(focusControllerProvider.notifier);

    await controller.start(subject: subject);
    final first = container.read(focusControllerProvider).sessionId;

    await controller.start(subject: subject);
    expect(container.read(focusControllerProvider).sessionId, first);

    final all = await db.select(db.sessions).get();
    expect(all, hasLength(1));
  });

  test('pause and resume flip status without ending the session', () async {
    final subject = await seedSubject();
    final controller = container.read(focusControllerProvider.notifier);

    await controller.start(subject: subject);
    final sessionId = container.read(focusControllerProvider).sessionId!;

    await controller.togglePause();
    expect(container.read(focusControllerProvider).running, isFalse);
    expect((await db.findSession(sessionId))!.status, SessionStatus.paused);

    await controller.togglePause();
    expect(container.read(focusControllerProvider).running, isTrue);
    expect((await db.findSession(sessionId))!.status, SessionStatus.running);
  });

  test(
    'raw heart-rate trace is never persisted when the session ends',
    () async {
      final container2 = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          biosignalServiceFactoryProvider.overrideWithValue(
            FakeBiosignalService.new,
          ),
        ],
      );
      addTearDown(container2.dispose);

      final subject = await seedSubject();
      final controller = container2.read(focusControllerProvider.notifier);
      await controller.start(subject: subject);
      await controller.stop();

      final rawTables = await db
          .customSelect(
            "SELECT name FROM sqlite_master WHERE type = 'table' AND name = 'hr_samples'",
          )
          .get();
      expect(rawTables, isEmpty);
    },
  );

  test('active sessions remain available for process restoration', () async {
    final subject = await seedSubject();
    final controller = container.read(focusControllerProvider.notifier);
    await controller.start(subject: subject);
    final sessionId = container.read(focusControllerProvider).sessionId!;

    final row = await db.findSession(sessionId);
    expect(row!.status, SessionStatus.running);
    expect(row.endedAt, isNull);

    await controller.stop();
  });

  test('extend adds time, persists it, and survives the final clamp', () async {
    final subject = await seedSubject();
    final controller = container.read(focusControllerProvider.notifier);
    await controller.start(
      subject: subject,
      planned: const Duration(minutes: 25),
    );
    final sessionId = container.read(focusControllerProvider).sessionId!;

    await controller.extend(const Duration(minutes: 10));

    final state = container.read(focusControllerProvider);
    expect(state.planned, const Duration(minutes: 35));
    final row = await db.findSession(sessionId);
    expect(row!.plannedMinutes, 35);
    expect(row.plannedEndAt, isNotNull);

    await controller.stop();
  });

  test('extend after expiry is refused', () async {
    final subject = await seedSubject();
    await db.upsertSession(
      SessionsCompanion.insert(
        id: 'expired',
        subjectId: subject.id,
        startedAt: DateTime.now().subtract(const Duration(hours: 1)),
        plannedMinutes: const Value(25),
        status: SessionStatus.running,
        signalOrigin: SignalOrigin.unmeasured,
      ),
    );
    final controller = container.read(focusControllerProvider.notifier);
    container.read(focusControllerProvider);
    for (var i = 0; i < 10; i++) {
      if (container.read(focusControllerProvider).sessionId == 'expired') break;
      await Future<void>.delayed(Duration.zero);
    }

    await controller.extend(const Duration(minutes: 10));
    expect(
      container.read(focusControllerProvider).planned,
      const Duration(minutes: 25),
    );
    expect((await db.findSession('expired'))!.plannedMinutes, 25);
  });

  test('attachSource re-points the session at what is being read', () async {
    final subject = await seedSubject();
    await db.upsertSource(
      SourcesCompanion.insert(
        id: 'source-1',
        subjectId: subject.id,
        title: 'Chapter 4',
        filePath: '/tmp/chapter4.pdf',
        addedAt: DateTime.now(),
      ),
    );
    final controller = container.read(focusControllerProvider.notifier);
    await controller.start(subject: subject);
    final sessionId = container.read(focusControllerProvider).sessionId!;
    expect(container.read(focusControllerProvider).sourceId, isNull);

    await controller.attachSource('source-1');

    expect(container.read(focusControllerProvider).sourceId, 'source-1');
    expect((await db.findSession(sessionId))!.sourceId, 'source-1');

    await controller.stop();
  });

  test('an expired restored session waits at check-out', () async {
    final subject = await seedSubject();
    await db.upsertSession(
      SessionsCompanion.insert(
        id: 'expired',
        subjectId: subject.id,
        startedAt: DateTime.now().subtract(const Duration(hours: 1)),
        plannedMinutes: const Value(25),
        status: SessionStatus.running,
        signalOrigin: SignalOrigin.unmeasured,
      ),
    );

    container.read(focusControllerProvider);
    for (var i = 0; i < 10; i++) {
      if (container.read(focusControllerProvider).sessionId == 'expired') break;
      await Future<void>.delayed(Duration.zero);
    }

    final restored = container.read(focusControllerProvider);
    expect(restored.sessionId, 'expired');
    expect(restored.running, isFalse);
    expect(restored.expiredAt(DateTime.now()), isTrue);
    expect((await db.findSession('expired'))!.status, SessionStatus.paused);
  });
}
