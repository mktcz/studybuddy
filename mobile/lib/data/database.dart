import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../domain/enums.dart';
import '../domain/study_logic.dart';

part 'database.g.dart';


class Subjects extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 120)();


  IntColumn get accentIndex => integer().withDefault(const Constant(0))();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get archivedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}


class Sources extends Table {
  TextColumn get id => text()();
  TextColumn get subjectId =>
      text().references(Subjects, #id, onDelete: KeyAction.cascade)();
  TextColumn get title => text().withLength(min: 1, max: 300)();


  TextColumn get filePath => text()();

  IntColumn get bytes => integer().withDefault(const Constant(0))();
  IntColumn get pageCount => integer().nullable()();


  IntColumn get lastPage => integer().nullable()();

  DateTimeColumn get addedAt => dateTime()();
  DateTimeColumn get lastOpenedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}


class Sessions extends Table {
  TextColumn get id => text()();
  TextColumn get subjectId =>
      text().references(Subjects, #id, onDelete: KeyAction.cascade)();


  TextColumn get sourceId =>
      text().nullable().references(Sources, #id, onDelete: KeyAction.setNull)();

  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get canonicalStartedAt => dateTime().nullable()();
  DateTimeColumn get plannedEndAt => dateTime().nullable()();
  DateTimeColumn get endedAt => dateTime().nullable()();

  IntColumn get plannedMinutes => integer().withDefault(const Constant(25))();


  IntColumn get focusedMinutes => integer().withDefault(const Constant(0))();


  IntColumn get pausedSeconds => integer().withDefault(const Constant(0))();
  DateTimeColumn get pauseStartedAt => dateTime().nullable()();

  IntColumn get status => intEnum<SessionStatus>()();
  IntColumn get signalOrigin => intEnum<SignalOrigin>()();


  RealColumn get hsiFocus => real().nullable()();
  RealColumn get hsiFocusConfidence => real().nullable()();
  RealColumn get hsiCapacity => real().nullable()();
  RealColumn get hsiCapacityConfidence => real().nullable()();
  RealColumn get hsiArousal => real().nullable()();
  RealColumn get hsiArousalConfidence => real().nullable()();
  RealColumn get hsiStress => real().nullable()();
  RealColumn get hsiStressConfidence => real().nullable()();
  RealColumn get hsiQuality => real().nullable()();


  TextColumn get synheartSessionId => text().nullable()();
  TextColumn get watchSessionId => text().nullable()();
  IntColumn get acceptedSamples => integer().withDefault(const Constant(0))();
  IntColumn get totalSamples => integer().withDefault(const Constant(0))();
  IntColumn get coverageSeconds => integer().withDefault(const Constant(0))();
  IntColumn get accuracyHigh => integer().withDefault(const Constant(0))();
  IntColumn get accuracyMedium => integer().withDefault(const Constant(0))();
  IntColumn get accuracyLow => integer().withDefault(const Constant(0))();
  IntColumn get hsiWindowCount => integer().withDefault(const Constant(0))();
  IntColumn get syncState =>
      intEnum<SyncState>().withDefault(Constant(SyncState.localOnly.index))();
  IntColumn get uploadedCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get uploadAttemptedAt => dateTime().nullable()();
  TextColumn get syncError => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}


class HsiWindows extends Table {
  IntColumn get rowId => integer().autoIncrement()();
  TextColumn get sessionId =>
      text().references(Sessions, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get at => dateTime()();
  IntColumn get signalOrigin => intEnum<SignalOrigin>().withDefault(
    Constant(SignalOrigin.unmeasured.index),
  )();
  TextColumn get hsiVersion => text().nullable()();
  RealColumn get focus => real().nullable()();
  RealColumn get focusConfidence => real().nullable()();
  RealColumn get capacity => real().nullable()();
  RealColumn get capacityConfidence => real().nullable()();
  RealColumn get arousal => real().nullable()();
  RealColumn get arousalConfidence => real().nullable()();
  RealColumn get stress => real().nullable()();
  RealColumn get stressConfidence => real().nullable()();
  RealColumn get quality => real().nullable()();
}


class CaptureSummaries extends Table {
  IntColumn get rowId => integer().autoIncrement()();
  TextColumn get sessionId =>
      text().references(Sessions, #id, onDelete: KeyAction.cascade)();
  IntColumn get phase => intEnum<CapturePhase>()();
  IntColumn get signalOrigin => intEnum<SignalOrigin>()();
  TextColumn get watchSessionId => text().nullable()();
  TextColumn get coreSessionId => text().nullable()();
  IntColumn get acceptedSamples => integer().withDefault(const Constant(0))();
  IntColumn get totalSamples => integer().withDefault(const Constant(0))();
  IntColumn get coverageSeconds => integer().withDefault(const Constant(0))();
  IntColumn get accuracyHigh => integer().withDefault(const Constant(0))();
  IntColumn get accuracyMedium => integer().withDefault(const Constant(0))();
  IntColumn get accuracyLow => integer().withDefault(const Constant(0))();
  IntColumn get hsiWindowCount => integer().withDefault(const Constant(0))();
  RealColumn get hsiFocus => real().nullable()();
  RealColumn get hsiFocusConfidence => real().nullable()();
  RealColumn get hsiCapacity => real().nullable()();
  RealColumn get hsiCapacityConfidence => real().nullable()();
  RealColumn get hsiArousal => real().nullable()();
  RealColumn get hsiArousalConfidence => real().nullable()();
  RealColumn get hsiStress => real().nullable()();
  RealColumn get hsiStressConfidence => real().nullable()();
  RealColumn get quality => real().nullable()();
  TextColumn get diagnosticError => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
}

class Profiles extends Table {
  IntColumn get id => integer()();
  TextColumn get nickname => text().withDefault(const Constant(''))();
  BoolColumn get setupComplete =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get wearableConsent =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get cloudConsent => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}


class PageEvents extends Table {
  IntColumn get rowId => integer().autoIncrement()();
  TextColumn get sessionId =>
      text().references(Sessions, #id, onDelete: KeyAction.cascade)();
  TextColumn get sourceId =>
      text().references(Sources, #id, onDelete: KeyAction.cascade)();


  IntColumn get page => integer()();

  DateTimeColumn get at => dateTime()();
}


class SubjectSummary {
  const SubjectSummary({
    required this.subject,
    required this.sourceCount,
    required this.focusedMinutes,
    required this.lastStudiedAt,
  });

  final Subject subject;
  final int sourceCount;
  final int focusedMinutes;
  final DateTime? lastStudiedAt;
}

class SessionListItem {
  const SessionListItem({required this.session, this.subject});

  final Session session;
  final Subject? subject;
}


class SevenDayInsight {
  const SevenDayInsight({
    required this.focusedMinutes,
    required this.completedSessions,
    required this.measuredSessions,
    this.meanFocus,
    this.meanStress,
    this.focusVsMinutesCorrelation,
  });

  final int focusedMinutes;
  final int completedSessions;


  final int measuredSessions;


  final double? meanFocus;
  final double? meanStress;


  final double? focusVsMinutesCorrelation;
}

@DriftDatabase(
  tables: [
    Subjects,
    Sources,
    Sessions,
    HsiWindows,
    CaptureSummaries,
    Profiles,
    PageEvents,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'studybuddy'));

  @override
  int get schemaVersion => 7;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {


      Future<Set<String>> columnsOf(TableInfo table) async {
        final rows = await m.database
            .customSelect('PRAGMA table_info(${table.actualTableName})')
            .get();
        return rows.map((row) => row.read<String>('name')).toSet();
      }

      Future<void> addIfMissing(
        TableInfo table,
        GeneratedColumn<Object> column,
      ) async {
        if (!(await columnsOf(table)).contains(column.$name)) {
          await m.addColumn(table, column);
        }
      }

      Future<bool> tableExists(TableInfo table) async {
        final row = await m.database
            .customSelect(
              "SELECT 1 AS present FROM sqlite_master WHERE type = 'table' AND name = ? LIMIT 1",
              variables: [Variable<String>(table.actualTableName)],
            )
            .getSingleOrNull();
        return row != null;
      }

      Future<void> createIfMissing(TableInfo table) async {
        if (!await tableExists(table)) await m.createTable(table);
      }


      if (from < 3) {
        await addIfMissing(sessions, sessions.canonicalStartedAt);
        await addIfMissing(sessions, sessions.plannedEndAt);
        await addIfMissing(sessions, sessions.watchSessionId);
        await addIfMissing(sessions, sessions.acceptedSamples);
        await addIfMissing(sessions, sessions.totalSamples);
        await addIfMissing(sessions, sessions.coverageSeconds);
        await addIfMissing(sessions, sessions.accuracyHigh);
        await addIfMissing(sessions, sessions.accuracyMedium);
        await addIfMissing(sessions, sessions.accuracyLow);
        await addIfMissing(sessions, sessions.hsiWindowCount);
        await addIfMissing(sessions, sessions.syncState);
        await addIfMissing(sessions, sessions.uploadedCount);
        await addIfMissing(sessions, sessions.uploadAttemptedAt);
        await addIfMissing(sessions, sessions.syncError);
        await createIfMissing(hsiWindows);
        await createIfMissing(profiles);
      }
      if (from < 4) {
        await addIfMissing(sessions, sessions.pauseStartedAt);
        await createIfMissing(captureSummaries);
      }
      if (from < 5) {
        await addIfMissing(hsiWindows, hsiWindows.signalOrigin);
      }
      if (from < 6) {
        await addIfMissing(sessions, sessions.hsiFocusConfidence);
        await addIfMissing(sessions, sessions.hsiCapacityConfidence);
        await addIfMissing(sessions, sessions.hsiArousalConfidence);
        await addIfMissing(sessions, sessions.hsiStressConfidence);
      }
      if (from < 7) {


        await m.database.customStatement('DROP TABLE IF EXISTS chat_messages');
        await m.database.customStatement('DROP TABLE IF EXISTS conversations');
        await m.database.customStatement('DROP TABLE IF EXISTS check_ins');
        await createIfMissing(pageEvents);
      }
    },
    beforeOpen: (details) async {


      await customStatement('PRAGMA foreign_keys = ON');


      await customStatement('DROP TABLE IF EXISTS hr_samples');
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_sessions_ended_at ON sessions(ended_at)',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_sessions_subject_started ON sessions(subject_id, started_at)',
      );


      await customStatement('''
        UPDATE sessions
        SET status = ${SessionStatus.abandoned.index},
            ended_at = COALESCE(ended_at, CAST(strftime('%s', 'now') AS INTEGER))
        WHERE status IN (${SessionStatus.running.index}, ${SessionStatus.paused.index})
          AND id NOT IN (
            SELECT id FROM sessions
            WHERE status IN (${SessionStatus.running.index}, ${SessionStatus.paused.index})
            ORDER BY started_at DESC
            LIMIT 1
          )
      ''');
      await customStatement('''
        CREATE UNIQUE INDEX IF NOT EXISTS idx_sessions_single_active
        ON sessions ((1))
        WHERE status IN (${SessionStatus.running.index}, ${SessionStatus.paused.index})
      ''');
      await customStatement('''
        DELETE FROM hsi_windows
        WHERE row_id NOT IN (
          SELECT MAX(row_id) FROM hsi_windows GROUP BY session_id, at
        )
      ''');
      await customStatement('DROP INDEX IF EXISTS idx_hsi_session_at');
      await customStatement(
        'CREATE UNIQUE INDEX idx_hsi_session_at ON hsi_windows(session_id, at)',
      );
      await customStatement('''
        DELETE FROM capture_summaries
        WHERE row_id NOT IN (
          SELECT MAX(row_id) FROM capture_summaries GROUP BY session_id, phase
        )
      ''');
      await customStatement(
        'CREATE UNIQUE INDEX IF NOT EXISTS idx_capture_session_phase ON capture_summaries(session_id, phase)',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_page_events_session_at ON page_events(session_id, at)',
      );
    },
  );


  Stream<List<SubjectSummary>> watchSubjectSummaries() {
    final query = customSelect(
      '''
      SELECT
        s.*,
        (SELECT COUNT(*) FROM sources src WHERE src.subject_id = s.id)
          AS source_count,
        (SELECT COALESCE(SUM(ses.focused_minutes), 0) FROM sessions ses
          WHERE ses.subject_id = s.id AND ses.ended_at IS NOT NULL)
          AS focused_minutes,
        (SELECT MAX(ses.ended_at) FROM sessions ses
          WHERE ses.subject_id = s.id AND ses.ended_at IS NOT NULL)
          AS last_studied_at
      FROM subjects s
      WHERE s.archived_at IS NULL
      ORDER BY last_studied_at DESC NULLS LAST, s.created_at DESC
      ''',
      readsFrom: {subjects, sources, sessions},
    );

    return query.watch().map(
      (rows) => rows
          .map((row) {
            final lastStudied = row.read<int?>('last_studied_at');
            return SubjectSummary(
              subject: subjects.map(row.data),
              sourceCount: row.read<int>('source_count'),
              focusedMinutes: row.read<int>('focused_minutes'),
              lastStudiedAt: lastStudied == null
                  ? null
                  : DateTime.fromMillisecondsSinceEpoch(lastStudied * 1000),
            );
          })
          .toList(growable: false),
    );
  }

  Future<Subject?> findSubject(String id) =>
      (select(subjects)..where((t) => t.id.equals(id))).getSingleOrNull();

  Stream<Subject?> watchSubject(String id) =>
      (select(subjects)..where((t) => t.id.equals(id))).watchSingleOrNull();


  Future<void> upsertSubject(SubjectsCompanion subject) =>
      into(subjects).insertOnConflictUpdate(subject);


  Future<void> updateSubject(String id, SubjectsCompanion changes) =>
      (update(subjects)..where((t) => t.id.equals(id))).write(changes);


  Future<void> archiveSubject(String id) =>
      (update(subjects)..where((t) => t.id.equals(id))).write(
        SubjectsCompanion(archivedAt: Value(DateTime.now())),
      );

  Future<void> deleteSubject(String id) =>
      (delete(subjects)..where((t) => t.id.equals(id))).go();


  Stream<List<Source>> watchSources(String subjectId) {
    return (select(sources)
          ..where((t) => t.subjectId.equals(subjectId))
          ..orderBy([
            (t) => OrderingTerm(
              expression: t.lastOpenedAt,
              mode: OrderingMode.desc,
            ),
            (t) => OrderingTerm(expression: t.addedAt, mode: OrderingMode.desc),
          ]))
        .watch();
  }

  Future<Source?> findSource(String id) =>
      (select(sources)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<void> upsertSource(SourcesCompanion source) =>
      into(sources).insertOnConflictUpdate(source);

  Future<void> recordSourceOpened(String id, int page, int? pageCount) {
    return (update(sources)..where((t) => t.id.equals(id))).write(
      SourcesCompanion(
        lastPage: Value(page),
        lastOpenedAt: Value(DateTime.now()),
        pageCount: pageCount == null ? const Value.absent() : Value(pageCount),
      ),
    );
  }

  Future<void> deleteSource(String id) =>
      (delete(sources)..where((t) => t.id.equals(id))).go();


  Stream<Session?> watchActiveSession() {
    return (select(sessions)
          ..where(
            (t) => t.status.isInValues([
              SessionStatus.running,
              SessionStatus.paused,
            ]),
          )
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.startedAt, mode: OrderingMode.desc),
          ])
          ..limit(1))
        .watchSingleOrNull();
  }

  Stream<List<Session>> watchRecentSessions({int limit = 30}) {
    return (select(sessions)
          ..where((t) => t.endedAt.isNotNull())
          ..orderBy([
            (t) => OrderingTerm(expression: t.endedAt, mode: OrderingMode.desc),
          ])
          ..limit(limit))
        .watch();
  }

  Stream<List<SessionListItem>> watchRecentSessionItems({int limit = 30}) {
    final query =
        select(sessions).join([
            leftOuterJoin(subjects, subjects.id.equalsExp(sessions.subjectId)),
          ])
          ..where(sessions.endedAt.isNotNull())
          ..orderBy([OrderingTerm.desc(sessions.endedAt)])
          ..limit(limit);
    return query.watch().map(
      (rows) => rows
          .map(
            (row) => SessionListItem(
              session: row.readTable(sessions),
              subject: row.readTableOrNull(subjects),
            ),
          )
          .toList(growable: false),
    );
  }

  Stream<SevenDayInsight> watchSevenDayInsight() {
    final since = DateTime.now().subtract(const Duration(days: 7));
    final query = customSelect(
      '''
      SELECT s.focused_minutes, s.signal_origin, s.hsi_focus, s.hsi_stress
      FROM sessions s
      WHERE s.status = ? AND s.ended_at >= ?
      ''',
      variables: [
        Variable.withInt(SessionStatus.completed.index),
        Variable.withInt(since.millisecondsSinceEpoch ~/ 1000),
      ],
      readsFrom: {sessions},
    );
    return query.watch().map((rows) {
      var minutes = 0;
      var measured = 0;
      final focusValues = <double>[];
      final stressValues = <double>[];
      final correlationFocus = <double>[];
      final correlationMinutes = <double>[];
      for (final row in rows) {
        final focusedMinutes = row.read<int>('focused_minutes');
        minutes += focusedMinutes;
        if (row.read<int>('signal_origin') == SignalOrigin.unmeasured.index) {
          continue;
        }
        measured += 1;
        final focus = row.read<double?>('hsi_focus');
        final stress = row.read<double?>('hsi_stress');
        if (focus != null) {
          focusValues.add(focus);
          correlationFocus.add(focus);
          correlationMinutes.add(focusedMinutes.toDouble());
        }
        if (stress != null) stressValues.add(stress);
      }
      double? mean(List<double> values) => values.isEmpty
          ? null
          : values.reduce((a, b) => a + b) / values.length;
      return SevenDayInsight(
        focusedMinutes: minutes,
        completedSessions: rows.length,
        measuredSessions: measured,
        meanFocus: mean(focusValues),
        meanStress: mean(stressValues),
        focusVsMinutesCorrelation: pearson(
          correlationFocus,
          correlationMinutes,
        ),
      );
    });
  }

  Stream<List<Session>> watchSessionsForDay(DateTime day) {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));
    return (select(sessions)
          ..where(
            (t) =>
                t.endedAt.isBiggerOrEqualValue(start) &
                t.endedAt.isSmallerThanValue(end),
          )
          ..orderBy([(t) => OrderingTerm(expression: t.endedAt)]))
        .watch();
  }

  Stream<List<SessionListItem>> watchSessionItemsForDay(DateTime day) {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));
    final query =
        select(sessions).join([
            leftOuterJoin(subjects, subjects.id.equalsExp(sessions.subjectId)),
          ])
          ..where(
            sessions.endedAt.isBiggerOrEqualValue(start) &
                sessions.endedAt.isSmallerThanValue(end),
          )
          ..orderBy([OrderingTerm.asc(sessions.endedAt)]);
    return query.watch().map(
      (rows) => rows
          .map(
            (row) => SessionListItem(
              session: row.readTable(sessions),
              subject: row.readTableOrNull(subjects),
            ),
          )
          .toList(growable: false),
    );
  }


  Future<void> upsertSession(SessionsCompanion session) =>
      into(sessions).insertOnConflictUpdate(session);


  Future<void> updateSession(String id, SessionsCompanion changes) =>
      (update(sessions)..where((t) => t.id.equals(id))).write(changes);

  Future<Session?> findSession(String id) =>
      (select(sessions)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<Session?> findActiveSession() =>
      (select(sessions)
            ..where(
              (t) => t.status.isInValues([
                SessionStatus.running,
                SessionStatus.paused,
              ]),
            )
            ..orderBy([
              (t) => OrderingTerm(
                expression: t.startedAt,
                mode: OrderingMode.desc,
              ),
            ])
            ..limit(1))
          .getSingleOrNull();


  Future<int> reconcileOrphanedSessions() {
    return (update(sessions)..where(
          (t) => t.status.isInValues([
            SessionStatus.running,
            SessionStatus.paused,
          ]),
        ))
        .write(
          SessionsCompanion(
            status: Value(SessionStatus.abandoned),
            endedAt: Value(DateTime.now()),
          ),
        );
  }


  Stream<Map<DateTime, int>> watchMinutesByDay({int days = 400}) {
    final since = DateTime.now().subtract(Duration(days: days));

    final query = customSelect(
      '''
      SELECT
        CAST(strftime('%s', date(ended_at, 'unixepoch', 'localtime')) AS INTEGER)
          AS day,
        SUM(focused_minutes) AS minutes
      FROM sessions
      WHERE ended_at IS NOT NULL AND ended_at >= ?
      GROUP BY day
      ''',
      variables: [Variable.withInt(since.millisecondsSinceEpoch ~/ 1000)],
      readsFrom: {sessions},
    );

    return query.watch().map((rows) {
      final result = <DateTime, int>{};
      for (final row in rows) {
        final day = row.read<int?>('day');
        if (day == null) continue;


        final utc = DateTime.fromMillisecondsSinceEpoch(
          day * 1000,
          isUtc: true,
        );
        result[DateTime(utc.year, utc.month, utc.day)] = row.read<int>(
          'minutes',
        );
      }
      return result;
    });
  }


  Future<void> insertPageEvent(PageEventsCompanion event) =>
      into(pageEvents).insert(event);


  Future<List<PageEvent>> pageEventsFor(String sessionId) =>
      (select(pageEvents)
            ..where((t) => t.sessionId.equals(sessionId))
            ..orderBy([(t) => OrderingTerm(expression: t.at)]))
          .get();

  Future<void> insertHsiWindow(String sessionId, StateSample sample) {
    return into(hsiWindows).insert(
      HsiWindowsCompanion.insert(
        sessionId: sessionId,
        at: sample.at,
        signalOrigin: Value(sample.origin),
        hsiVersion: Value(sample.hsiVersion),
        focus: Value(sample.focus),
        focusConfidence: Value(sample.focusConfidence),
        capacity: Value(sample.capacity),
        capacityConfidence: Value(sample.capacityConfidence),
        arousal: Value(sample.arousal),
        arousalConfidence: Value(sample.arousalConfidence),
        stress: Value(sample.stress),
        stressConfidence: Value(sample.stressConfidence),
        quality: Value(sample.quality),
      ),
      mode: InsertMode.insertOrIgnore,
    );
  }

  Future<List<HsiWindow>> hsiWindowsFor(String sessionId) =>
      (select(hsiWindows)
            ..where((t) => t.sessionId.equals(sessionId))
            ..orderBy([(t) => OrderingTerm(expression: t.at)]))
          .get();

  Future<void> saveCaptureSummary(CaptureSummariesCompanion value) async {
    final sessionId = value.sessionId.value;
    final phase = value.phase.value;
    final changed =
        await (update(captureSummaries)..where(
              (table) =>
                  table.sessionId.equals(sessionId) &
                  table.phase.equalsValue(phase),
            ))
            .write(value);
    if (changed == 0) await into(captureSummaries).insert(value);
  }

  Future<List<CaptureSummary>> captureSummariesFor(String sessionId) =>
      (select(captureSummaries)
            ..where((t) => t.sessionId.equals(sessionId))
            ..orderBy([(t) => OrderingTerm.asc(t.phase)]))
          .get();

  Stream<Profile?> watchProfile() =>
      (select(profiles)..where((t) => t.id.equals(1))).watchSingleOrNull();

  Future<Profile?> getProfile() =>
      (select(profiles)..where((t) => t.id.equals(1))).getSingleOrNull();

  Future<void> saveProfile({
    required String nickname,
    required bool setupComplete,
    required bool wearableConsent,
    required bool cloudConsent,
  }) {
    return into(profiles).insertOnConflictUpdate(
      ProfilesCompanion.insert(
        id: const Value(1),
        nickname: Value(nickname.trim()),
        setupComplete: Value(setupComplete),
        wearableConsent: Value(wearableConsent),
        cloudConsent: Value(cloudConsent),
      ),
    );
  }

  Future<void> deleteAllUserData() => transaction(() async {
    await delete(pageEvents).go();
    await delete(hsiWindows).go();
    await delete(captureSummaries).go();

    await customStatement('DROP TABLE IF EXISTS hr_samples');
    await delete(sessions).go();
    await delete(sources).go();
    await delete(subjects).go();
    await delete(profiles).go();
  });
}
