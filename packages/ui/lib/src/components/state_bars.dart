import 'package:flutter/material.dart';

import '../theme/study_theme.dart';
import '../tokens/motion.dart';
import '../tokens/shape.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';


class StateBarData {
  const StateBarData({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;


  final double value;

  final Color color;
}


class StateBars extends StatelessWidget {
  const StateBars({super.key, required this.bars, this.big = false});

  final List<StateBarData> bars;


  final bool big;

  @override
  Widget build(BuildContext context) {
    final sb = context.sb;
    final labelStyle = big ? context.text.titleMedium : context.text.bodyMedium;
    final valueStyle = (big ? context.text.titleLarge : context.text.titleSmall)
        ?.merge(SbType.tabular);
    final barHeight = big ? 10.0 : 8.0;

    return Column(
      children: [
        for (final (index, bar) in bars.indexed)
          Padding(
            padding: EdgeInsets.only(
              bottom: index == bars.length - 1
                  ? 0
                  : (big ? SbSpace.md : SbSpace.sm),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: big ? 96 : 84,
                  child: Text(bar.label, style: labelStyle),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: SbRadius.pillAll,
                    child: TweenAnimationBuilder<double>(
                      duration: SbMotion.slow,
                      curve: SbMotion.emphasised,
                      tween: Tween(end: bar.value.clamp(0.0, 1.0)),
                      builder: (context, value, _) => Stack(
                        children: [
                          Container(height: barHeight, color: sb.raised),
                          FractionallySizedBox(
                            widthFactor: value == 0 ? 0.005 : value,
                            child: Container(
                              height: barHeight,
                              decoration: BoxDecoration(
                                color: bar.color,
                                borderRadius: SbRadius.pillAll,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: big ? 48 : 40,
                  child: Text(
                    '${(bar.value.clamp(0.0, 1.0) * 100).round()}',
                    textAlign: TextAlign.end,
                    style: valueStyle,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
