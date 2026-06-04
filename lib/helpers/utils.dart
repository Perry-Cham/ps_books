import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import '../dbs/initdb.dart';
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


//For decoding FB2 XML in particular and xml in general
class UniversalBookDecoder {
  /// Takes raw unmanaged bytes, detects the encoding via pure Dart heuristics,
  /// and decodes it using CharsetConverter.
  static Future<String> decodeBytesToUtf8(Uint8List fileBytes) async {
    if (fileBytes.isEmpty) return "";

    String detectedEncoding = 'windows-1251'; // Default fallback legacy charset

    try {
      // 1. Check for standard Byte Order Marks (BOM)
      if (fileBytes.length >= 3 && fileBytes[0] == 0xEF && fileBytes[1] == 0xBB && fileBytes[2] == 0xBF) {
        print("🎯 Detected via BOM: UTF-8");
        // Strip BOM bytes and decode immediately using core Dart
        return utf8.decode(fileBytes.sublist(3), allowMalformed: true);
      }

      if (fileBytes.length >= 2 && fileBytes[0] == 0xFF && fileBytes[1] == 0xFE) {
        print("🎯 Detected via BOM: UTF-16 Little Endian");
        detectedEncoding = 'utf-16le';
      } else if (fileBytes.length >= 2 && fileBytes[0] == 0xFE && fileBytes[1] == 0xFF) {
        print("🎯 Detected via BOM: UTF-16 Big Endian");
        detectedEncoding = 'utf-16be';
      }
      // 2. No BOM found. Fall back to structural byte pattern validation
      else if (_isLikelyUtf8(fileBytes)) {
        print("🎯 No BOM found, but byte structures match valid UTF-8");
        return utf8.decode(fileBytes, allowMalformed: true);
      } else {
        print("🎯 Byte structures do not match UTF-8. Falling back to legacy: $detectedEncoding");
      }

      // 3. Hand off the detected encoding label to the platform-channel decoder
      return await CharsetConverter.decode(
        detectedEncoding,
        fileBytes,
      );
    } catch (e, h) {
      print("⚠️ Platform-agnostic conversion failed: $e. Falling back to safe standard UTF-8.");
      print(h);
      return utf8.decode(fileBytes, allowMalformed: true);
    }
  }

  /// Pure Dart structural heuristic to verify if a byte stream is legal UTF-8.
  /// Inspects a max sample of 4096 bytes for lightning fast file analysis.
  static bool _isLikelyUtf8(Uint8List bytes) {
    int i = 0;
    final int maxInspectLength = bytes.length > 4096 ? 4096 : bytes.length;

    while (i < maxInspectLength) {
      int byte = bytes[i];

      // Standard ASCII Range (0xxxxxxx) -> Valid UTF-8 structure
      if ((byte & 0x80) == 0) {
        i++;
        continue;
      }

      // Multi-byte sequence structures checks
      int expectedContinuationBytes = 0;
      if ((byte & 0xE0) == 0xC0) {
        expectedContinuationBytes = 1; // 110xxxxx
      } else if ((byte & 0xF0) == 0xE0) {
        expectedContinuationBytes = 2; // 1110xxxx
      } else if ((byte & 0xF8) == 0xF0) {
        expectedContinuationBytes = 3; // 11110xxx
      } else {
        return false; // Found an illegal lead byte variant
      }

      i++;
      // Ensure all trailing bytes match the mandatory 10xxxxxx sequence marker
      for (int j = 0; j < expectedContinuationBytes; j++) {
        if (i >= maxInspectLength) return true; // File cut off, but valid up to this point
        if ((bytes[i] & 0xC0) != 0x80) {
          return false; // Malformed sequence byte detected
        }
        i++;
      }
    }
    return true;
  }
}

Future<void> deleteBooks(Set<int> deletedBookIds) async {
  if (deletedBookIds.isEmpty) return;

  for (final id in deletedBookIds) {
    final book = await _db.getBookById(id);
    await _db.deleteBook(id);
    if (book.coverPath != null) {
      final image = File(book.coverPath!);
      if (await image.exists()) {
        await image.delete();
      }
    }
    final bookFile = File(book.path);
    if (await bookFile.exists()) {
      await bookFile.delete();
    }
  }
}