import 'package:dart_pdf_engine/dart_pdf_engine_viewer.dart';
import 'package:image/image.dart';
import 'package:pdfrx/pdfrx.dart' as pdf;
import 'package:drift/drift.dart';
import 'package:epub_pro/epub_pro.dart';
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
        allowedExtensions: ['pdf', 'epub', 'pptx', 'docx'],
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
      await CoversDir.create();

      for (PlatformFile file in result.files) {
        final sourceFile = File(file.path!);
        final fileName = path.basename(file.name);
        await BooksDir.create();
        final destinationPath = '${BooksDir.path}/$fileName';
        //   final destinationFile = File(destinationPath);
        final fileBytes = await sourceFile.readAsBytes();

        await sourceFile.copy(destinationPath);
        paths.add(destinationPath);
        print("saved ${file.name} in $destinationPath");

        String extension = file.name.split('.').last;
        try {
          if (extension == 'pdf') {
            print("start of pdf code");
            await pdf.pdfrxInitialize();

            final doc = PdfDocument.fromBytes(fileBytes);
            final docForImage = await pdf.PdfDocument.openData(fileBytes);
            String bookTitle =
                doc.documentInfo.title ?? file.name.split('.')[0];
            final page = docForImage.pages[0];
            final pageImage = await page.render(
              width: (page.width * 2).toInt(),
              height: (page.height * 2).toInt(),
            );

            final img = pageImage?.createImageNF();

            final coverImage = img != null ? encodePng(img) : null;
            String path = '${CoversDir.path}/bookTitle';
            if (coverImage != null) {
              await File(path).writeAsBytes(coverImage);
            }

            if (doc.isLoaded) {
              await database
                  .into(database.books)
                  .insert(
                    BooksCompanion.insert(
                      name: doc.documentInfo.title ?? file.name.split('.')[0],
                      path: destinationPath,
                      extension: extension,
                      page: Value(1),
                      coverPath: coverImage != null ? Value(path) : Value(null),
                    ),
                  );
            }
            doc.dispose();
          } else if (extension == 'epub') {
            EpubBook? doc;
            try {
              doc = await EpubReader.readBook(fileBytes);
            } catch (e) {
              print(e);
            }
            final bookTitle = doc?.title ?? file.name.split('.')[0];
            final img = doc?.coverImage;
            final image = img != null ? encodePng(img) : null;
            final path = '${CoversDir.path}/$bookTitle';
            if (image != null) {
              await File(path).writeAsBytes(image);
            }

            await database
                .into(database.books)
                .insert(
                  BooksCompanion.insert(
                    name: bookTitle,
                    path: destinationPath,
                    extension: extension,
                    coverPath: image != null ? Value(path) : Value(null),
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
          } else {
            continue;
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
