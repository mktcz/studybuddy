import 'package:flutter/material.dart';

import '../theme/study_theme.dart';
import '../tokens/shape.dart';
import '../tokens/spacing.dart';


class HairlineRow extends StatelessWidget {
  const HairlineRow({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.divider = true,
    this.padding,
    this.crossAxisAlignment = CrossAxisAlignment.center,
  });


  factory HairlineRow.text({
    Key? key,
    required String label,
    String? value,
    String? subtitle,
    VoidCallback? onTap,
    bool divider = true,
  }) {
    return HairlineRow(
      key: key,
      title: Text(label),
      subtitle: subtitle == null ? null : Text(subtitle),
      trailing: value == null ? null : _RowValue(value),
      onTap: onTap,
      divider: divider,
    );
  }

  final Widget? leading;
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;


  final bool divider;

  final EdgeInsetsGeometry? padding;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    final sb = context.sb;
    final text = context.text;

    final content = Padding(
      padding: padding ?? const EdgeInsets.symmetric(vertical: SbSpace.rowY),
      child: Row(
        crossAxisAlignment: crossAxisAlignment,
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: SbSpace.sm)],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                DefaultTextStyle.merge(style: text.titleSmall, child: title),
                if (subtitle != null) ...[
                  const SizedBox(height: SbSpace.xxs),
                  DefaultTextStyle.merge(
                    style: text.bodyMedium,
                    child: subtitle!,
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: SbSpace.sm),
            trailing!,
          ],
        ],
      ),
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        border: divider
            ? Border(
                bottom: BorderSide(color: sb.line, width: SbStroke.hairline),
              )
            : null,
      ),
      child: onTap == null
          ? content
          : InkWell(
              onTap: onTap,
              borderRadius: SbRadius.cardAll,
              child: content,
            ),
    );
  }
}

class _RowValue extends StatelessWidget {
  const _RowValue(this.value);

  final String value;

  @override
  Widget build(BuildContext context) =>
      Text(value, style: context.text.bodyMedium);
}
