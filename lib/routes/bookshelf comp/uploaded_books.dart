import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'package:ps_books/dbs/initdb.dart';
import 'package:ps_books/models/drive_book.dart';
import 'package:ps_books/state/google_auth.dart';
import 'package:googleapis/drive/v3.dart' as drive;

import 'drive_book_widget.dart';

final _db = DBProvider().db;

class DrivePage extends ConsumerWidget {
  const DrivePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the combined provider
    final driveBooksAsync = ref.watch(driveBooksProvider);

    Future<void> _uploadFiles() async {
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

        List<String> successes = [];
        List<String> failures = [];

        for (PlatformFile pf in result.files) {
          try {
            if (pf.path == null) {
              failures.add(pf.name);
              continue;
            }
            final f = File(pf.path!);
            final len = await f.length();
            final media = drive.Media(f.openRead(), len);
            final metadata = drive.File()..name = pf.name..parents = [folderId];
            final created = await driveApi.files.create(metadata, uploadMedia: media);
            successes.add(created.name ?? pf.name);
          } catch (e) {
            failures.add(pf.name);
          }
        }

        // Refresh provider and show result
        ref.refresh(driveBooksProvider);

        showDialog(
          context: context,
          builder: (ctx) {
            return AlertDialog(
              title: const Text('Upload complete'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (successes.isNotEmpty) ...[
                    const Text('Uploaded:'),
                    for (var s in successes) Text('- $s'),
                  ],
                  if (failures.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    const Text('Failed:'),
                    for (var f in failures) Text('- $f'),
                  ],
                ],
              ),
              actions: [TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('OK'))],
            );
          },
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Cloud Books")),
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
        onPressed: _uploadFiles,
        child: const Icon(Icons.upload_file),
      ),
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
