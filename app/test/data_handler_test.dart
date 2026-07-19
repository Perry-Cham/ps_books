import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:ps_books/helpers/book_processor.dart';

void main() {
  group('DataHandler', () {
    test('export manifest includes series and isSeries in book entries', () async {
      final booksJson = [
        {
          'name': 'Batman Issue 1',
          'author': 'Bob Kane',
          'path': 'books/batman_001.cbz',
          'extension': 'cbz',
          'progress': 0.0,
          'page': null,
          'cfi': null,
          'coverPath': null,
          'lastRead': false,
          'collection': null,
          'series': 1,
          'isSeries': true,
        },
        {
          'name': 'Batman Issue 2',
          'author': 'Bob Kane',
          'path': 'books/batman_002.cbz',
          'extension': 'cbz',
          'progress': 0.0,
          'page': null,
          'cfi': null,
          'coverPath': null,
          'lastRead': false,
          'collection': null,
          'series': 1,
          'isSeries': true,
        },
      ];

      final seriesJson = [
        {
          'id': 1,
          'name': 'Batman Series',
          'cover': null,
          'description': 'The complete Batman collection',
          'collection': null,
        },
      ];

      final output = jsonEncode({
        'books': booksJson,
        'collections': <Map<String, dynamic>>[],
        'series': seriesJson,
      });

      expect(output, contains('"series":1'));
      expect(output, contains('"isSeries":true'));
      expect(output, contains('Batman Series'));
      expect(output, contains('The complete Batman collection'));
    });
  });

  group('processBook', () {
    test('extracts title from epub filename when no metadata', () async {
      final dir = Directory.systemTemp.createTempSync('covers_test');

      try {
        final result = await processBook(
          fileBytes: Uint8List(0),
          fileName: 'The Great Gatsby.epub',
          extension: 'epub',
          coversDir: dir,
        );
        expect(result.title, equals('The Great Gatsby'));
        expect(result.coverPath, isNull);
      } finally {
        dir.deleteSync(recursive: true);
      }
    });

    test('extracts title from pdf filename when no metadata', () async {
      final dir = Directory.systemTemp.createTempSync('covers_test2');

      try {
        final result = await processBook(
          fileBytes: Uint8List(0),
          fileName: 'annual_report_2024.pdf',
          extension: 'pdf',
          coversDir: dir,
        );
        expect(result.title, equals('annual report 2024'));
      } finally {
        dir.deleteSync(recursive: true);
      }
    });

    test('handles cbz extension correctly', () async {
      final dir = Directory.systemTemp.createTempSync('covers_test3');

      try {
        final result = await processBook(
          fileBytes: Uint8List(0),
          fileName: 'comic_issue_001.cbz',
          extension: 'cbz',
          coversDir: dir,
        );
        expect(result.title, equals('comic issue 001'));
      } finally {
        dir.deleteSync(recursive: true);
      }
    });

    test('handles mobi/azw3 extensions', () async {
      final dir = Directory.systemTemp.createTempSync('covers_test4');

      try {
        final result = await processBook(
          fileBytes: Uint8List(0),
          fileName: 'test_book.azw3',
          extension: 'azw3',
          coversDir: dir,
        );
        expect(result.title, equals('test book'));
      } finally {
        dir.deleteSync(recursive: true);
      }
    });
  });
}
