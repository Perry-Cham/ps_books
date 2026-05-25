import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ps_books/services/download/downloader.dart';

enum DownloadProvider { libgen, zlib, steb }

class DownloadState {
  final List<DownloadBook>? searchResults;
  final bool? loading;
  final DownloadProvider downloadProvider;

  DownloadState({
    this.searchResults = const [],
    this.loading,
    this.downloadProvider = DownloadProvider.libgen,
  });

  DownloadState updateState({
    List<DownloadBook>? books,
    bool? loading,
    DownloadProvider? downloadProvider,
  }) {
    return DownloadState(
      searchResults: books ?? searchResults,
      loading: loading ?? this.loading,
      downloadProvider: downloadProvider ?? this.downloadProvider,
    );
  }
}

class DownloadNotifier extends Notifier<DownloadState> {
  @override
  DownloadState build() => DownloadState();

  void updateState({
    List<DownloadBook>? books,
    bool? loading,
    DownloadProvider? downloadProvider,
  }) {
    state = state.updateState(
      books: books,
      loading: loading,
      downloadProvider: downloadProvider,
    );
  }
}

final DownloadStateProvider =
    NotifierProvider<DownloadNotifier, DownloadState>(DownloadNotifier.new);

// Download progress state
class DownloadProgressState {
  final double progress;
  final String fileName;
  final bool isDownloading;
  final String completedMessage;

  DownloadProgressState({
    this.progress = 0.0,
    this.fileName = '',
    this.completedMessage = '',
    this.isDownloading = false,
  });

  DownloadProgressState copyWith({
    double? progress,
    String? fileName,
    bool? isDownloading,
    String? completedMessage
  }) {
    return DownloadProgressState(
      progress: progress ?? this.progress,
      fileName: fileName ?? this.fileName,
      isDownloading: isDownloading ?? this.isDownloading,
      completedMessage: completedMessage ?? this.completedMessage
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

  // Handle stream lifecycle safely away from widget contexts
  void startDownload(String url, String fileName) {
    // Cancel any older dangling download subscriptions if necessary
    _downloadSubscription?.cancel();

    setFileName(fileName);

    _downloadSubscription = downloadBookWithProgress(url).listen(
          (progress) {
        updateProgress(progress);
      },
      onDone: () {
        // Set a message string flag inside our state instead of hard-firing UI SnackBars
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
}


final downloadProgressProvider =
    NotifierProvider<DownloadProgressNotifier, DownloadProgressState>(
        DownloadProgressNotifier.new);