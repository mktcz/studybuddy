import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:studybuddy/domain/enums.dart';
import 'package:studybuddy/features/biosignal/bio_reading.dart';
import 'package:studybuddy/features/biosignal/watch_frame_decoder.dart';
import 'package:studybuddy/features/focus/readiness_scan_sheet.dart';
import 'package:studybuddy/features/state/hsi_engine.dart';
import 'package:synheart_core/synheart_core.dart';

void main() {
  test('parses all four HSI 1.3 axes and preserves confidence', () {
    final state = stateSampleFromHsi(
      HSIState.fromJson(
        jsonEncode({
          'hsi_version': '1.3',
          'timestamp_ms': 1787210000000,
          'axes': {
            'cognitive': [
              {'name': 'focus', 'score': .72, 'confidence': .81},
              {'name': 'capacity', 'score': .64, 'confidence': .73},
            ],
            'affective': [
              {'name': 'arousal', 'score': .48, 'confidence': .62},
              {'name': 'stress', 'score': .21, 'confidence': .59},
            ],
          },
        }),
      ),
    );

    expect(state.focus, .72);
    expect(state.capacity, .64);
    expect(state.arousal, .48);
    expect(state.stress, .21);
    expect(state.focusConfidence, .81);
    expect(state.capacityConfidence, .73);
    expect(state.arousalConfidence, .62);
    expect(state.stressConfidence, .59);
    expect(
      state.availableAxes.keys,
      containsAll(<String>['Focus', 'Capacity', 'Arousal', 'Stress']),
    );
  });

  test('zero-confidence Core placeholders are not available axes', () {
    final state = stateSampleFromHsi(
      HSIState.fromJson(
        jsonEncode({
          'hsi_version': '1.3',
          'timestamp_ms': 1787210000000,
          'axes': {
            'cognitive': [
              {'name': 'focus', 'score': 0, 'confidence': 0},
              {'name': 'capacity', 'score': 0.5, 'confidence': 0},
            ],
            'affective': [
              {'name': 'arousal', 'score': 0.5, 'confidence': 0},
              {'name': 'stress', 'score': 0, 'confidence': 0},
            ],
          },
        }),
      ),
    );

    expect(state.focus, 0);
    expect(state.capacity, 0.5);
    expect(state.availableAxes, isEmpty);
    expect(state.isEligible, isFalse);
  });

  test('parses canonical HSI 1.3 axes without inventing missing values', () {
    final raw = jsonEncode({
      'hsi_version': '1.3',
      'observed_at_utc': '2026-08-20T10:05:00Z',
      'axes': {
        'cognitive': [
          {'name': 'focus', 'score': .72, 'confidence': .8},
          {'name': 'capacity', 'score': .61, 'confidence': .7},
        ],
        'affective': [
          {'name': 'stress', 'score': .35, 'confidence': .6},
        ],
      },
      'meta': {
        'provenance': {
          'sources': {
            'watch': {
              'signals': ['hr'],
              'source_tier': 3,
              'quality': .9,
            },
          },
        },
      },
    });

    final sample = stateSampleFromHsi(HSIState.fromJson(raw));

    expect(sample.focus, .72);
    expect(sample.capacity, .61);
    expect(sample.stress, .35);
    expect(sample.arousal, isNull);
    expect(sample.hsiVersion, '1.3');
    expect(sample.at, DateTime.parse('2026-08-20T10:05:00Z'));
    expect(sample.quality, closeTo(.9, 1e-9));
    expect(sample.meanConfidence, closeTo(.7, 1e-9));
  });

  test('accepts native and legacy five-second frame metric names', () {
    final native = BioReading.fromMetrics({
      'accepted_samples': 31,
      'mean_hr_bpm': 74.4,
    }, origin: SignalOrigin.wearableReal);
    final legacy = BioReading.fromMetrics({
      'sample_count': 12,
      'hr_mean_bpm': 68.6,
    }, origin: SignalOrigin.wearableReal);

    expect(native.sampleCount, 31);
    expect(native.acceptedSamplesTotal, 31);


    expect(native.bpm, closeTo(74.4, 1e-9));
    expect(legacy.sampleCount, 12);
    expect(legacy.bpm, closeTo(68.6, 1e-9));
  });

  test('decodes timestamped samples with cumulative count and provenance', () {
    final readings = WatchFrameDecoder.samples({
      'signal_source': 'wearable_synthetic_test',
      'accepted_samples': 17,
      'samples': [
        {'t': 1000, 'bpm': 70.25},
        {'t': 2000, 'bpm': 72.5},
        {'t': 3000, 'bpm': 0},
        {'t': 'bad', 'bpm': 80},
      ],
    }, clockOffsetMs: 250);

    expect(readings, hasLength(2));
    expect(readings[0].at.millisecondsSinceEpoch, 1250);
    expect(readings[1].at.millisecondsSinceEpoch, 2250);
    expect(readings.map((reading) => reading.bpm), [70.25, 72.5]);
    expect(readings.map((reading) => reading.acceptedSamplesTotal), [17, 17]);
    expect(
      readings.every(
        (reading) => reading.origin == SignalOrigin.wearableSyntheticTest,
      ),
      isTrue,
    );
    expect(readings.every((reading) => reading.rrIntervalMs == null), isTrue);
  });

  test('decodes versioned samples with RR, dropped counts, and seq', () {
    final readings = WatchFrameDecoder.samples(
      {
        'schema_version': 1,
        'signal_source': 'wearable_real',
        'accepted_samples_total': 37,
        'accepted_rr_total': 36,
        'dropped_samples_total': 2,
        'samples': [
          {
            'timestamp_ms': 1000,
            'bpm': 72.0,
            'rr_interval_ms': 835.0,
            'accuracy': 'medium',
          },
          {
            'timestamp_ms': 1800,
            'bpm': 71.4,
            'rr_interval_ms': 0,
            'accuracy': 'high',
          },
        ],
      },
      clockOffsetMs: 0,
      sessionId: 's1',
      seq: 12,
    );

    expect(readings, hasLength(2));
    expect(readings[0].rrIntervalMs, 835.0);
    expect(readings[0].accuracy, 'medium');
    expect(readings[0].seq, 12);
    expect(readings[0].sessionId, 's1');
    expect(readings[0].acceptedSamplesTotal, 37);
    expect(readings[0].acceptedRrTotal, 36);
    expect(readings[0].droppedSamplesTotal, 2);
    expect(readings[1].rrIntervalMs, isNull);
    expect(readings[1].bpm, 71.4);
  });

  test('rejects out-of-order samples and never invents RR from BPM', () {
    final readings = WatchFrameDecoder.samples({
      'accepted_samples_total': 3,
      'samples': [
        {'timestamp_ms': 2000, 'bpm': 60},
        {'timestamp_ms': 1000, 'bpm': 80, 'rr_interval_ms': 750},
        {'timestamp_ms': 3000, 'bpm': 62},
      ],
    }, clockOffsetMs: 0);

    expect(readings.map((reading) => reading.at.millisecondsSinceEpoch), [
      2000,
      3000,
    ]);
    expect(readings.every((reading) => reading.rrIntervalMs == null), isTrue);
  });

  test('per-sample decoder falls back to legacy cumulative metric names', () {
    final readings = WatchFrameDecoder.samples({
      'sample_count': 4,
      'samples': [
        {'t': 10, 'bpm': 60},
      ],
    }, clockOffsetMs: 0);
    expect(readings.single.acceptedSamplesTotal, 4);
  });

  test('readiness requires real coverage as well as eligible HSI', () {
    final state = stateSampleFromHsi(
      HSIState.fromJson(
        jsonEncode({
          'hsi_version': '1.3',
          'timestamp_ms': 1787210000000,
          'axes': {
            'cognitive': [
              {'name': 'focus', 'score': .7, 'confidence': .9},
              {'name': 'capacity', 'score': .6, 'confidence': .8},
            ],
          },
        }),
      ),
    );

    expect(
      ReadinessResult(
        state: state,
        bio: const BioOutcome(
          origin: SignalOrigin.wearableReal,
          acceptedSamples: 19,
          coverageSeconds: 75,
        ),
      ).measured,
      isFalse,
    );
    expect(
      ReadinessResult(
        state: state,
        bio: const BioOutcome(
          origin: SignalOrigin.wearableReal,
          acceptedSamples: 40,
          coverageSeconds: 30,
        ),
      ).measured,
      isFalse,
    );
    expect(
      ReadinessResult(
        state: state,
        bio: const BioOutcome(
          origin: SignalOrigin.wearableReal,
          acceptedSamples: 20,
          coverageSeconds: 40,
        ),
      ).measured,
      isTrue,
    );
  });
}
