import 'package:flutter/material.dart';

import '../format.dart';
import '../theme/study_theme.dart';
import '../tokens/motion.dart';
import '../tokens/shape.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';
import 'status_dot.dart';


class FocusBar extends StatelessWidget {
  const FocusBar({
    super.key,
    required this.subjectName,
    required this.elapsed,
    required this.running,
    this.message,
    this.accent,
    this.progress,
    this.onTap,
    this.onTogglePause,
    this.onStop,
  });

  final String subjectName;
  final Duration elapsed;


  final bool running;


  final String? message;

  final Color? accent;


  final double? progress;

  final VoidCallback? onTap;
  final VoidCallback? onTogglePause;
  final VoidCallback? onStop;

  @override
  Widget build(BuildContext context) {
    final sb = context.sb;
    final color = accent ?? sb.accent;

    return Material(
      color: sb.canvas,
      child: Semantics(
        container: true,
        label: 'Session, $subjectName, ${SbFormat.elapsed(elapsed)} elapsed',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ProgressLine(progress: progress, color: color, track: sb.line),
            SizedBox(
              height: SbSize.focusBar,
              child: InkWell(
                onTap: onTap,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: SbSpace.md),
                  child: Row(
                    children: [
                      StatusDot(color: color, pulse: running),
                      const SizedBox(width: SbSpace.sm),
                      Expanded(
                        child: Text(
                          message ?? subjectName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: message == null
                              ? context.text.titleSmall
                              : context.text.titleSmall?.copyWith(color: color),
                        ),
                      ),
                      Text(
                        SbFormat.elapsed(elapsed),
                        style: (context.text.titleSmall ?? const TextStyle())
                            .merge(SbType.tabular),
                      ),
                      if (onTogglePause != null)
                        IconButton(
                          onPressed: onTogglePause,
                          visualDensity: VisualDensity.compact,
                          tooltip: running ? 'Pause' : 'Resume',
                          icon: Icon(
                            running
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            size: 22,
                          ),
                        ),
                      if (onStop != null)
                        IconButton(
                          onPressed: onStop,
                          visualDensity: VisualDensity.compact,
                          tooltip: 'End session',
                          icon: const Icon(Icons.stop_rounded, size: 22),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressLine extends StatelessWidget {
  const _ProgressLine({
    required this.progress,
    required this.color,
    required this.track,
  });

  final double? progress;
  final Color color;
  final Color track;

  @override
  Widget build(BuildContext context) {
    if (progress == null) {
      return Divider(height: SbStroke.hairline, color: track);
    }
    return TweenAnimationBuilder<double>(
      duration: SbMotion.base,
      curve: SbMotion.standard,
      tween: Tween(end: progress!.clamp(0.0, 1.0)),
      builder: (context, value, _) => LinearProgressIndicator(
        value: value,
        minHeight: 2,
        color: color,
        backgroundColor: track,
      ),
    );
  }
}
