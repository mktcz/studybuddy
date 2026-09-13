import 'package:flutter/material.dart';
import 'package:ui/ui.dart';

import '../../domain/enums.dart';
import '../../domain/study_logic.dart';
import 'axis_style.dart';
import 'hsi_engine.dart';


class HsiPanel extends StatelessWidget {
  const HsiPanel({
    super.key,
    required this.sample,
    required this.status,
    this.compact = false,
  });

  final StateSample? sample;
  final HsiStatus status;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final sb = context.sb;
    final current = sample;
    final bars = current == null
        ? const <StateBarData>[]
        : stateBarsFor(context, current);
    final age = current == null ? null : DateTime.now().difference(current.at);
    final fresh = age != null && age < const Duration(seconds: 20);

    return Semantics(
      container: true,
      label: bars.isEmpty
          ? 'Listening for your first measured state'
          : 'Your measured state, ${bars.length} readings',
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: sb.line),
          borderRadius: SbRadius.cardAll,
        ),
        child: Padding(
          padding: EdgeInsets.all(compact ? SbSpace.sm : SbSpace.md),
          child: bars.isEmpty
              ? _Listening(status: status, compact: compact)
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        StatusDot(color: sb.accent, pulse: fresh, size: 7),
                        const SizedBox(width: SbSpace.xs),
                        Expanded(
                          child: Text(
                            'Your state',
                            style: context.text.titleMedium,
                          ),
                        ),
                        if (current?.origin ==
                            SignalOrigin.wearableSyntheticTest) ...[
                          Text('test signal', style: context.text.bodySmall),
                          const SizedBox(width: SbSpace.xs),
                        ],
                        Text(_ageLabel(age), style: context.text.bodySmall),
                      ],
                    ),
                    SizedBox(height: compact ? SbSpace.sm : SbSpace.md),
                    StateBars(bars: bars),
                  ],
                ),
        ),
      ),
    );
  }

  static String _ageLabel(Duration? age) {
    if (age == null) return 'Waiting';
    if (age.inSeconds < 2) return 'Now';
    if (age.inMinutes < 1) return '${age.inSeconds}s ago';
    return '${age.inMinutes}m ago';
  }
}

class _Listening extends StatelessWidget {
  const _Listening({required this.status, required this.compact});

  final HsiStatus status;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final detail = switch (status.phase) {
      HsiPhase.ready =>
        'Your watch is warming up — the first reading takes about a minute.',
      HsiPhase.awaitingConsent => 'Measurement is turned off in Settings.',
      HsiPhase.starting => 'Getting ready…',
      HsiPhase.unconfigured => 'This build is not set up for measurement.',
      HsiPhase.failed =>
        status.error ?? 'Measurement is unavailable right now.',
    };
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StatusDot(
          color: context.sb.muted,
          pulse: status.phase == HsiPhase.ready,
          size: 7,
        ),
        const SizedBox(width: SbSpace.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Listening', style: context.text.titleMedium),
              if (!compact) ...[
                const SizedBox(height: SbSpace.xxs),
                Text(detail, style: context.text.bodyMedium),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
