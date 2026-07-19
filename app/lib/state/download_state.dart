import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ps_books/models/comic_book_model.dart';
import 'package:ps_books/services/download/downloader.dart';

enum DownloadProvider { libgen, steb, manga }
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

class DownloadProgressState {
  final double progress;
  final String fileName;
  final bool isDownloading;
  final String completedMessage;
  final CancelToken? cancelToken;

  DownloadProgressState({
    this.progress = 0.0,
    this.fileName = '',
    this.completedMessage = '',
    this.isDownloading = false,
    this.cancelToken,
  });

  DownloadProgressState copyWith({
    double? progress,
    String? fileName,
    bool? isDownloading,
    String? completedMessage,
    CancelToken? cancelToken,
  }) {
    return DownloadProgressState(
      progress: progress ?? this.progress,
      fileName: fileName ?? this.fileName,
      isDownloading: isDownloading ?? this.isDownloading,
      completedMessage: completedMessage ?? this.completedMessage,
      cancelToken: cancelToken ?? this.cancelToken,
    );
  }
}

class DownloadProgressNotifier extends Notifier<DownloadProgressState> {
  @override
  DownloadProgressState build() => DownloadProgressState();

  StreamSubscription<double>? _downloadSubscription;

  void updateProgress(double progress) {
    print(progress);
    state = state.copyWith(progress: progress);
  }

  void setFileName(String fileName) {
    state = state.copyWith(fileName: fileName, isDownloading: true);
  }

  void resetProgress() {
    state = DownloadProgressState();
  }

  void startDownload(String url, String fileName) {
    _downloadSubscription?.cancel();

    setFileName(fileName);
    state = state.copyWith(cancelToken: CancelToken(), isDownloading: true);

    _downloadSubscription = downloadBookWithProgress(url, state.cancelToken!).listen(
      (progress) {
        updateProgress(progress);
      },
      onDone: () {
        state = state.copyWith(
          progress: 1.0,
          completedMessage: '$fileName has downloaded',
        );

        Future.delayed(const Duration(seconds: 2), () {
          resetProgress();
        });
      },
      onError: (error) {
        print('Download error: $error');
        resetProgress();
      },
    );
  }

  void dispose() {
    _downloadSubscription?.cancel();
  }

  void cancel() {
    state.cancelToken?.cancel();
    resetProgress();
  }
}

final downloadProgressProvider =
    NotifierProvider<DownloadProgressNotifier, DownloadProgressState>(
  DownloadProgressNotifier.new,
);
