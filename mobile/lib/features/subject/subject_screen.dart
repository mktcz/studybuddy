import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui/ui.dart';
import 'package:uuid/uuid.dart';

import '../../app/providers.dart';
import '../../data/database.dart';
import '../../data/pdf_picker.dart';
import '../focus/focus_bar_host.dart';
import '../focus/focus_controller.dart';
import '../focus/start_flow.dart';
import '../home/subject_editor.dart';
import '../state/rest_alert_host.dart';


class SubjectScreen extends ConsumerWidget {
  const SubjectScreen({super.key, required this.subjectId});

  final String subjectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subject = ref.watch(subjectProvider(subjectId)).value;
    final sources = ref.watch(sourcesProvider(subjectId)).value ?? const [];
    final summaries = ref.watch(subjectSummariesProvider).value ?? const [];
    final focus = ref.watch(
      focusControllerProvider.select((value) => (isActive: value.isActive)),
    );

    if (subject == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final accent = context.sb.subject(subject.accentIndex);
    SubjectSummary? summary;
    for (final candidate in summaries) {
      if (candidate.subject.id == subject.id) {
        summary = candidate;
        break;
      }
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
          icon: const Icon(Icons.arrow_back),
        ),
        actions: [
          IconButton(
            onPressed: () =>
                SubjectEditor.show(context, ref, existing: subject),
            tooltip: 'Edit subject',
            icon: const Icon(Icons.more_horiz),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          SbSpace.gutter,
          SbSpace.xs,
          SbSpace.gutter,
          SbSpace.xxxl,
        ),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 4,
                height: 44,
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: SbRadius.pillAll,
                ),
              ),
              const SizedBox(width: SbSpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(subject.name, style: context.text.displaySmall),
                    const SizedBox(height: SbSpace.xxs),
                    Text(
                      '${summary?.sourceCount ?? sources.length} ${(summary?.sourceCount ?? sources.length) == 1 ? 'source' : 'sources'}  ·  ${SbFormat.minutes(summary?.focusedMinutes ?? 0)} focused',
                      style: context.text.bodyMedium?.copyWith(
                        color: context.sb.muted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: SbSpace.xl),


          if (!focus.isActive) ...[
            FilledButton.icon(
              onPressed: () => startSessionFlow(context, ref, subject),
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Study now'),
            ),
            const SizedBox(height: SbSpace.xxl),
          ] else
            const SizedBox(height: SbSpace.sm),

          SectionHeader(
            label: 'Sources',
            actionLabel: 'Add PDF',
            onAction: () => _importPdf(context, ref, subject),
          ),

          if (sources.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: SbSpace.md),
              child: Text(
                'No sources yet. Add a PDF and it becomes readable here, with '
                'your reading time counted against this subject.',
                style: context.text.bodyLarge?.copyWith(
                  color: context.sb.muted,
                ),
              ),
            )
          else
            for (final (index, source) in sources.indexed)
              SourceTile(
                title: source.title,
                subtitle: _sourceSubtitle(source),
                progress: _readingProgress(source),
                accent: accent,
                divider: index != sources.length - 1,
                onTap: () =>
                    context.go('/subject/${subject.id}/read/${source.id}'),
                trailing: IconButton(
                  onPressed: () => _removeSource(context, ref, source),
                  tooltip: 'Remove source',
                  icon: const Icon(Icons.close, size: 18),
                ),
              ),
        ],
      ),
      bottomNavigationBar: const SafeArea(child: FocusBarHost()),
    );
  }

  static String _sourceSubtitle(Source source) {
    final parts = <String>[];
    if (source.pageCount != null) parts.add('${source.pageCount} pages');
    if (source.lastOpenedAt != null) {
      parts.add('opened ${SbFormat.relative(source.lastOpenedAt!)}');
    } else {
      parts.add('not opened yet');
    }
    return parts.join(' · ');
  }

  static double? _readingProgress(Source source) {
    final pages = source.pageCount;
    final page = source.lastPage;
    if (pages == null || page == null || pages <= 0) return null;
    return page / pages;
  }

  static Future<void> _importPdf(
    BuildContext context,
    WidgetRef ref,
    Subject subject,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final db = ref.read(databaseProvider);
    final store = ref.read(sourceStoreProvider);

    File? cached;
    try {
      final picked = await const PdfPicker().pick();

      if (picked == null) return;

      cached = File(picked.path);
      final sourceId = const Uuid().v4();
      final stored = await store.import(cached, sourceId);

      await db.upsertSource(
        SourcesCompanion.insert(
          id: sourceId,
          subjectId: subject.id,
          title: picked.name,
          filePath: stored,
          bytes: Value(picked.bytes),


          addedAt: DateTime.now(),
        ),
      );
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text('Could not import that PDF: $error')),
      );
    } finally {

      if (cached != null && cached.existsSync()) {
        await cached.delete();
      }
    }
  }

  static Future<void> _removeSource(
    BuildContext context,
    WidgetRef ref,
    Source source,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => RestAlertSuppressionScope(
        child: AlertDialog(
          title: const Text('Remove source?'),
          content: Text('"${source.title}" will be deleted from this device.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Remove'),
            ),
          ],
        ),
      ),
    );

    if (confirmed != true) return;

    await ref.read(sourceStoreProvider).remove(source.filePath);
    await ref.read(databaseProvider).deleteSource(source.id);
  }
}
