import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../app/providers.dart';
import '../../data/database.dart';
import '../../domain/enums.dart';
import '../../domain/session_nudges.dart';
import '../../domain/study_logic.dart';
import '../biosignal/bio_reading.dart';
import '../biosignal/biosignal_service.dart';
import '../biosignal/watch_sample_push.dart';
import '../state/hsi_providers.dart';
import '../state/hsi_engine.dart';
import '../state/ambient_measurement.dart';
import '../state/watch_hsi_relay.dart';

class FocusState {
  const FocusState({
    this.sessionId,
    this.subjectId,
    this.subjectName = '',
    this.accentIndex = 0,
    this.sourceId,
    this.planned = const Duration(minutes: 25),
    this.startedAt,
    this.pausedTotal = Duration.zero,
    this.pausedSince,
    this.running = false,
    this.state,
    this.notice,
    this.nudge,
  });

  final String? sessionId;
  final String? subjectId;
  final String subjectName;
  final int accentIndex;


  final String? sourceId;

  final Duration planned;
  final DateTime? startedAt;
  final Duration pausedTotal;
  final DateTime? pausedSince;
  final bool running;
  final StateSample? state;
  final String? notice;


  final Nudge? nudge;

  bool get isActive => sessionId != null;

  Duration elapsedAt(DateTime now) {
    final start = startedAt;
    if (start == null) return Duration.zero;
    final livePause = pausedSince == null
        ? Duration.zero
        : now.difference(pausedSince!);
    final elapsed = now.difference(start) - pausedTotal - livePause;
    return elapsed.isNegative ? Duration.zero : elapsed;
  }

  double progressAt(DateTime now) =>
      planned.inSeconds == 0 ? 0 : elapsedAt(now).inSeconds / planned.inSeconds;

  bool expiredAt(DateTime now) => elapsedAt(now) >= planned;

  FocusState copyWith({
    String? sourceId,
    Duration? planned,
    DateTime? startedAt,
    Duration? pausedTotal,
    DateTime? pausedSince,
    bool clearPausedSince = false,
    bool? running,
    StateSample? state,
    String? notice,
    bool clearNotice = false,
    Nudge? nudge,
    bool clearNudge = false,
  }) {
    return FocusState(
      sessionId: sessionId,
      subjectId: subjectId,
      subjectName: subjectName,
      accentIndex: accentIndex,
      sourceId: sourceId ?? this.sourceId,
      planned: planned ?? this.planned,
      startedAt: startedAt ?? this.startedAt,
      pausedTotal: pausedTotal ?? this.pausedTotal,
      pausedSince: clearPausedSince ? null : (pausedSince ?? this.pausedSince),
      running: running ?? this.running,
      state: state ?? this.state,
      notice: clearNotice ? null : (notice ?? this.notice),
      nudge: clearNudge ? null : (nudge ?? this.nudge),
    );
  }
}

class FocusController extends Notifier<FocusState> {
  BiosignalService? _bio;
  StreamSubscription<BioReading>? _readings;
  StreamSubscription<DateTime>? _canonicalStarts;
  StreamSubscription<StateSample>? _stateSamples;
  final List<StateSample> _sessionStates = [];
  final NudgeEngine _nudges = NudgeEngine();
  bool _receivedSignal = false;
  bool _holdsAmbientExclusive = false;
  Future<void> _restoreFuture = Future.value();
  Timer? _expiryTimer;

  static const _uuid = Uuid();

  @override
  FocusState build() {
    ref.onDispose(_teardown);
    _restoreFuture = _restoreActiveSession();
    return const FocusState();
  }

  AppDatabase get _db => ref.read(databaseProvider);

  Future<void> _restoreActiveSession() async {
    final row = await _db.findActiveSession();
    if (row == null || state.isActive) return;
    final subject = await _db.findSubject(row.subjectId);
    if (subject == null) {
      await _db.updateSession(
        row.id,
        SessionsCompanion(
          status: const Value(SessionStatus.abandoned),
          endedAt: Value(DateTime.now()),
        ),
      );
      return;
    }
    final started = row.canonicalStartedAt ?? row.startedAt;
    final restored = FocusState(
      sessionId: row.id,
      subjectId: row.subjectId,
      subjectName: subject.name,
      accentIndex: subject.accentIndex,
      sourceId: row.sourceId,
      planned: Duration(minutes: row.plannedMinutes),
      startedAt: started,
      pausedTotal: Duration(seconds: row.pausedSeconds),
      pausedSince: row.pauseStartedAt,
      running: row.status == SessionStatus.running,
    );
    state = restored;
    _nudges.reset();
    if (restored.expiredAt(DateTime.now())) {
      await _markExpired(
        'This focus block ended while the app was away. '
        'End the session to see your debrief.',
      );
    } else if (state.running) {
      _scheduleExpiry();
      unawaited(_relayTimer());
      try {
        await _startCapture(row.id, state.planned);
      } catch (_) {
        await _releaseAmbientExclusive();
        rethrow;
      }
    }
  }

  Future<void> start({
    required Subject subject,
    String? sourceId,
    Duration planned = const Duration(minutes: 25),
    BioOutcome? readinessBio,
    CoreCaptureResult? readinessCore,
  }) async {
    await _restoreFuture;
    if (state.isActive) return;

    final sessionId = _uuid.v4();
    final provisionalStart = DateTime.now();
    await _db.upsertSession(
      SessionsCompanion.insert(
        id: sessionId,
        subjectId: subject.id,
        sourceId: Value(sourceId),
        startedAt: provisionalStart,
        plannedMinutes: Value(planned.inMinutes),
        status: SessionStatus.running,
        signalOrigin: SignalOrigin.unmeasured,
      ),
    );
    if (readinessBio != null || readinessCore != null) {
      await _saveCaptureSummary(
        sessionId,
        CapturePhase.readiness,
        readinessBio ?? const BioOutcome(origin: SignalOrigin.unmeasured),
        readinessCore ?? const CoreCaptureResult(),
      );
    }

    state = FocusState(
      sessionId: sessionId,
      subjectId: subject.id,
      subjectName: subject.name,
      accentIndex: subject.accentIndex,
      sourceId: sourceId,
      planned: planned,
      startedAt: provisionalStart,
      running: true,
      notice: 'Starting the watch…',
    );
    _nudges.reset();
    _scheduleExpiry();
    unawaited(_relayTimer());
    try {
      await _startCapture(sessionId, planned);
    } catch (_) {
      await _releaseAmbientExclusive();
      rethrow;
    }
  }

  Future<void> _startCapture(String sessionId, Duration planned) async {
    await ref.read(ambientMeasurementProvider).acquireExclusive();
    _holdsAmbientExclusive = true;
    await _cleanUpCapture(stopCore: false);
    final bio = ref.read(biosignalServiceFactoryProvider)();
    _bio = bio;
    _receivedSignal = false;

    final hsi = ref.read(hsiEngineProvider);
    final coreSessionId = await hsi.startCoreSession(planned);
    if (coreSessionId != null) {
      await _db.updateSession(
        sessionId,
        SessionsCompanion(synheartSessionId: Value(coreSessionId)),
      );
    }

    _sessionStates.clear();
    _stateSamples = hsi.states.listen((sample) {
      if (state.sessionId != sessionId) return;
      _sessionStates.add(sample);
      unawaited(_db.insertHsiWindow(sessionId, sample));
      unawaited(ref.read(watchHsiRelayProvider).send(sessionId, sample));
      final nudge = _nudges.onWindow(
        sample: sample,
        elapsed: state.elapsedAt(sample.at),
        planned: state.planned,
      );
      state = state.copyWith(state: sample, clearNotice: true, nudge: nudge);
      if (nudge != null) {
        unawaited(ref.read(watchHsiRelayProvider).sendNudge(sessionId, nudge));
      }
    });
    _canonicalStarts = bio.canonicalStarts.listen((startedAt) {
      if (state.sessionId != sessionId) return;
      state = state.copyWith(startedAt: startedAt);
      _scheduleExpiry();
      unawaited(
        _db.updateSession(
          sessionId,
          SessionsCompanion(
            canonicalStartedAt: Value(startedAt),
            plannedEndAt: Value(startedAt.add(planned)),
            watchSessionId: Value(sessionId),
          ),
        ),
      );
      unawaited(_relayTimer());
    });
    _readings = bio.readings.listen((reading) {
      if (state.sessionId != sessionId) return;
      hsi.feedWatchReading(reading);
      if (reading.bpm == null) return;
      if (!_receivedSignal) {
        _receivedSignal = true;
        state = state.copyWith(
          notice:
              'Watch connected. Your first reading arrives in about a minute.',
        );
      }
    });

    try {
      await bio.start(sessionId: sessionId, planned: planned);
      if (!await bio.isWatchReady() && state.sessionId == sessionId) {
        state = state.copyWith(
          notice:
              'Your watch is not reachable — the timer still works, but '
              'nothing is being measured.',
        );
      }
    } catch (error) {
      state = state.copyWith(notice: 'Measurement could not start: $error');
    }
  }

  Future<void> togglePause() async {
    if (!state.isActive) return;
    final now = DateTime.now();
    if (state.expiredAt(now)) {
      await _markExpired();
      return;
    }
    if (state.running) {
      state = state.copyWith(
        running: false,
        pausedSince: now,
        clearNudge: true,
      );
    } else {
      final added = state.pausedSince == null
          ? Duration.zero
          : now.difference(state.pausedSince!);
      state = state.copyWith(
        running: true,
        pausedTotal: state.pausedTotal + added,
        clearPausedSince: true,
      );
    }
    await _db.updateSession(
      state.sessionId!,
      SessionsCompanion(
        status: Value(
          state.running ? SessionStatus.running : SessionStatus.paused,
        ),
        pausedSeconds: Value(state.pausedTotal.inSeconds),
        pauseStartedAt: Value(state.pausedSince),
        plannedEndAt: Value(
          state.startedAt?.add(state.planned + state.pausedTotal),
        ),
      ),
    );
    _scheduleExpiry();
    unawaited(_relayTimer());
  }


  Future<void> extend(Duration extra) async {
    final sessionId = state.sessionId;
    if (sessionId == null || state.expiredAt(DateTime.now())) return;
    state = state.copyWith(planned: state.planned + extra, clearNudge: true);
    _nudges.onExtended();
    await _db.updateSession(
      sessionId,
      SessionsCompanion(
        plannedMinutes: Value(state.planned.inMinutes),
        plannedEndAt: Value(
          state.startedAt?.add(state.planned + state.pausedTotal),
        ),
      ),
    );
    _scheduleExpiry();
    unawaited(_relayTimer());
  }


  Future<void> attachSource(String sourceId) async {
    final sessionId = state.sessionId;
    if (sessionId == null || state.sourceId == sourceId) return;
    state = state.copyWith(sourceId: sourceId);
    await _db.updateSession(
      sessionId,
      SessionsCompanion(sourceId: Value(sourceId)),
    );
  }

  void dismissNudge() {
    if (state.nudge == null) return;
    state = state.copyWith(clearNudge: true);
  }

  void _scheduleExpiry() {
    _expiryTimer?.cancel();
    if (!state.isActive || !state.running) return;
    final remaining = state.planned - state.elapsedAt(DateTime.now());
    if (remaining <= Duration.zero) {
      unawaited(_markExpired());
      return;
    }
    _expiryTimer = Timer(remaining, () => unawaited(_markExpired()));
  }

  Future<void> _markExpired([
    String notice = 'Focus complete — end the session to see your debrief.',
  ]) async {
    if (!state.isActive) return;
    final now = DateTime.now();
    if (!state.expiredAt(now)) {
      if (state.running) _scheduleExpiry();
      return;
    }
    final freezeAt = state.startedAt!.add(state.planned + state.pausedTotal);
    state = state.copyWith(
      running: false,
      pausedSince: freezeAt,
      notice: notice,
      clearNudge: true,
    );
    await _db.updateSession(
      state.sessionId!,
      SessionsCompanion(
        status: const Value(SessionStatus.paused),
        pauseStartedAt: Value(freezeAt),
      ),
    );
    unawaited(_relayTimer());
  }

  Future<void> stop({bool completed = true}) async {
    final sessionId = state.sessionId;
    if (sessionId == null) return;
    _expiryTimer?.cancel();
    final now = DateTime.now();
    final focused = state.elapsedAt(now);
    final finalPaused =
        state.pausedTotal +
        (state.pausedSince == null
            ? Duration.zero
            : now.difference(state.pausedSince!));
    final bio = _bio;
    final outcome = bio == null
        ? const BioOutcome(origin: SignalOrigin.unmeasured)
        : await bio.stop(sessionId);
    final core = await ref.read(hsiEngineProvider).stopCoreSession();


    final storedWindows = await _db.hsiWindowsFor(sessionId);
    final allWindows = <int, StateSample>{
      for (final window in storedWindows)
        window.at.millisecondsSinceEpoch: StateSample(
          at: window.at,
          origin: window.signalOrigin,
          focus: window.focus,
          focusConfidence: window.focusConfidence,
          capacity: window.capacity,
          capacityConfidence: window.capacityConfidence,
          arousal: window.arousal,
          arousalConfidence: window.arousalConfidence,
          stress: window.stress,
          stressConfidence: window.stressConfidence,
          quality: window.quality,
          hsiVersion: window.hsiVersion,
        ),
      for (final sample in _sessionStates)
        sample.at.millisecondsSinceEpoch: sample,
    };
    final meanState = weightedStateMean(
      allWindows.values.toList()..sort((a, b) => a.at.compareTo(b.at)),
    );

    final high = outcome.accuracyCounts[HeartRateQuality.high] ?? 0;
    final medium = outcome.accuracyCounts[HeartRateQuality.medium] ?? 0;
    final low = outcome.accuracyCounts[HeartRateQuality.low] ?? 0;


    final measured = meanState != null && allWindows.isNotEmpty;
    final origin = outcome.origin != SignalOrigin.unmeasured
        ? outcome.origin
        : core.signalOrigin;


    final productionMeasured = measured && origin != SignalOrigin.unmeasured;
    final captureError = core.error ?? outcome.errorMessage;
    await _saveCaptureSummary(
      sessionId,
      CapturePhase.focus,
      outcome,
      core,
      stateOverride: meanState,
      windowCountOverride: allWindows.length,
    );
    await _db.updateSession(
      sessionId,
      SessionsCompanion(
        endedAt: Value(now),
        focusedMinutes: Value(
          focused.inMinutes.clamp(0, state.planned.inMinutes),
        ),
        pausedSeconds: Value(finalPaused.inSeconds),
        pauseStartedAt: const Value(null),
        status: Value(
          completed ? SessionStatus.completed : SessionStatus.abandoned,
        ),
        signalOrigin: Value(measured ? origin : SignalOrigin.unmeasured),
        hsiFocus: Value(meanState?.focus),
        hsiFocusConfidence: Value(meanState?.focusConfidence),
        hsiCapacity: Value(meanState?.capacity),
        hsiCapacityConfidence: Value(meanState?.capacityConfidence),
        hsiArousal: Value(meanState?.arousal),
        hsiArousalConfidence: Value(meanState?.arousalConfidence),
        hsiStress: Value(meanState?.stress),
        hsiStressConfidence: Value(meanState?.stressConfidence),
        hsiQuality: Value(meanState?.quality),
        synheartSessionId: Value(core.coreSessionId),
        watchSessionId: Value(outcome.watchSessionId ?? sessionId),
        acceptedSamples: Value(outcome.acceptedSamples),
        totalSamples: Value(outcome.totalSamples),
        coverageSeconds: Value(outcome.coverageSeconds),
        accuracyHigh: Value(high),
        accuracyMedium: Value(medium),
        accuracyLow: Value(low),
        hsiWindowCount: Value(allWindows.length),
        syncState: Value(
          productionMeasured ? SyncState.pending : SyncState.localOnly,
        ),
        syncError: Value(captureError),
      ),
    );

    await _cleanUpCapture(stopCore: false);
    await _releaseAmbientExclusive();
    state = const FocusState();


    if (productionMeasured) {
      unawaited(_finalizeIngestion(sessionId, captureError));
    }
  }

  Future<void> _finalizeIngestion(
    String sessionId,
    String? captureError,
  ) async {
    try {
      final ingestion = await ref.read(hsiEngineProvider).flushIngestion();
      await _db.updateSession(
        sessionId,
        SessionsCompanion(
          syncState: Value(ingestion.state),
          uploadedCount: Value(ingestion.uploaded),
          uploadAttemptedAt: Value(ingestion.lastAttemptAt ?? DateTime.now()),
          syncError: Value(ingestion.error ?? captureError),
        ),
      );
    } catch (_) {

    }
  }

  Future<void> _relayTimer() async {
    final sessionId = state.sessionId;
    final startedAt = state.startedAt;
    if (sessionId == null || startedAt == null) return;
    await ref
        .read(watchHsiRelayProvider)
        .sendTimer(
          sessionId: sessionId,
          startedAt: startedAt,
          planned: state.planned,
          pausedTotal: state.pausedTotal,
          pausedSince: state.pausedSince,
        );
  }

  Future<void> _saveCaptureSummary(
    String sessionId,
    CapturePhase phase,
    BioOutcome bio,
    CoreCaptureResult core, {
    StateSample? stateOverride,
    int? windowCountOverride,
  }) async {
    final sample = stateOverride ?? core.meanState;
    await _db.saveCaptureSummary(
      CaptureSummariesCompanion.insert(
        sessionId: sessionId,
        phase: phase,
        signalOrigin: bio.origin,
        watchSessionId: Value(bio.watchSessionId),
        coreSessionId: Value(core.coreSessionId),
        acceptedSamples: Value(bio.acceptedSamples),
        totalSamples: Value(bio.totalSamples),
        coverageSeconds: Value(bio.coverageSeconds),
        accuracyHigh: Value(bio.accuracyCounts[HeartRateQuality.high] ?? 0),
        accuracyMedium: Value(bio.accuracyCounts[HeartRateQuality.medium] ?? 0),
        accuracyLow: Value(bio.accuracyCounts[HeartRateQuality.low] ?? 0),
        hsiWindowCount: Value(windowCountOverride ?? core.windowCount),
        hsiFocus: Value(sample?.focus),
        hsiFocusConfidence: Value(sample?.focusConfidence),
        hsiCapacity: Value(sample?.capacity),
        hsiCapacityConfidence: Value(sample?.capacityConfidence),
        hsiArousal: Value(sample?.arousal),
        hsiArousalConfidence: Value(sample?.arousalConfidence),
        hsiStress: Value(sample?.stress),
        hsiStressConfidence: Value(sample?.stressConfidence),
        quality: Value(sample?.quality),
        diagnosticError: Value(core.error ?? bio.errorMessage),
        createdAt: DateTime.now(),
      ),
    );
  }

  Future<void> _cleanUpCapture({required bool stopCore}) async {
    await _readings?.cancel();
    _readings = null;
    await _canonicalStarts?.cancel();
    _canonicalStarts = null;
    await _stateSamples?.cancel();
    _stateSamples = null;
    _sessionStates.clear();
    if (stopCore) await ref.read(hsiEngineProvider).stopCoreSession();
    await _bio?.dispose();
    _bio = null;
  }

  Future<void> _releaseAmbientExclusive() async {
    if (!_holdsAmbientExclusive) return;
    _holdsAmbientExclusive = false;
    await ref.read(ambientMeasurementProvider).releaseExclusive();
  }

  void _teardown() {
    _expiryTimer?.cancel();
    _readings?.cancel();
    _canonicalStarts?.cancel();
    _stateSamples?.cancel();
    _bio?.dispose();
    _holdsAmbientExclusive = false;
  }
}

final focusControllerProvider = NotifierProvider<FocusController, FocusState>(
  FocusController.new,
);


final focusElapsedProvider = StreamProvider<Duration>((ref) async* {
  var lastSession = ref.watch(
    focusControllerProvider.select((value) => value.sessionId),
  );
  while (lastSession != null) {
    final focus = ref.read(focusControllerProvider);
    final now = DateTime.now();
    yield focus.elapsedAt(now);


    await Future<void>.delayed(Duration(milliseconds: 1000 - now.millisecond));
    if (!ref.mounted) return;
    lastSession = ref.read(focusControllerProvider).sessionId;
  }
});
