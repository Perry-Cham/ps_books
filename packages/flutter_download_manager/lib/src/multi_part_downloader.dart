import 'dart:io';
import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;

import 'download_parts_info.dart';
import 'download_status.dart';

/// Handles multi-connection (multi-threaded) downloads with pause/resume support
class MultiPartDownloader {
  final Dio dio;
  final int connections;
  static const String partialExtension = ".partial";
  static const String tempExtension = ".temp";

  MultiPartDownloader({
    required this.dio,
    required this.connections,
  });

  /// Send a HEAD request to get the file size from the server
  Future<int?> getFileSize(String url) async {
    try {
      final response = await dio.head(
        url,
        options: Options(
          followRedirects: true,
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      // Try Content-Length header first
      final contentLength = response.headers.value('content-length');
      if (contentLength != null) {
        return int.tryParse(contentLength);
      }

      // Some servers return Accept-Ranges but not Content-Length on HEAD
      // We'll need to handle this case in the download method
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting file size: $e');
      }
      return null;
    }
  }

  /// Check if server supports range requests
  Future<bool> supportsRangeRequests(String url) async {
    try {
      final response = await dio.head(
        url,
        options: Options(
          followRedirects: true,
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      final acceptRanges = response.headers.value('accept-ranges');
      return acceptRanges?.toLowerCase() == 'bytes';
    } catch (e) {
      if (kDebugMode) {
        print('Error checking range support: $e');
      }
      return false;
    }
  }

  /// Download a file using multiple connections
  ///
  /// [url] - The URL to download from
  /// [savePath] - Where to save the file
  /// [cancelToken] - For canceling the download
  /// [onProgress] - Progress callback (0.0 to 1.0)
  /// Returns true if download completed successfully
  Future<bool> download(
    String url,
    String savePath,
    CancelToken cancelToken, {
    void Function(double progress)? onProgress,
  }) async {
    final partialFilePath = '$savePath$partialExtension';

    // Check for existing parts file (resumable download)
    var partsFile = await DownloadPartsFile.load(partialFilePath);

    if (partsFile == null) {
      // New download - get file size and create parts
      final fileSize = await getFileSize(url);
      
      if (fileSize == null || fileSize <= 0) {
        if (kDebugMode) {
          print('Could not determine file size, falling back to single connection');
        }
        return false; // Signal to use single-connection download
      }

      // Check if server supports range requests
      final supportsRanges = await supportsRangeRequests(url);
      if (!supportsRanges && connections > 1) {
        if (kDebugMode) {
          print('Server does not support range requests, using single connection');
        }
        return false;
      }

      partsFile = DownloadPartsFile.create(
        filePath: partialFilePath,
        savePath: savePath,
        totalConnections: connections,
        totalFileSize: fileSize,
      );

      // Save initial state
      await partsFile!.save();
    }

    // Note: We don't pre-allocate the file because Content-Length may differ from 
    // actual size when compression is involved. File will be created/expanded as parts are downloaded.
    final partialFile = File(partialFilePath);

    try {
      // Start parallel downloads for each part
      final completer = Completer<bool>();
      final progressStreamController = StreamController<double>.broadcast();
      var completedParts = 0;
      var failedParts = 0;
      final totalParts = partsFile.parts.length;

      // Listen to overall progress
      progressStreamController.stream.listen((progress) {
        onProgress?.call(progress);
      });

      // Launch download for each part
      final futures = <Future>[];

      for (final part in partsFile.parts) {
        if (part.isComplete) {
          completedParts++;
          continue;
        }

        futures.add(_downloadPart(
          url: url,
          partialFilePath: partialFilePath,
          part: part,
          cancelToken: cancelToken,
          partsFile: partsFile!,
          onPartProgress: (partIndex, bytesDownloaded) {
            // Update parts file periodically
            _updateProgressThrottled(partsFile!, partIndex, bytesDownloaded);
            
            // Calculate and broadcast overall progress
            final overallProgress = partsFile!.progress;
            progressStreamController.add(overallProgress);
          },
        ).then((success) {
          if (success) {
            completedParts++;
          } else {
            failedParts++;
          }
        }));
      }

      // Wait for all parts to complete
      await Future.wait(futures);

      // Final update to parts file
      await partsFile.save();

      await progressStreamController.close();

      if (failedParts > 0 && !cancelToken.isCancelled) {
        if (kDebugMode) {
          print('$failedParts parts failed to download');
        }
        return false;
      }

      // Verify all data is written and rename file
      if (partsFile.allComplete || failedParts == 0) {
        final actualSize = await partialFile.length();
        
        // Accept download if:
        // 1. All parts completed successfully, OR
        // 2. File has content (actual size is reasonable)
        if (actualSize > 0) { 
          // Rename to final path
          final finalFile = File(savePath);
          if (await finalFile.exists()) {
            await finalFile.delete();
          }
          await partialFile.rename(savePath);
          
          // Clean up parts file
          await partsFile.delete();
          
          return true;
        }
      }

      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Multi-part download error: $e');
      }
      
      // Save current progress before throwing
      await partsFile?.save();
      rethrow;
    }
  }

  // Throttle progress updates to avoid excessive file I/O
  DateTime _lastProgressUpdate = DateTime.now();
  final Map<int, int> _pendingProgressUpdates = {};

  Future<void> _updateProgressThrottled(
    DownloadPartsFile partsFile,
    int partIndex,
    int bytesDownloaded,
  ) async {
    _pendingProgressUpdates[partIndex] = bytesDownloaded;

    final now = DateTime.now();
    if (now.difference(_lastProgressUpdate).inMilliseconds > 500) {
      _lastProgressUpdate = now;
      
      if (_pendingProgressUpdates.isNotEmpty) {
        final updates = List<int>.filled(partsFile.parts.length, 0);
        _pendingProgressUpdates.forEach((key, value) {
          if (key < updates.length) {
            updates[key] = value;
          }
        });
        
        await partsFile.updateAllParts(updates);
        _pendingProgressUpdates.clear();
      }
    }
  }

  /// Download a specific part/chunk of the file
  Future<bool> _downloadPart({
    required String url,
    required String partialFilePath,
    required DownloadPartInfo part,
    required CancelToken cancelToken,
    required DownloadPartsFile partsFile,
    required void Function(int partIndex, int bytesDownloaded) onPartProgress,
  }) async {
    final startByte = part.currentBytePosition;
    final endByte = part.endByte;

    if (startByte > endByte) {
      return true; // Already complete
    }

    try {
      final tempPartPath = '$partialFilePath.part${part.partIndex}$tempExtension';
      
      // Use dio.download with proper options for range requests
      // Disable automatic decompression to avoid issues with partial content
      final response = await dio.download(
        url,
        tempPartPath,
        cancelToken: cancelToken,
        deleteOnError: false,
        options: Options(
          headers: {
            HttpHeaders.rangeHeader: 'bytes=$startByte-$endByte',
            HttpHeaders.acceptEncodingHeader: 'identity', // Disable compression
          },
          responseType: ResponseType.bytes,
          receiveDataWhenStatusError: false,
        ),
        onReceiveProgress: (received, total) {
          // Calculate actual downloaded bytes for this part
          final downloadedForThisSession = received;
          onPartProgress(part.partIndex, part.downloadedBytes + downloadedForThisSession);
        },
      );

      // Verify we got partial content or ok status
      if (response.statusCode == HttpStatus.partialContent ||
          response.statusCode == HttpStatus.ok) {
        // Write the part data to the correct position in the main file
        final tempFile = File(tempPartPath);
        if (await tempFile.exists()) {
          final partData = await tempFile.readAsBytes();
          
          if (partData.isNotEmpty) {
            final raf = await File(partialFilePath).open(mode: FileMode.write);
            await raf.setPosition(startByte);
            await raf.writeFrom(partData);
            await raf.close();
            
            // Update part info
            part.downloadedBytes += partData.length;
            
            // Clean up temp file
            await tempFile.delete();
            
            return true;
          } else {
            // Empty file - might be an issue with the download
            await tempFile.delete();
            return false;
          }
        }
      }

      return false;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        if (kDebugMode) {
          print('Part ${part.partIndex} download canceled');
        }
        rethrow;
      }
      
      if (kDebugMode) {
        print('Error downloading part ${part.partIndex}: $e');
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Unexpected error downloading part ${part.partIndex}: $e');
      }
      return false;
    }
  }

  /// Pause the download by saving current state
  Future<void> pause(String partialFilePath) async {
    final partsFile = await DownloadPartsFile.load(partialFilePath);
    if (partsFile != null) {
      await partsFile.save();
      if (kDebugMode) {
        print('Download paused. Progress saved: ${partsFile}');
      }
    }
  }

  /// Get current progress from parts file
  Future<double?> getProgress(String partialFilePath) async {
    final partsFile = await DownloadPartsFile.load(partialFilePath);
    return partsFile?.progress;
  }

  /// Get download speed estimate based on progress over time
  /// Returns bytes per second, or null if cannot calculate
  Future<double?> getDownloadSpeed(String partialFilePath) async {
    final partsFile = await DownloadPartsFile.load(partialFilePath);
    if (partsFile == null) return null;

    // This is a simplified speed calculation
    // A real implementation would track time deltas
    // For now, return null to indicate speed tracking should be done elsewhere
    return null;
  }

  /// Clean up all temporary files associated with a download
  /// [filePath] should be the partial file path (including .partial extension)
  static Future<void> cleanup(String filePath) async {
    // Delete the partial file itself
    final partialFile = File(filePath);
    if (await partialFile.exists()) {
      await partialFile.delete();
    }
    
    // Delete the parts info file
    final partsFile = File('$filePath${DownloadPartsFile.extension}');
    if (await partsFile.exists()) {
      await partsFile.delete();
    }

    // Also clean up any .partN.temp files
    final dir = path.dirname(filePath);
    final fileName = path.basename(filePath);
    
    if (await Directory(dir).exists()) {
      final dirEntity = Directory(dir);
      await for (final entity in dirEntity.list()) {
        if (entity is File && entity.path.contains(fileName) && 
            entity.path.contains('.part') && entity.path.contains(tempExtension)) {
          await entity.delete();
        }
      }
    }
  }
}
