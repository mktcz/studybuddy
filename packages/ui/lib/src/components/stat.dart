import 'package:flutter/material.dart';

import '../theme/study_theme.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';


class StatColumn extends StatelessWidget {
  const StatColumn({
    super.key,
    required this.value,
    required this.label,
    this.emphasis = StatEmphasis.medium,
    this.color,
  });


  final String value;
  final String label;
  final StatEmphasis emphasis;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final text = context.text;
    final style = switch (emphasis) {
      StatEmphasis.large => text.headlineMedium,
      StatEmphasis.medium => text.titleLarge,
      StatEmphasis.small => text.titleMedium,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: (style ?? const TextStyle())
              .merge(SbType.tabular)
              .copyWith(color: color),
        ),
        const SizedBox(height: SbSpace.xxs),
        Text(label, style: text.bodyMedium),
      ],
    );
  }
}

enum StatEmphasis { small, medium, large }


class StatRow extends StatelessWidget {
  const StatRow({super.key, required this.stats});

  final List<StatColumn> stats;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [for (final stat in stats) Expanded(child: stat)],
    );
  }
}
