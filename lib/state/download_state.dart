import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ps_books/services/downloader.dart';

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

  DownloadProgressState({
    this.progress = 0.0,
    this.fileName = '',
    this.isDownloading = false,
  });

  DownloadProgressState copyWith({
    double? progress,
    String? fileName,
    bool? isDownloading,
  }) {
    return DownloadProgressState(
      progress: progress ?? this.progress,
      fileName: fileName ?? this.fileName,
      isDownloading: isDownloading ?? this.isDownloading,
    );
  }
}

class DownloadProgressNotifier extends Notifier<DownloadProgressState> {
  @override
  DownloadProgressState build() => DownloadProgressState();

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
}

final downloadProgressProvider =
    NotifierProvider<DownloadProgressNotifier, DownloadProgressState>(
        DownloadProgressNotifier.new);