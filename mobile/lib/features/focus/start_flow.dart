import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui/ui.dart';

import '../../app/providers.dart';
import '../../data/database.dart';
import '../../domain/study_logic.dart';
import '../state/hsi_providers.dart';
import '../state/rest_alert_host.dart';
import 'focus_controller.dart';
import 'readiness_scan_sheet.dart';


Future<void> startSessionFlow(
  BuildContext context,
  WidgetRef ref,
  Subject subject, {
  String? sourceId,
}) async {
  final controller = ref.read(focusControllerProvider.notifier);
  if (ref.read(focusControllerProvider).isActive) return;
  final flow = ref.read(guidedFocusFlowProvider.notifier);
  flow.setActive(true);
  try {
    ReadinessResult? readiness;
    TimerRecommendation recommendation;
    _RecommendationBasis basis;


    var ambient = ref.read(currentStateProvider);
    if (ambient == null) {
      final latest = ref.read(hsiEngineProvider).latest;
      if (latest != null &&
          DateTime.now().difference(latest.at) <= const Duration(minutes: 15)) {
        ambient = latest;
      }
    }
    if (ambient != null && ambient.isEligible) {
      recommendation = recommendTimer(state: ambient);
      basis = _RecommendationBasis.ambient;
    } else {
      readiness = await ReadinessScanSheet.show(context);
      if (!context.mounted || readiness == null) return;
      final measured = readiness.measured;
      recommendation = recommendTimer(state: measured ? readiness.state : null);
      basis = measured
          ? _RecommendationBasis.scan
          : _RecommendationBasis.unmeasured;
    }

    int? minutes;
    while (true) {
      final result = await _PlanSheet.show(
        context,
        subject: subject,
        recommendation: recommendation,
        basis: basis,
      );
      if (!context.mounted || result == null) return;
      if (result.rescan) {
        readiness = await ReadinessScanSheet.show(context);
        if (!context.mounted) return;
        if (readiness == null) continue;
        final measured = readiness.measured;
        recommendation = recommendTimer(
          state: measured ? readiness.state : null,
        );
        basis = measured
            ? _RecommendationBasis.scan
            : _RecommendationBasis.unmeasured;
        continue;
      }
      minutes = result.minutes;
      break;
    }
    if (minutes == null) return;

    await controller.start(
      subject: subject,
      sourceId: sourceId,
      planned: Duration(minutes: minutes),
      readinessBio: readiness?.bio,
      readinessCore: readiness?.core,
    );


    if (sourceId == null && context.mounted) {
      final sources = await ref
          .read(databaseProvider)
          .watchSources(subject.id)
          .first;
      final lastRead = sources
          .where((source) => source.lastOpenedAt != null)
          .firstOrNull;
      if (lastRead != null && context.mounted) {
        context.go('/subject/${subject.id}/read/${lastRead.id}');
      }
    }
  } finally {
    flow.setActive(false);
  }
}


enum _RecommendationBasis { ambient, scan, unmeasured }

class _PlanChoice {
  const _PlanChoice.start(this.minutes) : rescan = false;
  const _PlanChoice.rescan() : minutes = null, rescan = true;

  final int? minutes;
  final bool rescan;
}

class _PlanSheet extends StatefulWidget {
  const _PlanSheet({
    required this.subject,
    required this.recommendation,
    required this.basis,
  });

  final Subject subject;
  final TimerRecommendation recommendation;
  final _RecommendationBasis basis;

  static Future<_PlanChoice?> show(
    BuildContext context, {
    required Subject subject,
    required TimerRecommendation recommendation,
    required _RecommendationBasis basis,
  }) {
    return showModalBottomSheet<_PlanChoice>(
      context: context,
      isScrollControlled: true,
      builder: (_) => RestAlertSuppressionScope(
        child: _PlanSheet(
          subject: subject,
          recommendation: recommendation,
          basis: basis,
        ),
      ),
    );
  }

  @override
  State<_PlanSheet> createState() => _PlanSheetState();
}

class _PlanSheetState extends State<_PlanSheet> {
  static const _options = [25, 45, 60];
  late int _minutes = widget.recommendation.focusMinutes;

  String get _basisLine => switch (widget.basis) {
    _RecommendationBasis.ambient => 'From your recent measured state.',
    _RecommendationBasis.scan => 'Measured just now.',
    _RecommendationBasis.unmeasured =>
      'Default length — nothing measured recently.',
  };

  @override
  Widget build(BuildContext context) {
    final sb = context.sb;
    final accent = sb.subject(widget.subject.accentIndex);
    final qualifier = widget.recommendation.qualifier;

    return SafeArea(
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

            Eyebrow(widget.subject.name, color: accent),
            const SizedBox(height: SbSpace.xs),
            Text('How long?', style: context.text.headlineSmall),
            const SizedBox(height: SbSpace.lg),

            SegmentedChoice<int>(
              options: _options,
              value: _minutes,
              onChanged: (v) => setState(() => _minutes = v),
              labelOf: (v) => '$v min',
            ),

            const SizedBox(height: SbSpace.sm),
            Text(_basisLine, style: context.text.bodyMedium),
            if (qualifier != null) ...[
              const SizedBox(height: SbSpace.xxs),
              Text(
                qualifier,
                style: context.text.bodyMedium?.copyWith(color: sb.muted),
              ),
            ],

            const SizedBox(height: SbSpace.xl),
            FilledButton(
              onPressed: () =>
                  Navigator.of(context).pop(_PlanChoice.start(_minutes)),
              child: const Text('Start focus'),
            ),
            if (widget.basis != _RecommendationBasis.scan) ...[
              const SizedBox(height: SbSpace.xs),
              TextButton(
                onPressed: () =>
                    Navigator.of(context).pop(const _PlanChoice.rescan()),
                child: const Text('Measure now instead'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
