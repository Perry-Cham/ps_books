import 'dart:io';

import 'package:flutter_download_manager/flutter_download_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ps_books/models/comic_book_model.dart';
import 'package:ps_books/services/download/downloader.dart';

enum DownloadProvider { libgen, steb, manga, gutenberg }
enum SearchMode { normal, series }

class DownloadState {
  final List<SeriesModel>? searchResults;
  final bool? loading;
  final DownloadProvider downloadProvider;
  final SearchMode searchMode;

  DownloadState({
    this.searchResults = const [],
    this.loading,
    this.downloadProvider = DownloadProvider.libgen,
    this.searchMode = SearchMode.normal,
  });

  DownloadState updateState({
    List<SeriesModel>? books,
    bool? loading,
    DownloadProvider? downloadProvider,
    SearchMode? searchMode,
  }) {
    return DownloadState(
      searchResults: books ?? searchResults,
      loading: loading ?? this.loading,
      downloadProvider: downloadProvider ?? this.downloadProvider,
      searchMode: searchMode ?? this.searchMode,
    );
  }
}

class DownloadNotifier extends Notifier<DownloadState> {
  @override
  DownloadState build() => DownloadState();

  void updateState({
    List<SeriesModel>? books,
    bool? loading,
    DownloadProvider? downloadProvider,
    SearchMode? searchMode,
  }) {
    state = state.updateState(
      books: books,
      loading: loading,
      downloadProvider: downloadProvider,
      searchMode: searchMode,
    );
  }
}

final DownloadStateProvider =
    NotifierProvider<DownloadNotifier, DownloadState>(DownloadNotifier.new);

class DownloadTaskInfo {
  final String url;
  final String fileName;
  final double progress;
  final DownloadStatus status;

  const DownloadTaskInfo({
    required this.url,
    required this.fileName,
    this.progress = 0.0,
    this.status = DownloadStatus.queued,
  });

  DownloadTaskInfo copyWith({
    double? progress,
    DownloadStatus? status,
  }) {
    return DownloadTaskInfo(
      url: url,
      fileName: fileName,
      progress: progress ?? this.progress,
      status: status ?? this.status,
    );
  }
}

class DownloadProgressState {
  final Map<String, DownloadTaskInfo> downloads;

  const DownloadProgressState({this.downloads = const {}});

  List<DownloadTaskInfo> get downloadList => downloads.values.toList();
}

class DownloadProgressNotifier extends Notifier<DownloadProgressState> {
  @override
  DownloadProgressState build() => const DownloadProgressState();

  Future<void> startDownload(String url, String fileName) async {
    if (state.downloads.containsKey(url)) return;

    final d = await getApplicationDocumentsDirectory();
    final booksDir = Directory('${d.path}/Books');
    await booksDir.create(recursive: true);
    final savePath = '${booksDir.path}/$fileName';

    final task = await downloadManager.addDownload(url, savePath);
    if (task == null) return;

    state = DownloadProgressState(downloads: {
      ...state.downloads,
      url: DownloadTaskInfo(url: url, fileName: fileName),
    });

    task.progress.addListener(() {
      final info = state.downloads[url];
      if (info != null) {
        state = DownloadProgressState(downloads: {
          ...state.downloads,
          url: info.copyWith(progress: task.progress.value),
        });
      }
    });

    task.status.addListener(() async {
      final info = state.downloads[url];
      if (info == null) return;

      state = DownloadProgressState(downloads: {
        ...state.downloads,
        url: info.copyWith(status: task.status.value),
      });

      if (task.status.value == DownloadStatus.completed) {
        await processDownloadedBook(savePath);
        Future.delayed(const Duration(seconds: 3), () {
          _removeTask(url);
        });
      } else if (task.status.value == DownloadStatus.failed) {
        Future.delayed(const Duration(seconds: 3), () {
          _removeTask(url);
        });
      } else if (task.status.value == DownloadStatus.canceled) {
        _removeTask(url);
      }
    });
  }

  void _removeTask(String url) {
    final map = Map<String, DownloadTaskInfo>.from(state.downloads);
    map.remove(url);
    state = DownloadProgressState(downloads: map);
  }

  void cancelDownload(String url) {
    downloadManager.cancelDownload(url);
    _removeTask(url);
  }
}

final downloadProgressProvider =
    NotifierProvider<DownloadProgressNotifier, DownloadProgressState>(
  DownloadProgressNotifier.new,
);
