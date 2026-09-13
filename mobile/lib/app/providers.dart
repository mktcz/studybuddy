import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart';
import '../data/source_store.dart';
import '../domain/study_logic.dart';
import '../features/biosignal/biosignal_service.dart';
import '../features/biosignal/watch_diagnostic.dart';


final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});


final biosignalServiceFactoryProvider = Provider<BiosignalService Function()>(
  (ref) => BiosignalService.new,
);


final sourceStoreProvider = Provider<SourceStore>((ref) => const SourceStore());


final subjectSummariesProvider = StreamProvider<List<SubjectSummary>>((ref) {
  return ref.watch(databaseProvider).watchSubjectSummaries();
});

final subjectProvider = StreamProvider.family<Subject?, String>((ref, id) {
  return ref.watch(databaseProvider).watchSubject(id);
});

final sourcesProvider = StreamProvider.family<List<Source>, String>((
  ref,
  subjectId,
) {
  return ref.watch(databaseProvider).watchSources(subjectId);
});


final minutesByDayProvider = StreamProvider<Map<DateTime, int>>((ref) {
  return ref.watch(databaseProvider).watchMinutesByDay();
});


final streakProvider = Provider<int>((ref) {
  final byDay = ref.watch(minutesByDayProvider).value;
  return byDay == null ? 0 : streakDays(byDay);
});


final todayMinutesProvider = Provider<int>((ref) {
  final byDay = ref.watch(minutesByDayProvider).value;
  if (byDay == null) return 0;
  final now = DateTime.now();
  return byDay[DateTime(now.year, now.month, now.day)] ?? 0;
});

final recentSessionsProvider = StreamProvider<List<SessionListItem>>((ref) {
  return ref.watch(databaseProvider).watchRecentSessionItems();
});

final sevenDayInsightProvider = StreamProvider<SevenDayInsight>((ref) {
  return ref.watch(databaseProvider).watchSevenDayInsight();
});

final profileProvider = StreamProvider<Profile?>((ref) {
  return ref.watch(databaseProvider).watchProfile();
});

final watchDiagnosticProvider = FutureProvider.autoDispose(
  (ref) => const WatchDiagnosticService().check(),
);
