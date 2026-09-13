import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui/ui.dart';

import 'focus_controller.dart';
import 'focus_view.dart';


class FocusBarHost extends ConsumerWidget {
  const FocusBarHost({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final focus = ref.watch(focusControllerProvider);
    if (!focus.isActive) return const SizedBox.shrink();
    final elapsed = ref.watch(focusElapsedProvider).value ?? Duration.zero;
    final controller = ref.read(focusControllerProvider.notifier);

    return FocusBar(
      subjectName: focus.subjectName,
      message: focus.nudge?.message,
      elapsed: elapsed,
      running: focus.running,
      accent: context.sb.subject(focus.accentIndex),
      progress: focus.progressAt(DateTime.now()),
      onTap: () => FocusView.show(context),
      onTogglePause: focus.expiredAt(DateTime.now())
          ? null
          : controller.togglePause,
      onStop: () => FocusView.confirmStop(context, ref),
    );
  }
}
