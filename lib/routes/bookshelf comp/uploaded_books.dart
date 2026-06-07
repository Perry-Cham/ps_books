import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';

import 'package:ps_books/dbs/initdb.dart';
import 'package:ps_books/models/drive_book.dart';
import 'package:ps_books/state/google_auth.dart';
import 'package:ps_books/state/wishlist_download_state.dart';
import 'package:googleapis/drive/v3.dart' as drive;

import 'drive_book_widget.dart';

final _db = DBProvider().db;

class DrivePage extends ConsumerWidget {
  const DrivePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the combined provider
    final driveBooksAsync = ref.watch(driveBooksProvider);

    Future<void> uploadFiles() async {
      try {
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          allowMultiple: true,
          allowedExtensions: ['pdf', 'epub'],
          type: FileType.custom,
        );

        if (result == null || result.files.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No files selected')));
          return;
        }

        final authService = ref.read(authServiceProvider);
        final driveApi = await authService.getDriveApi();
        final folderId = await authService.folderId;
        if (driveApi == null || folderId == null) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Not authenticated with Google Drive')));
          return;
        }

        final files = result.files
            .where((pf) => pf.path != null)
            .map((pf) => File(pf.path!))
            .toList();

        if (files.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid files selected')));
          return;
        }

        // Show the upload modal immediately
        showDialog(
          context: context,
          builder: (context) => const UploadProgressModal(),
        );

        await ref.read(uploadProgressProvider.notifier).uploadFiles(files, driveApi, folderId);

        // Refresh provider
        ref.refresh(driveBooksProvider);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Cloud Books"),
        actions: [
          IconButton(
            icon: const Icon(Icons.downloading),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const DownloadProgressDialog(),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.upload),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const UploadProgressModal(),
              );
            },
          ),
        ],
      ),
      body: driveBooksAsync.when(
        data: (books) {
          if (books.isEmpty) {
            return const Center(child: Text("No books found in Google Drive."));
          }
          return ListView.builder(
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              return DriveBookWidget(file: book);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) {
          print(err);
          print(stack);
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Error accessing Google Drive"),
                ElevatedButton(
                  onPressed: () => ref.refresh(driveBooksProvider),
                  child: const Text("Retry"),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: uploadFiles,
        child: const Icon(Icons.upload_file),
      ),
    );
  }
}

class DownloadProgressDialog extends ConsumerWidget {
  const DownloadProgressDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloadState = ref.watch(driveProgressProvider);

    return AlertDialog(
      title: const Text('Download Progress'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            downloadState.fileName.isEmpty
                ? 'No active download'
                : 'Downloading: ${downloadState.fileName}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          LinearProgressIndicator(
            value: downloadState.isDownloading && downloadState.progress > 0
                ? downloadState.progress
                : (downloadState.isDownloading ? null : 0.0),
          ),
          const SizedBox(height: 10),
          if (downloadState.isDownloading)
            Text('${(downloadState.progress * 100).toStringAsFixed(1)}%'),
          if (downloadState.completedMessage.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              downloadState.completedMessage,
              style: const TextStyle(color: Colors.green),
            ),
          ],
        ],
      ),
      actions: [
        if (downloadState.isDownloading)
          TextButton(
            onPressed: () {
              ref.read(driveProgressProvider.notifier).cancel();
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class UploadProgressModal extends ConsumerWidget {
  const UploadProgressModal({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uploadState = ref.watch(uploadProgressProvider);
    final uploads = uploadState.total.values.toList();

    return AlertDialog(
      title: const Text('Upload Progress'),
      content: SizedBox(
        width: double.maxFinite,
        child: uploads.isEmpty
            ? const Text('No active uploads')
            : ListView.builder(
                shrinkWrap: true,
                itemCount: uploads.length,
                itemBuilder: (context, index) {
                  final upload = uploads[index];
                  final progress =
                      upload.total > 0 ? upload.received / upload.total : 0.0;
                  return ListTile(
                    title: Text(upload.fileName),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LinearProgressIndicator(
                            value: upload.isUploading
                                ? progress
                                : (upload.completedMessage == 'Done'
                                    ? 1.0
                                    : 0.0)),
                        Text(upload.isUploading
                            ? '${(progress * 100).toStringAsFixed(1)}%'
                            : upload.completedMessage),
                      ],
                    ),
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

Future<dynamic> displayFolderContents(
  drive.DriveApi driveApi,
  String folderId,
) async {
  // Use the 'q' parameter to find files whose parent is your folder
  final String query = "'$folderId' in parents and trashed = false";

  // The '$fields' parameter is critical—it tells Google exactly which metadata to send
  final fileList = await driveApi.files.list(
    q: query,
    $fields: "files(id, name, mimeType, size, modifiedTime, thumbnailLink)",
  );

  if (fileList.files != null) {
    for (var file in fileList.files!) {
      return DriveBook.fromDriveFile(file);
    }
  }
}
