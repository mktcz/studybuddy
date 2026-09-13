import 'package:flutter/material.dart';

import '../theme/study_theme.dart';
import '../tokens/motion.dart';


class StatusDot extends StatefulWidget {
  const StatusDot({super.key, this.color, this.size = 7, this.pulse = false});

  final Color? color;
  final double size;
  final bool pulse;

  @override
  State<StatusDot> createState() => _StatusDotState();
}

class _StatusDotState extends State<StatusDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: SbMotion.pulse,
  );

  @override
  void initState() {
    super.initState();
    if (widget.pulse) _controller.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(StatusDot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.pulse == oldWidget.pulse) return;
    if (widget.pulse) {
      _controller.repeat(reverse: true);
    } else {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? context.sb.accent;

    final dot = DecoratedBox(
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: SizedBox.square(dimension: widget.size),
    );

    if (!widget.pulse) return dot;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {


        final t = Curves.easeInOut.transform(_controller.value);
        return Opacity(opacity: 0.45 + 0.55 * (1 - t), child: child);
      },
      child: dot,
    );
  }
}
