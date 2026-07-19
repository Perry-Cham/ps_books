import 'package:ps_books/dbs/database.dart';

class LibraryItem {
  final int id;
  final String name;
  final String? coverPath;
  final bool isSeries;
  final int? seriesId;
  final double progress;
  final int? collection;
  final String? author;

  const LibraryItem({
    required this.id,
    required this.name,
    this.coverPath,
    required this.isSeries,
    this.seriesId,
    this.progress = 0.0,
    this.collection,
    this.author,
  });

  factory LibraryItem.fromBook(Book book) {
    return LibraryItem(
      id: book.id,
      name: book.name,
      coverPath: book.coverPath,
      isSeries: book.isSeries,
      seriesId: book.series,
      progress: book.progress,
      collection: book.collection,
      author: book.author,
    );
  }

  factory LibraryItem.fromSeries(Sery series, {String? coverPath}) {
    return LibraryItem(
      id: series.id,
      name: series.name,
      coverPath: coverPath ?? series.cover,
      isSeries: true,
      seriesId: series.id,
      collection: series.collection,
    );
  }
}
