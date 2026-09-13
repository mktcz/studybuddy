import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui/ui.dart';
import 'package:uuid/uuid.dart';

import '../../app/providers.dart';
import '../../domain/enums.dart';
import '../../domain/study_logic.dart';
import '../biosignal/bio_reading.dart';
import '../biosignal/biosignal_service.dart';
import '../biosignal/watch_diagnostic.dart';
import '../biosignal/watch_sample_push.dart';
import '../state/ambient_measurement.dart';
import '../state/hsi_panel.dart';
import '../state/hsi_engine.dart';
import '../state/hsi_providers.dart';
import '../state/rest_alert_host.dart';


const signalCheckDuration = Duration(seconds: 180);

class SignalCheckScreen extends ConsumerStatefulWidget {
  const SignalCheckScreen({super.key});

  @override
  ConsumerState<SignalCheckScreen> createState() => _SignalCheckScreenState();
}

class _SignalCheckScreenState extends ConsumerState<SignalCheckScreen> {
  BiosignalService? _bio;
  StreamSubscription<BioReading>? _readings;
  StreamSubscription<StateSample>? _states;
  Timer? _timer;
  Timer? _watchPoll;
  String? _sessionId;
  int _frames = 0;
  int _lastSeq = 0;
  int _acceptedHr = 0;
  int _acceptedRr = 0;
  int _dropped = 0;
  int _hsiWindows = 0;
  DateTime? _firstAcceptedAt;
  DateTime? _lastAcceptedAt;
  DateTime? _lastEventAt;
  StateSample? _latest;
  BioOutcome? _outcome;
  CoreCaptureResult? _core;
  HumanStateGateway? _gateway;
  WatchDiagnostic? _watch;
  String? _error;
  bool _running = false;
  bool _stopping = false;
  bool _holdsExclusive = false;
  bool _holdsRestSuppression = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _holdsRestSuppression) return;
      ref.read(restAlertSuppressionProvider.notifier).acquire();
      _holdsRestSuppression = true;
    });
  }

  Future<void> _run() async {
    if (_running) return;
    final ambient = ref.read(ambientMeasurementProvider);
    final gateway = ref.read(hsiEngineProvider);
    final bio = ref.read(biosignalServiceFactoryProvider)();
    _gateway = gateway;
    _bio = bio;
    setState(() {
      _running = true;
      _frames = 0;
      _lastSeq = 0;
      _acceptedHr = 0;
      _acceptedRr = 0;
      _dropped = 0;
      _hsiWindows = 0;
      _firstAcceptedAt = null;
      _lastAcceptedAt = null;
      _lastEventAt = null;
      _latest = null;
      _outcome = null;
      _core = null;
      _watch = null;
      _error = null;
    });
    try {
      await ambient.acquireExclusive();
      _holdsExclusive = true;
      if (!mounted) {
        await _releaseExclusive();
        return;
      }
      await _refreshWatch();
      if (!mounted) return;
      final watch = _watch;
      if (watch == null || !watch.reachable) {
        throw StateError('The watch companion is not reachable.');
      }
      if (!watch.permissionGranted) {
        throw StateError('Heart-rate permission is not granted on the watch.');
      }
      if (!watch.sensorSupported) {
        throw StateError(
          'Health Services does not expose heart rate on this watch.',
        );
      }
      if (!gateway.ready) {
        throw StateError('Synheart Core or wearable consent is not ready.');
      }
      _states = gateway.states.listen((sample) {
        if (!mounted) return;
        setState(() {
          _latest = sample;
          _hsiWindows++;
        });
      });
      _readings = bio.readings.listen((reading) {
        _frames++;
        _lastEventAt = DateTime.now();
        if (reading.seq != null && reading.seq! > _lastSeq) {
          _lastSeq = reading.seq!;
        }
        if (reading.acceptedSamplesTotal > _acceptedHr) {
          _acceptedHr = reading.acceptedSamplesTotal;
        }
        if (reading.acceptedRrTotal > _acceptedRr) {
          _acceptedRr = reading.acceptedRrTotal;
        }
        if (reading.droppedSamplesTotal > _dropped) {
          _dropped = reading.droppedSamplesTotal;
        }
        if (reading.bpm != null || reading.rrIntervalMs != null) {
          _firstAcceptedAt ??= reading.at;
          _lastAcceptedAt = reading.at;
        }
        gateway.feedWatchReading(reading);
        if (mounted) setState(() {});
      });
      _sessionId = 'diagnostic_${const Uuid().v4()}';
      await gateway.startCoreSession(signalCheckDuration);
      await bio.start(
        sessionId: _sessionId!,
        planned: signalCheckDuration,
        windowLabel: 'readiness_debug',
      );
      _timer = Timer(signalCheckDuration, _stop);
      _watchPoll = Timer.periodic(
        const Duration(seconds: 5),
        (_) => _refreshWatch(),
      );
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
      await _stop();
    }
  }

  Future<void> _refreshWatch() async {
    final watch = await const WatchDiagnosticService().check();
    if (mounted) setState(() => _watch = watch);
  }

  Future<void> _stop() async {
    if (_stopping) return;
    _stopping = true;
    _timer?.cancel();
    _timer = null;
    _watchPoll?.cancel();
    _watchPoll = null;
    final outcome = await _bio?.stop(_sessionId ?? '');
    final gateway = _gateway;
    final core = await gateway?.stopCoreSession() ?? const CoreCaptureResult();
    _core = core;
    if (outcome != null) _outcome = outcome;
    await _readings?.cancel();
    await _states?.cancel();
    await _bio?.dispose();
    _bio = null;
    _readings = null;
    _states = null;
    await _refreshWatch();
    if (outcome != null &&
        outcome.origin != SignalOrigin.unmeasured &&
        core.windowCount > 0 &&
        gateway != null) {
      await gateway.flushIngestion();
    }
    await _releaseExclusive();
    if (mounted) {
      setState(() {
        _running = false;
        _stopping = false;
      });
      ref.invalidate(integrationHealthProvider);
      ref.invalidate(ingestionStatusProvider);
    }
  }

  Future<void> _releaseExclusive() async {
    if (!_holdsExclusive) return;
    _holdsExclusive = false;
    await ref.read(ambientMeasurementProvider).releaseExclusive();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _watchPoll?.cancel();
    _readings?.cancel();
    _states?.cancel();
    _bio?.dispose();
    if (_holdsExclusive) {
      _holdsExclusive = false;
      unawaited(ref.read(ambientMeasurementProvider).releaseExclusive());
    }
    if (_holdsRestSuppression) {
      _holdsRestSuppression = false;
      ref.read(restAlertSuppressionProvider.notifier).release();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final health = ref.watch(integrationHealthProvider).value;
    final status =
        ref.watch(hsiStatusProvider).value ??
        ref.read(hsiEngineProvider).status;
    final watch = _watch;
    final lastEventAge = _lastEventAgeLabel(watch);
    return PopScope(
      canPop: !_running,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await _stop();
        if (context.mounted) Navigator.of(context).pop();
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Signal check')),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(
            SbSpace.gutter,
            SbSpace.lg,
            SbSpace.gutter,
            SbSpace.xxxl,
          ),
          children: [
            Text(
              'This follows real watch HR and RR through Synheart Core. '
              'A four-axis reading needs about three minutes of RR/HRV.',
              style: context.text.bodyLarge,
            ),
            const SizedBox(height: SbSpace.lg),
            _CheckRow(
              label: 'Watch connection and permission',
              passed:
                  watch?.installed == true &&
                  watch?.reachable == true &&
                  watch?.permissionGranted == true,
              value: watch?.permissionGranted == true ? 'granted' : 'needed',
            ),
            _CheckRow(
              label: 'Capture state',
              passed:
                  watch?.capturing == true || (_outcome?.isMeasured ?? false),
              value: watch?.captureState ?? 'IDLE',
            ),
            _CheckRow(
              label: 'Last event age',
              passed: lastEventAge != null,
              value: lastEventAge ?? '—',
            ),
            _CheckRow(
              label: 'Frame sequence',
              passed: _frames > 0 || _lastSeq > 0,
              value: '${watch?.frameSeq ?? _lastSeq}',
            ),
            _CheckRow(
              label: 'HR samples (total / accepted)',
              passed: _acceptedHr > 0,
              value:
                  '${_outcome?.totalSamples ?? (_acceptedHr + _dropped)} / '
                  '${_outcome?.acceptedSamples ?? _acceptedHr}',
            ),
            _CheckRow(
              label: 'RR samples (total / accepted)',
              passed: (_outcome?.acceptedRrSamples ?? _acceptedRr) > 0,
              value: '${_outcome?.acceptedRrSamples ?? _acceptedRr}',
            ),
            _CheckRow(
              label: 'Rejections by accuracy',
              passed: true,
              value: _accuracySummary(watch),
            ),
            _CheckRow(
              label: 'Data Layer queue',
              passed: (watch?.transport.queueDepth ?? 0) == 0 || _running,
              value:
                  'depth ${watch?.transport.queueDepth ?? 0}'
                  '${watch?.transport.lastError == null ? '' : ', error'}',
            ),
            _CheckRow(
              label: 'Core HR push count',
              passed: status.hrPushCount > 0,
              value: '${status.hrPushCount}',
            ),
            _CheckRow(
              label: 'Core RR push count',
              passed: status.rrPushCount > 0,
              value: '${status.rrPushCount}',
            ),
            _CheckRow(
              label: 'HSI window count',
              passed: (_core?.windowCount ?? _hsiWindows) > 0,
              value: '${_core?.windowCount ?? _hsiWindows}',
            ),
            _CheckRow(
              label: 'Simulator preset / seed',
              passed: true,
              value: watch?.syntheticInput == true
                  ? '${watch?.preset ?? '—'} / ${watch?.effectiveSeed ?? '—'}'
                  : 'production',
            ),
            _CheckRow(
              label: 'Provenance',
              passed: true,
              value:
                  watch?.provenance ??
                  (watch?.syntheticInput == true
                      ? 'watch_synthetic'
                      : 'wearable_real'),
            ),
            _CheckRow(
              label: 'Focus degenerate',
              passed: _latest?.focusDegenerate != true,
              value: _latest?.focusDegenerate == true
                  ? 'yes (raw ${_latest?.focus})'
                  : 'no',
            ),
            const SizedBox(height: SbSpace.sm),
            ...hsiAxisNames.map(_axisRow),
            const SizedBox(height: SbSpace.lg),
            HsiPanel(sample: _latest, status: status),
            if (_error != null) ...[
              const SizedBox(height: SbSpace.sm),
              Text(_error!, style: context.text.bodyMedium),
            ],
            if (!_running) ...[
              const SizedBox(height: SbSpace.sm),
              Text(_recovery(health), style: context.text.bodyMedium),
            ],
            const SizedBox(height: SbSpace.lg),
            FilledButton(
              onPressed: _running ? _stop : _run,
              child: Text(_running ? 'Stop check' : 'Run 180-second check'),
            ),
            const SizedBox(height: SbSpace.sm),
            OutlinedButton.icon(
              onPressed: () async {
                await Clipboard.setData(
                  ClipboardData(text: _diagnosticReport(health, status)),
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Sanitized diagnostics copied.'),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.copy_outlined),
              label: const Text('Copy sanitized diagnostics'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _axisRow(String name) {
    final sample = _latest;
    final axis = sample?.availableAxes[name];
    final windows = _core?.windowCount ?? _hsiWindows;
    final rr = _outcome?.acceptedRrSamples ?? _acceptedRr;
    if (axis != null) {
      return _CheckRow(
        label: '$name value / confidence',
        passed: axis.confidence > 0,
        value:
            '${axis.value.toStringAsFixed(2)} / '
            '${axis.confidence.toStringAsFixed(2)}',
      );
    }
    final reason = axisUnavailableReason(
      axis: name,
      sample: sample,
      hsiWindowCount: windows,
      acceptedRrCount: rr,
    );
    return _CheckRow(label: name, passed: false, value: reason ?? '—');
  }

  String? _lastEventAgeLabel(WatchDiagnostic? watch) {
    final ageMs = watch?.lastEventAgeMs;
    if (ageMs != null) return '${(ageMs / 1000).round()}s';
    final at = _lastEventAt;
    if (at == null) return null;
    return '${DateTime.now().difference(at).inSeconds}s';
  }

  String _accuracySummary(WatchDiagnostic? watch) {
    final counts =
        watch?.accuracyCounts ??
        _outcome?.accuracyCounts.map(
          (key, value) => MapEntry(key.name, value),
        ) ??
        const <String, int>{};
    if (counts.isEmpty) return 'none';
    return counts.entries
        .where((entry) => entry.value > 0)
        .map((entry) => '${entry.key} ${entry.value}')
        .join(', ');
  }

  String _recovery(IntegrationHealth? health) {
    if (_watch?.reachable != true) {
      return 'Recovery: open Study Buddy on the paired watch and keep both devices connected, then retry.';
    }
    if (_watch?.permissionGranted != true) {
      return 'Recovery: grant heart-rate permission inside the watch app, then retry.';
    }
    if (_watch?.sensorSupported != true) {
      return 'Recovery: this watch must expose heart rate through Health Services.';
    }
    if ((_outcome?.acceptedSamples ?? _acceptedHr) < 30) {
      return 'Recovery: tighten the watch slightly and keep still until at least 30 medium/high-accuracy samples arrive.';
    }
    if ((_outcome?.acceptedRrSamples ?? _acceptedRr) <= 0) {
      return 'Recovery: affective axes need RR/HRV from the watch. A physical HR-only watch cannot invent them; use the debug fixture for a four-axis demo.';
    }
    if (health?.runtimeAvailable != true) {
      return 'Recovery: reinstall the pinned Synheart Core runtime and verify the ABI diagnostic.';
    }
    if (health?.deviceAuthReady != true || health?.cloudTokenReady != true) {
      return 'Local HSI works. Cloud recovery requires valid platform authorization and an effective cloud consent token.';
    }
    return 'Signal path is ready. Cloud queue state is shown above.';
  }

  String _diagnosticReport(IntegrationHealth? health, HsiStatus status) {
    return const JsonEncoder.withIndent('  ').convert({
      'generated_at': DateTime.now().toUtc().toIso8601String(),
      'watch': {
        'installed': _watch?.installed,
        'reachable': _watch?.reachable,
        'permission_granted': _watch?.permissionGranted,
        'sensor_supported': _watch?.sensorSupported,
        'sensor_available': _watch?.sensorAvailable,
        'capture_state': _watch?.captureState,
        'last_quality': _watch?.quality,
        'last_event_age_ms': _watch?.lastEventAgeMs,
        'frame_seq': _watch?.frameSeq ?? _lastSeq,
        'accepted_hr_total': _outcome?.acceptedSamples ?? _acceptedHr,
        'accepted_rr_total': _outcome?.acceptedRrSamples ?? _acceptedRr,
        'dropped_samples_total': _outcome?.droppedSamples ?? _dropped,
        'accuracy_counts': _watch?.accuracyCounts,
        'synthetic_input': _watch?.syntheticInput,
        'preset': _watch?.preset,
        'effective_seed': _watch?.effectiveSeed,
        'provenance': _watch?.provenance,
        'error': _watch?.error,
      },
      'transport': {
        'queue_depth': _watch?.transport.queueDepth,
        'oldest_event_age_ms': _watch?.transport.oldestEventAgeMs,
        'last_send_at_ms': _watch?.transport.lastSendAtMs,
        'last_ack_at_ms': _watch?.transport.lastAckAtMs,
        'last_error': _watch?.transport.lastError,
        'five_second_frames': _frames,
        'coverage_seconds': _coverageSeconds,
      },
      'core': {
        'phase': status.phase.name,
        'runtime_available': health?.runtimeAvailable,
        'runtime_version': health?.runtimeVersion,
        'hr_push_count': status.hrPushCount,
        'rr_push_count': status.rrPushCount,
        'hsi_windows_seen': _core?.windowCount ?? _hsiWindows,
        'focus_degenerate': _latest?.focusDegenerate == true,
        'focus_raw': _latest?.focus,
        'axes': {
          for (final name in hsiAxisNames)
            name: _latest?.availableAxes[name] == null
                ? {
                    'value': null,
                    'confidence': null,
                    'reason': axisUnavailableReason(
                      axis: name,
                      sample: _latest,
                      hsiWindowCount: _core?.windowCount ?? _hsiWindows,
                      acceptedRrCount:
                          _outcome?.acceptedRrSamples ?? _acceptedRr,
                    ),
                  }
                : {
                    'value': _latest!.availableAxes[name]!.value,
                    'confidence': _latest!.availableAxes[name]!.confidence,
                    'reason': null,
                  },
        },
        'capture_error': _core?.error,
        'error': health?.error,
      },
      'cloud': {
        'device_auth_ready': health?.deviceAuthReady,
        'consent_token_ready': health?.cloudTokenReady,
        'queue_length': health?.ingestion.queueLength,
        'state': health?.ingestion.state.name,
        'last_upload_at': health?.ingestion.lastUploadAt?.toIso8601String(),
        'error': health?.ingestion.error,
      },
      'recovery': _recovery(health),
      'core_diagnostics': jsonDecode(
        ref.read(hsiEngineProvider).sanitizedDiagnostics(),
      ),
    });
  }

  int get _coverageSeconds {
    final completed = _outcome?.coverageSeconds;
    if (completed != null) return completed;
    final first = _firstAcceptedAt;
    final last = _lastAcceptedAt;
    if (first == null || last == null) return 0;
    return last.difference(first).inSeconds.clamp(0, 180);
  }
}

class _CheckRow extends StatelessWidget {
  const _CheckRow({required this.label, required this.passed, this.value});

  final String label;
  final bool passed;
  final String? value;

  @override
  Widget build(BuildContext context) {
    return HairlineRow(
      title: Text(label),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            passed ? Icons.check_circle_outline : Icons.remove_circle_outline,
            size: 18,
            color: passed ? context.sb.accent : context.sb.muted,
          ),
          if (value != null) ...[
            const SizedBox(width: SbSpace.xs),
            Text(value!),
          ],
        ],
      ),
    );
  }
}
