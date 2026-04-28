import 'package:drift/drift.dart';
import 'package:ps_books/dbs/database.dart';
import 'package:ps_books/dbs/initdb.dart';

class BookToDb {
  final _db = DBProvider().db;

  // Or as a reactive Stream (recommended for Flutter UI)
  Stream<List<BookData>> watchAllBooks() {
    return _db.select(_db.book).watch(); // Auto-updates when data changes
  }

  //Get single Book
  Future<BookData> getBookById(int id) {
    return (_db.select(_db.book)..where((t) => t.id.equals(id))).getSingle();
  }

  //Insert Single Book returns the generated id
  Future<int> addBook(BookData entry) {
    return _db.into(_db.book).insert(entry);
  }

  //deleteBook
  Future deleteBook(int id) {
    return (_db.delete(_db.book)..where((b) => b.id.equals(id))).go();
  }

  //Update Page
  Future updatePage(int id, int page) {
    return (_db.update(
      _db.book,
    )..where((b) => b.id.equals(id))).write(BookCompanion(page: Value(page)));
  }

  //Update Epub Position
  Future updatePositionAndProgress(int id, String position) {
    return (_db.update(_db.book)..where((b) => b.id.equals(id))).write(
      BookCompanion(cfi: Value(position)),
    );
  }

  //Update Epub Position
  Future updateProgress(int id, double progress) {
    return (_db.update(_db.book)..where((b) => b.id.equals(id))).write(
      BookCompanion(progress: Value(progress)),
    );
  }

  // Update categories
  Future updateCategories(int id, int categories) {
    return (_db.update(_db.book)..where((b) => b.id.equals(id))).write(
      BookCompanion(collection: Value(categories)),
    );
  }

  // Set categories for all books
  Future<int> setBookCollection(int bookId, int collectionId) async {
    return await (_db.update(_db.book)..where((t) => t.id.equals(bookId)))
        .write(BookCompanion(collection: Value(collectionId)));
  }

  // Get Categories Stream
  Stream<List<Collection>> getCategories() {
    return _db.select(_db.collections).watch();
  }

  //Get Single Collection
  Future<Collection?> getCollection(String name) async {
    return await (_db.select(
      _db.collections,
    )..where((t) => t.name.equals(name))).getSingleOrNull();
  }

  //Add Single Collection
  Future<int> addCollection(String name) async {
    return await (_db
        .into(_db.collections)
        .insert(CollectionsCompanion(name: Value(name))));
  }

  // Delete a collection and clear the reference on any books that used it.
  Future<void> deleteCollection(int collectionId) async {
    await (_db.update(_db.book)
          ..where((b) => b.collection.equals(collectionId)))
        .write(BookCompanion(collection: const Value(null)));
    await (_db.delete(
      _db.collections,
    )..where((c) => c.id.equals(collectionId))).go();
  }
}
