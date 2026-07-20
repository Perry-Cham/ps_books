# Flutter Download Manager - Multi-Connection Extension

## Overview

This extension adds **multi-connection (multi-threaded) downloading** support to the Flutter Download Manager library. This feature can significantly improve download speeds by splitting files into multiple chunks and downloading them in parallel.

## New Features

### 1. Multi-Connection Downloads

Download files using multiple simultaneous connections to maximize bandwidth usage:

```dart
final downloadManager = DownloadManager(
  maxConcurrentTasks: 2,
  connections: 4, // Download using 4 parallel connections
);

final task = await downloadManager.addDownload(
  'https://example.com/large-file.zip',
  '/path/to/save/file.zip',
);
```

### 2. Download Speed Tracking

Monitor download speeds in real-time:

```dart
// Get current speed in bytes per second
double? speed = downloadManager.getDownloadSpeed(url);

// Get formatted speed string (e.g., "1.5 MB/s")
String? formattedSpeed = downloadManager.getFormattedDownloadSpeed(url);
```

### 3. Pause/Resume with Progress Saving

Downloads can be paused and resumed with full progress tracking:

```dart
// Pause download - saves progress to .download.parts file
await downloadManager.pauseDownload(url);

// Resume download - reads progress from .download.parts file
await downloadManager.resumeDownload(url);
```

### 4. `.download.parts` File Format

When multi-connection downloads are paused, a `.download.parts` file is created/updated containing:

- **Total connections**: Number of parallel connections used
- **Total file size**: Expected file size in bytes
- **Part information**: For each part:
  - Part index
  - Start byte offset
  - End byte offset  
  - Bytes downloaded so far
  - Current byte position (for resume)

This allows downloads to resume exactly where they left off.

## How It Works

1. **File Size Detection**: Sends a HEAD request to get the file size from the server
2. **Range Request Support**: Verifies the server supports HTTP range requests
3. **Byte Range Calculation**: Divides the file into N equal chunks based on connection count
4. **Parallel Download**: Launches N simultaneous requests with `Range: bytes=X-Y` headers
5. **Progress Tracking**: Updates the `.download.parts` file periodically with download progress
6. **File Assembly**: Writes each chunk to the correct position in the output file
7. **Completion**: Renames partial file to final destination when all chunks complete

## API Reference

### DownloadManager Constructor

```dart
DownloadManager({
  int? maxConcurrentTasks, // Max concurrent downloads (default: 2)
  Dio? dio,               // Custom Dio instance
  int? connections,       // Number of connections PER download (new!)
})
```

### New Properties

- `connections` - Get configured number of connections
- `isMultiPartEnabled` - Check if multi-part downloading is enabled
- `getDownloadSpeed(url)` - Get current download speed in bytes/sec
- `getFormattedDownloadSpeed(url)` - Get human-readable speed string

### New Classes

#### `DownloadPartsFile`
Manages the `.download.parts` file for pause/resume functionality:

```dart
// Create parts file for new download
final parts = DownloadPartsFile.create(
  filePath: '/path/to/file.partial',
  savePath: '/path/to/file',
  totalConnections: 4,
  totalFileSize: 1024000,
);

// Save/load progress
await parts.save();
final loaded = await DownloadPartsFile.load('/path/to/file.partial');

// Track progress
double progress = parts.progress; // 0.0 to 1.0
bool complete = parts.allComplete;
```

#### `DownloadPartInfo`
Represents a single download chunk:

```dart
class DownloadPartInfo {
  final int partIndex;
  int startByte;
  int endByte;
  int downloadedBytes;
  
  bool get isComplete;      // Is this part fully downloaded?
  int get remainingBytes;   // How many bytes left?
  int get currentBytePosition; // Resume from this position
}
```

#### `MultiPartDownloader`
Low-level multi-part download handler:

```dart
final downloader = MultiPartDownloader(
  dio: dio,
  connections: 4,
);

// Check server support
bool supportsRanges = await downloader.supportsRangeRequests(url);
int? fileSize = await downloader.getFileSize(url);

// Download with progress callback
await downloader.download(
  url,
  savePath,
  cancelToken,
  onProgress: (progress) {
    print('${(progress * 100).toStringAsFixed(1)}%');
  },
);
```

## Requirements

- Dart SDK: >=2.17.0 <4.0.0
- Flutter: >=2.0.0
- Server must support HTTP Range Requests (most modern servers do)

## Fallback Behavior

If the server doesn't support range requests or multi-part download fails:
- Automatically falls back to single-connection download
- Preserves all existing pause/resume functionality
- No data loss or corruption

## Testing

Run the test suite to verify functionality:

```bash
cd test_download_manager
dart test test/multi_part_download_test.dart
```

Test coverage includes:
- Byte range calculation and distribution
- Parts file creation, saving, and loading
- Progress tracking accuracy
- Actual multi-connection downloads
- Pause/resume mechanism
- Cleanup of temporary files
- Edge cases (single connection, many connections, etc.)

## Performance Tips

1. **Optimal Connection Count**: 4-8 connections typically provide best results
   - Too few: Underutilizes bandwidth
   - Too many: Server throttling, overhead

2. **Large Files Benefit Most**: Files >1MB see significant improvement
   - Small files may not benefit due to connection overhead

3. **Server Considerations**: 
   - CDN servers handle range requests well
   - Some servers may limit connections per IP
   - Rate limiting can reduce effectiveness

## Example Usage

### Basic Multi-Connection Download

```dart
void downloadLargeFile() async {
  final manager = DownloadManager(connections: 8);
  
  final task = await manager.addDownload(
    'https://example.com/large-file.zip',
    '/downloads/large-file.zip',
  );
  
  // Listen to progress
  task.progress.addListener(() {
    print('Progress: ${(task.progress.value * 100).toStringAsFixed(1)}%');
    print('Speed: ${manager.getFormattedDownloadSpeed(task.request.url)}');
  });
  
  // Wait for completion
  final status = await manager.whenDownloadComplete(task.request.url);
  print('Download $status');
}
```

### Pause and Resume

```dart
async void pauseableDownload() async {
  final manager = DownloadManager(connections: 4);
  final url = 'https://example.com/big-file.iso';
  
  await manager.addDownload(url, '/downloads/big-file.iso');
  
  // User pauses after 30 seconds
  await Future.delayed(Duration(seconds: 30));
  await manager.pauseDownload(url);
  print('Download paused - progress saved');
  
  // Later, user resumes
  await manager.resumeDownload(url);
  print('Download resumed from where it left off');
}
```

### Batch Downloads with Speed Monitoring

```dart
async void batchWithMonitoring() async {
  final manager = DownloadManager(
    maxConcurrentTasks: 3,
    connections: 4,
  );
  
  final urls = [
    'https://example.com/file1.zip',
    'https://example.com/file2.zip',
    'https://example.com/file3.zip',
  ];
  
  await manager.addBatchDownloads(urls, '/downloads/');
  
  // Monitor overall batch progress
  final progress = manager.getBatchDownloadProgress(urls);
  progress.addListener(() {
    print('Batch progress: ${(progress.value * 100).toStringAsFixed(1)}%');
    
    // Show individual speeds
    for (final url in urls) {
      final speed = manager.getFormattedDownloadSpeed(url);
      if (speed != null) print('  $url: $speed');
    }
  });
}
```

## Changelog

### Version 0.6.0
- ✨ Added multi-connection downloading support
- ✨ Added download speed tracking
- ✨ Added `.download.parts` file for pause/resume
- ✨ Added `connections` parameter to constructor
- 🔧 Improved error handling and fallback behavior
- 📝 Updated SDK constraints for Dart 3.x compatibility
- 🐛 Fixed cleanup of temporary files

## License

See original LICENSE file for license information.
