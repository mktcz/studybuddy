import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui/ui.dart';

import '../../app/providers.dart';
import '../../data/database.dart';
import '../focus/focus_controller.dart';
import '../state/ambient_measurement.dart';
import '../state/hsi_engine.dart';
import '../state/hsi_providers.dart';
import 'subject_editor.dart';


class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  static const path = '/';

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with WidgetsBindingObserver {
  late final AmbientMeasurement _ambient;

  @override
  void initState() {
    super.initState();
    _ambient = ref.read(ambientMeasurementProvider);
    WidgetsBinding.instance.addObserver(this);
    ref.listenManual<HsiStatus>(
      hsiStatusProvider.select(
        (value) => value.value ?? const HsiStatus(phase: HsiPhase.starting),
      ),
      (_, next) {
        if (next.phase == HsiPhase.ready) _maybeStartAmbient();
      },
      fireImmediately: true,
    );
    ref.listenManual<bool>(
      focusControllerProvider.select((value) => value.isActive),
      (previous, active) {
        if (!active && previous == true) _maybeStartAmbient();
      },
    );
  }

  void _maybeStartAmbient() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (GoRouterState.of(context).uri.path != HomeScreen.path) return;
      if (ref.read(focusControllerProvider).isActive) return;
      unawaited(_ambient.start());
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _maybeStartAmbient();
    } else if ((state == AppLifecycleState.paused ||
            state == AppLifecycleState.detached) &&
        !ref.read(focusControllerProvider).isActive) {
      unawaited(_ambient.stop());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_ambient.stop());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final summaries = ref.watch(subjectSummariesProvider);
    final todayMinutes = ref.watch(todayMinutesProvider);
    final streak = ref.watch(streakProvider);
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                SbSpace.gutter,
                SbSpace.xl,
                SbSpace.gutter,
                0,
              ),
              sliver: SliverList.list(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Subjects',
                          style: context.text.displaySmall,
                        ),
                      ),
                      IconButton.filledTonal(
                        onPressed: () => SubjectEditor.show(context, ref),
                        tooltip: 'New subject',
                        icon: const Icon(Icons.add_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: SbSpace.xxs),
                  Text(
                    _todayLine(todayMinutes, streak),
                    style: context.text.bodyMedium?.copyWith(
                      color: context.sb.muted,
                    ),
                  ),
                  const SizedBox(height: SbSpace.xl),
                ],
              ),
            ),

            switch (summaries) {
              AsyncValue(value: final list?) when list.isEmpty =>
                const SliverToBoxAdapter(child: _EmptySubjects()),
              AsyncValue(value: final list?) => SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: SbSpace.gutter),
                sliver: SliverList.separated(
                  itemCount: list.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: SbSpace.sm),
                  itemBuilder: (context, index) {
                    final summary = list[index];
                    return _SubjectRow(summary: summary);
                  },
                ),
              ),
              AsyncValue(error: final error?) => SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: SbSpace.gutter,
                  ),
                  child: Text('Could not load subjects: $error'),
                ),
              ),
              _ => const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(SbSpace.xxl),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
            },
            const SliverToBoxAdapter(child: SizedBox(height: SbSpace.xxxl)),
          ],
        ),
      ),
    );
  }

  static String _todayLine(int minutes, int streak) {
    final focused = '${SbFormat.minutes(minutes)} today';
    if (streak == 0) return focused;
    return '$focused  ·  $streak day streak';
  }
}


class _SubjectRow extends ConsumerWidget {
  const _SubjectRow({required this.summary});

  final SubjectSummary summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final focus = ref.watch(focusControllerProvider);
    final active = focus.subjectId == summary.subject.id && focus.isActive;
    final elapsed = active
        ? ref.watch(focusElapsedProvider).value ?? Duration.zero
        : null;
    final expired = active && focus.expiredAt(DateTime.now());

    return SubjectCard(
      name: summary.subject.name,
      accent: context.sb.subject(summary.subject.accentIndex),
      sourceCount: summary.sourceCount,
      focusedLabel: SbFormat.minutes(summary.focusedMinutes),
      active: active,
      statusLabel: active
          ? (expired ? 'Ready for check-out' : 'Session in progress')
          : null,
      trailingLabel: elapsed == null ? null : SbFormat.elapsed(elapsed),


      onTap: () => context.go('/subject/${summary.subject.id}'),
      onLongPress: () =>
          SubjectEditor.show(context, ref, existing: summary.subject),
    );
  }
}

class _EmptySubjects extends ConsumerWidget {
  const _EmptySubjects();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        SbSpace.gutter,
        SbSpace.sm,
        SbSpace.gutter,
        SbSpace.lg,
      ),
      child: Container(
        padding: const EdgeInsets.all(SbSpace.lg),
        decoration: BoxDecoration(
          border: Border.all(color: context.sb.line),
          borderRadius: SbRadius.cardAll,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Create a subject', style: context.text.titleLarge),
            const SizedBox(height: SbSpace.xs),
            Text(
              'Keep a course, its PDFs, and its study sessions together.',
              style: context.text.bodyLarge?.copyWith(color: context.sb.muted),
            ),
            const SizedBox(height: SbSpace.lg),
            FilledButton.icon(
              onPressed: () => SubjectEditor.show(context, ref),
              icon: const Icon(Icons.add_rounded),
              label: const Text('New subject'),
            ),
          ],
        ),
      ),
    );
  }
}
