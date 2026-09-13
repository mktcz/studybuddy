import 'package:flutter/material.dart';
import 'package:ui/ui.dart';

import 'wear_state.dart';
import 'wear_core.dart';
import 'widgets/round_scaffold.dart';
import 'widgets/session_face.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const StudyBuddyWearApp());
}

class StudyBuddyWearApp extends StatelessWidget {
  const StudyBuddyWearApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StudyBuddy',
      debugShowCheckedModeBanner: false,


      theme: studyTheme(brightness: Brightness.dark),
      home: const WearHome(),
    );
  }
}

class WearHome extends StatefulWidget {
  const WearHome({super.key});

  @override
  State<WearHome> createState() => _WearHomeState();
}

class _WearHomeState extends State<WearHome> {
  final _bridge = WearBridge();
  final _core = WearCore();
  WearState _state = const WearState.loading();
  WearCoreStatus? _coreStatus;
  bool _requesting = false;

  @override
  void initState() {
    super.initState();

    _bridge.states.listen((state) {
      if (mounted) setState(() => _state = state);
    });
    _bridge.start();
    _core.initialize().then((status) {
      if (mounted) setState(() => _coreStatus = status);
    });
  }

  @override
  void dispose() {
    _bridge.dispose();
    _core.dispose();
    super.dispose();
  }

  Future<void> _requestPermission() async {
    setState(() => _requesting = true);
    try {
      await _bridge.requestPermission();
    } finally {
      if (mounted) setState(() => _requesting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final core = _coreStatus;
    return AmbientMode(
      builder: (context, ambient) => core == null
          ? const RoundScaffold(
              child: _Message(
                heading: 'Starting Synheart',
                detail: 'Checking the on-device runtime',
              ),
            )
          : !core.ready
          ? RoundScaffold(
              child: _Message(
                heading: 'Synheart unavailable',
                detail: core.error ?? 'The watch runtime could not start.',
              ),
            )
          : switch (_state.phase) {


              WearPhase.active => SessionFace(
                state: _state,
                ambient: ambient,
                onStop: _bridge.requestStop,
                onTogglePause: () =>
                    _bridge.requestPause(paused: !_state.paused),
              ),
              WearPhase.loading => const RoundScaffold(
                child: _Message(
                  heading: 'Checking watch',
                  detail: 'One moment',
                ),
              ),
              WearPhase.blocked => RoundScaffold(
                child: _Blocked(
                  state: _state,
                  busy: _requesting,
                  onGrant: _requestPermission,
                ),
              ),
              WearPhase.idle => RoundScaffold(
                child: _Idle(state: _state, ambient: ambient),
              ),
            },
    );
  }
}


class _Idle extends StatelessWidget {
  const _Idle({required this.state, required this.ambient});

  final WearState state;
  final bool ambient;

  @override
  Widget build(BuildContext context) {
    final sb = context.sb;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Mark(icon: Icons.watch_outlined, color: sb.muted, ambient: ambient),
        const SizedBox(height: SbSpace.sm),
        Text('Ready', style: context.text.titleLarge),
        const SizedBox(height: SbSpace.xxs),
        Text(
          'Start a session from your phone.',
          textAlign: TextAlign.center,
          style: context.text.bodySmall,
        ),
      ],
    );
  }
}


class _Blocked extends StatelessWidget {
  const _Blocked({
    required this.state,
    required this.busy,
    required this.onGrant,
  });

  final WearState state;
  final bool busy;
  final VoidCallback onGrant;

  @override
  Widget build(BuildContext context) {
    final sb = context.sb;
    final canGrant = !state.permissionGranted && state.heartRateSupported;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Mark(
          icon: Icons.priority_high_rounded,
          color: sb.danger,
          ambient: false,
        ),
        const SizedBox(height: SbSpace.sm),
        Text(
          state.heading,
          textAlign: TextAlign.center,
          style: context.text.titleLarge,
        ),
        const SizedBox(height: SbSpace.xxs),
        Text(
          state.detail,
          textAlign: TextAlign.center,
          style: context.text.bodySmall,
        ),
        if (canGrant) ...[
          const SizedBox(height: SbSpace.sm),
          FilledButton(
            onPressed: busy ? null : onGrant,
            style: FilledButton.styleFrom(
              minimumSize: const Size(0, 38),
              padding: const EdgeInsets.symmetric(horizontal: SbSpace.md),
              backgroundColor: sb.accent,
              foregroundColor: sb.canvas,
            ),
            child: Text(busy ? 'Asking…' : 'Allow heart rate'),
          ),
        ],
      ],
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.heading, required this.detail});

  final String heading;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(heading, style: context.text.titleLarge),
        const SizedBox(height: SbSpace.xxs),
        Text(
          detail,
          textAlign: TextAlign.center,
          style: context.text.bodySmall,
        ),
      ],
    );
  }
}

class _Mark extends StatelessWidget {
  const _Mark({required this.icon, required this.color, required this.ambient});

  final IconData icon;
  final Color color;
  final bool ambient;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,


        color: ambient ? null : color.withValues(alpha: SbAlpha.fill),
        border: Border.all(color: color.withValues(alpha: SbAlpha.border)),
      ),
      child: Icon(icon, size: 20, color: color),
    );
  }
}
