import 'package:dio/dio.dart';

class DownloadRequest {
  final String url;
  final String path;
  var cancelToken = CancelToken();
  var forceDownload = false;
  
  /// Number of parallel connections for this specific download request
  /// If null, uses the DownloadManager's default connections setting
  final int? connections;

  DownloadRequest(
    this.url,
    this.path, {
    this.connections,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DownloadRequest &&
          runtimeType == other.runtimeType &&
          url == other.url &&
          path == other.path;

  @override
  int get hashCode => url.hashCode ^ path.hashCode;
}
