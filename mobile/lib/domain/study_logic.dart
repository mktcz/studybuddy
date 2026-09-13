import 'dart:math' as math;

import 'enums.dart';


class StateSample {
  const StateSample({
    required this.at,
    required this.origin,
    this.focus,
    this.capacity,
    this.arousal,
    this.stress,
    this.sleep,
    this.quality,
    this.focusConfidence,
    this.capacityConfidence,
    this.arousalConfidence,
    this.stressConfidence,
    this.sleepConfidence,
    this.hsiVersion,
  });

  final DateTime at;
  final SignalOrigin origin;


  final double? focus;
  final double? capacity;
  final double? arousal;
  final double? stress;


  final double? sleep;


  final double? quality;
  final double? focusConfidence;
  final double? capacityConfidence;
  final double? arousalConfidence;
  final double? stressConfidence;
  final double? sleepConfidence;
  final String? hsiVersion;


  List<double> get readinessAxes {
    final axes = availableAxes;
    return [
      if (axes['Focus'] != null) axes['Focus']!.value,
      if (axes['Capacity'] != null) axes['Capacity']!.value,
    ];
  }

  double? get meanConfidence {
    final values = availableAxes.values
        .map((axis) => axis.confidence)
        .toList(growable: false);
    return values.isEmpty
        ? null
        : values.reduce((a, b) => a + b) / values.length;
  }


  bool get isEligible =>
      origin != SignalOrigin.unmeasured && readinessAxes.length >= 2;

  Map<String, ({double value, double confidence})> get availableAxes {
    final result = <String, ({double value, double confidence})>{};
    void add(String name, double? value, double? confidence) {
      if (value == null || !value.isFinite) return;
      if (confidence == null || !confidence.isFinite || confidence <= 0) {
        return;
      }
      if (value < 0 || value > 1) return;
      result[name] = (value: value, confidence: confidence);
    }

    add('Focus', focus, focusConfidence);
    add('Capacity', capacity, capacityConfidence);
    add('Arousal', arousal, arousalConfidence);
    add('Stress', stress, stressConfidence);
    add('Sleep', sleep, sleepConfidence);
    return result;
  }


  bool get focusDegenerate => axisValueDegenerate(focus);
}


bool axisValueDegenerate(double? value) {
  if (value == null) return false;
  return !value.isFinite || value < 0 || value > 1;
}


const hsiAxisNames = ['Focus', 'Capacity', 'Arousal', 'Stress'];

const _affectiveAxes = {'Arousal', 'Stress'};


String? axisUnavailableReason({
  required String axis,
  required StateSample? sample,
  required int hsiWindowCount,
  required int acceptedRrCount,
}) {
  final present = sample?.availableAxes.containsKey(axis) ?? false;
  if (present) return null;
  if (axis == 'Focus' && sample?.focusDegenerate == true) {
    return 'degenerate focus';
  }
  if (hsiWindowCount <= 0) return 'insufficient window';
  if (_affectiveAxes.contains(axis) && acceptedRrCount <= 0) {
    return 'RR/HRV unavailable';
  }
  return 'insufficient window';
}


StateSample? weightedStateMean(List<StateSample> samples) {
  final wearable = samples
      .where((sample) => sample.origin != SignalOrigin.unmeasured)
      .toList(growable: false);
  if (wearable.isEmpty) return null;

  ({double? value, double? confidence}) aggregate(
    double? Function(StateSample) value,
    double? Function(StateSample) confidence,
  ) {
    var weighted = 0.0;
    var weights = 0.0;
    var confidenceSum = 0.0;
    var counted = 0;
    for (final sample in wearable) {
      final v = value(sample);
      if (v == null || !v.isFinite) continue;
      final c = confidence(sample);
      if (c == null || !c.isFinite || c <= 0) continue;
      weighted += v * c;
      weights += c;
      confidenceSum += c;
      counted += 1;
    }
    if (counted == 0 || weights <= 0) return (value: null, confidence: null);
    return (value: weighted / weights, confidence: confidenceSum / counted);
  }

  final focus = aggregate((s) => s.focus, (s) => s.focusConfidence);
  final capacity = aggregate((s) => s.capacity, (s) => s.capacityConfidence);
  final arousal = aggregate((s) => s.arousal, (s) => s.arousalConfidence);
  final stress = aggregate((s) => s.stress, (s) => s.stressConfidence);
  final qualities = wearable
      .map((sample) => sample.quality)
      .whereType<double>()
      .where((value) => value.isFinite)
      .toList(growable: false);
  if ([
    focus.value,
    capacity.value,
    arousal.value,
    stress.value,
  ].every((value) => value == null)) {
    return null;
  }
  return StateSample(
    at: wearable.last.at,
    origin: wearable.any((s) => s.origin == SignalOrigin.wearableSyntheticTest)
        ? SignalOrigin.wearableSyntheticTest
        : SignalOrigin.wearableReal,
    focus: focus.value,
    capacity: capacity.value,
    arousal: arousal.value,
    stress: stress.value,
    focusConfidence: focus.confidence,
    capacityConfidence: capacity.confidence,
    arousalConfidence: arousal.confidence,
    stressConfidence: stress.confidence,
    quality: qualities.isEmpty
        ? null
        : qualities.reduce((a, b) => a + b) / qualities.length,
    hsiVersion: wearable.last.hsiVersion,
  );
}


class TimerRecommendation {
  const TimerRecommendation({
    required this.focusMinutes,
    required this.breakMinutes,
    required this.readiness,
    required this.usedMeasuredState,
    this.qualifier,
  });

  final int focusMinutes;
  final int breakMinutes;


  final double? readiness;


  final bool usedMeasuredState;


  final String? qualifier;
}


TimerRecommendation recommendTimer({StateSample? state}) {
  final measured = state?.isEligible ?? false;
  if (!measured) {
    return const TimerRecommendation(
      focusMinutes: 45,
      breakMinutes: 10,
      readiness: null,
      usedMeasuredState: false,
    );
  }

  final axes = state!.readinessAxes;
  final readiness = axes.reduce((a, b) => a + b) / axes.length;

  var (focusMinutes, breakMinutes) = switch (readiness) {
    < .42 => (25, 5),
    < .70 => (45, 10),
    _ => (60, 15),
  };

  String? qualifier;
  final sleep = state.sleep;
  if (sleep != null && sleep < .4) {
    if (focusMinutes > 45) {
      (focusMinutes, breakMinutes) = (45, 10);
    }
    qualifier = 'Short sleep measured — a shorter block suits today.';
  }

  return TimerRecommendation(
    focusMinutes: focusMinutes,
    breakMinutes: breakMinutes,
    readiness: readiness,
    usedMeasuredState: true,
    qualifier: qualifier,
  );
}


double? pearson(List<double> xs, List<double> ys) {
  if (xs.length != ys.length || xs.length < 7) return null;

  final xMean = xs.reduce((a, b) => a + b) / xs.length;
  final yMean = ys.reduce((a, b) => a + b) / ys.length;

  var numerator = 0.0;
  var xSum = 0.0;
  var ySum = 0.0;
  for (var i = 0; i < xs.length; i++) {
    final dx = xs[i] - xMean;
    final dy = ys[i] - yMean;
    numerator += dx * dy;
    xSum += dx * dx;
    ySum += dy * dy;
  }

  final denominator = math.sqrt(xSum * ySum);
  if (denominator == 0) return null;
  return numerator / denominator;
}


int streakDays(Map<DateTime, int> minutesByDay, {DateTime? today}) {
  final anchor = _dateOnly(today ?? DateTime.now());
  final hasToday = (minutesByDay[anchor] ?? 0) > 0;

  var cursor = hasToday ? anchor : anchor.subtract(const Duration(days: 1));
  var count = 0;
  while ((minutesByDay[cursor] ?? 0) > 0) {
    count++;
    cursor = cursor.subtract(const Duration(days: 1));
  }
  return count;
}

DateTime _dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);
