import 'package:flutter_test/flutter_test.dart';
import 'package:studybuddy/features/biosignal/synthetic_beat_fixture.dart';

void main() {
  group('SyntheticBeatFixture', () {
    test('aliases normalize without breaking rest/focus/stress names', () {
      expect(SyntheticBeatFixture.normalizePreset('calm'), 'rest');
      expect(SyntheticBeatFixture.normalizePreset('stressed'), 'stress');
      expect(SyntheticBeatFixture.normalizePreset('recover'), 'recovery');
      expect(SyntheticBeatFixture.normalizePreset('mix'), 'mixed');
      expect(SyntheticBeatFixture.normalizePreset('focus'), 'focus');
    });

    test('randomSeed reports the chosen entropy', () {
      expect(SyntheticBeatFixture.randomSeed(() => 424242), 424242);
    });

    test(
      'equal preset and seed are deterministic and different seeds differ',
      () {
        final a = SyntheticBeatFixture(preset: 'focus', seed: 42).sampleAt(7);
        final b = SyntheticBeatFixture(preset: 'focus', seed: 42).sampleAt(7);
        final c = SyntheticBeatFixture(preset: 'focus', seed: 43).sampleAt(7);
        expect(a.bpm, b.bpm);
        expect(a.rrIntervalMs, b.rrIntervalMs);
        expect(a.bpm, isNot(c.bpm));
      },
    );

    test('HR and RR stay physiologically bounded', () {
      for (final preset in SyntheticBeatFixture.presets) {
        final fixture = SyntheticBeatFixture(preset: preset, seed: 99);
        for (var beat = 0; beat < 400; beat++) {
          final sample = fixture.sampleAt(beat);
          expect(sample.bpm, inInclusiveRange(40, 180));
          expect(sample.rrIntervalMs, inInclusiveRange(400, 1600));
          expect(fixture.delayMs(sample), inInclusiveRange(400, 1600));
        }
      }
    });

    test('timestamps advance by rounded RR, not 1 Hz', () {
      final beats = SyntheticBeatFixture(
        preset: 'focus',
        seed: 42,
      ).timedBeats(count: 8).toList();
      for (var i = 1; i < beats.length; i++) {
        expect(
          beats[i].timestampMs - beats[i - 1].timestampMs,
          beats[i - 1].rrIntervalMs.round(),
        );
      }
      expect(beats[1].timestampMs - beats[0].timestampMs, isNot(1000));
    });

    test('recovery moves from stress toward rest', () {
      final recovery = SyntheticBeatFixture(preset: 'recovery', seed: 42);
      final stress = SyntheticBeatFixture(preset: 'stress', seed: 42);
      final rest = SyntheticBeatFixture(preset: 'rest', seed: 42);
      expect(
        recovery.sampleAt(0).rrIntervalMs,
        stress.sampleAt(0).rrIntervalMs,
      );
      expect(
        recovery.sampleAt(180).rrIntervalMs,
        closeTo(rest.sampleAt(180).rrIntervalMs, 1e-9),
      );
    });

    test('mixed cycles focus then stress', () {
      final mixed = SyntheticBeatFixture(preset: 'mixed', seed: 42);
      final focus = SyntheticBeatFixture(preset: 'focus', seed: 42);
      final stress = SyntheticBeatFixture(preset: 'stress', seed: 42);
      expect(mixed.sampleAt(0).rrIntervalMs, focus.sampleAt(0).rrIntervalMs);
      expect(mixed.sampleAt(150).rrIntervalMs, stress.sampleAt(150).rrIntervalMs);
    });

    test('matches the Kotlin watch fixture for seed 42 focus', () {
      final beats = SyntheticBeatFixture(
        preset: 'focus',
        seed: 42,
      ).timedBeats(count: 3).toList();
      expect(beats[0].timestampMs, 0);
      expect(beats[0].rrIntervalMs, closeTo(830.156450361552, 1e-9));
      expect(beats[0].bpm, closeTo(72.26368496893578, 1e-9));
      expect(beats[1].timestampMs, 830);
      expect(beats[1].rrIntervalMs, closeTo(832.711763146003, 1e-9));
      expect(beats[2].timestampMs, 1663);
    });
  });
}
