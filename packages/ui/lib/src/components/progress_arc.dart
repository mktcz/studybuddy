import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/study_theme.dart';
import '../tokens/shape.dart';


class ProgressArc extends StatelessWidget {
  const ProgressArc({
    super.key,
    required this.progress,
    this.color,
    this.trackColor,
    this.strokeWidth = SbStroke.arc,
    this.startAngle = -math.pi / 2,
    this.ambient = false,
    this.child,
  });


  final double progress;

  final Color? color;
  final Color? trackColor;
  final double strokeWidth;


  final double startAngle;


  final bool ambient;

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final sb = context.sb;
    return CustomPaint(
      painter: _ArcPainter(
        progress: progress.clamp(0.0, 1.0),
        color: color ?? sb.accent,
        trackColor: ambient ? Colors.transparent : (trackColor ?? sb.line),
        strokeWidth: ambient ? 1.5 : strokeWidth,
        startAngle: startAngle,
      ),
      child: child == null ? null : Center(child: child),
    );
  }
}

class _ArcPainter extends CustomPainter {
  const _ArcPainter({
    required this.progress,
    required this.color,
    required this.trackColor,
    required this.strokeWidth,
    required this.startAngle,
  });

  final double progress;
  final Color color;
  final Color trackColor;
  final double strokeWidth;
  final double startAngle;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromCircle(
      center: size.center(Offset.zero),
      radius: (math.min(size.width, size.height) - strokeWidth) / 2,
    );

    if (trackColor.a > 0) {
      canvas.drawCircle(
        rect.center,
        rect.width / 2,
        Paint()
          ..color = trackColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth,
      );
    }

    if (progress <= 0) return;

    canvas.drawArc(
      rect,
      startAngle,
      math.pi * 2 * progress,
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_ArcPainter old) =>
      old.progress != progress ||
      old.color != color ||
      old.trackColor != trackColor ||
      old.strokeWidth != strokeWidth ||
      old.startAngle != startAngle;
}
