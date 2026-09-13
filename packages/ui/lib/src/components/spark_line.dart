import 'package:flutter/material.dart';

import '../theme/study_theme.dart';


class SparkLine extends StatelessWidget {
  const SparkLine({
    super.key,
    required this.values,
    this.color,
    this.height = 40,
  });


  final List<double?> values;

  final Color? color;
  final double height;

  @override
  Widget build(BuildContext context) {
    final sb = context.sb;
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _SparkLinePainter(
          values: values,
          color: color ?? sb.accent,
          baseline: sb.line,
        ),
      ),
    );
  }
}

class _SparkLinePainter extends CustomPainter {
  const _SparkLinePainter({
    required this.values,
    required this.color,
    required this.baseline,
  });

  final List<double?> values;
  final Color color;
  final Color baseline;

  @override
  void paint(Canvas canvas, Size size) {
    final base = Paint()
      ..color = baseline
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(0, size.height),
      Offset(size.width, size.height),
      base,
    );
    if (values.length < 2) return;

    final line = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final dot = Paint()..color = color;

    final step = size.width / (values.length - 1);
    double yOf(double value) =>
        size.height - value.clamp(0.0, 1.0) * size.height;

    Path? path;
    var runLength = 0;
    for (var i = 0; i < values.length; i++) {
      final value = values[i];
      if (value == null) {
        if (path != null && runLength == 1) {

          canvas.drawCircle(
            Offset((i - 1) * step, yOf(values[i - 1]!)),
            2,
            dot,
          );
        }
        if (path != null) canvas.drawPath(path, line);
        path = null;
        runLength = 0;
        continue;
      }
      final point = Offset(i * step, yOf(value));
      if (path == null) {
        path = Path()..moveTo(point.dx, point.dy);
        runLength = 1;
      } else {
        path.lineTo(point.dx, point.dy);
        runLength++;
      }
    }
    if (path != null) {
      if (runLength == 1) {
        canvas.drawCircle(
          Offset((values.length - 1) * step, yOf(values.last!)),
          2,
          dot,
        );
      } else {
        canvas.drawPath(path, line);
      }
    }
  }

  @override
  bool shouldRepaint(_SparkLinePainter oldDelegate) =>
      oldDelegate.values != values ||
      oldDelegate.color != color ||
      oldDelegate.baseline != baseline;
}
