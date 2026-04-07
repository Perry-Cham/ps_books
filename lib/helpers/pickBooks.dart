import 'package:dart_pdf_reader/dart_pdf_reader.dart';
import 'package:drift/drift.dart';
import 'dart:ui';
import 'package:pdfrx/pdfrx.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'dart:io';
import 'package:ps_books/dbs/database.dart';
import 'package:ps_books/dbs/initdb.dart';
final database = DBProvider().db;

class Pick_Books {
  Future<Message> pickbooks() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        allowedExtensions: ['pdf', 'epub'],
        type: FileType.custom,
      );
      if (result == null || result.files.isEmpty) {
        return Message(message: "No files were selected", state: "Error");
      }

      List<String> paths = [];
      final directory = await getApplicationDocumentsDirectory();

      final BooksDir = Directory("${directory.path}/Books");
     
      for (PlatformFile file in result.files) {
        final sourceFile = File(file.path!);
        final fileName = path.basename(file.name);
        await BooksDir.create();
        final destinationPath = '${BooksDir.path}/$fileName';
        final destinationFile = File(destinationPath);

        await sourceFile.copy(destinationFile.path);
        paths.add(destinationPath);
        print("saved ${file.name} in $destinationPath");

        String extension = file.name.split('.').last;
        if (extension == 'pdf') {
          print("start of pdf code");
     
          await database
              .into(database.book)
              .insert(
                BookCompanion.insert(
                  name: file.name.split('.')[0],
                  path: destinationPath,
                  extension: extension,
                  page: Value(1),
                ),
              );
        } else if (extension == 'epub') {
          await database
              .into(database.book)
              .insert(
                BookCompanion.insert(
                  name: file.name.split('.')[0],
                  path: destinationPath,
                  extension: extension,
                ),
              );
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
