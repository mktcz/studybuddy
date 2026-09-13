import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:synheart_core/synheart_core.dart';
import 'package:uuid/uuid.dart';

import '../../domain/enums.dart';
import '../../domain/study_logic.dart';

enum HsiPhase { unconfigured, starting, awaitingConsent, ready, failed }

class StudyConsentChoice {
  const StudyConsentChoice({
    required this.measuredState,
    required this.cloudUpload,
  });

  final bool measuredState;
  final bool cloudUpload;
}

class IngestionSnapshot {
  const IngestionSnapshot({
    this.state = SyncState.localOnly,
    this.queueLength = 0,
    this.uploaded = 0,
    this.failed = 0,
    this.requeued = 0,
    this.lastUploadAt,
    this.lastAttemptAt,
    this.error,
  });

  final SyncState state;
  final int queueLength;
  final int uploaded;
  final int failed;
  final int requeued;
  final DateTime? lastUploadAt;
  final DateTime? lastAttemptAt;
  final String? error;
}

class IntegrationHealth {
  const IntegrationHealth({
    required this.phase,
    this.runtimeAvailable = false,
    this.runtimeVersion,
    this.buildInfo,
    this.biosignalConsent = false,
    this.cloudUploadConsent = false,
    this.deviceAuthReady = false,
    this.cloudTokenReady = false,
    this.networkAvailable = true,
    this.hsiFrameCount = 0,
    this.hrPushCount = 0,
    this.rrPushCount = 0,
    this.ingestion = const IngestionSnapshot(),
    this.error,
  });

  final HsiPhase phase;
  final bool runtimeAvailable;
  final String? runtimeVersion;
  final String? buildInfo;
  final bool biosignalConsent;
  final bool cloudUploadConsent;
  final bool deviceAuthReady;
  final bool cloudTokenReady;
  final bool networkAvailable;
  final int hsiFrameCount;
  final int hrPushCount;
  final int rrPushCount;
  final IngestionSnapshot ingestion;
  final String? error;

  bool get readyForLocalHsi => runtimeAvailable && biosignalConsent;
}

class CoreCaptureResult {
  const CoreCaptureResult({
    this.coreSessionId,
    this.windowCount = 0,
    this.meanState,
    this.persistedSummary,
    this.signalOrigin = SignalOrigin.unmeasured,
    this.error,
  });

  final String? coreSessionId;
  final int windowCount;
  final StateSample? meanState;
  final Map<String, dynamic>? persistedSummary;
  final SignalOrigin signalOrigin;
  final String? error;
}

class HsiStatus {
  const HsiStatus({
    required this.phase,
    this.runtimeVersion,
    this.frameCount = 0,
    this.hrPushCount = 0,
    this.rrPushCount = 0,
    this.error,
  });

  final HsiPhase phase;
  final String? runtimeVersion;
  final int frameCount;
  final int hrPushCount;
  final int rrPushCount;
  final String? error;

  bool get computing => phase == HsiPhase.ready;
}

abstract interface class HumanStateGateway {
  Stream<StateSample> get states;
  Stream<HsiStatus> get statuses;
  StateSample? get latest;
  HsiStatus get status;
  bool get ready;
  bool get consented;

  Future<IntegrationHealth> initialize();
  Future<IntegrationHealth> health();
  Future<String?> setConsent(StudyConsentChoice choice);
  Future<String?> startCoreSession(Duration planned);
  Future<CoreCaptureResult> stopCoreSession();
  void pushHeartRate(
    DateTime at,
    double bpm, {
    SignalOrigin origin = SignalOrigin.wearableReal,
  });
  void pushRr(
    DateTime at,
    double rrIntervalMs, {
    SignalOrigin origin = SignalOrigin.wearableReal,
  });
  Future<IngestionSnapshot> ingestionStatus();
  Future<IngestionSnapshot> flushIngestion();


  void recordStudyMetric(
    String name,
    DateTime at, {
    double? value,
    Map<String, String> tags = const {},
  });


  Future<String?> generateTakeaway(String prompt);
  String sanitizedDiagnostics();
  Future<void> wipeLocalData();
  Future<void> dispose();
}


class HsiEngine implements HumanStateGateway {
  HsiEngine({FlutterSecureStorage? secureStorage})
    : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  static const _appId = String.fromEnvironment('SYNHEART_APP_ID');
  static const _orgId = String.fromEnvironment('SYNHEART_ORG_ID');
  static const _uuid = Uuid();
  static const _subjectKey = 'study_buddy_subject_id';

  final FlutterSecureStorage _secureStorage;
  final _states = StreamController<StateSample>.broadcast();
  final _statuses = StreamController<HsiStatus>.broadcast();
  final _runtimeLogs = <String>[];
  final _sessionStates = <StateSample>[];
  final _rawSessionWindows = <String>[];

  StreamSubscription<String>? _rawSubscription;
  HsiStatus _status = const HsiStatus(phase: HsiPhase.unconfigured);
  StateSample? _latest;
  bool _initializing = false;
  bool _initialized = false;
  bool _deviceAuthReady = false;
  int _hrPushCount = 0;
  int _rrPushCount = 0;
  int _hsiFrameCount = 0;
  int _lastPublishedTimestampMs = 0;
  String? _activeCoreSessionId;
  Future<String?>? _coreStart;
  String? _diagnosticFailure;
  SignalOrigin _captureOrigin = SignalOrigin.unmeasured;
  IngestionSnapshot _lastIngestion = const IngestionSnapshot();

  @override
  Stream<StateSample> get states => _states.stream;

  @override
  Stream<HsiStatus> get statuses async* {
    yield _status;
    yield* _statuses.stream;
  }

  @override
  StateSample? get latest => _latest;

  @override
  HsiStatus get status => _status;

  bool get configured => _appId.isNotEmpty && _orgId.isNotEmpty;

  @override
  bool get ready => _status.phase == HsiPhase.ready;

  @override
  bool get consented {
    if (!_initialized) return false;
    return Synheart.consentEffectiveStateTyped()?.biosignals == true;
  }

  @override
  Future<IntegrationHealth> initialize() async {
    if (_initialized || _initializing) return health();
    if (!configured) {
      _setStatus(const HsiStatus(phase: HsiPhase.unconfigured));
      return health();
    }
    _initializing = true;
    _setStatus(const HsiStatus(phase: HsiPhase.starting));

    try {
      final subjectId = await _loadOrCreateSubjectId();
      await Synheart.initialize(
        config: SynheartConfig(
          appId: _appId,
          subjectId: subjectId,
          appVersion: '1.0.0',
          appName: 'Study Buddy',
          category: 'Productivity',
          developer: 'Study Buddy',
          deviceId: subjectId,
          mode: SynheartMode.insight,
          wearConfig: const WearConfig(
            sampleRateHz: 1,
            enableCaching: true,


            enableHighFrequencyHrv: true,
          ),
          cloudConfig: CloudConfig(
            subjectId: subjectId,
            instanceId: subjectId,
            orgId: _orgId,
          ),
          consentConfig: ConsentConfig(
            appId: _appId,
            userId: subjectId,
            deviceId: subjectId,
            platform: 'flutter',
          ),
          deviceAuthConfig: const DeviceAuthConfig(
            authBaseUrl: 'https://api.synheart.ai',
            packageName: 'com.studybuddy.app',


            allowUnattestedDevRegistration: kDebugMode,
          ),
          allowUnsignedCapabilities: kDebugMode,
          batchIngestOnStop: false,
        ),
        runtimeLogEnvFilter: kDebugMode ? 'info' : null,
        runtimeLogForwarder: kDebugMode ? _captureRuntimeLog : null,
      );
      _initialized = true;
      await _disableLegacyPhoneSignalConsent();


      _rawSubscription = Synheart.onHSIUpdate.listen(_onRawHsi);

      final diagnostics = Synheart.runtimeDiagnostics();
      if (diagnostics['isAvailable'] != true) {
        _diagnosticFailure = 'Native Synheart Core is unavailable.';
        _setStatus(
          HsiStatus(phase: HsiPhase.failed, error: _diagnosticFailure),
        );
        return await health();
      }

      if (Synheart.consentEffectiveStateTyped()?.cloudUpload == true) {
        unawaited(_restoreCloudReadiness());
      }
      _refreshStatus();
    } catch (error) {
      _diagnosticFailure = _safeError(error);
      _setStatus(HsiStatus(phase: HsiPhase.failed, error: _diagnosticFailure));
    } finally {
      _initializing = false;
    }
    return health();
  }


  Future<void> _disableLegacyPhoneSignalConsent() async {
    final effective = Synheart.consentEffectiveStateTyped();
    if (effective?.phoneContext != true && effective?.behavior != true) return;
    final current = Synheart.consentGetEditableFormTyped();
    if (current == null) {
      _captureRuntimeLog(
        'Could not inspect legacy phone-signal consent for revocation.',
      );
      return;
    }
    final result = await Synheart.consentSubmitFormTyped(
      form: current.copyWith(
        phoneContext: false,
        behavior: false,
        allowResearch: false,
        allowVendorSync: false,
      ),
    );
    final error = result?['error']?.toString();
    if (result == null || (error != null && error.isNotEmpty)) {
      _captureRuntimeLog(
        'Legacy phone-signal consent revocation failed: ${_safeText(error ?? 'no result')}',
      );
    }
  }

  Future<void> _restoreCloudReadiness() async {
    try {
      _deviceAuthReady = await Synheart.ensureDeviceAuthRegistered();
      if (_deviceAuthReady) {
        final tokenReady = await Synheart.ensureCloudConsentReady();
        if (tokenReady) unawaited(flushIngestion());
      }
    } catch (error) {
      _captureRuntimeLog(
        'Cloud readiness restore failed: ${_safeError(error)}',
      );
    } finally {
      _refreshStatus();
    }
  }

  @override
  Future<String?> setConsent(StudyConsentChoice choice) async {
    if (!_initialized || _status.phase == HsiPhase.unconfigured) {
      return 'Synheart is not configured in this build.';
    }
    if (_status.phase == HsiPhase.failed) return _status.error;

    final current = Synheart.consentGetEditableFormTyped();
    if (current == null) return 'Synheart did not provide a consent form.';
    final submitted = await Synheart.consentSubmitFormTyped(
      form: current.copyWith(
        biosignals: choice.measuredState,
        phoneContext: false,
        behavior: false,
        consentTier: choice.cloudUpload ? ConsentTier.cloud : ConsentTier.local,
        allowCloud: choice.cloudUpload,
        allowResearch: false,
        allowVendorSync: false,
        syni: false,
      ),
    );
    final error = submitted?['error']?.toString();
    if (submitted == null) return 'Consent could not be saved.';
    if (error != null && error.isNotEmpty) return _safeText(error);

    if (choice.cloudUpload) {
      try {
        _deviceAuthReady = await Synheart.ensureDeviceAuthRegistered();
        if (!_deviceAuthReady) {
          _refreshStatus();
          return 'Local consent is saved, but this build could not be verified for cloud upload.';
        }
        final tokenReady = await Synheart.ensureCloudConsentReady();
        if (!tokenReady) {
          _refreshStatus();
          return 'Local consent is saved, but the cloud consent token is still pending.';
        }
      } catch (error) {
        _refreshStatus();
        return 'Local consent is saved. Cloud setup failed: ${_safeError(error)}';
      }
    }
    _refreshStatus();
    return null;
  }

  @override
  Future<String?> startCoreSession(Duration planned) {
    if (!ready || _activeCoreSessionId != null) {
      return Future.value(_activeCoreSessionId);
    }
    final inFlight = _coreStart;
    if (inFlight != null) return inFlight;
    final start = _startCoreSession(planned);
    _coreStart = start;
    return start.whenComplete(() {
      if (identical(_coreStart, start)) _coreStart = null;
    });
  }

  Future<String?> _startCoreSession(Duration planned) async {
    _sessionStates.clear();
    _rawSessionWindows.clear();
    _captureOrigin = SignalOrigin.unmeasured;


    _lastPublishedTimestampMs = 0;
    try {


      if (Synheart.isSessionRunning) {
        await Synheart.stopSession().timeout(const Duration(seconds: 8));
      }
      final handle = await Synheart.startSession(
        durationSec: planned.inSeconds + 10,
      ).timeout(const Duration(seconds: 12));


      await _stopSdkCollectors();


      Synheart.setTaskType(TaskType.focus);
      Synheart.setFocusKind(FocusKind.medium);
      _activeCoreSessionId =
          handle?.sessionId ?? Synheart.currentSession?.sessionId;
      return _activeCoreSessionId;
    } catch (error) {
      await _stopSdkCollectors();
      _captureRuntimeLog('Core session start failed: ${_safeError(error)}');


      _activeCoreSessionId = null;
      return null;
    }
  }

  Future<void> _stopSdkCollectors() async {
    for (final stop in <Future<void> Function()>[
      Synheart.stopWearCollection,
      Synheart.stopPhoneCollection,
      Synheart.stopBehaviorCollection,
    ]) {
      try {
        await stop();
      } catch (error) {
        _captureRuntimeLog(
          'SDK collector stop was not needed: ${_safeError(error)}',
        );
      }
    }
  }

  @override
  void pushHeartRate(
    DateTime at,
    double bpm, {
    SignalOrigin origin = SignalOrigin.wearableReal,
  }) {
    if (!ready || !bpm.isFinite || bpm <= 0) return;


    Synheart.pushWearHr(
      at.millisecondsSinceEpoch,
      bpm,
      provider: 'watch_sample',
    );
    debugPrint(
      'Synheart.pushWearHr ts=${at.millisecondsSinceEpoch} bpm=$bpm '
      'provider=watch_sample origin=${origin.name}',
    );
    _hrPushCount++;
    if (origin == SignalOrigin.wearableSyntheticTest) {
      _captureOrigin = origin;
    } else if (_captureOrigin == SignalOrigin.unmeasured) {
      _captureOrigin = SignalOrigin.wearableReal;
    }
    _refreshStatus();
  }

  @override
  void pushRr(
    DateTime at,
    double rrIntervalMs, {
    SignalOrigin origin = SignalOrigin.wearableReal,
  }) {
    if (!ready || !rrIntervalMs.isFinite || rrIntervalMs <= 0) return;
    Synheart.pushRr(
      at.millisecondsSinceEpoch,
      rrIntervalMs,
      provider: 'watch_sample',
    );
    debugPrint(
      'Synheart.pushRr ts=${at.millisecondsSinceEpoch} rrMs=$rrIntervalMs '
      'provider=watch_sample origin=${origin.name}',
    );
    _rrPushCount++;
    if (origin == SignalOrigin.wearableSyntheticTest) {
      _captureOrigin = origin;
    } else if (_captureOrigin == SignalOrigin.unmeasured) {
      _captureOrigin = SignalOrigin.wearableReal;
    }
    _refreshStatus();
  }

  @override
  Future<CoreCaptureResult> stopCoreSession() async {


    try {
      await _coreStart;
    } catch (_) {}
    final sessionId = _activeCoreSessionId;
    if (!_initialized || sessionId == null) {
      return const CoreCaptureResult();
    }
    String? error;
    try {
      if (Synheart.isSessionRunning) {
        await Synheart.stopSession().timeout(const Duration(seconds: 8));
      }
    } catch (value) {
      error = _safeError(value);
    }

    Map<String, dynamic>? summary;
    List<Map<String, dynamic>> persisted = const [];
    try {
      final summaryFuture = Synheart.getSessionSummary(sessionId)
          .timeout(const Duration(seconds: 5));
      final windowsFuture = Synheart.getHSIWindows(sessionId)
          .timeout(const Duration(seconds: 5));
      final values = await Future.wait<Object?>([summaryFuture, windowsFuture]);
      summary = values[0] as Map<String, dynamic>?;
      persisted = values[1]! as List<Map<String, dynamic>>;
      if (persisted.length != _rawSessionWindows.length) {
        _captureRuntimeLog(
          'Core persisted ${persisted.length} HSI windows; '
          '${_rawSessionWindows.length} wearable-backed windows were accepted live.',
        );
      }
    } catch (value) {
      error ??= _safeError(value);
    }
    final result = CoreCaptureResult(
      coreSessionId: sessionId,
      windowCount: _rawSessionWindows.length,
      meanState: weightedStateMean(_sessionStates),
      persistedSummary: summary,
      signalOrigin: _captureOrigin,
      error: error,
    );
    _activeCoreSessionId = null;
    _sessionStates.clear();
    _rawSessionWindows.clear();
    _captureOrigin = SignalOrigin.unmeasured;
    Synheart.setTaskType(TaskType.unknown);
    Synheart.setFocusKind(FocusKind.unknown);
    return result;
  }


  bool _syniPersonaBound = false;

  @override
  Future<String?> generateTakeaway(String prompt) async {
    if (!_initialized) return null;
    try {
      final syni = Synheart.syni;
      if (syni == null || !syni.hasCloud) return null;
      if (!_syniPersonaBound) {
        syni.bindPersona(await SyniSpecPersona.load('focus.coach.v1'));
        _syniPersonaBound = true;
      }
      final response = await syni
          .chat(prompt, mode: SyniExecutionMode.cloudOnly)
          .timeout(const Duration(seconds: 12));
      if (response.isFallback) return null;
      final text = response.message?.trim();
      return (text == null || text.isEmpty) ? null : text;
    } catch (error) {

      _captureRuntimeLog('Syni takeaway unavailable: ${_safeError(error)}');
      return null;
    }
  }

  @override
  void recordStudyMetric(
    String name,
    DateTime at, {
    double? value,
    Map<String, String> tags = const {},
  }) {
    if (!_initialized || !ready) return;
    unawaited(
      Synheart.recordMetric(
        MetricEvent(
          name: name,
          timestampMs: at.millisecondsSinceEpoch,
          value: value ?? 1,
          tags: tags.isEmpty ? null : tags,
        ),
      ).catchError((Object error) {
        _captureRuntimeLog('Metric $name dropped: ${_safeError(error)}');
      }),
    );
  }


  void _onRawHsi(String raw) {
    if (_activeCoreSessionId == null ||
        _captureOrigin == SignalOrigin.unmeasured) {
      return;
    }
    try {
      final priorTimestamp = _lastPublishedTimestampMs;
      final parsed = HSIState.fromJson(raw);
      if (kDebugMode) {
        final a = parsed.hsi;
        debugPrint('HSI axes conf focus=${a.focus?.confidence} capacity=${a.capacity?.confidence} arousal=${a.arousal?.confidence} stress=${a.stress?.confidence}');
      }
      _publishState(parsed);
      if (_lastPublishedTimestampMs != priorTimestamp) {
        _rawSessionWindows.add(raw);
      }
    } catch (error) {
      _captureRuntimeLog('Malformed HSI window ignored: ${_safeError(error)}');
    }
  }

  void _publishState(HSIState state) {


    if (_captureOrigin == SignalOrigin.unmeasured) return;
    final sample = stateSampleFromHsi(state, origin: _captureOrigin);
    final timestampMs = sample.at.millisecondsSinceEpoch;
    if (timestampMs <= _lastPublishedTimestampMs) return;
    if (sample.availableAxes.isEmpty) return;


    _lastPublishedTimestampMs = timestampMs;
    _hsiFrameCount++;
    _latest = sample;
    if (_activeCoreSessionId != null) _sessionStates.add(sample);
    if (!_states.isClosed) _states.add(sample);
    _refreshStatus();
  }

  @override
  Future<IntegrationHealth> health() async {
    if (!_initialized) {
      return IntegrationHealth(phase: _status.phase, error: _status.error);
    }
    final diagnostics = Synheart.runtimeDiagnostics(probeAll: true);
    final effective = Synheart.consentEffectiveStateTyped();
    final auth = Synheart.coreDeviceAuthStatus();
    final authState = (auth?['status'] ?? auth?['state'])
        ?.toString()
        .toLowerCase();
    final deviceReady =
        _deviceAuthReady ||
        auth?['registered'] == true ||
        auth?['ready'] == true ||
        authState == 'registered' ||
        authState == 'ready';
    final consentMachine = Synheart.consentStatus();
    final consentState = consentMachine?['status']?.toString().toLowerCase();
    final tokenReady =
        effective?.cloudUpload == true &&
        consentState == 'granted' &&
        !Synheart.consentNeedsTokenRefresh() &&
        !Synheart.consentTokenSubjectStale();
    String? buildInfo;
    try {
      buildInfo = jsonEncode(Synheart.buildInfo);
    } catch (_) {}
    final ingestion = await ingestionStatus();
    final connectivity = await Connectivity().checkConnectivity();
    final networkAvailable = !connectivity.contains(ConnectivityResult.none);
    return IntegrationHealth(
      phase: _status.phase,
      runtimeAvailable: diagnostics['isAvailable'] == true,
      runtimeVersion: diagnostics['version']?.toString(),
      buildInfo: buildInfo,
      biosignalConsent: effective?.biosignals == true,
      cloudUploadConsent: effective?.cloudUpload == true,
      deviceAuthReady: deviceReady,
      cloudTokenReady: tokenReady,
      networkAvailable: networkAvailable,
      hsiFrameCount: _status.frameCount,
      hrPushCount: _hrPushCount,
      rrPushCount: _rrPushCount,
      ingestion: ingestion,
      error: _diagnosticFailure,
    );
  }

  @override
  Future<IngestionSnapshot> ingestionStatus() async {
    if (!_initialized || Synheart.runtimeDiagnostics()['isAvailable'] != true) {
      return const IngestionSnapshot(
        state: SyncState.failed,
        error: 'Native Core is unavailable.',
      );
    }
    if (Synheart.consentEffectiveStateTyped()?.cloudUpload != true) {
      return const IngestionSnapshot(state: SyncState.localOnly);
    }
    final queue = Synheart.ingestion.queueStatus;
    final online = !(await Connectivity().checkConnectivity()).contains(
      ConnectivityResult.none,
    );
    final error = queue.lastUploadError;
    _lastIngestion = IngestionSnapshot(
      state: !online && queue.queueLength > 0
          ? SyncState.offlineQueued
          : error != null
          ? _errorState(error)
          : queue.queueLength > 0
          ? SyncState.pending
          : queue.lastUploadAt != null
          ? SyncState.synced
          : SyncState.pending,
      queueLength: queue.queueLength,
      lastUploadAt: queue.lastUploadAt,
      lastAttemptAt: queue.lastUploadAttemptAt,
      error: error,
    );
    return _lastIngestion;
  }

  @override
  Future<IngestionSnapshot> flushIngestion() async {
    final before = await ingestionStatus();
    if (before.state == SyncState.localOnly ||
        before.state == SyncState.offlineQueued) {
      return before;
    }
    try {
      _deviceAuthReady = await Synheart.ensureDeviceAuthRegistered();
      if (!_deviceAuthReady) {
        return _lastIngestion = IngestionSnapshot(
          state: SyncState.rejected,
          queueLength: before.queueLength,
          lastAttemptAt: DateTime.now(),
          error: 'Device authorization is not ready.',
        );
      }
      if (!await Synheart.ensureCloudConsentReady()) {
        return _lastIngestion = IngestionSnapshot(
          state: SyncState.pending,
          queueLength: before.queueLength,
          lastAttemptAt: DateTime.now(),
          error: 'Cloud consent token is pending.',
        );
      }
      final result = await Synheart.ingestion.flushIfEligible().timeout(
        const Duration(seconds: 15),
      );
      final queue = Synheart.ingestion.queueStatus;
      final state = !result.success
          ? _errorState(result.errorMessage ?? queue.lastUploadError)
          : queue.queueLength > 0
          ? SyncState.pending
          : result.uploaded > 0 || queue.lastUploadAt != null
          ? SyncState.synced
          : SyncState.pending;
      _lastIngestion = IngestionSnapshot(
        state: state,
        queueLength: queue.queueLength,
        uploaded: result.uploaded,
        failed: result.failed,
        requeued: result.requeued,
        lastUploadAt: queue.lastUploadAt,
        lastAttemptAt: queue.lastUploadAttemptAt,
        error: result.errorMessage ?? queue.lastUploadError,
      );
      return _lastIngestion;
    } catch (error) {
      final online = !(await Connectivity().checkConnectivity()).contains(
        ConnectivityResult.none,
      );
      _lastIngestion = IngestionSnapshot(
        state: online
            ? _errorState(error.toString())
            : before.queueLength > 0
            ? SyncState.offlineQueued
            : SyncState.pending,
        queueLength: before.queueLength,
        lastAttemptAt: DateTime.now(),
        error: _safeError(error),
      );
      return _lastIngestion;
    }
  }

  SyncState _errorState(String? error) {
    final value = error?.toLowerCase() ?? '';
    return value.contains('401') ||
            value.contains('403') ||
            value.contains('attest') ||
            value.contains('consent') ||
            value.contains('reject')
        ? SyncState.rejected
        : SyncState.failed;
  }

  void _refreshStatus() {
    if (!_initialized || _status.phase == HsiPhase.failed) return;
    final diagnostics = Synheart.runtimeDiagnostics();
    _setStatus(
      HsiStatus(
        phase: consented ? HsiPhase.ready : HsiPhase.awaitingConsent,
        runtimeVersion: diagnostics['version']?.toString(),
        frameCount: _hsiFrameCount,
        hrPushCount: _hrPushCount,
        rrPushCount: _rrPushCount,
      ),
    );
  }

  void _setStatus(HsiStatus value) {
    _status = value;
    if (!_statuses.isClosed) _statuses.add(value);
  }

  void _captureRuntimeLog(String line) {
    final safe = _safeText(line);
    if (safe.isEmpty) return;
    _runtimeLogs.add(safe);
    if (_runtimeLogs.length > 80) _runtimeLogs.removeAt(0);
  }

  String _safeText(String value) => value
      .replaceAll(
        RegExp(
          r'(api[_-]?key|secret|token|proof|subject[_-]?id)[=: ]+[^\s,}]+',
          caseSensitive: false,
        ),
        r'$1=<redacted>',
      )
      .trim();

  String _safeError(Object value) => _safeText(value.toString());

  @override
  String sanitizedDiagnostics() {
    final diagnostics = _initialized
        ? Synheart.runtimeDiagnostics(probeAll: true)
        : <String, dynamic>{'isAvailable': false};
    return const JsonEncoder.withIndent('  ').convert({
      'generated_at': DateTime.now().toUtc().toIso8601String(),
      'package': 'com.studybuddy.app',
      'configured': configured,
      'phase': _status.phase.name,
      'runtime': {
        'available': diagnostics['isAvailable'] == true,
        'version': diagnostics['version'],
        'frames': _status.frameCount,
        'accepted_hr_pushes': _hrPushCount,
        'accepted_rr_pushes': _rrPushCount,
      },
      'consent': _initialized
          ? {
              'biosignals': Synheart.consentEffectiveStateTyped()?.biosignals,
              'cloud_upload':
                  Synheart.consentEffectiveStateTyped()?.cloudUpload,
              'status': Synheart.consentStatus()?['status'],
            }
          : null,
      'device_auth': _initialized ? Synheart.coreDeviceAuthStatus() : null,
      'ingestion': {
        'state': _lastIngestion.state.name,
        'queue_length': _lastIngestion.queueLength,
        'uploaded': _lastIngestion.uploaded,
        'failed': _lastIngestion.failed,
        'last_upload_at': _lastIngestion.lastUploadAt?.toIso8601String(),
        'last_attempt_at': _lastIngestion.lastAttemptAt?.toIso8601String(),
        'error': _lastIngestion.error,
      },
      'logs': _runtimeLogs,
      'failure': _diagnosticFailure,
    });
  }

  Future<String> _loadOrCreateSubjectId() async {
    var id = await _secureStorage.read(key: _subjectKey);
    if (id != null && id.isNotEmpty) return id;

    final directory = await getApplicationSupportDirectory();
    final legacy = File(p.join(directory.path, 'subject_id'));
    if (await legacy.exists()) {
      final value = (await legacy.readAsString()).trim();
      if (value.isNotEmpty) id = value;
      await legacy.delete();
    }
    id ??= 'sb_${_uuid.v4()}';
    await _secureStorage.write(key: _subjectKey, value: id);
    return id;
  }

  @override
  Future<void> wipeLocalData() async {
    if (_initialized) await Synheart.wipeLocalData();
    await _secureStorage.delete(key: _subjectKey);
  }

  @override
  Future<void> dispose() async {
    await _rawSubscription?.cancel();
    if (_initialized) await Synheart.dispose();
    await _states.close();
    await _statuses.close();
  }
}


StateSample stateSampleFromHsi(
  HSIState state, {
  SignalOrigin origin = SignalOrigin.wearableReal,
}) {
  final axes = state.hsi;
  String? version;
  DateTime? observedAt;
  double? sourceQuality;
  try {
    final raw = jsonDecode(state.rawJson) as Map<String, dynamic>;
    version = raw['hsi_version']?.toString();
    final timestamp = raw['timestamp_ms'] ?? raw['observed_at_ms'];
    if (timestamp is num) {
      observedAt = DateTime.fromMillisecondsSinceEpoch(timestamp.toInt());
    } else if (raw['observed_at_utc'] case final String value) {
      observedAt = DateTime.tryParse(value);
    }
    final windows = raw['windows'];
    if (observedAt == null && windows is Map) {
      final ends = windows.values
          .whereType<Map>()
          .map(
            (window) => DateTime.tryParse(window['end_utc']?.toString() ?? ''),
          )
          .whereType<DateTime>()
          .toList(growable: false);
      if (ends.isNotEmpty) {
        ends.sort();
        observedAt = ends.last;
      }
    }
    final sources = raw['meta'] is Map
        ? (raw['meta'] as Map)['provenance'] is Map
              ? ((raw['meta'] as Map)['provenance'] as Map)['sources']
              : null
        : null;
    if (sources is Map) {
      final qualities = sources.values
          .whereType<Map>()
          .map((source) => source['quality'])
          .whereType<num>()
          .map((value) => value.toDouble())
          .where((value) => value.isFinite)
          .toList(growable: false);
      if (qualities.isNotEmpty) {
        sourceQuality = qualities.reduce((a, b) => a + b) / qualities.length;
      }
    }
  } catch (_) {


  }

  return StateSample(
    at: observedAt ?? DateTime.fromMillisecondsSinceEpoch(state.timestampMs),
    origin: origin,
    focus: axes.focus?.value,
    capacity: axes.capacity?.value,
    arousal: axes.arousal?.value,
    stress: axes.stress?.value,
    sleep: axes.sleep?.value,
    focusConfidence: axes.focus?.confidence,
    capacityConfidence: axes.capacity?.confidence,
    arousalConfidence: axes.arousal?.confidence,
    stressConfidence: axes.stress?.confidence,
    sleepConfidence: axes.sleep?.confidence,
    quality: sourceQuality,
    hsiVersion: version,
  );
}
