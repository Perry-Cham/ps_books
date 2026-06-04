import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:ps_books/models/drive_book.dart';
import 'package:ps_books/state/google_auth.dart';
import 'package:ps_books/state/wishlist_download_state.dart';

class DriveBookWidget extends ConsumerWidget {
  final drive.File file;

  const DriveBookWidget({super.key, required this.file});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(driveProgressProvider, (next, prev) {
      if (next != null && next.completedMessage != "") {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.completedMessage)));
      }});
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
            onPressed: () async {
              ref.read(driveProgressProvider.notifier).startDownload(file);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Your Book is downloading")));
            },
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
  }

