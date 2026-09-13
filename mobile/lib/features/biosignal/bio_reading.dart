import '../../domain/enums.dart';
import '../../domain/study_logic.dart';


class BioReading {
  const BioReading({
    required this.at,
    required this.bpm,
    required this.sampleCount,
    required this.origin,
    this.rrIntervalMs,
    this.acceptedSamplesTotal = 0,
    this.acceptedRrTotal = 0,
    this.droppedSamplesTotal = 0,
    this.schemaVersion = 1,
    this.sessionId,
    this.seq,
    this.accuracy,
    this.state,
  });

  final DateTime at;


  final double? bpm;


  final double? rrIntervalMs;

  final int sampleCount;
  final int acceptedSamplesTotal;
  final int acceptedRrTotal;
  final int droppedSamplesTotal;
  final int schemaVersion;
  final String? sessionId;
  final int? seq;
  final String? accuracy;
  final SignalOrigin origin;


  final StateSample? state;

  bool get isMeasured => bpm != null && sampleCount > 0;


  factory BioReading.fromMetrics(
    Map<String, dynamic> metrics, {
    required SignalOrigin origin,
    StateSample? state,
    DateTime? at,
    String? sessionId,
    int? seq,
  }) {


    final count =
        (metrics['frame_sample_count'] as num?)?.toInt() ??
        (metrics['accepted_samples_total'] as num?)?.toInt() ??
        (metrics['accepted_samples'] as num?)?.toInt() ??
        (metrics['sample_count'] as num?)?.toInt() ??
        0;
    final mean =
        (metrics['frame_hr_mean_bpm'] as num?)?.toDouble() ??
        (metrics['mean_hr_bpm'] as num?)?.toDouble() ??
        (metrics['hr_mean_bpm'] as num?)?.toDouble() ??
        0;
    final acceptedTotal =
        (metrics['accepted_samples_total'] as num?)?.toInt() ??
        (metrics['accepted_samples'] as num?)?.toInt() ??
        count;
    final acceptedRr =
        (metrics['accepted_rr_total'] as num?)?.toInt() ??
        (metrics['accepted_rr_samples'] as num?)?.toInt() ??
        0;
    final dropped =
        (metrics['dropped_samples_total'] as num?)?.toInt() ??
        (((metrics['total_samples'] as num?)?.toInt() ?? acceptedTotal) -
            acceptedTotal);
    final schema = (metrics['schema_version'] as num?)?.toInt() ?? 1;

    return BioReading(
      at: at ?? DateTime.now(),
      bpm: (count > 0 && mean > 0) ? mean.toDouble() : null,
      sampleCount: count,
      acceptedSamplesTotal: acceptedTotal,
      acceptedRrTotal: acceptedRr < 0 ? 0 : acceptedRr,
      droppedSamplesTotal: dropped < 0 ? 0 : dropped,
      schemaVersion: schema,
      sessionId: sessionId,
      seq: seq,
      origin: origin,
      state: state,
    );
  }
}


class BioOutcome {
  const BioOutcome({
    required this.origin,
    this.acceptedSamples = 0,
    this.acceptedRrSamples = 0,
    this.totalSamples = 0,
    this.droppedSamples = 0,
    this.coverageSeconds = 0,
    this.accuracyCounts = const {},
    this.watchSessionId,
    this.startedAt,
    this.lastSeq,
    this.state,
    this.errorMessage,
  });

  final SignalOrigin origin;

  final int acceptedSamples;
  final int acceptedRrSamples;
  final int totalSamples;
  final int droppedSamples;
  final int coverageSeconds;
  final Map<HeartRateQuality, int> accuracyCounts;
  final String? watchSessionId;
  final DateTime? startedAt;
  final int? lastSeq;
  final StateSample? state;


  final String? errorMessage;

  bool get isMeasured => acceptedSamples > 0;
}
