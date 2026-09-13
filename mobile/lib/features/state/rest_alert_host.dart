import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/session_nudges.dart';
import '../../domain/study_logic.dart';
import '../focus/focus_controller.dart';
import '../settings/settings_screen.dart';
import '../state/hsi_providers.dart';


class RestAlertSuppression extends Notifier<int> {
  @override
  int build() => 0;

  void acquire() => state++;

  void release() {
    if (state > 0) state--;
  }
}

final restAlertSuppressionProvider =
    NotifierProvider<RestAlertSuppression, int>(RestAlertSuppression.new);


class RestAlertUiBlocked extends Notifier<bool> {
  @override
  bool build() => false;

  void setBlocked(bool blocked) {
    if (state != blocked) state = blocked;
  }
}

final restAlertUiBlockedProvider = NotifierProvider<RestAlertUiBlocked, bool>(
  RestAlertUiBlocked.new,
);

final restAlertControllerProvider =
    NotifierProvider<RestAlertController, RestAlert?>(RestAlertController.new);


class GuidedFocusFlowController extends Notifier<bool> {
  @override
  bool build() => false;

  void setActive(bool value) => state = value;
}

final guidedFocusFlowProvider =
    NotifierProvider<GuidedFocusFlowController, bool>(
      GuidedFocusFlowController.new,
    );

class RestAlertController extends Notifier<RestAlert?> {
  final NudgeEngine _engine = NudgeEngine();
  StreamSubscription<StateSample>? _states;

  @override
  RestAlert? build() {
    ref.onDispose(() => _states?.cancel());
    final engine = ref.watch(hsiEngineProvider);
    _states?.cancel();
    _states = engine.states.listen(ingest);
    return _engine.pendingRestAlert;
  }

  bool _ingestBlocked() {
    if (ref.read(restAlertSuppressionProvider) > 0) return true;
    if (ref.read(guidedFocusFlowProvider)) return true;
    if (ref.read(restAlertUiBlockedProvider)) return true;
    return false;
  }

  @visibleForTesting
  void ingest(StateSample sample, {DateTime? now}) {
    if (_ingestBlocked()) {
      hideWithoutDismissing();
      return;
    }
    final focus = ref.read(focusControllerProvider);
    final alert = _engine.onRestWindow(
      sample: sample,
      sessionId: focus.sessionId,
      focusActive: focus.isActive && focus.running,
      now: now ?? DateTime.now(),
    );
    if (alert != null) state = alert;
  }

  void hideWithoutDismissing() {
    _engine.dropPendingPresentation();
    if (state != null) state = null;
  }

  void dismiss() {
    _engine.dismissRestAlert();
    state = null;
  }

  Future<void> takeBreak() async {
    final running = ref.read(focusControllerProvider).running;
    _engine.actOnRestAlert();
    state = null;
    if (running) {
      await ref.read(focusControllerProvider.notifier).togglePause();
    }
  }
}


class RestAlertSuppressionScope extends ConsumerStatefulWidget {
  const RestAlertSuppressionScope({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<RestAlertSuppressionScope> createState() =>
      _RestAlertSuppressionScopeState();
}

class _RestAlertSuppressionScopeState
    extends ConsumerState<RestAlertSuppressionScope> {
  bool _held = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _held) return;
      ref.read(restAlertSuppressionProvider.notifier).acquire();
      _held = true;
    });
  }

  @override
  void dispose() {
    if (_held) {
      ref.read(restAlertSuppressionProvider.notifier).release();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}


class RestAlertHost extends ConsumerStatefulWidget {
  const RestAlertHost({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<RestAlertHost> createState() => _RestAlertHostState();
}

class _RestAlertHostState extends ConsumerState<RestAlertHost>
    with WidgetsBindingObserver {
  bool _dialogOpen = false;
  AppLifecycleState _lifecycle = AppLifecycleState.resumed;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _lifecycle =
        WidgetsBinding.instance.lifecycleState ?? AppLifecycleState.resumed;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() => _lifecycle = state);
  }

  bool _suppressed(BuildContext context) {
    if (_lifecycle != AppLifecycleState.resumed) return true;
    if (ref.read(restAlertSuppressionProvider) > 0) return true;
    if (ref.read(guidedFocusFlowProvider)) return true;
    final path = GoRouter.maybeOf(context)?.state.uri.path;
    if (path == SettingsScreen.path) return true;
    return false;
  }

  Future<void> _present(RestAlert alert) async {
    if (!mounted || _dialogOpen) return;
    if (_suppressed(context)) return;
    _dialogOpen = true;
    final action = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Take a short rest'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(alert.message),
              const SizedBox(height: 12),
              Text(
                NudgeEngine.restDisclaimer,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, 'dismiss'),
              child: const Text('Dismiss'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, 'break'),
              child: const Text('Take a break'),
            ),
          ],
        );
      },
    );
    _dialogOpen = false;
    if (!mounted) return;
    final controller = ref.read(restAlertControllerProvider.notifier);
    if (action == 'break') {
      await controller.takeBreak();
    } else {
      controller.dismiss();
    }
  }

  @override
  Widget build(BuildContext context) {
    final alert = ref.watch(restAlertControllerProvider);
    ref.watch(restAlertSuppressionProvider);
    ref.watch(guidedFocusFlowProvider);
    final blocked = _suppressed(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(restAlertUiBlockedProvider.notifier).setBlocked(blocked);
      if (blocked) {
        ref.read(restAlertControllerProvider.notifier).hideWithoutDismissing();
        return;
      }
      if (alert == null || _dialogOpen) return;
      unawaited(_present(alert));
    });
    return widget.child;
  }
}
