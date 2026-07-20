import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'package:collection/collection.dart';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_download_manager/flutter_download_manager.dart';

import 'download_parts_info.dart';
import 'multi_part_downloader.dart';

class DownloadManager {
  final Map<String, DownloadTask> _cache = <String, DownloadTask>{};
  final Queue<DownloadRequest> _queue = Queue();
  var dio = Dio();
  static const partialExtension = ".partial";
  static const tempExtension = ".temp";

  // Multi-connection support
  int? _connections;
  MultiPartDownloader? _multiPartDownloader;

  int maxConcurrentTasks = 2;
  int runningTasks = 0;

  // Download speed tracking
  final Map<String, _SpeedTracker> _speedTrackers = {};

  static final DownloadManager _dm = new DownloadManager._internal();

  DownloadManager._internal();

  /// Create a DownloadManager instance
  ///
  /// [maxConcurrentTasks] - Maximum number of concurrent downloads (default: 2)
  /// [dio] - Custom Dio instance for HTTP requests
  /// [connections] - Number of parallel connections per download for multi-part downloading.
  ///                When specified (>1), enables multi-connection downloading which can significantly
  ///                improve download speeds by splitting the file into chunks and downloading them
  ///                in parallel. Requires server support for range requests.
  factory DownloadManager({
    int? maxConcurrentTasks,
    Dio? dio,
    int? connections,
  }) {
    if (maxConcurrentTasks != null) {
      _dm.maxConcurrentTasks = maxConcurrentTasks;
    }

    _dm.dio = dio ?? Dio();
    _dm._connections = connections;
    
    // Initialize multi-part downloader if connections specified
    if (connections != null && connections > 1) {
      _dm._multiPartDownloader = MultiPartDownloader(
        dio: _dm.dio,
        connections: connections,
      );
    }

    return _dm;
  }

  /// Get the number of configured connections for multi-part downloading
  int? get connections => _connections;

  /// Check if multi-part downloading is enabled
  bool get isMultiPartEnabled => _connections != null && _connections! > 1;

  void Function(int, int) createCallback(url, int partialFileLength) =>
      (int received, int total) {
        getDownload(url)?.progress.value =
            (received + partialFileLength) / (total + partialFileLength);

        // Update speed tracking
        _updateSpeedTracker(url, received);

        if (total == -1) {}
      };

  void _updateSpeedTracker(String url, int bytesReceived) {
    if (!_speedTrackers.containsKey(url)) {
      _speedTrackers[url] = _SpeedTracker();
    }
    _speedTrackers[url]!.update(bytesReceived);
  }

  /// Get current download speed in bytes per second
  double? getDownloadSpeed(String url) {
    return _speedTrackers[url]?.currentSpeed;
  }

  /// Get formatted download speed string (e.g., "1.5 MB/s")
  String? getFormattedDownloadSpeed(String url) {
    final speed = getDownloadSpeed(url);
    if (speed == null) return null;
    return _formatBytes(speed.round()) + '/s';
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  Future<void> download(String url, String savePath, cancelToken,
      {forceDownload = false}) async {
    late String partialFilePath;
    late File partialFile;
    
    try {
      var task = getDownload(url);

      if (task == null || task.status.value == DownloadStatus.canceled) {
        return;
      }
      setStatus(task, DownloadStatus.downloading);

      if (kDebugMode) {
        print(url);
        print('Multi-part enabled: $isMultiPartEnabled, connections: $_connections');
      }
      
      var file = File(savePath.toString());
      partialFilePath = savePath + partialExtension;
      partialFile = File(partialFilePath);

      var fileExist = await file.exists();
      var partialFileExist = await partialFile.exists();
      
      // Check for parts file existence (multi-part download)
      var partsFileExists = await DownloadPartsFile.exists(partialFilePath);

      if (fileExist) {
        if (kDebugMode) {
          print("File Exists");
        }
        setStatus(task, DownloadStatus.completed);
        
      } else if (isMultiPartEnabled || partsFileExists) {
        // Use multi-part downloader
        await _downloadWithMultipleConnections(
          url, savePath, partialFilePath, task, cancelToken
        );
        
      } else if (partialFileExist) {
        if (kDebugMode) {
          print("Partial File Exists");
        }

        var partialFileLength = await partialFile.length();

        var response = await dio.download(url, partialFilePath + tempExtension,
            onReceiveProgress: createCallback(url, partialFileLength),
            options: Options(
              headers: {HttpHeaders.rangeHeader: 'bytes=$partialFileLength-'},
            ),
            cancelToken: cancelToken,
            deleteOnError: true);

        if (response.statusCode == HttpStatus.partialContent) {
          var ioSink = partialFile.openWrite(mode: FileMode.writeOnlyAppend);
          var _f = File(partialFilePath + tempExtension);
          await ioSink.addStream(_f.openRead());
          await _f.delete();
          await ioSink.close();
          await partialFile.rename(savePath);

          setStatus(task, DownloadStatus.completed);
        }
      } else {
        var response = await dio.download(url, partialFilePath,
            onReceiveProgress: createCallback(url, 0),
            cancelToken: cancelToken,
            deleteOnError: false);

        if (response.statusCode == HttpStatus.ok) {
          await partialFile.rename(savePath);
          setStatus(task, DownloadStatus.completed);
        }
      }
    } catch (e) {
      var task = getDownload(url)!;
      
      // For multi-part downloads, save progress on pause
      if (isMultiPartEnabled && task.status.value == DownloadStatus.paused) {
        await _multiPartDownloader?.pause(partialFilePath);
      }
      
      if (task.status.value != DownloadStatus.canceled &&
          task.status.value != DownloadStatus.paused) {
        setStatus(task, DownloadStatus.failed);
        runningTasks--;

        if (_queue.isNotEmpty) {
          _startExecution();
        }
        rethrow;
      } else if (task.status.value == DownloadStatus.paused) {
        final ioSink = partialFile.openWrite(mode: FileMode.writeOnlyAppend);
        final f = File(partialFilePath + tempExtension);
        if (await f.exists()) {
          await ioSink.addStream(f.openRead());
        }
        await ioSink.close();
      }
    }

    // Clean up speed tracker
    _speedTrackers.remove(url);

    runningTasks--;

    if (_queue.isNotEmpty) {
      _startExecution();
    }
  }

  /// Download using multiple connections
  Future<void> _downloadWithMultipleConnections(
    String url,
    String savePath,
    String partialFilePath,
    DownloadTask task,
    CancelToken cancelToken,
  ) async {
    // Ensure multi-part downloader is initialized
    _multiPartDownloader ??= MultiPartDownloader(
      dio: dio,
      connections: _connections ?? 4,
    );

    final success = await _multiPartDownloader!.download(
      url,
      savePath,
      cancelToken,
      onProgress: (progress) {
        task.progress.value = progress;
      },
    );

    if (success) {
      setStatus(task, DownloadStatus.completed);
    } else {
      // Fall back to single connection if multi-part failed
      if (kDebugMode) {
        print('Multi-part download failed or not supported, falling back to single connection');
      }
      
      // Clean up and let normal download handle it
      await MultiPartDownloader.cleanup(partialFilePath);
      
      // Re-run with single connection by temporarily disabling multi-part
      final originalConnections = _connections;
      _connections = null; // Disable for this attempt
      
      try {
        await _downloadSingleConnection(url, savePath, partialFilePath, task, cancelToken);
      } finally {
        _connections = originalConnections; // Restore setting
      }
    }
  }

  /// Standard single-connection download (fallback)
  Future<void> _downloadSingleConnection(
    String url,
    String savePath,
    String partialFilePath,
    DownloadTask task,
    CancelToken cancelToken,
  ) async {
    final partialFile = File(partialFilePath);
    final fileExist = await File(savePath).exists();
    final partialFileExist = await partialFile.exists();

    if (fileExist) {
      setStatus(task, DownloadStatus.completed);
      return;
    }

    if (partialFileExist) {
      final partialFileLength = await partialFile.length();
      
      final response = await dio.download(
        url,
        partialFilePath + tempExtension,
        onReceiveProgress: createCallback(url, partialFileLength),
        options: Options(
          headers: {HttpHeaders.rangeHeader: 'bytes=$partialFileLength-'},
        ),
        cancelToken: cancelToken,
        deleteOnError: true,
      );

      if (response.statusCode == HttpStatus.partialContent) {
        final ioSink = partialFile.openWrite(mode: FileMode.writeOnlyAppend);
        final tempFile = File(partialFilePath + tempExtension);
        await ioSink.addStream(tempFile.openRead());
        await tempFile.delete();
        await ioSink.close();
        await partialFile.rename(savePath);
        setStatus(task, DownloadStatus.completed);
      }
    } else {
      final response = await dio.download(
        url,
        partialFilePath,
        onReceiveProgress: createCallback(url, 0),
        cancelToken: cancelToken,
        deleteOnError: false,
      );

      if (response.statusCode == HttpStatus.ok) {
        await partialFile.rename(savePath);
        setStatus(task, DownloadStatus.completed);
      }
    }
  }

  void disposeNotifiers(DownloadTask task) {
    // task.status.dispose();
    // task.progress.dispose();
  }

  void setStatus(DownloadTask? task, DownloadStatus status) {
    if (task != null) {
      task.status.value = status;

      // tasks.add(task);
      if (status.isCompleted) {
        disposeNotifiers(task);
      }
    }
  }

  Future<DownloadTask?> addDownload(String url, String savedDir) async {
    if (url.isNotEmpty) {
      if (savedDir.isEmpty) {
        savedDir = ".";
      }

      var isDirectory = await Directory(savedDir).exists();
      var downloadFilename = isDirectory
          ? savedDir + Platform.pathSeparator + getFileNameFromUrl(url)
          : savedDir;

      return _addDownloadRequest(DownloadRequest(url, downloadFilename));
    }
  }

  Future<DownloadTask> _addDownloadRequest(
    DownloadRequest downloadRequest,
  ) async {
    if (_cache[downloadRequest.url] != null) {
      if (!_cache[downloadRequest.url]!.status.value.isCompleted &&
          _cache[downloadRequest.url]!.request == downloadRequest) {
        // Do nothing
        return _cache[downloadRequest.url]!;
      } else {
        _queue.remove(_cache[downloadRequest.url]);
      }
    }

    _queue.add(DownloadRequest(downloadRequest.url, downloadRequest.path));
    var task = DownloadTask(_queue.last);

    _cache[downloadRequest.url] = task;

    _startExecution();

    return task;
  }

  Future<void> pauseDownload(String url) async {
    if (kDebugMode) {
      print("Pause Download");
    }
    var task = getDownload(url)!;
    setStatus(task, DownloadStatus.paused);
    
    // Save multi-part progress before cancelling
    if (isMultiPartEnabled && task.request.path != null) {
      final partialFilePath = '${task.request.path}$partialExtension';
      await _multiPartDownloader?.pause(partialFilePath);
    }
    
    task.request.cancelToken.cancel();

    _queue.remove(task.request);
  }

  Future<void> cancelDownload(String url) async {
    if (kDebugMode) {
      print("Cancel Download");
    }
    var task = getDownload(url)!;
    setStatus(task, DownloadStatus.canceled);
    
    // Clean up multi-part files on cancel
    if (isMultiPartEnabled && task.request.path != null) {
      final partialFilePath = '${task.request.path}$partialExtension';
      await MultiPartDownloader.cleanup(partialFilePath);
    }
    
    _queue.remove(task.request);
    task.request.cancelToken.cancel();
  }

  Future<void> resumeDownload(String url) async {
    if (kDebugMode) {
      print("Resume Download");
    }
    var task = getDownload(url)!;
    setStatus(task, DownloadStatus.downloading);
    task.request.cancelToken = CancelToken();
    _queue.add(task.request);

    _startExecution();
  }

  Future<void> removeDownload(String url) async {
    // Clean up multi-part files on removal
    final task = getDownload(url);
    if (task != null && isMultiPartEnabled && task.request.path != null) {
      final partialFilePath = '${task.request.path}$partialExtension';
      await MultiPartDownloader.cleanup(partialFilePath);
    }
    
    cancelDownload(url);
    _cache.remove(url);
  }

  // Do not immediately call getDownload After addDownload, rather use the returned DownloadTask from addDownload
  DownloadTask? getDownload(String url) {
    return _cache[url];
  }

  Future<DownloadStatus> whenDownloadComplete(String url,
      {Duration timeout = const Duration(hours: 2)}) async {
    DownloadTask? task = getDownload(url);

    if (task != null) {
      return task.whenDownloadComplete(timeout: timeout);
    } else {
      return Future.error("Not found");
    }
  }

  List<DownloadTask> getAllDownloads() {
    return _cache.values.toList();
  }

  // Batch Download Mechanism
  Future<void> addBatchDownloads(List<String> urls, String savedDir) async {
    urls.forEach((url) {
      addDownload(url, savedDir);
    });
  }

  List<DownloadTask?> getBatchDownloads(List<String> urls) {
    return urls.map((e) => _cache[e]).toList();
  }

  Future<void> pauseBatchDownloads(List<String> urls) async {
    urls.forEach((element) {
      pauseDownload(element);
    });
  }

  Future<void> cancelBatchDownloads(List<String> urls) async {
    urls.forEach((element) {
      cancelDownload(element);
    });
  }

  Future<void> resumeBatchDownloads(List<String> urls) async {
    urls.forEach((element) {
      resumeDownload(element);
    });
  }

  ValueNotifier<double> getBatchDownloadProgress(List<String> urls) {
    ValueNotifier<double> progress = ValueNotifier(0);
    var total = urls.length;

    if (total == 0) {
      return progress;
    }

    if (total == 1) {
      return getDownload(urls.first)?.progress ?? progress;
    }

    var progressMap = Map<String, double>();

    urls.forEach((url) {
      DownloadTask? task = getDownload(url);

      if (task != null) {
        progressMap[url] = 0.0;

        if (task.status.value.isCompleted) {
          progressMap[url] = 1.0;
          progress.value = progressMap.values.sum / total;
        }

        var progressListener;
        progressListener = () {
          progressMap[url] = task.progress.value;
          progress.value = progressMap.values.sum / total;
        };

        task.progress.addListener(progressListener);

        var listener;
        listener = () {
          if (task.status.value.isCompleted) {
            progressMap[url] = 1.0;
            progress.value = progressMap.values.sum / total;
            task.status.removeListener(listener);
            task.progress.removeListener(progressListener);
          }
        };

        task.status.addListener(listener);
      } else {
        total--;
      }
    });

    return progress;
  }

  Future<List<DownloadTask?>?> whenBatchDownloadsComplete(List<String> urls,
      {Duration timeout = const Duration(hours: 2)}) async {
    var completer = Completer<List<DownloadTask?>?>();

    var completed = 0;
    var total = urls.length;

    urls.forEach((url) {
      DownloadTask? task = getDownload(url);

      if (task != null) {
        if (task.status.value.isCompleted) {
          completed++;

          if (completed == total) {
            completer.complete(getBatchDownloads(urls));
          }
        }

        var listener;
        listener = () {
          if (task.status.value.isCompleted) {
            completed++;

            if (completed == total) {
              completer.complete(getBatchDownloads(urls));
              task.status.removeListener(listener);
            }
          }
        };

        task.status.addListener(listener);
      } else {
        total--;

        if (total == 0) {
          completer.complete(null);
        }
      }
    });

    return completer.future.timeout(timeout);
  }

  void _startExecution() async {
    if (runningTasks == maxConcurrentTasks || _queue.isEmpty) {
      return;
    }

    while (_queue.isNotEmpty && runningTasks < maxConcurrentTasks) {
      runningTasks++;
      if (kDebugMode) {
        print('Concurrent workers: $runningTasks');
      }
      var currentRequest = _queue.removeFirst();

      download(
          currentRequest.url, currentRequest.path, currentRequest.cancelToken);

      await Future.delayed(Duration(milliseconds: 500), null);
    }
  }

  /// This function is used for get file name with extension from url
  String getFileNameFromUrl(String url) {
    return url.split('/').last;
  }
  
  /// Dispose resources and clean up
  void dispose() {
    _speedTrackers.clear();
    _cache.clear();
    _queue.clear();
  }
}

/// Tracks download speed over time
class _SpeedTracker {
  final List<_SpeedSample> _samples = [];
  static const int _maxSamples = 10;
  static const Duration _sampleWindow = Duration(seconds: 1);
  
  DateTime? _lastUpdateTime;
  int _lastBytes = 0;
  double _currentSpeed = 0;

  void update(int bytesReceived) {
    final now = DateTime.now();
    
    if (_lastUpdateTime == null) {
      _lastUpdateTime = now;
      _lastBytes = bytesReceived;
      return;
    }
    
    final timeDiff = now.difference(_lastUpdateTime!).inMilliseconds;
    if (timeDiff > 0) {
      final bytesDiff = bytesReceived - _lastBytes;
      final instantSpeed = (bytesDiff / timeDiff) * 1000; // bytes per second
      
      _samples.add(_SpeedSample(instantSpeed, now));
      
      // Remove old samples
      final cutoff = now.subtract(_sampleWindow);
      _samples.removeWhere((sample) => sample.timestamp.isBefore(cutoff));
      
      // Keep only recent samples
      while (_samples.length > _maxSamples) {
        _samples.removeAt(0);
      }
      
      // Calculate average speed
      if (_samples.isNotEmpty) {
        _currentSpeed = _samples.map((s) => s.speed).reduce((a, b) => a + b) / _samples.length;
      }
    }
    
    _lastUpdateTime = now;
    _lastBytes = bytesReceived;
  }
  
  double? get currentSpeed => _currentSpeed > 0 ? _currentSpeed : null;
}

class _SpeedSample {
  final double speed;
  final DateTime timestamp;
  
  _SpeedSample(this.speed, this.timestamp);
}
