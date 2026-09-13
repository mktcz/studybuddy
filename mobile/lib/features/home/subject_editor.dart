import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui/ui.dart';
import 'package:uuid/uuid.dart';

import '../../app/providers.dart';
import '../../data/database.dart';
import '../state/rest_alert_host.dart';


class SubjectEditor extends ConsumerStatefulWidget {
  const SubjectEditor({super.key, this.existing});

  final Subject? existing;

  static Future<void> show(
    BuildContext context,
    WidgetRef ref, {
    Subject? existing,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) =>
          RestAlertSuppressionScope(child: SubjectEditor(existing: existing)),
    );
  }

  @override
  ConsumerState<SubjectEditor> createState() => _SubjectEditorState();
}

class _SubjectEditorState extends ConsumerState<SubjectEditor> {
  late final _name = TextEditingController(text: widget.existing?.name ?? '');
  late int _accent = widget.existing?.accentIndex ?? 0;

  @override
  void initState() {
    super.initState();
    _name.addListener(_onNameChanged);
  }

  void _onNameChanged() => setState(() {});

  @override
  void dispose() {
    _name
      ..removeListener(_onNameChanged)
      ..dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.isEmpty) return;

    final db = ref.read(databaseProvider);
    final existing = widget.existing;

    if (existing == null) {
      await db.upsertSubject(
        SubjectsCompanion.insert(
          id: const Uuid().v4(),
          name: name,
          accentIndex: Value(_accent),
          createdAt: DateTime.now(),
        ),
      );
    } else {


      await db.updateSubject(
        existing.id,
        SubjectsCompanion(name: Value(name), accentIndex: Value(_accent)),
      );
    }

    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _archive() async {
    final existing = widget.existing;
    if (existing == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => RestAlertSuppressionScope(
        child: AlertDialog(
          title: const Text('Archive subject?'),
          content: Text(
            '"${existing.name}" will be hidden from the shelf. Its sessions '
            'stay in your history.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Archive'),
            ),
          ],
        ),
      ),
    );

    if (confirmed != true) return;
    await ref.read(databaseProvider).archiveSubject(existing.id);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final sb = context.sb;
    final isNew = widget.existing == null;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: SbSpace.xl,
          right: SbSpace.xl,
          top: SbSpace.lg,
          bottom: MediaQuery.viewInsetsOf(context).bottom + SbSpace.xl,
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

            Eyebrow(isNew ? 'New subject' : 'Edit subject'),
            const SizedBox(height: SbSpace.md),

            TextField(
              controller: _name,
              autofocus: isNew,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(hintText: 'Organic Chemistry'),
            ),
            const SizedBox(height: SbSpace.xl),

            const Eyebrow('Colour'),
            const SizedBox(height: SbSpace.sm),
            Wrap(
              spacing: SbSpace.sm,
              runSpacing: SbSpace.sm,
              children: [
                for (var i = 0; i < sb.subjects.length; i++)
                  _AccentSwatch(
                    color: sb.subjects[i],
                    selected: _accent == i,
                    onTap: () => setState(() => _accent = i),
                  ),
              ],
            ),
            const SizedBox(height: SbSpace.xl),

            FilledButton(
              onPressed: _name.text.trim().isEmpty ? null : _save,
              child: Text(isNew ? 'Create' : 'Save'),
            ),
            if (!isNew) ...[
              const SizedBox(height: SbSpace.xs),
              TextButton(
                onPressed: _archive,
                child: const Text('Archive subject'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AccentSwatch extends StatelessWidget {
  const _AccentSwatch({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: SbMotion.quick,
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            borderRadius: SbRadius.cardAll,
            border: Border.all(
              color: selected ? context.sb.ink : Colors.transparent,
              width: 2,
            ),
          ),
          child: selected
              ? Icon(Icons.check, size: 18, color: context.sb.canvas)
              : null,
        ),
      ),
    );
  }
}
