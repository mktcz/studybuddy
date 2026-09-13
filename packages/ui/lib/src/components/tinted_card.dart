import 'package:flutter/material.dart';

import '../theme/study_theme.dart';
import '../tokens/colors.dart';
import '../tokens/shape.dart';
import '../tokens/spacing.dart';


class TintedCard extends StatelessWidget {
  const TintedCard({
    super.key,
    required this.child,
    this.accent,
    this.onTap,
    this.padding = const EdgeInsets.all(SbSpace.lg),
    this.height,
  });

  final Widget child;


  final Color? accent;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final color = accent ?? context.sb.accent;

    final card = Container(
      height: height,
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: color.withValues(alpha: SbAlpha.fill),
        border: Border.all(color: color.withValues(alpha: SbAlpha.border)),
        borderRadius: SbRadius.cardAll,
      ),
      child: child,
    );

    if (onTap == null) return card;

    return Semantics(
      button: true,
      child: InkWell(onTap: onTap, borderRadius: SbRadius.cardAll, child: card),
    );
  }
}
