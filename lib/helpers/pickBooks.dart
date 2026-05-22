import 'package:ps_books/helpers/book_processor.dart';
import 'package:ps_books/models/book_data.dart';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'dart:io';
import 'package:ps_books/dbs/database.dart';
import 'package:ps_books/dbs/initdb.dart';

final database = DBProvider().db;
final _extensions = ['pdf', 'epub', 'fb2'];

class Pick_Books {
  Future<Message> pickbooks() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        allowedExtensions: ['pdf', 'epub', 'fb2', 'pptx', 'docx'],
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

            await database.into(database.books).insert(
                  BooksCompanion.insert(
                    name: bookData.title,
                    author: Value(bookData.author),
                    path: destinationPath,
                    extension: extension,
                    page: extension == 'pdf' ? const Value(1) : const Value.absent(),
                    coverPath: bookData.coverPath != null
                        ? Value(bookData.coverPath)
                        : const Value(null),
                  ),
                );
          } else if (extension == 'docx' || extension == 'pptx') {
            await database.into(database.books).insert(
                  BooksCompanion.insert(
                    name: file.name.split('.')[0],
                    path: destinationPath,
                    extension: extension,
                  ),
                );
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
}


//Fucntion that inserts books into database
void importBook() {}

class Search extends StatelessWidget {
  const Search({super.key, required this.title});
  final String title;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Text(title),
        TextField(
          decoration: InputDecoration(
            hintText: 'Search Books... ',
            prefixIcon: Icon(Icons.search),
            filled: true,
          ),
        ),
      ],
    );
  }
}

class Message {
  const Message({required this.message, required this.state});
  final String message;
  //This must be either success or error
  final String state;
}
