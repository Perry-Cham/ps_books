import 'dart:io';
import 'package:drift/drift.dart';
import 'package:ps_books/dbs/database.dart';
import 'package:ps_books/dbs/initdb.dart';

class BookToDb {
  final _db = DBProvider().db;

  /* === BOOKS === */
  Stream<List<Book>> watchAllBooks() {
    return _db.select(_db.books).watch();
  }

  Future<List<Book>> getAllBooks() {
    return _db.select(_db.books).get();
  }

  Future<List<Book>> getBooksByName(String name) {
    return (_db.select(_db.books)..where((t) => t.name.equals(name))).get();
  }

  Future<List<Book>> getBooksBySeries(int seriesId) {
    return (_db.select(_db.books)..where((t) => t.series.equals(seriesId))).get();
  }

  Future<List<Collection>> getAllCollections() {
    return _db.select(_db.collections).get();
  }

  Future<List<SavedBook>> getAllSavedBooks() {
    return _db.select(_db.savedBooks).get();
  }

  Future<SavedBook?> getSavedBookByTitleAndAuthor(String title, String author) async {
    final results = await (_db.select(_db.savedBooks)
      ..where((t) => t.title.equals(title))).get();
    return results.cast<SavedBook?>().firstWhere(
      (b) => b!.author == author,
      orElse: () => null,
    );
  }

  Future<Book> getBookById(int id) {
    return (_db.select(_db.books)..where((t) => t.id.equals(id))).getSingle();
  }

  Stream<Book?> getCurrentlyReading() {
    return (_db.select(_db.books)..where((t) => t.lastRead.equals(true)))
        .watch()
        .map((list) => list.isNotEmpty ? list.first : null);
  }

  Future<void> setCurrentlyReading(int id) async {
    final book = await getBookById(id);
    if (book.lastRead) return;

    _db.transaction(() async {
      await (_db.update(_db.books)..where((t) => t.lastRead.equals(true)))
          .write(BooksCompanion(lastRead: Value(false)));
      await (_db.update(_db.books)..where((t) => t.id.equals(id))).write(
        BooksCompanion(lastRead: Value(true)),
      );
    });
  }

  Future<int> addBook({
    required String name,
    String? author,
    required String path,
    required String extension,
    int? page,
    String? coverPath,
    int? series,
    bool isSeries = false,
    DateTime? dateAdded,
  }) {
    return _db
        .into(_db.books)
        .insert(
          BooksCompanion(
            name: Value(name),
            author: Value(author),
            path: Value(path),
            extension: Value(extension),
            page: Value(page),
            coverPath: Value(coverPath),
            series: Value(series),
            isSeries: Value(isSeries),
            dateAdded: dateAdded != null ? Value(dateAdded) : Value.absent(),
          ),
        );
  }

  Future<int> addWishBook(String title, String author, {int? collection}) async {
    return _db
        .into(_db.savedBooks)
        .insert(
          SavedBooksCompanion(
            title: Value(title),
            author: Value(author),
            collection: Value(collection),
          ),
        );
  }

  Future deleteBook(int id) {
    return (_db.delete(_db.books)..where((b) => b.id.equals(id))).go();
  }

  Future deleteSavedBook(int id) {
    return (_db.delete(_db.savedBooks)..where((b) => b.id.equals(id))).go();
  }

  Stream<List<SavedBook>> watchAllSavedBooks() {
    return _db.select(_db.savedBooks).watch();
  }

  Future updatePage(int id, int page) {
    return (_db.update(_db.books)..where((b) => b.id.equals(id)))
        .write(BooksCompanion(page: Value(page)));
  }

  Future updatePositionAndProgress(int id, String position) {
    return (_db.update(_db.books)..where((b) => b.id.equals(id)))
        .write(BooksCompanion(cfi: Value(position)));
  }

  Future updateProgress(int id, double progress) {
    return (_db.update(_db.books)..where((b) => b.id.equals(id)))
        .write(BooksCompanion(progress: Value(progress)));
  }

  /* === SERIES === */
  Stream<List<Sery>> watchAllSeries() {
    return _db.select(_db.series).watch();
  }

  Future<List<Sery>> getAllSeries() {
    return _db.select(_db.series).get();
  }

  Future<Sery?> getSeriesByName(String name) async {
    final results = await (_db.select(_db.series)
      ..where((t) => t.name.equals(name))).get();
    return results.isNotEmpty ? results.first : null;
  }

  Future<Sery?> getSeriesById(int id) async {
    final results = await (_db.select(_db.series)
      ..where((t) => t.id.equals(id))).get();
    return results.isNotEmpty ? results.first : null;
  }

  Future<int> addSeries(String name, {String? cover, String? description, int? collection, DateTime? dateAdded}) {
    return _db
        .into(_db.series)
        .insert(
          SeriesCompanion(
            name: Value(name),
            cover: Value(cover),
            description: Value(description),
            collection: Value(collection),
            dateAdded: dateAdded != null ? Value(dateAdded) : Value.absent(),
          ),
        );
  }

  Future updateSeries(int id, {String? name, String? cover, String? description}) {
    return (_db.update(_db.series)..where((t) => t.id.equals(id))).write(
      SeriesCompanion(
        name: name != null ? Value(name) : const Value.absent(),
        cover: cover != null ? Value(cover) : const Value.absent(),
        description: description != null ? Value(description) : const Value.absent(),
      ),
    );
  }

  Future updateSeriesCover(int id, String? cover) {
    return (_db.update(_db.series)..where((t) => t.id.equals(id)))
        .write(SeriesCompanion(cover: Value(cover)));
  }

  Future updateSeriesDescription(int id, String? description) {
    return (_db.update(_db.series)..where((t) => t.id.equals(id)))
        .write(SeriesCompanion(description: Value(description)));
  }

  Future deleteSeries(int id) async {
    await (_db.update(_db.books)..where((b) => b.series.equals(id)))
        .write(BooksCompanion(series: const Value(null)));
    await (_db.delete(_db.series)..where((t) => t.id.equals(id))).go();
  }

  Future<void> deleteSeriesBatch(Set<({int id, bool isSeries})> items) async {
    final ids = items.where((i) => i.isSeries).map((i) => i.id).toList();
    if (ids.isEmpty) return;
    for (final id in ids) {
      await (_db.update(_db.books)..where((b) => b.series.equals(id)))
          .write(BooksCompanion(series: const Value(null)));
    }
    await (_db.delete(_db.series)..where((t) => t.id.isIn(ids))).go();
  }

  Future<void> deleteBooksBatch(Set<({int id, bool isSeries})> items) async {
    final ids = items.where((i) => !i.isSeries).map((i) => i.id).toList();
    if (ids.isEmpty) return;
    final books = await (_db.select(_db.books)..where((b) => b.id.isIn(ids))).get();
    for (final book in books) {
      if (book.coverPath != null) {
        final image = File(book.coverPath!);
        if (await image.exists()) await image.delete();
      }
      final bookFile = File(book.path);
      if (await bookFile.exists()) await bookFile.delete();
    }
    await (_db.delete(_db.books)..where((b) => b.id.isIn(ids))).go();
  }

  /* === COLLECTIONS === */
  Future updateCategories(int id, int categories) {
    return (_db.update(_db.books)..where((b) => b.id.equals(id)))
        .write(BooksCompanion(collection: Value(categories)));
  }

  Future<int> setBookCollection(int bookId, int collectionId) async {
    return await (_db.update(_db.books)..where((t) => t.id.equals(bookId)))
        .write(BooksCompanion(collection: Value(collectionId)));
  }

  Future<int> batchUpdateCollection(Set<int> bookIds, int collectionId) async {
    return await (_db.update(_db.books)..where((t) => t.id.isIn(bookIds)))
        .write(BooksCompanion(collection: Value(collectionId)));
  }

  Future<int> removeCollection(int bookId) async {
    return await (_db.update(_db.books)..where((t) => t.id.equals(bookId)))
        .write(BooksCompanion(collection: Value(null)));
  }

  Future<int> setSavedBookCollection(int bookId, int collectionId) async {
    return await (_db.update(_db.savedBooks)..where((t) => t.id.equals(bookId)))
        .write(SavedBooksCompanion(collection: Value(collectionId)));
  }

  Stream<List<Collection>> getCategories() {
    return (_db.select(_db.collections)
      ..where((t) => t.isSavedCollection.equals(false))).watch();
  }

  Stream<List<Collection>> getSavedCategories() {
    return (_db.select(_db.collections)
      ..where((t) => t.isSavedCollection.equals(true))).watch();
  }

  Future<Collection?> getCollection(String name) async {
    return await (_db.select(_db.collections)
      ..where((t) => t.name.equals(name))).getSingleOrNull();
  }

  Future<int> addCollection(String name, {bool isSavedCollection = false}) async {
    if (isSavedCollection) {
      return await (_db.into(_db.collections).insert(
        CollectionsCompanion(
          name: Value(name),
          isSavedCollection: Value(isSavedCollection),
        ),
      ));
    }
    return await (_db.into(_db.collections).insert(
      CollectionsCompanion(name: Value(name)),
    ));
  }

  Future<void> deleteCollection(int collectionId) async {
    await (_db.update(_db.books)..where((b) => b.collection.equals(collectionId)))
        .write(BooksCompanion(collection: const Value(null)));
    await (_db.delete(_db.collections)..where((c) => c.id.equals(collectionId))).go();
  }
}
