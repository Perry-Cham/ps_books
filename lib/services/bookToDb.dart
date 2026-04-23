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
    return (_db.update(_db.book)..where((b) => b.id.equals(id))).write(BookCompanion(page: Value(page)));
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
  Future updateCategories(int id, String? categories) {
    return (_db.update(_db.book)..where((b) => b.id.equals(id))).write(
      BookCompanion(categories: Value(categories)),
    );
  }

  // Set categories for all books
  Future setAllCategories(String categories, int id) async {
    await (_db.update(_db.book)..where((t) => t.id.equals(id))).write(BookCompanion(categories: Value(categories)));
  }

  // Add more methods as needed
}