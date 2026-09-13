import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui/ui.dart';

import '../../app/providers.dart';
import '../biosignal/watch_diagnostic.dart';
import '../state/hsi_engine.dart';
import '../state/hsi_providers.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _page = PageController();
  final _nickname = TextEditingController();
  int _index = 0;
  WatchDiagnostic? _watch;
  bool _checkingWatch = false;
  bool _measured = true;
  bool _cloud = false;
  bool _saving = false;
  String? _cloudError;

  @override
  void initState() {
    super.initState();
    unawaited(ref.read(hsiEngineProvider).initialize());
    unawaited(_checkWatch());
  }

  @override
  void dispose() {
    _page.dispose();
    _nickname.dispose();
    super.dispose();
  }

  Future<void> _checkWatch() async {
    setState(() => _checkingWatch = true);
    try {
      final value = await const WatchDiagnosticService().check();
      if (mounted) setState(() => _watch = value);
    } finally {
      if (mounted) setState(() => _checkingWatch = false);
    }
  }

  void _next() {
    _page.nextPage(duration: SbMotion.base, curve: SbMotion.emphasised);
  }

  Future<void> _finish({bool onDeviceOnly = false}) async {
    if (_saving) return;
    final gateway = ref.read(hsiEngineProvider);
    final database = ref.read(databaseProvider);
    setState(() {
      _saving = true;
      _cloudError = null;
    });
    final cloud = onDeviceOnly ? false : _cloud;
    final choice = StudyConsentChoice(
      measuredState: _measured,
      cloudUpload: cloud,
    );
    final error = await gateway.setConsent(choice);
    if (error != null && _cloud && !onDeviceOnly) {
      if (mounted) {
        setState(() {
          _saving = false;
          _cloudError = error;
        });
      }
      return;
    }
    final effective = await gateway.health();
    await database.saveProfile(
      nickname: _nickname.text,
      setupComplete: true,
      wearableConsent: effective.biosignalConsent,
      cloudConsent: effective.cloudUploadConsent,
    );
    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                SbSpace.gutter,
                SbSpace.lg,
                SbSpace.gutter,
                0,
              ),
              child: Row(
                children: [
                  for (var page = 0; page < 3; page++) ...[
                    Expanded(
                      child: AnimatedContainer(
                        duration: SbMotion.base,
                        height: 2,
                        decoration: BoxDecoration(
                          color: page <= _index
                              ? context.sb.ink
                              : context.sb.line,
                          borderRadius: SbRadius.pillAll,
                        ),
                      ),
                    ),
                    if (page != 2) const SizedBox(width: SbSpace.xs),
                  ],
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _page,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (value) => setState(() => _index = value),
                children: [
                  _ProfilePage(controller: _nickname, onNext: _next),
                  _WatchPage(
                    status: _watch,
                    checking: _checkingWatch,
                    onCheck: _checkWatch,
                    onNext: _next,
                  ),
                  _ConsentPage(
                    measured: _measured,
                    cloud: _cloud,
                    saving: _saving,
                    cloudError: _cloudError,
                    onMeasured: (value) => setState(() {
                      _measured = value;
                      if (!value) _cloud = false;
                    }),
                    onCloud: (value) {
                      if (_measured) setState(() => _cloud = value);
                    },
                    onFinish: _finish,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfilePage extends StatelessWidget {
  const _ProfilePage({required this.controller, required this.onNext});

  final TextEditingController controller;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return _OnboardingPage(
      title: 'Study with evidence, not guesses',
      body:
          'Study Buddy measures your state through your watch while you '
          'study — focus, capacity, arousal, and stress — and uses it to '
          'shape sessions that actually fit you.',
      children: [
        TextField(
          controller: controller,
          maxLength: 40,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Nickname (optional)',
            hintText: 'What should we call you?',
          ),
        ),
        const SizedBox(height: SbSpace.lg),
        FilledButton(onPressed: onNext, child: const Text('Continue')),
      ],
    );
  }
}

class _WatchPage extends StatelessWidget {
  const _WatchPage({
    required this.status,
    required this.checking,
    required this.onCheck,
    required this.onNext,
  });

  final WatchDiagnostic? status;
  final bool checking;
  final Future<void> Function() onCheck;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final reachable = status?.reachable == true;
    return _OnboardingPage(
      title: reachable ? 'Your watch is connected' : 'Connect your watch',
      body: 'Install Study Buddy on the paired watch, open it, and allow heart-rate access there. The phone never asks for unrelated permissions.',
      children: [
        HairlineRow.text(
          label: 'Installed and reachable',
          value: checking
              ? 'Checking…'
              : (reachable ? 'Ready' : 'Not reachable'),
        ),
        HairlineRow.text(
          label: 'Heart-rate permission',
          value: status?.permissionGranted == true
              ? 'Granted'
              : 'Grant on watch',
        ),
        HairlineRow.text(
          label: 'Sensor capability',
          value: status?.sensorSupported == true ? 'Available' : 'Unavailable',
        ),
        HairlineRow.text(
          label: 'Contact and accuracy',
          value: status?.sensorAvailable == true
              ? status!.quality
              : 'Checked during readiness',
          divider: false,
        ),
        const SizedBox(height: SbSpace.lg),
        OutlinedButton(
          onPressed: checking ? null : onCheck,
          child: const Text('Check again'),
        ),
        const SizedBox(height: SbSpace.sm),
        FilledButton(onPressed: onNext, child: const Text('Continue')),
      ],
    );
  }
}

class _ConsentPage extends StatelessWidget {
  const _ConsentPage({
    required this.measured,
    required this.cloud,
    required this.saving,
    required this.cloudError,
    required this.onMeasured,
    required this.onCloud,
    required this.onFinish,
  });

  final bool measured;
  final bool cloud;
  final bool saving;
  final String? cloudError;
  final ValueChanged<bool> onMeasured;
  final ValueChanged<bool> onCloud;
  final Future<void> Function({bool onDeviceOnly}) onFinish;

  @override
  Widget build(BuildContext context) {
    return _OnboardingPage(
      title: 'You control what leaves your phone',
      body:
          'Your watch measures focus, energy, capacity, and stress while you '
          'study. Backing up to Synheart is optional — nothing else ever '
          'leaves your phone.',
      children: [
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          title: const Text('Measure with your watch'),
          subtitle: const Text('Needed for everything measured.'),
          value: measured,
          onChanged: onMeasured,
        ),
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          title: const Text('Back up to Synheart'),
          subtitle: const Text('Optional — only your measurements.'),
          value: cloud,
          onChanged: measured ? onCloud : null,
        ),
        if (cloudError != null) ...[
          const SizedBox(height: SbSpace.sm),
          Text(cloudError!, style: context.text.bodyMedium),
        ],
        const SizedBox(height: SbSpace.lg),
        FilledButton(
          onPressed: saving ? null : () => onFinish(),
          child: Text(saving ? 'Saving…' : 'Finish setup'),
        ),
        if (cloudError != null)
          TextButton(
            onPressed: saving ? null : () => onFinish(onDeviceOnly: true),
            child: const Text('Continue on device'),
          ),
      ],
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({
    required this.title,
    required this.body,
    required this.children,
  });

  final String title;
  final String body;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        SbSpace.gutter,
        SbSpace.xxxl,
        SbSpace.gutter,
        SbSpace.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: context.text.displaySmall),
          const SizedBox(height: SbSpace.md),
          Text(body, style: context.text.bodyLarge),
          const SizedBox(height: SbSpace.xxl),
          ...children,
        ],
      ),
    );
  }
}
