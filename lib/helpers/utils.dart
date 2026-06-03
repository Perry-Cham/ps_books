import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import '../dbs/initdb.dart';
import 'package:flutter_charset_detector/flutter_charset_detector.dart';
import 'package:charset_converter/charset_converter.dart';

final _db = DBProvider().db;

Future<Uint8List> convertEpubToBytes({required String path}) async {
  File file = File(path);
  Uint8List epubBytes = await file.readAsBytes();
  print('done converting epub');
  return epubBytes;
}

Future<void> deleteSavedBooks({required Set<int> booksToDelete}) async {
    if (booksToDelete.isEmpty) return;

  for (final id in booksToDelete) {
    await _db.deleteSavedBook(id);
  }
}

class UniversalBookDecoder {

  /// Takes raw unmanaged bytes, detects the encoding, and decodes it safely to a Dart String
  static Future<String> decodeBytesToUtf8(Uint8List fileBytes) async {
    if (fileBytes.isEmpty) return "";

    try {
      // 1. Let Mozilla's heuristic engine auto-detect the encoding
      // This identifies Windows-1251, UTF-8 with/without BOM, Shift_JIS, etc.
      final DecodingResult detectionResult = await CharsetDetector.autoDecode(fileBytes);

      final String detectedEncodingName = detectionResult.charset.toLowerCase();
      print("🎯 Auto-detected charset: $detectedEncodingName");

      // 2. If it's already a variant of UTF-8 or standard ASCII, return it directly
      if (detectedEncodingName.contains('utf-8') || detectedEncodingName == 'ascii') {
        return detectionResult.string;
      }

      // 3. Fallback conversion for legacy charsets (like windows-1251 or windows-1252)
      // charset_converter calls native platform channels to read the byte array mapping
      String decodedString = await CharsetConverter.decode(
       detectedEncodingName,
        fileBytes,
      );

      return decodedString;
    } catch (e, h) {
      print("⚠️ Auto-detection/conversion failed: $e. Falling back to standard UTF-8 parsing with dropped errors.");
      print(h);
      // Safe fallback strategy if everything fails
      return utf8.decode(fileBytes, allowMalformed: true);
    }
  }
}

Future<void> deleteBooks(Set<int> deletedBookIds) async {
  if (deletedBookIds.isEmpty) return;

  for (final id in deletedBookIds) {
    final book = await _db.getBookById(id);
    await _db.deleteBook(id);
    if(book.coverPath != null){
    final image = File(book.coverPath!);
    await image.delete();
    }
    final bookFile = File(book.path);
    await bookFile.delete();
  }
}
