import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui/ui.dart';
import 'package:uuid/uuid.dart';

import '../../app/providers.dart';
import '../../domain/enums.dart';
import '../../domain/study_logic.dart';
import '../biosignal/bio_reading.dart';
import '../biosignal/biosignal_service.dart';
import '../biosignal/watch_sample_push.dart';
import '../state/ambient_measurement.dart';
import '../state/hsi_panel.dart';
import '../state/hsi_engine.dart';
import '../state/hsi_providers.dart';
import '../state/rest_alert_host.dart';

class ReadinessResult {
  const ReadinessResult({this.state, this.bio, this.core, this.error});

  final StateSample? state;
  final BioOutcome? bio;
  final CoreCaptureResult? core;
  final String? error;


  bool get measured =>
      bio != null &&
      bio!.acceptedSamples >= 20 &&
      bio!.coverageSeconds >= 40 &&
      state?.isEligible == true;
}

class ReadinessScanSheet extends ConsumerStatefulWidget {
  const ReadinessScanSheet({super.key});

  static Future<ReadinessResult?> show(BuildContext context) {
    return showModalBottomSheet<ReadinessResult>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      builder: (_) => const ReadinessScanSheet(),
    );
  }

  @override
  ConsumerState<ReadinessScanSheet> createState() => _ReadinessScanSheetState();
}

class _ReadinessScanSheetState extends ConsumerState<ReadinessScanSheet> {


  static const _duration = Duration(seconds: 75);

  BiosignalService? _bio;
  StreamSubscription<BioReading>? _readings;
  StreamSubscription<StateSample>? _states;
  Timer? _timer;
  DateTime? _started;
  String? _sessionId;
  HumanStateGateway? _hsi;
  StateSample? _latest;
  String? _error;
  bool _checking = true;
  bool _finishing = false;
  bool _holdsExclusive = false;
  bool _holdsRestSuppression = false;

  @override
  void initState() {
    super.initState();


    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(_start());
    });
  }

  Future<void> _start() async {


    final ambient = ref.read(ambientMeasurementProvider);
    final hsi = ref.read(hsiEngineProvider);
    final bio = ref.read(biosignalServiceFactoryProvider)();
    _hsi = hsi;
    _bio = bio;
    ref.read(restAlertSuppressionProvider.notifier).acquire();
    _holdsRestSuppression = true;
    try {
      await ambient.acquireExclusive().timeout(
        const Duration(seconds: 12),
        onTimeout: () => throw TimeoutException(
          'Stopping the current watch session timed out.',
        ),
      );
      _holdsExclusive = true;
      if (!mounted) {
        await bio.dispose();
        await _releaseExclusive();
        return;
      }
      final watchReady = await bio.isWatchReady().timeout(
        const Duration(seconds: 8),
        onTimeout: () => false,
      );
      if (!watchReady) {
        throw StateError(
          'The watch is not reachable. Open Study Buddy on the watch and grant its sensor permission.',
        );
      }
      if (!hsi.ready) {
        throw StateError(
          'Measured state is not ready. You can start with the default length.',
        );
      }
      _states = hsi.states.listen((sample) {
        if (mounted) setState(() => _latest = sample);
      });
      _readings = bio.readings.listen((reading) {
        hsi.feedWatchReading(reading);
      });
      final coreId = await hsi
          .startCoreSession(_duration)
          .timeout(const Duration(seconds: 20), onTimeout: () => null);
      if (coreId == null) {
        throw StateError('Synheart Core could not start a readiness session.');
      }
      if (!mounted) {
        await hsi.stopCoreSession();
        await bio.dispose();
        await _releaseExclusive();
        return;
      }
      _sessionId = 'readiness_${const Uuid().v4()}';
      await bio
          .start(
            sessionId: _sessionId!,
            planned: _duration,
            windowLabel: 'readiness',
          )
          .timeout(const Duration(seconds: 15));
      _started = DateTime.now();
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        setState(() {});
        if (DateTime.now().difference(_started!) >= _duration) {
          unawaited(_finish());
        }
      });
      if (mounted) setState(() => _checking = false);
    } catch (error) {
      _timer?.cancel();
      await _readings?.cancel();
      _readings = null;
      await _states?.cancel();
      _states = null;
      await _bio?.stop(_sessionId ?? '');
      await _hsi?.stopCoreSession();
      await _bio?.dispose();
      await _releaseExclusive();
      if (_holdsRestSuppression) {
        _holdsRestSuppression = false;
        ref.read(restAlertSuppressionProvider.notifier).release();
      }
      if (mounted) {
        setState(() {
          _checking = false;
          _error = 'Readiness measurement failed: $error';
        });
      }
    }
  }

  Future<void> _finish() async {
    if (_finishing) return;
    _finishing = true;
    _timer?.cancel();
    final bio = _bio;
    final outcome = bio == null
        ? const BioOutcome(origin: SignalOrigin.unmeasured)
        : await bio.stop(_sessionId ?? '');


    await Future<void>.delayed(const Duration(seconds: 3));
    final core = await _hsi?.stopCoreSession() ?? const CoreCaptureResult();
    final result = ReadinessResult(
      state: core.meanState ?? _latest,
      bio: outcome,
      core: core,
      error: core.error,
    );
    await _releaseExclusive();
    if (mounted) Navigator.of(context).pop(result);
  }

  Future<void> _continueUnmeasured() async {
    if (_finishing) return;
    _finishing = true;
    _timer?.cancel();
    await _bio?.stop(_sessionId ?? '');
    await _hsi?.stopCoreSession();
    await _releaseExclusive();
    if (mounted) Navigator.of(context).pop(ReadinessResult(error: _error));
  }

  Future<void> _releaseExclusive() async {
    if (!_holdsExclusive) return;
    _holdsExclusive = false;
    await ref.read(ambientMeasurementProvider).releaseExclusive();
  }

  @override
  void dispose() {
    _timer?.cancel();
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
    final elapsed = _started == null
        ? Duration.zero
        : DateTime.now().difference(_started!);
    final remaining = (_duration.inSeconds - elapsed.inSeconds).clamp(
      0,
      _duration.inSeconds,
    );
    final status =
        ref.watch(hsiStatusProvider).value ??
        ref.read(hsiEngineProvider).status;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          SbSpace.xl,
          SbSpace.xl,
          SbSpace.xl,
          SbSpace.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Eyebrow('Before you start'),
            const SizedBox(height: SbSpace.xs),
            Text('How ready are you?', style: context.text.headlineSmall),
            const SizedBox(height: SbSpace.xs),
            Text(
              _checking
                  ? 'Checking your watch…'
                  : _error ??
                        'Hold still for a moment — your watch is reading '
                            'your state.',
              style: context.text.bodyMedium,
            ),
            const SizedBox(height: SbSpace.lg),
            HsiPanel(sample: _latest, status: status, compact: true),
            if (_started != null) ...[
              const SizedBox(height: SbSpace.lg),
              LinearProgressIndicator(
                value: (elapsed.inSeconds / _duration.inSeconds).clamp(0, 1),
              ),
              const SizedBox(height: SbSpace.xs),
              Text(
                '$remaining seconds remaining',
                textAlign: TextAlign.center,
                style: context.text.bodySmall?.merge(SbType.tabular),
              ),
            ],
            const SizedBox(height: SbSpace.lg),
            if (_error != null)
              FilledButton(
                onPressed: _continueUnmeasured,
                child: const Text('Continue unmeasured'),
              )
            else

              OutlinedButton(
                onPressed: _continueUnmeasured,
                child: const Text('Skip — use default length'),
              ),
          ],
        ),
      ),
    );
  }
}
