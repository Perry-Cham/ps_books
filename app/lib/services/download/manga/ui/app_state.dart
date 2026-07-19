// =============================================================================
// mangodl_flutter — Educational Flutter port of mangodl-nodejs.
// See lib/parsers/base.dart for the project-wide disclaimer.
// =============================================================================

// -----------------------------------------------------------------------------
// lib/ui/app_state.dart — App state using ChangeNotifier.
//
// The JS version kept state in DOM elements (searchResults div, etc).
// For Flutter we use a simple ChangeNotifier that the UI widgets
// listen to via ListenableBuilder. This is the simplest non-trivial
// state-management approach for Flutter and avoids the cognitive
// overhead of Riverpod / BLoC for a learning project.
//
// The state machine has these phases:
//   idle → searching → searchResults
//   idle → loadingChapters → chapterList
//   chapterList → downloading → downloaded (per chapter)
// ----------------------------------------------------------------------------

import 'package:flutter/foundation.dart';

import '../parsers/base.dart';
import '../parsers/registry.dart';
import '../services/download_service.dart' as svc;

enum AppState { idle, searching, searchingDone, loadingChapters, chaptersReady }

class ChapterDownloadStatus {
  final String chapterId;
  final String? status; // null = idle, 'downloading', 'done', 'error'
  final String? error;
  const ChapterDownloadStatus({
    required this.chapterId,
    this.status,
    this.error,
  });
}

class MangodlAppState extends ChangeNotifier {
  AppState _phase = AppState.idle;
  String _selectedParserKey = 'weebcentral';
  String _statusMessage = 'Ready.';
  List<MangaSearchResult> _searchResults = [];
  MangaSearchResult? _selectedManga;
  List<ChapterInfo> _chapters = [];
  final Map<String, ChapterDownloadStatus> _chapterStatus = {};
  String? _lastError;

  AppState get phase => _phase;
  String get selectedParserKey => _selectedParserKey;
  String get statusMessage => _statusMessage;
  List<MangaSearchResult> get searchResults => _searchResults;
  MangaSearchResult? get selectedManga => _selectedManga;
  List<ChapterInfo> get chapters => _chapters;
  String? get lastError => _lastError;

  ChapterDownloadStatus? statusOf(String chapterId) => _chapterStatus[chapterId];

  void selectParser(String key) {
    _selectedParserKey = key;
    notifyListeners();
  }

  Future<void> search(String query) async {
    _phase = AppState.searching;
    _statusMessage = 'Searching for "$query"…';
    _lastError = null;
    _searchResults = [];
    notifyListeners();

    try {
      final parser = ParserRegistry.get(_selectedParserKey);
      final results = await parser.search(query);
      _searchResults = results;
      _phase = AppState.searchingDone;
      _statusMessage = 'Found ${results.length} result(s).';
    } catch (e) {
      _lastError = e.toString();
      _statusMessage = 'Search failed: $e';
      _phase = AppState.searchingDone;
    }
    notifyListeners();
  }

  Future<void> selectManga(MangaSearchResult manga) async {
    _selectedManga = manga;
    _phase = AppState.loadingChapters;
    _statusMessage = 'Loading chapters for "${manga.title}"…';
    _lastError = null;
    _chapters = [];
    _chapterStatus.clear();
    notifyListeners();

    try {
      final parser = ParserRegistry.get(_selectedParserKey);
      final chapters = await parser.getChapters(detailUrl: manga.detailUrl);
      _chapters = chapters;
      _phase = AppState.chaptersReady;
      _statusMessage = 'Loaded ${chapters.length} chapter(s). Tap one to download.';
    } catch (e) {
      _lastError = e.toString();
      _statusMessage = 'Failed to load chapters: $e';
      _phase = AppState.chaptersReady;
    }
    notifyListeners();
  }

  Future<void> downloadChapter(
    ChapterInfo chapter, {
    String outputDir = './mangodl_downloads',
    String format = 'cbz',
  }) async {
    _chapterStatus[chapter.id] = ChapterDownloadStatus(
      chapterId: chapter.id,
      status: 'downloading',
    );
    _statusMessage = 'Downloading ${chapter.label}…';
    notifyListeners();

    try {
      final parser = ParserRegistry.get(_selectedParserKey);
      await svc.downloadChapter(
        parser: parser,
        chapter: chapter,
        outputDir: outputDir,
        format: format,
      );
      _chapterStatus[chapter.id] = ChapterDownloadStatus(
        chapterId: chapter.id,
        status: 'done',
      );
      _statusMessage = 'Downloaded ${chapter.label}.';
    } catch (e) {
      _chapterStatus[chapter.id] = ChapterDownloadStatus(
        chapterId: chapter.id,
        status: 'error',
        error: e.toString(),
      );
      _statusMessage = 'Failed: $e';
    }
    notifyListeners();
  }

  void clearSelection() {
    _selectedManga = null;
    _chapters = [];
    _phase = AppState.idle;
    _statusMessage = 'Ready.';
    notifyListeners();
  }
}
