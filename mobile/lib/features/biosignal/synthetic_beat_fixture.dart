class SyntheticBeatFixture {
  SyntheticBeatFixture({required String preset, required this.seed})
    : preset = normalizePreset(preset);

  final String preset;
  final int seed;

  static const presets = {'rest', 'focus', 'stress', 'recovery', 'mixed'};


  static String normalizePreset(String raw) {
    return switch (raw.trim().toLowerCase()) {
      'rest' || 'calm' => 'rest',
      'stress' || 'stressed' => 'stress',
      'recovery' || 'recover' => 'recovery',
      'mixed' || 'mix' => 'mixed',
      _ => 'focus',
    };
  }

  static int randomSeed([int Function()? entropy]) {
    final value = entropy?.call() ?? DateTime.now().microsecondsSinceEpoch;
    return value & 0x7fffffff;
  }

  ({double baseRrMs, double ampMs, double jitterMs}) get _rest =>
      (baseRrMs: 1034.0, ampMs: 70.0, jitterMs: 48.0);

  ({double baseRrMs, double ampMs, double jitterMs}) get _focus =>
      (baseRrMs: 833.0, ampMs: 48.0, jitterMs: 24.0);

  ({double baseRrMs, double ampMs, double jitterMs}) get _stress =>
      (baseRrMs: 638.0, ampMs: 14.0, jitterMs: 6.0);

  ({double baseRrMs, double ampMs, double jitterMs}) _paramsAt(int beat) {
    return switch (preset) {
      'rest' => _rest,
      'stress' => _stress,
      'recovery' => _lerp(_stress, _rest, _clamp01(beat / 180.0)),
      'mixed' => _mixedAt(beat),
      _ => _focus,
    };
  }

  ({double baseRrMs, double ampMs, double jitterMs}) _mixedAt(int beat) {
    final cycle = beat % 240;
    if (cycle < 90) return _focus;
    if (cycle < 120) {
      return _lerp(_focus, _stress, (cycle - 90) / 30.0);
    }
    if (cycle < 210) return _stress;
    return _lerp(_stress, _focus, (cycle - 210) / 30.0);
  }

  ({double baseRrMs, double ampMs, double jitterMs}) _lerp(
    ({double baseRrMs, double ampMs, double jitterMs}) a,
    ({double baseRrMs, double ampMs, double jitterMs}) b,
    double t,
  ) {
    final w = _clamp01(t);
    return (
      baseRrMs: a.baseRrMs + (b.baseRrMs - a.baseRrMs) * w,
      ampMs: a.ampMs + (b.ampMs - a.ampMs) * w,
      jitterMs: a.jitterMs + (b.jitterMs - a.jitterMs) * w,
    );
  }

  static double _clamp01(double value) {
    if (value < 0) return 0;
    if (value > 1) return 1;
    return value;
  }


  ({double bpm, double rrIntervalMs, String accuracy}) sampleAt(int beat) {
    final params = _paramsAt(beat);
    final unit = _unit(seed + beat * 9973);
    final walk = _unit(seed + beat * 7919) * 2 - 1;
    final rr =
        params.baseRrMs +
        params.ampMs * _sin(beat / 12) +
        (unit * 2 - 1) * params.jitterMs +
        walk * 12.0;
    final rrMs = rr.clamp(400.0, 1600.0);
    final observation = (_unit(seed + beat * 4243) * 2 - 1) * 0.15;
    final bpm = (60000.0 / rrMs + observation).clamp(40.0, 180.0);
    return (bpm: bpm, rrIntervalMs: rrMs, accuracy: 'medium');
  }

  int delayMs(({double bpm, double rrIntervalMs, String accuracy}) sample) =>
      sample.rrIntervalMs.round().clamp(400, 1600);


  Iterable<
    ({
      int beatIndex,
      int timestampMs,
      double bpm,
      double rrIntervalMs,
      String accuracy,
      String preset,
      int seed,
    })
  >
  timedBeats({required int count, int startMs = 0}) sync* {
    var timestampMs = startMs;
    for (var beat = 0; beat < count; beat++) {
      final sample = sampleAt(beat);
      yield (
        beatIndex: beat,
        timestampMs: timestampMs,
        bpm: sample.bpm,
        rrIntervalMs: sample.rrIntervalMs,
        accuracy: sample.accuracy,
        preset: preset,
        seed: seed,
      );
      timestampMs += delayMs(sample);
    }
  }

  double _sin(double turns) {
    final tau = 6.283185307179586;
    var x = (turns * tau) % tau;
    if (x > 3.141592653589793) x -= tau;
    final x2 = x * x;
    return x * (1 - x2 / 6 + x2 * x2 / 120);
  }

  double _unit(int value) {
    var x = value ^ 0x5DEECE66D;
    x = (x * 1103515245 + 12345) & 0x7fffffff;
    return x / 0x7fffffff;
  }
}
