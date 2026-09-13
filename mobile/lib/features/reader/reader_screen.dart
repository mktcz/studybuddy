import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:ui/ui.dart';

import '../../app/providers.dart';
import '../../data/database.dart';
import '../focus/focus_bar_host.dart';
import '../focus/focus_controller.dart';
import '../focus/start_flow.dart';
import '../state/hsi_providers.dart';


class ReaderScreen extends ConsumerStatefulWidget {
  const ReaderScreen({
    super.key,
    required this.subjectId,
    required this.sourceId,
  });

  final String subjectId;
  final String sourceId;

  @override
  ConsumerState<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends ConsumerState<ReaderScreen> {
  final _controller = PdfViewerController();
  final _searchController = TextEditingController();
  late final AppDatabase _database;

  PdfTextSearcher? _searcher;
  Source? _source;
  int _page = 1;
  int? _pageCount;
  bool _searching = false;
  bool? _fileExists;
  bool _loaded = false;
  Timer? _saveDebounce;
  int? _lastEventPage;

  @override
  void initState() {
    super.initState();
    _database = ref.read(databaseProvider);
    unawaited(_load());
  }

  Future<void> _load() async {
    final sourceStore = ref.read(sourceStoreProvider);
    final source = await _database.findSource(widget.sourceId);
    final exists = source == null
        ? false
        : await sourceStore.existsAsync(source.filePath);
    if (!mounted) return;
    setState(() {
      _source = source;
      _page = source?.lastPage ?? 1;
      _pageCount = source?.pageCount;
      _fileExists = exists;
      _loaded = true;
    });


    final focus = ref.read(focusControllerProvider);
    if (source != null &&
        focus.isActive &&
        focus.subjectId == widget.subjectId) {
      unawaited(
        ref
            .read(focusControllerProvider.notifier)
            .attachSource(widget.sourceId),
      );
      _recordPageEvent();
    }
  }


  void _schedulePositionSave() {
    _saveDebounce?.cancel();
    _saveDebounce = Timer(const Duration(seconds: 1), () {
      _database.recordSourceOpened(widget.sourceId, _page, _pageCount);
      _recordPageEvent();
    });
  }


  void _recordPageEvent() {
    final focus = ref.read(focusControllerProvider);
    if (!focus.isActive || focus.subjectId != widget.subjectId) return;
    if (_lastEventPage == _page) return;
    _lastEventPage = _page;
    final now = DateTime.now();
    unawaited(
      _database.insertPageEvent(
        PageEventsCompanion.insert(
          sessionId: focus.sessionId!,
          sourceId: widget.sourceId,
          page: _page,
          at: now,
        ),
      ),
    );


    ref
        .read(hsiEngineProvider)
        .recordStudyMetric(
          'study.page',
          now,
          value: _page.toDouble(),
          tags: {'source': widget.sourceId},
        );
  }

  @override
  void dispose() {
    _saveDebounce?.cancel();

    unawaited(_database.recordSourceOpened(widget.sourceId, _page, _pageCount));
    _searcher?.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sb = context.sb;
    final source = _source;
    final focusActive = ref.watch(
      focusControllerProvider.select((value) => value.isActive),
    );

    if (!_loaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (source == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('This source no longer exists.')),
      );
    }

    if (_fileExists == false) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(SbSpace.gutter),
            child: Text(
              'This file is missing from storage. Remove the source and add '
              'it again.',
              textAlign: TextAlign.center,
              style: context.text.bodyLarge,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.canPop()
              ? context.pop()
              : context.go('/subject/${widget.subjectId}'),
          icon: const Icon(Icons.arrow_back),
        ),
        title: _searching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                textInputAction: TextInputAction.search,
                decoration: const InputDecoration(hintText: 'Search in PDF'),
                onSubmitted: (query) => _searcher?.startTextSearch(query),
              )
            : Text(
                source.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.text.titleMedium,
              ),
        actions: [
          if (_searching) ...[
            IconButton(
              onPressed: () => _searcher?.goToNextMatch(),
              tooltip: 'Next match',
              icon: const Icon(Icons.keyboard_arrow_down),
            ),
            IconButton(
              onPressed: () {
                _searcher?.resetTextSearch();
                _searchController.clear();
                setState(() => _searching = false);
              },
              tooltip: 'Close search',
              icon: const Icon(Icons.close),
            ),
          ] else ...[
            IconButton(
              onPressed: () => setState(() => _searching = true),
              tooltip: 'Search',
              icon: const Icon(Icons.search),
            ),
            if (!focusActive)
              IconButton(
                onPressed: () => _startSession(source),
                tooltip: 'Start focus on this source',
                icon: const Icon(Icons.play_arrow_rounded),
              ),
          ],
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(20),
          child: Padding(
            padding: const EdgeInsets.only(
              left: SbSpace.md,
              bottom: SbSpace.xs,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Eyebrow(
                _pageCount == null
                    ? 'Page $_page'
                    : 'Page $_page of $_pageCount',
              ),
            ),
          ),
        ),
      ),
      body: PdfViewer.file(
        source.filePath,
        controller: _controller,
        initialPageNumber: _page,
        params: PdfViewerParams(
          backgroundColor: sb.canvas,
          margin: SbSpace.xs,
          sizeDelegateProvider: const PdfViewerSizeDelegateProviderLegacy(
            maxScale: 8,
          ),
          onViewerReady: (document, controller) {
            _searcher = PdfTextSearcher(controller)..addListener(_onSearch);
            final count = document.pages.length;
            if (count != _pageCount && mounted) {
              setState(() => _pageCount = count);
              _schedulePositionSave();
            }
          },
          onPageChanged: (pageNumber) {
            if (pageNumber == null || !mounted) return;
            setState(() => _page = pageNumber);
            _schedulePositionSave();
          },
          loadingBannerBuilder: (context, bytes, total) =>
              const Center(child: CircularProgressIndicator()),
          errorBannerBuilder: (context, error, stack, documentRef) => Center(
            child: Padding(
              padding: const EdgeInsets.all(SbSpace.gutter),
              child: Text(
                'This PDF could not be opened.\n$error',
                textAlign: TextAlign.center,
                style: context.text.bodyMedium,
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: const SafeArea(child: FocusBarHost()),
    );
  }

  void _onSearch() {
    if (mounted) setState(() {});
  }

  Future<void> _startSession(Source source) async {
    final subject = await ref
        .read(databaseProvider)
        .findSubject(source.subjectId);
    if (subject == null || !mounted) return;
    await startSessionFlow(context, ref, subject, sourceId: source.id);
  }
}
