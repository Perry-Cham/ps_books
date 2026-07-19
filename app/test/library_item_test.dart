import 'package:flutter_test/flutter_test.dart';
import 'package:ps_books/dbs/database.dart';
import 'package:ps_books/models/library_item.dart';

void main() {
  group('LibraryItem', () {
    test('creates LibraryItem from Book with isSeries false', () {
      final book = Book(
        id: 1,
        name: 'Test Book',
        author: 'Author',
        path: '/path/to/book.epub',
        extension: 'epub',
        progress: 0.5,
        lastRead: false,
        isSeries: false,
        series: null,
        collection: null,
        page: null,
        cfi: null,
        coverPath: '/covers/test.png',
      );

      final item = LibraryItem.fromBook(book);

      expect(item.id, equals(1));
      expect(item.name, equals('Test Book'));
      expect(item.isSeries, isFalse);
      expect(item.coverPath, equals('/covers/test.png'));
      expect(item.progress, equals(0.5));
    });

    test('creates LibraryItem from Book with isSeries true', () {
      final book = Book(
        id: 2,
        name: 'Chapter 1',
        author: null,
        path: '/path/to/chapter.cbz',
        extension: 'cbz',
        progress: 0.0,
        lastRead: false,
        isSeries: true,
        series: 1,
        collection: null,
        page: 1,
        cfi: null,
        coverPath: null,
      );

      final item = LibraryItem.fromBook(book);

      expect(item.id, equals(2));
      expect(item.isSeries, isTrue);
      expect(item.seriesId, equals(1));
    });

    test('creates LibraryItem from Series', () {
      final series = Sery(
        id: 1,
        name: 'Batman Collection',
        cover: '/covers/batman.png',
        description: 'All Batman comics',
        collection: null,
      );

      final item = LibraryItem.fromSeries(series);

      expect(item.id, equals(1));
      expect(item.name, equals('Batman Collection'));
      expect(item.isSeries, isTrue);
      expect(item.coverPath, equals('/covers/batman.png'));
      expect(item.seriesId, equals(1));
    });

    test('fromSeries uses provided coverPath over series cover', () {
      final series = Sery(
        id: 1,
        name: 'Series',
        cover: '/original/cover.png',
        description: null,
        collection: null,
      );

      final item = LibraryItem.fromSeries(series, coverPath: '/custom/cover.png');

      expect(item.coverPath, equals('/custom/cover.png'));
    });

    test('isSeries flag distinguishes books from series', () {
      final bookItem = LibraryItem.fromBook(Book(
        id: 1,
        name: 'Book',
        author: null,
        path: '/path',
        extension: 'epub',
        progress: 0.0,
        lastRead: false,
        isSeries: false,
        series: null,
      ));

      final seriesItem = LibraryItem.fromSeries(Sery(
        id: 2,
        name: 'Series',
        cover: null,
        description: null,
        collection: null,
      ));

      expect(bookItem.isSeries, isFalse);
      expect(seriesItem.isSeries, isTrue);
    });
  });
}
