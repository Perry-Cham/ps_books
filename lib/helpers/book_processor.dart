import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:dart_pdf_engine/dart_pdf_engine_viewer.dart';
import 'package:image/image.dart';
import 'package:path/path.dart';
import 'package:pdfrx/pdfrx.dart' as pdf;
import 'package:epub_pro/epub_pro.dart';
import 'package:xml/xml.dart';
import 'package:ps_books/models/book_data.dart';
import 'package:kindle_unpack/kindle_unpack.dart';
import 'package:archive/archive.dart';
import './utils.dart';

Future<BookData> processBook({
  required Uint8List fileBytes,
  required String fileName,
  required String extension,
  required Directory coversDir,
}) async {
  String bookTitle = fileName.split('.')[0];
  String? author;
  String? coverPath;
  Map<String, dynamic> properties = {};

  try {
    if (extension == 'pdf') {
      try {
        final doc = PdfDocument.fromBytes(fileBytes);
        final docForImage = await pdf.PdfDocument.openData(fileBytes);
        if (doc.documentInfo.title != null) {
          bookTitle = doc.documentInfo.title!;
        }
        author =
            doc.documentInfo.author ?? doc.documentInfo.creator ?? "Unknown";

        final page = docForImage.pages[0];
        final pageImage = await page.render();

        final img = pageImage?.createImageNF();
        final coverImage = img != null ? encodePng(img) : null;
        if (coverImage != null) {
          // Sanitize title for filename
          String sanitizedTitle = bookTitle.replaceAll(
            RegExp(r'[<>:"/\\|?*]'),
            '_',
          );
          coverPath = "${coversDir.path}/$sanitizedTitle.png";
          await File(coverPath).writeAsBytes(coverImage);
        }
        doc.dispose();
      } catch (e) {
        print("Error processing PDF: $e");
      }
    } else if (extension == 'epub') {
      EpubBook? doc;
      try {
        doc = await EpubReader.readBook(fileBytes);
      } catch (e) {
        print("Error reading EPUB: $e");
      }
      if (doc != null) {
        bookTitle = doc.title ?? bookTitle;
        author = doc.author;
        final img = doc.coverImage;
        final image = img != null ? encodePng(img) : null;
        if (image != null) {
          String sanitizedTitle = bookTitle.replaceAll(
            RegExp(r'[<>:"/\\|?*]'),
            '_',
          );
          coverPath = '${coversDir.path}/$sanitizedTitle.png';
          await File(coverPath).writeAsBytes(image);
        }
      }
    } else if (extension == 'fb2') {
      try {
        final xmlString = await UniversalBookDecoder.decodeBytesToUtf8(fileBytes);
        final document = XmlDocument.parse(xmlString);

        final titleInfo = document.findAllElements('title-info').firstOrNull;
        if (titleInfo != null) {
          bookTitle =
              titleInfo.findElements('book-title').firstOrNull?.innerText ??
              bookTitle;
          final authorElement = titleInfo.findElements('author').firstOrNull;
          if (authorElement != null) {
            final firstName =
                authorElement
                    .findElements('first-name')
                    .firstOrNull
                    ?.innerText ??
                '';
            final lastName =
                authorElement
                    .findElements('last-name')
                    .firstOrNull
                    ?.innerText ??
                '';
            author = '$firstName $lastName'.trim();
          }

          final coverpage = titleInfo.findElements('coverpage').firstOrNull;
          final imageElement = coverpage?.findElements('image').firstOrNull;
          final coverId = imageElement
              ?.getAttribute('l:href')
              ?.replaceAll('#', '');

          if (coverId != null) {
            final binaries = document.findAllElements('binary');
            final binary = binaries
                .where((el) => el.getAttribute('id') == coverId)
                .firstOrNull;
            String extension;
            if (binary != null) {
              extension = binary.getAttribute('content-type') == 'image/jpg'
                  ? 'jpg'
                  : 'png';
              final base64Image = binary.innerText.trim();
              final bytes = base64Decode(base64Image);
              String sanitizedTitle = bookTitle.replaceAll(
                RegExp(r'[<>:"/\\|?*]'),
                '_',
              );
              coverPath = '${coversDir.path}/$sanitizedTitle.$extension';
              await File(coverPath).writeAsBytes(bytes);
            }
          }
        }
      } catch (e) {
        print("Error processing FB2: $e");
      }
    } else if (extension == 'mobi') {
      final book = KindleBook.fromBytes(fileBytes);
      bookTitle = book.title;
      author = book.exth?.authors.first;
      final img = book.images.cover?.data;
      if (img != null) {
        String sanitizedTitle = bookTitle.replaceAll(
          RegExp(r'[<>:"/\\|?*]'),
          '_',
        );
        coverPath = '${coversDir.path}/$sanitizedTitle.png';
        await File(coverPath).writeAsBytes(img);
      }
    } else if (extension == 'cbz' || extension == 'cbt') {
      try {
        Archive? archive;
        if (extension == 'cbz') {
          archive = ZipDecoder().decodeBytes(fileBytes);
        } else if (extension == 'cbt') {
          archive = TarDecoder().decodeBytes(fileBytes);
        }

        if (archive != null) {
          final imageFile = archive.files.firstWhere(
            (file) =>
                file.isFile &&
                (file.name.toLowerCase().endsWith('.jpg') ||
                    file.name.toLowerCase().endsWith('.png') ||
                    file.name.toLowerCase().endsWith('.jpeg')),
          );

          final imageContent = imageFile.content as Uint8List;
          String sanitizedTitle = bookTitle.replaceAll(
            RegExp(r'[<>:"/\\|?*]'),
            '_',
          );
          coverPath = '${coversDir.path}/$sanitizedTitle.png';
          await File(coverPath).writeAsBytes(imageContent);
        }
      } catch (e) {
        print("Error processing comic book cover: $e");
      }
    }
  } catch (e, stack) {
    print("General error processing book: $e");
    print(stack);
  }

  return BookData(
    title: bookTitle,
    author: author,
    coverPath: coverPath,
    properties: properties,
  );
}
