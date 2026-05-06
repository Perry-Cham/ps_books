import 'package:googleapis/drive/v3.dart' as drive;

class DriveBook{
  final String id;
  final String name;
  final String? mimeType;
  final int? size; // Size in bytes
  final DateTime? createdTime;
  final DateTime? modifiedTime;
  final String? iconLink;
  final String? webViewLink;
  final String? thumbnailLink;

  DriveBook({
    required this.id,
    required this.name,
    this.mimeType,
    this.size,
    this.createdTime,
    this.modifiedTime,
    this.iconLink,
    this.webViewLink,
    this.thumbnailLink,
  });

  /// Convert from Google Drive File object
  factory DriveBook.fromDriveFile(drive.File file) {
    return DriveBook(
      id: file.id ?? '',
      name: file.name ?? 'Unnamed',
      mimeType: file.mimeType,
      size: file.size != null ? int.tryParse(file.size!) : null,
      createdTime: file.createdTime,
      modifiedTime: file.modifiedTime,
      iconLink: file.iconLink,
      webViewLink: file.webViewLink,
      thumbnailLink: file.thumbnailLink,
    );
  }

  /// Human-readable file size
  String get formattedSize {
    if (size == null) return 'Unknown size';

    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    int unitIndex = 0;
    double fileSize = size!.toDouble();

    while (fileSize >= 1024 && unitIndex < units.length - 1) {
      fileSize /= 1024;
      unitIndex++;
    }

    return '${fileSize.toStringAsFixed(2)} ${units[unitIndex]}';
  }

  /// Human-readable modified time
  String get formattedModifiedTime {
    if (modifiedTime == null) return 'Unknown';

    final now = DateTime.now();
    final difference = now.difference(modifiedTime!);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} year(s) ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} month(s) ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day(s) ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour(s) ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute(s) ago';
    } else {
      return 'Just now';
    }
  }
}