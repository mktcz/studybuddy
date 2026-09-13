import 'package:flutter/material.dart';
import 'package:ui/ui.dart';

import '../../domain/study_logic.dart';


({String label, Color color}) axisStyle(BuildContext context, String axis) {
  final sb = context.sb;
  return switch (axis) {
    'Focus' => (label: 'Focus', color: sb.subject(0)),
    'Capacity' => (label: 'Capacity', color: sb.subject(6)),
    'Arousal' => (label: 'Energy', color: sb.subject(2)),
    'Stress' => (label: 'Stress', color: sb.danger),
    'Sleep' => (label: 'Sleep', color: sb.subject(3)),
    _ => (label: axis, color: sb.accent),
  };
}


const axisOrder = ['Focus', 'Capacity', 'Arousal', 'Stress', 'Sleep'];


List<StateBarData> stateBarsFor(BuildContext context, StateSample sample) {
  final axes = sample.availableAxes;
  return [
    for (final name in axisOrder)
      if (axes[name] case final axis?)
        StateBarData(
          label: axisStyle(context, name).label,
          value: axis.value,
          color: axisStyle(context, name).color,
        ),
  ];
}
