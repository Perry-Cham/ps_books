import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ps_books/services/downloader.dart';

class DownloadState {
  final List<DownloadBook>? searchResults;

  DownloadState({this.searchResults = const []});

  updateState(List<DownloadBook> books) {
    return DownloadState(searchResults: books);
  }
}

class DownloadNotifier extends Notifier<DownloadState> {
  @override
  DownloadState build() => DownloadState();

  void updateState(List<DownloadBook> books) {
    state = state.updateState(books);
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