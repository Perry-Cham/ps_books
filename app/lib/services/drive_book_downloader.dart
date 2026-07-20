import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:ps_books/services/auth/google/abstract.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:flutter/material.dart';
import 'package:ps_books/helpers/book_processor.dart';
import 'package:ps_books/services/dbServices/bookToDb.dart';
import 'package:path/path.dart' as p;

class DriveBookService {



  static Stream<double> downloadFile(
    AuthService service,
    drive.File file,
  ) async* {
    final authService = service;

    // 1. Prepare directory and safe file paths
    final dir = await getApplicationDocumentsDirectory();
    final booksDir = Directory('${dir.path}/Books');
    await booksDir.create(recursive: true);

    final safeName = file.name ?? 'downloaded_book';
    final savePath = '${booksDir.path}/$safeName';
    final outFile = File(savePath);
    final sink = outFile.openWrite();

    // Setup an asynchronous pipeline instead of nested callbacks
    try {
      final driveApi = await authService.getDriveApi();
      if (driveApi == null) {
        throw Exception(
          "Failed to retrieve an authorized Google Drive API instance.",
        );
      }

      final media =
          await driveApi.files.get(
                file.id!,
                downloadOptions: drive.DownloadOptions.fullMedia,
              )
              as drive.Media;

      int received = 0;
      final contentLength = file.size != null ? int.tryParse(file.size!) : null;

      // 2. FIXED: Use await for loop to listen to incoming stream chunks natively
      await for (final chunk in media.stream) {
        sink.add(chunk);

        // 3. FIXED: Increment chunk length metrics to compute authentic progress
        received += chunk.length;

        if (contentLength != null && contentLength > 0) {
          yield (received / contentLength);
        }
      }

      // Flush and close the sink before processing
      await sink.flush();
      await sink.close();

      // 5. Process the book and add to DB
      final bytes = await outFile.readAsBytes();
      final extension = p.extension(safeName).replaceAll('.', '').toLowerCase();

      final coversDir = Directory('${dir.path}/Covers');
      await coversDir.create(recursive: true);

      final bookData = await processBook(
        fileBytes: bytes,
        fileName: safeName,
        extension: extension,
        coversDir: coversDir,
      );

      await BookToDb().addBook(
        name: bookData.title,
        author: bookData.author,
        path: savePath,
        extension: extension,
        coverPath: bookData.coverPath,
        dateAdded: DateTime.now(),
      );
    } catch (e, h) {
      debugPrint("Download encountered an error: $e");
      debugPrint(h.toString());
      rethrow;
    } finally {
      // 4. Safely flush, lock, and close open I/O resources when stream finishes or fails
      try {
        await sink.flush();
      } catch (_) {}
      try {
        await sink.close();
      } catch (_) {}
    }
  }
}
