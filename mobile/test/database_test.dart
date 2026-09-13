import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;
import 'package:studybuddy/data/database.dart';
import 'package:studybuddy/domain/enums.dart';
import 'package:studybuddy/domain/study_logic.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  Future<void> seedSubject([String id = 's1']) => db.upsertSubject(
    SubjectsCompanion.insert(
      id: id,
      name: 'Organic Chemistry',
      createdAt: DateTime(2026, 1, 1),
    ),
  );

  Future<void> seedSession({
    required String id,
    required DateTime endedAt,
    int minutes = 30,
    String subjectId = 's1',
    SessionStatus status = SessionStatus.completed,
  }) {
    return db.upsertSession(
      SessionsCompanion.insert(
        id: id,
        subjectId: subjectId,
        startedAt: endedAt.subtract(Duration(minutes: minutes)),
        endedAt: Value(endedAt),
        focusedMinutes: Value(minutes),
        status: status,
        signalOrigin: SignalOrigin.unmeasured,
      ),
    );
  }

  group('watchMinutesByDay', () {
    test('keys a session under its local calendar date', () async {
      await seedSubject();

      final endedAt = DateTime.now().subtract(const Duration(hours: 1));
      await seedSession(id: 'a', endedAt: endedAt, minutes: 42);

      final byDay = await db.watchMinutesByDay().first;
      final today = DateTime(endedAt.year, endedAt.month, endedAt.day);

      expect(
        byDay[today],
        42,
        reason: 'byDay keys were ${byDay.keys.toList()}',
      );
    });

    test('sums several sessions on the same day', () async {
      await seedSubject();
      final now = DateTime.now().subtract(const Duration(hours: 2));
      await seedSession(id: 'a', endedAt: now, minutes: 20);
      await seedSession(id: 'b', endedAt: now, minutes: 25);

      final byDay = await db.watchMinutesByDay().first;
      expect(byDay[DateTime(now.year, now.month, now.day)], 45);
    });

    test('separates different days', () async {
      await seedSubject();
      final now = DateTime.now().subtract(const Duration(hours: 2));
      final yesterday = now.subtract(const Duration(days: 1));
      await seedSession(id: 'a', endedAt: now, minutes: 20);
      await seedSession(id: 'b', endedAt: yesterday, minutes: 35);

      final byDay = await db.watchMinutesByDay().first;
      expect(byDay[DateTime(now.year, now.month, now.day)], 20);
      expect(
        byDay[DateTime(yesterday.year, yesterday.month, yesterday.day)],
        35,
      );
    });

    test('ignores sessions that never ended', () async {
      await seedSubject();
      await db.upsertSession(
        SessionsCompanion.insert(
          id: 'running',
          subjectId: 's1',
          startedAt: DateTime.now(),
          status: SessionStatus.running,
          signalOrigin: SignalOrigin.unmeasured,
        ),
      );

      expect(await db.watchMinutesByDay().first, isEmpty);
    });

    test('feeds todayMinutes and streak correctly', () async {
      await seedSubject();
      final now = DateTime.now().subtract(const Duration(hours: 1));
      await seedSession(id: 'a', endedAt: now, minutes: 42);
      await seedSession(
        id: 'b',
        endedAt: now.subtract(const Duration(days: 1)),
        minutes: 10,
      );

      final byDay = await db.watchMinutesByDay().first;
      final today = DateTime(now.year, now.month, now.day);

      expect(byDay[today] ?? 0, 42);
      expect(streakDays(byDay, today: today), 2);
    });
  });

  test('partially expanded v2 database migrates without losing data', () async {
    await db.close();
    final raw = sqlite.sqlite3.openInMemory();
    final creator = AppDatabase(
      NativeDatabase.opened(raw, closeUnderlyingOnClose: false),
    );
    await creator.upsertSubject(
      SubjectsCompanion.insert(
        id: 'kept',
        name: 'Existing subject',
        createdAt: DateTime(2026, 1, 1),
      ),
    );
    await creator.close();


    raw.execute('PRAGMA user_version = 2');
    raw.execute('ALTER TABLE sessions ADD COLUMN mean_hr REAL');
    raw.execute(
      'CREATE TABLE hr_samples (row_id INTEGER PRIMARY KEY, session_id TEXT NOT NULL, at INTEGER NOT NULL, bpm INTEGER NOT NULL)',
    );
    for (final name in [
      'hsi_focus_confidence',
      'hsi_capacity_confidence',
      'hsi_arousal_confidence',
      'hsi_stress_confidence',
    ]) {
      raw.execute('ALTER TABLE sessions DROP COLUMN $name');
    }

    final migrated = AppDatabase(NativeDatabase.opened(raw));
    addTearDown(migrated.close);
    expect((await migrated.findSubject('kept'))?.name, 'Existing subject');
    final columns = await migrated
        .customSelect('PRAGMA table_info(sessions)')
        .get();
    expect(
      columns.map((row) => row.read<String>('name')),
      containsAll([
        'hsi_focus_confidence',
        'hsi_capacity_confidence',
        'hsi_arousal_confidence',
        'hsi_stress_confidence',
      ]),
    );
    expect(
      (await migrated.customSelect('PRAGMA user_version').getSingle())
          .read<int>('user_version'),
      7,
    );
    Future<bool> tableExists(String name) async =>
        (await migrated
                .customSelect(
                  "SELECT 1 FROM sqlite_master WHERE type = 'table' AND name = '$name'",
                )
                .get())
            .isNotEmpty;
    expect(await tableExists('hr_samples'), isFalse);

    expect(await tableExists('conversations'), isFalse);
    expect(await tableExists('chat_messages'), isFalse);
    expect(await tableExists('check_ins'), isFalse);
    expect(await tableExists('page_events'), isTrue);
  });

  test('only one focus session can remain active', () async {
    await seedSubject();
    Future<void> insertActive(String id) => db.upsertSession(
      SessionsCompanion.insert(
        id: id,
        subjectId: 's1',
        startedAt: DateTime.now(),
        status: SessionStatus.running,
        signalOrigin: SignalOrigin.unmeasured,
      ),
    );

    await insertActive('first');
    await expectLater(insertActive('second'), throwsA(isA<Exception>()));
    expect((await db.findActiveSession())?.id, 'first');
  });

  group('watchSubjectSummaries', () {
    test('aggregates sources and focused minutes per subject', () async {
      await seedSubject();
      await db.upsertSource(
        SourcesCompanion.insert(
          id: 'src1',
          subjectId: 's1',
          title: 'Chapter 4',
          filePath: '/tmp/a.pdf',
          addedAt: DateTime.now(),
        ),
      );
      await seedSession(id: 'a', endedAt: DateTime.now(), minutes: 30);

      final summaries = await db.watchSubjectSummaries().first;
      expect(summaries, hasLength(1));
      expect(summaries.single.sourceCount, 1);
      expect(summaries.single.focusedMinutes, 30);
      expect(summaries.single.lastStudiedAt, isNotNull);
    });

    test('hides archived subjects but keeps their sessions', () async {
      await seedSubject();
      await seedSession(id: 'a', endedAt: DateTime.now(), minutes: 30);
      await db.archiveSubject('s1');

      expect(await db.watchSubjectSummaries().first, isEmpty);
      expect(await db.watchMinutesByDay().first, isNotEmpty);
    });
  });

  group('partial writes', () {
    test('updateSession changes only the fields given', () async {
      await seedSubject();
      await seedSession(id: 'a', endedAt: DateTime.now(), minutes: 30);


      await db.updateSession(
        'a',
        const SessionsCompanion(status: Value(SessionStatus.abandoned)),
      );

      final row = await db.findSession('a');
      expect(row!.status, SessionStatus.abandoned);
      expect(row.subjectId, 's1');
      expect(row.focusedMinutes, 30);
    });

    test('updateSubject renames without needing createdAt', () async {
      await seedSubject();
      await db.updateSubject(
        's1',
        const SubjectsCompanion(name: Value('Physics')),
      );

      final row = await db.findSubject('s1');
      expect(row!.name, 'Physics');
      expect(row.createdAt, DateTime(2026, 1, 1));
    });
  });

  group('wearable aggregates', () {
    test(
      'capture summary updates the same phase instead of duplicating',
      () async {
        await seedSubject();
        await seedSession(id: 'a', endedAt: DateTime.now());
        final now = DateTime.now();
        CaptureSummariesCompanion value(int samples) =>
            CaptureSummariesCompanion.insert(
              sessionId: 'a',
              phase: CapturePhase.focus,
              signalOrigin: SignalOrigin.wearableReal,
              acceptedSamples: Value(samples),
              createdAt: now,
            );

        await db.saveCaptureSummary(value(12));
        await db.saveCaptureSummary(value(42));

        final rows = await db.captureSummariesFor('a');
        expect(rows, hasLength(1));
        expect(rows.single.acceptedSamples, 42);
      },
    );

    test('HSI windows retain wearable provenance and no raw trace', () async {
      await seedSubject();
      await seedSession(id: 'a', endedAt: DateTime.now());
      await db.insertHsiWindow(
        'a',
        StateSample(
          at: DateTime(2026, 8, 20),
          origin: SignalOrigin.wearableReal,
          focus: .7,
          focusConfidence: .8,
        ),
      );

      final rows = await db.hsiWindowsFor('a');
      expect(rows.single.signalOrigin, SignalOrigin.wearableReal);
      final rawTables = await db
          .customSelect(
            "SELECT name FROM sqlite_master WHERE type = 'table' AND name = 'hr_samples'",
          )
          .get();
      expect(rawTables, isEmpty);
    });
  });

  group('cascades', () {
    test('deleting a subject removes its sources and sessions', () async {
      await seedSubject();
      await db.upsertSource(
        SourcesCompanion.insert(
          id: 'src1',
          subjectId: 's1',
          title: 'Chapter 4',
          filePath: '/tmp/a.pdf',
          addedAt: DateTime.now(),
        ),
      );
      await seedSession(id: 'a', endedAt: DateTime.now());

      await db.deleteSubject('s1');

      expect(await db.select(db.sources).get(), isEmpty);
      expect(await db.select(db.sessions).get(), isEmpty);
    });
  });
}
