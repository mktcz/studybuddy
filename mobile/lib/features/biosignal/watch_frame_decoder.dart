import '../../domain/enums.dart';
import 'bio_reading.dart';


class WatchFrameDecoder {
  const WatchFrameDecoder._();

  static const schemaVersion = 1;

  static SignalOrigin originFromMetrics(Map<String, dynamic> metrics) =>
      metrics['signal_source'] == 'wearable_synthetic_test'
      ? SignalOrigin.wearableSyntheticTest
      : SignalOrigin.wearableReal;

  static int acceptedSamplesTotal(Map<String, dynamic> metrics) =>
      (metrics['accepted_samples_total'] as num?)?.toInt() ??
      (metrics['accepted_samples'] as num?)?.toInt() ??
      (metrics['sample_count'] as num?)?.toInt() ??
      (metrics['frame_sample_count'] as num?)?.toInt() ??
      0;

  static int acceptedRrTotal(Map<String, dynamic> metrics) =>
      (metrics['accepted_rr_total'] as num?)?.toInt() ??
      (metrics['accepted_rr_samples'] as num?)?.toInt() ??
      0;

  static int droppedSamplesTotal(Map<String, dynamic> metrics) {
    final explicit = (metrics['dropped_samples_total'] as num?)?.toInt();
    if (explicit != null) return explicit < 0 ? 0 : explicit;
    final total = (metrics['total_samples'] as num?)?.toInt();
    if (total == null) return 0;
    final dropped = total - acceptedSamplesTotal(metrics);
    return dropped < 0 ? 0 : dropped;
  }

  static List<BioReading> samples(
    Map<String, dynamic> metrics, {
    required int clockOffsetMs,
    String? sessionId,
    int? seq,
  }) {
    final raw = metrics['samples'];
    if (raw is! List) return const [];

    final origin = originFromMetrics(metrics);
    final acceptedTotal = acceptedSamplesTotal(metrics);
    final acceptedRr = acceptedRrTotal(metrics);
    final droppedTotal = droppedSamplesTotal(metrics);
    final schema =
        (metrics['schema_version'] as num?)?.toInt() ?? schemaVersion;
    final readings = <BioReading>[];
    var lastTimestampMs = -1;
    for (final entry in raw) {
      if (entry is! Map) continue;
      final timestamp = entry['timestamp_ms'] ?? entry['t'];
      final bpm = entry['bpm'];
      if (timestamp is! num || bpm is! num || !bpm.isFinite || bpm <= 0) {
        continue;
      }
      final timestampMs = timestamp.toInt();
      if (timestampMs < lastTimestampMs) {


        continue;
      }
      lastTimestampMs = timestampMs;
      readings.add(
        BioReading(
          at: DateTime.fromMillisecondsSinceEpoch(timestampMs + clockOffsetMs),
          bpm: bpm.toDouble(),
          rrIntervalMs: _rrIntervalMs(entry),
          sampleCount: 1,
          acceptedSamplesTotal: acceptedTotal,
          acceptedRrTotal: acceptedRr,
          droppedSamplesTotal: droppedTotal,
          schemaVersion: schema,
          sessionId: sessionId,
          seq: seq,
          accuracy: entry['accuracy']?.toString(),
          origin: origin,
        ),
      );
    }
    return readings;
  }


  static double? _rrIntervalMs(Map<dynamic, dynamic> entry) {
    final raw = entry['rr_interval_ms'];
    if (raw is! num || !raw.toDouble().isFinite || raw <= 0) return null;
    return raw.toDouble();
  }
}
