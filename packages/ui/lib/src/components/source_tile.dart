import 'package:flutter/material.dart';

import '../theme/study_theme.dart';
import '../tokens/shape.dart';
import '../tokens/spacing.dart';
import 'hairline_row.dart';


class SourceTile extends StatelessWidget {
  const SourceTile({
    super.key,
    required this.title,
    this.subtitle,
    this.progress,
    this.accent,
    this.onTap,
    this.trailing,
    this.divider = true,
  });

  final String title;


  final String? subtitle;


  final double? progress;

  final Color? accent;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool divider;

  @override
  Widget build(BuildContext context) {
    final sb = context.sb;
    final color = accent ?? sb.accent;

    return HairlineRow(
      onTap: onTap,
      divider: divider,
      crossAxisAlignment: CrossAxisAlignment.start,
      leading: Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Icon(Icons.description_outlined, size: 19, color: sb.muted),
      ),
      title: Text(title, maxLines: 2, overflow: TextOverflow.ellipsis),
      subtitle: subtitle == null && progress == null
          ? null
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (subtitle != null) Text(subtitle!),
                if (progress != null && progress! > 0) ...[
                  const SizedBox(height: SbSpace.xs),
                  ClipRRect(
                    borderRadius: SbRadius.cardAll,
                    child: LinearProgressIndicator(
                      value: progress!.clamp(0.0, 1.0),
                      minHeight: 2,
                      color: color,
                      backgroundColor: sb.line,
                    ),
                  ),
                ],
              ],
            ),
      trailing: trailing,
    );
  }
}
