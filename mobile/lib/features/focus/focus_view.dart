import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui/ui.dart';

import '../../domain/session_nudges.dart';
import '../state/hsi_engine.dart';
import '../state/hsi_panel.dart';
import '../state/hsi_providers.dart';
import 'focus_controller.dart';
import 'session_summary_sheet.dart';
import '../state/rest_alert_host.dart';


class FocusView extends ConsumerWidget {
  const FocusView({super.key});


  static const _actionButtonStyle = ButtonStyle(
    padding: WidgetStatePropertyAll(
      EdgeInsets.symmetric(horizontal: SbSpace.xs),
    ),
  );

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const RestAlertSuppressionScope(child: FocusView()),
    );
  }


  static Future<void> confirmStop(BuildContext context, WidgetRef ref) async {
    final sessionId = ref.read(focusControllerProvider).sessionId;
    final controller = ref.read(focusControllerProvider.notifier);
    await controller.stop();
    if (sessionId != null && context.mounted) {
      await SessionSummarySheet.show(context, sessionId);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final focus = ref.watch(focusControllerProvider);
    final elapsed = ref.watch(focusElapsedProvider).value ?? Duration.zero;
    final controller = ref.read(focusControllerProvider.notifier);
    final sb = context.sb;

    if (!focus.isActive) return const SizedBox.shrink();

    final accent = sb.subject(focus.accentIndex);
    final expired = focus.expiredAt(DateTime.now());
    final nudge = focus.nudge;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          SbSpace.xl,
          SbSpace.lg,
          SbSpace.xl,
          SbSpace.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 38,
                height: 3,
                decoration: BoxDecoration(
                  color: sb.line,
                  borderRadius: SbRadius.pillAll,
                ),
              ),
            ),
            const SizedBox(height: SbSpace.xl),

            Eyebrow(focus.subjectName, color: accent),
            const SizedBox(height: SbSpace.xl),

            Center(
              child: SizedBox.square(
                dimension: 220,
                child: ProgressArc(
                  progress: focus.progressAt(DateTime.now()),
                  color: accent,
                  strokeWidth: 6,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        SbFormat.elapsed(elapsed),
                        style: (context.text.displaySmall ?? const TextStyle())
                            .merge(SbType.tabular),
                      ),
                      const SizedBox(height: SbSpace.xxs),
                      Text(
                        'of ${focus.planned.inMinutes} min',
                        style: context.text.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: SbSpace.xl),

            HsiPanel(
              sample: focus.state,
              status:
                  ref.watch(hsiStatusProvider).value ??
                  const HsiStatus(phase: HsiPhase.starting),
              compact: true,
            ),

            if (nudge != null) ...[
              const SizedBox(height: SbSpace.sm),
              _NudgeCard(nudge: nudge, expired: expired),
            ],

            if (focus.notice != null) ...[
              const SizedBox(height: SbSpace.sm),
              _Notice(message: focus.notice!),
            ],

            const SizedBox(height: SbSpace.xl),

            Row(
              children: [
                if (!expired) ...[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: controller.togglePause,
                      style: _actionButtonStyle,
                      icon: Icon(
                        focus.running
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                      ),
                      label: Text(
                        focus.running ? 'Pause' : 'Resume',
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.fade,
                      ),
                    ),
                  ),
                  const SizedBox(width: SbSpace.xs),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          controller.extend(const Duration(minutes: 10)),
                      style: _actionButtonStyle,
                      icon: const Icon(Icons.more_time_rounded),
                      label: const Text(
                        '+10 min',
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.fade,
                      ),
                    ),
                  ),
                  const SizedBox(width: SbSpace.xs),
                ],
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () async {
                      final navigator = Navigator.of(context);
                      await FocusView.confirmStop(context, ref);
                      if (navigator.canPop()) navigator.pop();
                    },
                    style: _actionButtonStyle,
                    icon: const Icon(Icons.stop_rounded),
                    label: const Text(
                      'End',
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.fade,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: SbSpace.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.go('/subject/${focus.subjectId}');
                  },
                  child: const Text('Open subject'),
                ),
                if (focus.sourceId != null)
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      context.go(
                        '/subject/${focus.subjectId}/read/${focus.sourceId}',
                      );
                    },
                    child: const Text('Continue reading'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


class _NudgeCard extends ConsumerWidget {
  const _NudgeCard({required this.nudge, required this.expired});

  final Nudge nudge;
  final bool expired;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sb = context.sb;
    final controller = ref.read(focusControllerProvider.notifier);

    final (
      String? acceptLabel,
      Future<void> Function()? onAccept,
    ) = switch (nudge.kind) {
      NudgeKind.breakSuggested when !expired => (
        'Pause now',
        () => controller.togglePause(),
      ),
      NudgeKind.extendOffered when !expired => (
        'Add 10 min',
        () => controller.extend(const Duration(minutes: 10)),
      ),
      NudgeKind.wrapUpSuggested => (
        'End session',
        () => FocusView.confirmStop(context, ref),
      ),
      _ => (null, null),
    };

    return Container(
      padding: const EdgeInsets.all(SbSpace.sm),
      decoration: BoxDecoration(
        border: Border.all(color: sb.accent),
        borderRadius: SbRadius.cardAll,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.tips_and_updates_outlined, size: 17, color: sb.accent),
              const SizedBox(width: SbSpace.xs),
              Expanded(
                child: Text(nudge.message, style: context.text.bodyMedium),
              ),
            ],
          ),
          const SizedBox(height: SbSpace.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: controller.dismissNudge,
                child: const Text('Dismiss'),
              ),
              if (acceptLabel != null && onAccept != null)
                FilledButton.tonal(
                  onPressed: () async {
                    controller.dismissNudge();
                    await onAccept();
                  },
                  child: Text(acceptLabel),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final sb = context.sb;
    return Container(
      padding: const EdgeInsets.all(SbSpace.sm),
      decoration: BoxDecoration(
        border: Border.all(color: sb.line),
        borderRadius: SbRadius.cardAll,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 17, color: sb.muted),
          const SizedBox(width: SbSpace.xs),
          Expanded(child: Text(message, style: context.text.bodyMedium)),
        ],
      ),
    );
  }
}
