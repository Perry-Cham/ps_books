import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:ps_books/services/drive_book_downloader.dart';
import 'package:ps_books/state/google_auth.dart';

//Upload progress State
class UploadProgressState {
  final int total;
  final String fileName;
  final bool isUploading;
  final String completedMessage;
  final int received;

  UploadProgressState({
    this.total = 0,
    this.fileName = '',
    this.completedMessage = '',
    this.isUploading = false,
    this.received = 0
  });

  UploadProgressState copyWith({
    int? total,
    String? fileName,
    bool? isUploading,
    String? completedMessage,
    int? received
  }) {
    return UploadProgressState(
      total: total ?? this.total,
      fileName: fileName ?? this.fileName,
      isUploading: isUploading ?? this.isUploading,
      completedMessage: completedMessage ?? this.completedMessage,
      received: received?? this.received
    );
  }
}

// Total Upload Progress State
class TotalUploads {
  final Map<String, UploadProgressState> total;
  TotalUploads({this.total = const {}});
  TotalUploads copyWith(Map<String, UploadProgressState>? uploads){
 return TotalUploads(
   total: uploads ?? total,
);
  }
}

class UploadProgressNotifier extends Notifier<TotalUploads> {
  @override
  TotalUploads build() => TotalUploads();
//Note to future self when you develop the concurrent downloads feature we are creating an array of futures in this case to avoid awaiting drive.createw in a for in loop because doing so would prevent concurrent uploads they'd still upload sequentially


  // Also when you add concurrent downloads you'll want to use a stream controller at leats from libgen and friends anyway'
  Future<void> uploadFiles(List<File> files, drive.DriveApi driveApi, String folderId) async {
    // 1. Properly initialize the Map using file.path uniformly
    Map<String, UploadProgressState> initialMap = {...state.total};

    for (var file in files) {
      final String filename = file.path.split('/').last;
      initialMap[file.path] = UploadProgressState(
        fileName: filename,
        isUploading: true,
        total: await file.length(),
        received: 0,
      );
    }
    state = state.copyWith(initialMap);

    // 2. Map each file to an asynchronous upload process to run them CONCURRENTLY
    final uploadTasks = files.map((file) async {
      final String filename = file.path.split('/').last;
      final int totalSize = await file.length();
      int sent = 0;

      // Intercept the chunks and update Riverpod directly
      final trackedStream = file.openRead().map((chunk) {
        sent += chunk.length;

        // Update state immutably using the consistent file.path key
        state = state.copyWith({
          ...state.total,
          file.path: state.total[file.path]!.copyWith(
            received: sent,
          ),
        });
        return chunk;
      });

      try {
        // Hand off stream execution directly to Google Drive
        await driveApi.files.create(
          drive.File()
          ..name = filename
          ..parents = [folderId],
          uploadMedia: drive.Media(trackedStream, totalSize),
        );

        // Update when successfully complete
        state = state.copyWith({
          ...state.total,
          file.path: state.total[file.path]!.copyWith(
            received: totalSize,
            isUploading: false,
            completedMessage: 'Done',
          ),
        });
      } catch (e, h) {
        print("Error uploading $filename: $e");
        print(h);

        state = state.copyWith({
          ...state.total,
          file.path: state.total[file.path]!.copyWith(
            isUploading: false,
            completedMessage: 'Failed',
          ),
        });
      }
    });

    // 3. Await all uploads to run simultaneously
    await Future.wait(uploadTasks);
  }
}


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
    state = state.copyWith(progress: progress);
  }

  void setFileName(String fileName) {
    state = state.copyWith(fileName: fileName, isDownloading: true);
  }

  void resetProgress() {
    state = DownloadProgressState();
  }

  // Handle stream lifecycle safely away from widget contexts
  void startDownload(drive.File file) {
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

  void cancel() {
    state.cancelToken?.cancel();
    resetProgress();
  }
}

final driveProgressProvider =
    NotifierProvider<DownloadProgressNotifier, DownloadProgressState>(
      DownloadProgressNotifier.new,
    );

final uploadProgressProvider =
    NotifierProvider<UploadProgressNotifier, TotalUploads>(
      UploadProgressNotifier.new,
    );
