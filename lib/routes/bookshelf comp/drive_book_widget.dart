import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:ps_books/models/drive_book.dart';
import 'package:ps_books/state/google_auth.dart';

class DriveBookWidget extends ConsumerWidget {
  final drive.File file;

  const DriveBookWidget({Key? key, required this.file}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final model = DriveBook.fromDriveFile(file);

    return ListTile(
      leading: const Icon(Icons.book),
      title: Text(model.name),
      subtitle: Text(model.formattedSize),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _downloadFile(context, ref),
            tooltip: 'Download',
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _deleteFile(context, ref),
            tooltip: 'Delete from Drive',
          ),
        ],
      ),
    );
  }

  Future<void> _deleteFile(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete file'),
        content: Text('Delete "${file.name}" from Drive?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Delete')),
        ],
      ),
    );

    if (confirm != true) return;

    final authService = ref.read(authServiceProvider);
    final driveApi = await authService.getDriveApi();
    if (driveApi == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Not authenticated with Google Drive')));
      return;
    }

    try {
      await driveApi.files.delete(file.id!);
      ref.refresh(driveBooksProvider);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('File deleted')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete: $e')));
    }
  }

  Future<void> _downloadFile(BuildContext context, WidgetRef ref) async {
    final authService = ref.read(authServiceProvider);
    final driveApi = await authService.getDriveApi();
    if (driveApi == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Not authenticated with Google Drive')));
      return;
    }

    final snack = ScaffoldMessenger.of(context);
    final progressController = ValueNotifier<double?>(null);

    // Show simple progress dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Downloading...'),
            const SizedBox(height: 16),
            ValueListenableBuilder<double?>(
              valueListenable: progressController,
              builder: (_, value, __) {
                if (value == null) return const LinearProgressIndicator();
                return LinearProgressIndicator(value: value);
              },
            ),
          ],
        ),
      ),
    );

    try {
      final media = await driveApi.files.get(
        file.id!,
        downloadOptions: drive.DownloadOptions.fullMedia,
      ) as drive.Media;

      final dir = await getApplicationDocumentsDirectory();
      final booksDir = Directory('${dir.path}/Books');
      await booksDir.create(recursive: true);
      final safeName = file.name ?? 'downloaded_book';
      final savePath = p.join(booksDir.path, safeName);

      final outFile = File(savePath);
      final sink = outFile.openWrite();

      int received = 0;
      final contentLength = file.size != null ? int.tryParse(file.size!) : null;

      await for (var chunk in media.stream) {
        sink.add(chunk);
        received += chunk.length;
        if (contentLength != null) {
          progressController.value = received / contentLength;
        }
      }

      await sink.flush();
      await sink.close();

      

      Navigator.of(context).pop(); // close progress dialog
    
    } catch (e) {
      Navigator.of(context).pop();
      snack.showSnackBar(SnackBar(content: Text('Download failed: $e')));
    } finally {
      progressController.dispose();
    }
  }
}
