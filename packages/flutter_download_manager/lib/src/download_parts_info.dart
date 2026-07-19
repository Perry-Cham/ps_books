import 'dart:convert';
import 'dart:io';

/// Represents a single part/chunk of a multi-part download
class DownloadPartInfo {
  final int partIndex;
  int startByte;
  int endByte;
  int downloadedBytes;

  DownloadPartInfo({
    required this.partIndex,
    required this.startByte,
    required this.endByte,
    this.downloadedBytes = 0,
  });

  /// Get the current byte position to resume from
  int get currentBytePosition => startByte + downloadedBytes;

  /// Get remaining bytes for this part
  int get remainingBytes => (endByte - startByte + 1) - downloadedBytes;

  /// Check if this part is complete
  bool get isComplete => downloadedBytes >= (endByte - startByte + 1);

  Map<String, dynamic> toJson() => {
        'partIndex': partIndex,
        'startByte': startByte,
        'endByte': endByte,
        'downloadedBytes': downloadedBytes,
      };

  factory DownloadPartInfo.fromJson(Map<String, dynamic> json) =>
      DownloadPartInfo(
        partIndex: json['partIndex'] as int,
        startByte: json['startByte'] as int,
        endByte: json['endByte'] as int,
        downloadedBytes: json['downloadedBytes'] as int? ?? 0,
      );

  @override
  String toString() =>
      'Part $partIndex: bytes $startByte-$endByte, downloaded: $downloadedBytes';
}

/// Manages the .download.parts file for pause/resume functionality
class DownloadPartsFile {
  static const String extension = '.download.parts';

  final String filePath;
  final String savePath;
  int totalConnections;
  int totalFileSize;
  List<DownloadPartInfo> parts;

  DownloadPartsFile({
    required this.filePath,
    required this.savePath,
    required this.totalConnections,
    required this.totalFileSize,
    List<DownloadPartInfo>? parts,
  }) : parts = parts ?? [];

  /// Get the full path to the .download.parts file
  String get partsFilePath => '$filePath$extension';

  /// Create a new parts file with calculated byte ranges
  factory DownloadPartsFile.create({
    required String filePath,
    required String savePath,
    required int totalConnections,
    required int totalFileSize,
  }) {
    final parts = <DownloadPartInfo>[];
    final chunkSize = totalFileSize ~/ totalConnections;

    for (int i = 0; i < totalConnections; i++) {
      final startByte = i * chunkSize;
      final endByte = (i == totalConnections - 1)
          ? totalFileSize - 1 // Last chunk gets remainder
          : (i + 1) * chunkSize - 1;

      parts.add(DownloadPartInfo(
        partIndex: i,
        startByte: startByte,
        endByte: endByte,
      ));
    }

    return DownloadPartsFile(
      filePath: filePath,
      savePath: savePath,
      totalConnections: totalConnections,
      totalFileSize: totalFileSize,
      parts: parts,
    );
  }

  /// Save parts info to file
  Future<void> save() async {
    final file = File(partsFilePath);
    final data = {
      'totalConnections': totalConnections,
      'totalFileSize': totalFileSize,
      'savePath': savePath,
      'parts': parts.map((p) => p.toJson()).toList(),
      'lastUpdated': DateTime.now().toIso8601String(),
    };

    await file.writeAsString(jsonEncode(data));
  }

  /// Load parts info from file, returns null if file doesn't exist
  static Future<DownloadPartsFile?> load(String filePath) async {
    final partsFile = File('$filePath$extension');

    if (!await partsFile.exists()) {
      return null;
    }

    try {
      final content = await partsFile.readAsString();
      final data = jsonDecode(content) as Map<String, dynamic>;

      final partsList = (data['parts'] as List)
          .map((p) => DownloadPartInfo.fromJson(p as Map<String, dynamic>))
          .toList();

      return DownloadPartsFile(
        filePath: filePath,
        savePath: data['savePath'] as String,
        totalConnections: data['totalConnections'] as int,
        totalFileSize: data['totalFileSize'] as int,
        parts: partsList,
      );
    } catch (e) {
      // If file is corrupted, return null to start fresh
      return null;
    }
  }

  /// Update progress for a specific part
  Future<void> updatePartProgress(int partIndex, int bytesDownloaded) async {
    if (partIndex < parts.length) {
      parts[partIndex].downloadedBytes = bytesDownloaded;
      await save();
    }
  }

  /// Update all parts at once (more efficient)
  Future<void> updateAllParts(List<int> downloadedBytesPerPart) async {
    for (int i = 0; i < parts.length && i < downloadedBytesPerPart.length; i++) {
      parts[i].downloadedBytes = downloadedBytesPerPart[i];
    }
    await save();
  }

  /// Calculate overall download progress (0.0 to 1.0)
  double get progress {
    if (totalFileSize == 0) return 0.0;
    final totalDownloaded =
        parts.fold<int>(0, (sum, part) => sum + part.downloadedBytes);
    return totalDownloaded / totalFileSize;
  }

  /// Check if all parts are complete
  bool get allComplete => parts.every((part) => part.isComplete);

  /// Delete the parts file
  Future<void> delete() async {
    final file = File(partsFilePath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  /// Check if parts file exists
  static Future<bool> exists(String filePath) async {
    return await File('$filePath$extension').exists();
  }

  @override
  String toString() =>
      'DownloadPartsFile: $totalConnections connections, $totalFileSize bytes, '
      '${parts.length} parts, progress: ${(progress * 100).toStringAsFixed(1)}%';
}
