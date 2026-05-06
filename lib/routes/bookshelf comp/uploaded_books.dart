import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ps_books/dbs/initdb.dart';
import 'package:ps_books/models/drive_book.dart';
import 'package:ps_books/services/auth/google/abstract.dart';
import 'package:ps_books/state/google_auth.dart';
import 'package:googleapis/drive/v3.dart' as drive;

final _db = DBProvider().db;

class DrivePage extends ConsumerWidget {
  const DrivePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the combined provider
    final driveBooksAsync = ref.watch(driveBooksProvider);

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
              return ListTile(
                leading: const Icon(Icons.book),
                title: Text(book.name ?? "Unknown Title"),
                subtitle: Text("${(int.parse(book.size ?? '0') / 1024).toStringAsFixed(2)} KB"),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
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
        ),
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
