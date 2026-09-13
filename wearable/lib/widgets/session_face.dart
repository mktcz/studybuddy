import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ui/ui.dart';

import '../wear_state.dart';
import 'round_scaffold.dart';


class SessionFace extends StatefulWidget {
  const SessionFace({
    super.key,
    required this.state,
    required this.ambient,
    required this.onStop,
    required this.onTogglePause,
  });

  final WearState state;
  final bool ambient;
  final Future<void> Function() onStop;
  final Future<void> Function() onTogglePause;

  @override
  State<SessionFace> createState() => _SessionFaceState();
}

class _SessionFaceState extends State<SessionFace> {
  Timer? _ticker;
  DateTime _now = DateTime.now();
  bool _stopping = false;

  @override
  void initState() {
    super.initState();
    _restartTicker();
  }

  @override
  void didUpdateWidget(SessionFace oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.ambient != oldWidget.ambient) _restartTicker();
  }


  void _restartTicker() {
    _ticker?.cancel();
    _scheduleTick();
  }

  void _scheduleTick() {
    final now = DateTime.now();
    final intervalMs = widget.ambient ? 30000 : 1000;
    final epochMs = now.millisecondsSinceEpoch;
    final waitMs = intervalMs - (epochMs % intervalMs);
    _ticker = Timer(Duration(milliseconds: waitMs), () {
      if (!mounted) return;
      setState(() => _now = DateTime.now());
      _scheduleTick();
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _stop() async {
    setState(() => _stopping = true);
    try {
      await widget.onStop();
    } finally {
      if (mounted) setState(() => _stopping = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sb = context.sb;
    final state = widget.state;
    final ambient = widget.ambient;

    final elapsed = state.elapsedAt(_now);
    final progress = state.progressAt(_now);
    final accent = ambient ? sb.muted : sb.accent;
    final inset = roundInset(context);

    return RoundScaffold(
      padded: false,
      bleed: progress == null
          ? null
          : Padding(

              padding: EdgeInsets.all(inset * 0.25),
              child: ProgressArc(
                progress: progress,
                color: accent,
                ambient: ambient,
                strokeWidth: 5,
              ),
            ),
      child: Padding(
        padding: EdgeInsets.all(inset),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Eyebrow(
              state.isReadiness ? 'Readiness' : 'Focus',
              color: ambient ? sb.muted : accent,
            ),
            const SizedBox(height: SbSpace.xxs),

            Text(


              ambient
                  ? '${elapsed.inHours > 0 ? '${elapsed.inHours}:' : ''}'
                        '${(elapsed.inMinutes % 60).toString().padLeft(2, '0')}m'
                  : SbFormat.elapsed(elapsed),
              style: (context.text.headlineMedium ?? const TextStyle())
                  .merge(SbType.tabular)
                  .copyWith(color: ambient ? sb.muted : sb.ink),
            ),

            if (state.nudge case final nudge?) ...[
              const SizedBox(height: SbSpace.xxs),


              Text(
                nudge,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.text.bodySmall?.copyWith(
                  color: ambient ? sb.muted : sb.accent,
                ),
              ),
            ],

            const SizedBox(height: SbSpace.sm),
            _HsiAxes(axes: state.hsiAxes, ambient: ambient),

            if (!ambient) ...[
              const SizedBox(height: SbSpace.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _CircleButton(
                    icon: state.paused
                        ? Icons.play_arrow_rounded
                        : Icons.pause_rounded,
                    label: state.paused ? 'Resume' : 'Pause',
                    onPressed: widget.onTogglePause,
                  ),
                  const SizedBox(width: SbSpace.lg),


                  _CircleButton(
                    icon: Icons.stop_rounded,
                    label: 'End session',
                    filled: true,
                    diameter: 50,
                    iconSize: 24,
                    onPressed: _stopping ? null : _stop,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _HsiAxes extends StatelessWidget {
  const _HsiAxes({required this.axes, required this.ambient});

  final Map<String, HsiAxis> axes;
  final bool ambient;


  static const _icons = {
    'focus': Icons.center_focus_strong_rounded,
    'capacity': Icons.battery_full_rounded,
    'arousal': Icons.bolt_rounded,
    'stress': Icons.whatshot_rounded,
  };


  static const _labels = {
    'focus': 'Focus',
    'capacity': 'Capacity',
    'arousal': 'Energy',
    'stress': 'Stress',
  };

  @override
  Widget build(BuildContext context) {
    final sb = context.sb;
    final color = ambient ? sb.muted : sb.accent;
    if (axes.isEmpty) {
      return Text('Waiting for phone', style: context.text.bodySmall);
    }
    final visible = _icons.keys
        .where(axes.containsKey)
        .take(4)
        .toList(growable: false);
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: SbSpace.sm,
      runSpacing: 2,
      children: [
        for (final name in visible)
          Semantics(
            label: '${_labels[name]} ${(axes[name]!.value * 100).round()}',
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_icons[name], size: 13, color: color),
                const SizedBox(width: 4),
                Text(
                  '${(axes[name]!.value * 100).round()}',
                  style: context.text.labelSmall?.copyWith(color: color),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.filled = false,
    this.diameter = 44,
    this.iconSize = 22,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool filled;
  final double diameter;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final sb = context.sb;

    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          width: diameter,
          height: diameter,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: filled ? sb.accent : Colors.transparent,
            border: Border.all(color: filled ? sb.accent : sb.line),
          ),
          child: Icon(icon, size: iconSize, color: filled ? sb.canvas : sb.ink),
        ),
      ),
    );
  }
}
