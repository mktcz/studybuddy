import 'package:flutter/material.dart';

import '../theme/study_theme.dart';
import '../tokens/motion.dart';
import '../tokens/shape.dart';
import '../tokens/spacing.dart';


class SegmentedChoice<T> extends StatelessWidget {
  const SegmentedChoice({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
    this.labelOf,
  });

  final List<T> options;
  final T value;
  final ValueChanged<T> onChanged;


  final String Function(T option)? labelOf;

  @override
  Widget build(BuildContext context) {
    final sb = context.sb;

    return Row(
      children: [
        for (final (index, option) in options.indexed)
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                right: index == options.length - 1 ? 0 : SbSpace.xs,
              ),
              child: _Segment(
                label: labelOf?.call(option) ?? option.toString(),
                selected: option == value,
                onTap: () => onChanged(option),
                sbInk: sb.ink,
                sbCanvas: sb.canvas,
                sbLine: sb.line,
              ),
            ),
          ),
      ],
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.sbInk,
    required this.sbCanvas,
    required this.sbLine,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color sbInk;
  final Color sbCanvas;
  final Color sbLine;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: SbMotion.quick,
          curve: SbMotion.standard,
          padding: const EdgeInsets.symmetric(vertical: SbSpace.md),
          decoration: BoxDecoration(
            color: selected ? sbInk : Colors.transparent,
            border: Border.all(color: selected ? sbInk : sbLine),
            borderRadius: SbRadius.cardAll,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: context.text.labelLarge?.copyWith(
              color: selected ? sbCanvas : sbInk,
            ),
          ),
        ),
      ),
    );
  }
}


class RatingRow extends StatelessWidget {
  const RatingRow({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.count = 5,
  });

  final String label;


  final int value;
  final ValueChanged<int> onChanged;
  final int count;

  @override
  Widget build(BuildContext context) {
    final sb = context.sb;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: context.text.titleSmall),
        const SizedBox(height: SbSpace.sm),
        Row(
          children: [
            for (var i = 1; i <= count; i++)
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: i == count ? 0 : SbSpace.xs),
                  child: Semantics(
                    selected: value == i,
                    button: true,
                    label: '$label $i of $count',
                    excludeSemantics: true,
                    child: GestureDetector(
                      onTap: () => onChanged(i),
                      child: AnimatedContainer(
                        duration: SbMotion.quick,
                        curve: SbMotion.standard,
                        height: 38,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: value == i ? sb.ink : Colors.transparent,
                          border: Border.all(
                            color: value == i ? sb.ink : sb.line,
                          ),
                        ),
                        child: Text(
                          '$i',
                          style: context.text.labelLarge?.copyWith(
                            color: value == i ? sb.canvas : sb.muted,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
