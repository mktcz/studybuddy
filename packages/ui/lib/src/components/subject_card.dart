import 'package:flutter/material.dart';

import '../theme/study_theme.dart';
import '../tokens/colors.dart';
import '../tokens/shape.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';


class SubjectCard extends StatelessWidget {
  const SubjectCard({
    super.key,
    required this.name,
    required this.accent,
    required this.sourceCount,
    required this.focusedLabel,
    this.active = false,
    this.statusLabel,
    this.trailingLabel,
    this.onTap,
    this.onLongPress,
  });

  final String name;
  final Color accent;
  final int sourceCount;


  final String focusedLabel;


  final bool active;


  final String? statusLabel;


  final String? trailingLabel;

  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final sb = context.sb;
    final sources = '$sourceCount ${sourceCount == 1 ? 'source' : 'sources'}';

    final detail = statusLabel ?? '$sources · $focusedLabel';
    final semanticDetail = statusLabel ?? '$sources, $focusedLabel focused';

    return Semantics(
      button: true,
      label: [
        name,
        semanticDetail,
        if (trailingLabel != null) trailingLabel,
      ].join(', '),
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: SbRadius.cardAll,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: SbSpace.md,
            vertical: SbSpace.md,
          ),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: SbAlpha.fill),
            border: Border.all(
              color: accent.withValues(
                alpha: active ? SbAlpha.glyphStroke : SbAlpha.border,
              ),
              width: active ? 1.5 : SbStroke.hairline,
            ),
            borderRadius: SbRadius.cardAll,
          ),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 44,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: SbRadius.pillAll,
                ),
              ),
              const SizedBox(width: SbSpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.text.titleLarge,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: SbSpace.xxs),
                    Text(
                      detail,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.bodyMedium?.copyWith(color: sb.muted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: SbSpace.sm),
              if (trailingLabel != null) ...[
                Text(
                  trailingLabel!,
                  style: (context.text.titleMedium ?? const TextStyle()).merge(
                    SbType.tabular,
                  ),
                ),
                const SizedBox(width: SbSpace.xs),
              ],
              Icon(Icons.chevron_right_rounded, color: sb.muted, size: 21),
            ],
          ),
        ),
      ),
    );
  }
}
