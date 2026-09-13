import 'package:flutter/services.dart';

import 'watch_event_gate.dart';

class WatchDiagnostic {
  const WatchDiagnostic({
    this.installed = false,
    this.reachable = false,
    this.permissionGranted = false,
    this.sensorSupported = false,
    this.sensorAvailable = false,
    this.quality = 'unknown',
    this.captureState = 'IDLE',
    this.frameSeq = 0,
    this.acceptedHrTotal = 0,
    this.acceptedRrTotal = 0,
    this.droppedSamplesTotal = 0,
    this.lastEventAgeMs,
    this.accuracyCounts = const {},
    this.transport = const TransportDiagnostics(),
    this.syntheticInput = false,
    this.preset,
    this.effectiveSeed,
    this.provenance,
    this.error,
  });

  final bool installed;
  final bool reachable;
  final bool permissionGranted;
  final bool sensorSupported;
  final bool sensorAvailable;
  final String quality;
  final String captureState;
  final int frameSeq;
  final int acceptedHrTotal;
  final int acceptedRrTotal;
  final int droppedSamplesTotal;
  final int? lastEventAgeMs;
  final Map<String, int> accuracyCounts;
  final TransportDiagnostics transport;
  final bool syntheticInput;
  final String? preset;
  final int? effectiveSeed;
  final String? provenance;
  final String? error;

  bool get ready =>
      installed && reachable && permissionGranted && sensorSupported;

  bool get capturing =>
      captureState == 'STARTING' ||
      captureState == 'RUNNING' ||
      captureState == 'STOPPING';
}

class WatchDiagnosticService {
  const WatchDiagnosticService();

  static const _channel = MethodChannel('studybuddy/host');

  Future<WatchDiagnostic> check() async {
    try {
      final raw = await _channel.invokeMapMethod<Object?, Object?>(
        'getWatchDiagnostic',
      );
      if (raw == null) {
        return const WatchDiagnostic(error: 'The watch did not respond.');
      }
      return fromRaw(raw);
    } on PlatformException catch (error) {
      return WatchDiagnostic(error: error.message ?? error.code);
    } on MissingPluginException {
      return const WatchDiagnostic(error: 'Android watch bridge unavailable.');
    }
  }

  static WatchDiagnostic fromRaw(Map<Object?, Object?> raw) {
    final accuracy = <String, int>{};
    final rawAccuracy = raw['accuracy_counts'];
    if (rawAccuracy is Map) {
      for (final entry in rawAccuracy.entries) {
        final value = entry.value;
        if (value is num) accuracy[entry.key.toString()] = value.toInt();
      }
    }
    final transportRaw = raw['transport'];
    return WatchDiagnostic(
      installed: raw['installed'] == true,
      reachable: true,
      permissionGranted: raw['permissionGranted'] == true,
      sensorSupported: raw['heartRateSupported'] == true,
      sensorAvailable: raw['sensorAvailable'] == true,
      quality: raw['lastQuality']?.toString() ?? 'unknown',
      captureState:
          raw['capture_state']?.toString() ??
          (raw['active'] == true ? 'RUNNING' : 'IDLE'),
      frameSeq: (raw['frame_seq'] as num?)?.toInt() ?? 0,
      acceptedHrTotal:
          (raw['accepted_hr_total'] as num?)?.toInt() ??
          (raw['accepted_samples'] as num?)?.toInt() ??
          0,
      acceptedRrTotal: (raw['accepted_rr_total'] as num?)?.toInt() ?? 0,
      droppedSamplesTotal: (raw['dropped_samples_total'] as num?)?.toInt() ?? 0,
      lastEventAgeMs: (raw['last_event_age_ms'] as num?)?.toInt(),
      accuracyCounts: accuracy,
      transport: TransportDiagnostics.fromJson(
        transportRaw is Map
            ? Map<String, dynamic>.from(
                transportRaw.map((key, value) => MapEntry('$key', value)),
              )
            : null,
      ),
      syntheticInput: raw['synthetic_input'] == true,
      preset: raw['preset']?.toString(),
      effectiveSeed: (raw['effective_seed'] as num?)?.toInt(),
      provenance: raw['provenance']?.toString(),
      error: raw['error']?.toString(),
    );
  }
}
