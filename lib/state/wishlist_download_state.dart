import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:ps_books/services/drive_book_downloader.dart';
import 'package:ps_books/state/google_auth.dart';


// Download progress state
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
    CancelToken? cancelToken
  }) {
    return DownloadProgressState(
        progress: progress ?? this.progress,
        fileName: fileName ?? this.fileName,
        isDownloading: isDownloading ?? this.isDownloading,
        completedMessage: completedMessage ?? this.completedMessage,
        cancelToken: cancelToken ?? this.cancelToken
    );
  }
}


class DownloadProgressNotifier extends Notifier<DownloadProgressState> {
  @override
  DownloadProgressState build() => DownloadProgressState();

  StreamSubscription<double>? _downloadSubscription;

  void updateProgress(double progress) {
    state = state.copyWith(progress: progress);
  }

  void setFileName(String fileName) {
    state = state.copyWith(fileName: fileName, isDownloading: true);
  }

  void resetProgress() {
    state = DownloadProgressState();
  }

  // Handle stream lifecycle safely away from widget contexts
  void startDownload(File file) {
    // Cancel any older dangling download subscriptions if necessary
    _downloadSubscription?.cancel();

    state = state.copyWith(
      isDownloading: true,
      fileName: file.name ?? 'Unknown File',
    );

    //Actual Download
    final authService = ref.read(authServiceProvider);
    _downloadSubscription = DriveBookService.downloadFile(authService, file).listen(
          (progress) {
        updateProgress(progress);
      },
      onDone: () {
        // Set a message string flag inside our state instead of hard-firing UI SnackBars
        state = state.copyWith(
          progress: 1.0,
          completedMessage: '${file.name} has downloaded',
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
  void cancel(){
    state.cancelToken?.cancel();
    resetProgress();
  }
}


final driveProgressProvider =
NotifierProvider<DownloadProgressNotifier, DownloadProgressState>(
    DownloadProgressNotifier.new);