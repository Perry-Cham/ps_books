import 'package:ps_books/helpers/book_processor.dart';
import 'package:ps_books/models/book_data.dart';
import 'package:kindle_unpack/kindle_unpack.dart';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'dart:io';
import 'package:ps_books/dbs/database.dart';
import 'package:ps_books/dbs/initdb.dart';

final database = DBProvider().db;
final _extensions = ['pdf', 'epub', 'fb2', 'cbz', 'cbt', 'cbw'];

class Pick_Books {
  Future<Message> pickbooks() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        allowedExtensions: [
          'pdf',
          'epub',
          'fb2',
          'mobi',
          'pptx',
          'docx',
          'cbz',
          'cbt',
          'cbw',
        ],
        type: FileType.custom,
      );
      if (result == null || result.files.isEmpty) {
        return Message(message: "No files were selected", state: "Error");
      }

      List<String> paths = [];
      final directory = await getApplicationDocumentsDirectory();
      final supportDir = await getApplicationSupportDirectory();

      final BooksDir = Directory("${directory.path}/Books");
      final CoversDir = Directory("${supportDir.path}/Covers");
      await CoversDir.create(recursive: true);
      await BooksDir.create(recursive: true);

      for (PlatformFile file in result.files) {
        final sourceFile = File(file.path!);
        final fileName = path.basename(file.name);
        final destinationPath = '${BooksDir.path}/$fileName';
        final fileBytes = await sourceFile.readAsBytes();

        await sourceFile.copy(destinationPath);
        paths.add(destinationPath);
        print("saved ${file.name} in $destinationPath");

        String extension = file.name.split('.').last.toLowerCase();
        try {
          if (_extensions.contains(extension)) {
            final bookData = await processBook(
              fileBytes: fileBytes,
              fileName: fileName,
              extension: extension,
              coversDir: CoversDir,
            );

            await database
                .into(database.books)
                .insert(
                  BooksCompanion.insert(
                    name: bookData.title,
                    author: Value(bookData.author),
                    path: destinationPath,
                    extension: extension,
                    page: (extension == 'pdf' ||
                            extension == 'cbz' ||
                            extension == 'cbt' ||
                            extension == 'cbw')
                        ? const Value(1)
                        : const Value.absent(),
                    coverPath: bookData.coverPath != null
                        ? Value(bookData.coverPath)
                        : const Value(null),
                  ),
                );
          } else if (extension == 'docx' || extension == 'pptx') {
            await database
                .into(database.books)
                .insert(
                  BooksCompanion.insert(
                    name: file.name.split('.')[0],
                    path: destinationPath,
                    extension: extension,
                  ),
                );
          } else if (extension == 'mobi') {
            final book = KindleBook.fromBytes(fileBytes);
            final bookData = await processBook(
              fileBytes: fileBytes,
              fileName: fileName,
              extension: extension,
              coversDir: CoversDir,
            );
            final convertedEpubPath = "${BooksDir.path}/${bookData.title}.epub";
             await File(convertedEpubPath).writeAsBytes(book.toEpub());

            await database
                .into(database.books)
                .insert(
                  BooksCompanion.insert(
                    name: bookData.title,
                    author: Value(bookData.author),
                    path: convertedEpubPath,
                    extension: 'epub',
                    page: extension == 'pdf'
                        ? const Value(1)
                        : const Value.absent(),
                    coverPath: bookData.coverPath != null
                        ? Value(bookData.coverPath)
                        : const Value(null),
                  ),
                );
            final mobiFile = File(destinationPath);
            await mobiFile.delete();
          }
        } catch (e, stack) {
          print(e);
          print(stack);
        }
      }
      print(paths);
      return Message(
        message: "The operation completed successfully",
        state: "Success",
      );
    } catch (error) {
      print(error);
      return Message(message: "An Error occured", state: "Error");
    }
  }

  Future<bool> exportBooks() async {
    final docsPath = await getApplicationDocumentsDirectory();
    final docsDir = Directory("${docsPath.path}/Books");
    final books = await docsDir.list().toList();

    // 2. Launch the native "Select Directory" picker
    // This works natively on Windows, Linux, macOS, and Android
    String? selectedDirectoryUri = await FilePicker.platform.getDirectoryPath();
    if (books.isEmpty) {
      return false;
    }
    if (selectedDirectoryUri == null) {
      // User cancelled the picker dialog
      return false;
    }
    try {
      for (var book in books) {
        final bookFile = File(book.path);
        await bookFile.copy(
          "$selectedDirectoryUri/${bookFile.path.split(Platform.pathSeparator).last}",
        );
      }

      print("Book successfully exported!");
      return true;
    } catch (e) {
      print("Failed to export book: $e");
      return false;
    }
  }
}

class Message {
  const Message({required this.message, required this.state});

  final String message;

  //This must be either success or error
  final String state;
}
