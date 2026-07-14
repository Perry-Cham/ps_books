import 'package:drift/drift.dart';
import 'package:ps_books/dbs/database.dart';
import 'package:ps_books/dbs/initdb.dart';

class BookToDb {
  final _db = DBProvider().db;

  /* === BOOKS === */
  // Or as a reactive Stream (recommended for Flutter UI)
  Stream<List<Book>> watchAllBooks() {
    return _db.select(_db.books).watch(); // Auto-updates when data changes
  }

  //Get all books as a one-shot list
  Future<List<Book>> getAllBooks() {
    return _db.select(_db.books).get();
  }

  //Get books by name (for import matching)
  Future<List<Book>> getBooksByName(String name) {
    return (_db.select(_db.books)..where((t) => t.name.equals(name))).get();
  }

  //Get all collections as a one-shot list
  Future<List<Collection>> getAllCollections() {
    return _db.select(_db.collections).get();
  }

  //Get all saved books as a one-shot list
  Future<List<SavedBook>> getAllSavedBooks() {
    return _db.select(_db.savedBooks).get();
  }

  //Find a saved book by title and author (for import matching)
  Future<SavedBook?> getSavedBookByTitleAndAuthor(String title, String author) async {
    final results = await (_db.select(_db.savedBooks)
      ..where((t) => t.title.equals(title))).get();
    return results.cast<SavedBook?>().firstWhere(
      (b) => b!.author == author,
      orElse: () => null,
    );
  }

  //Get single Book
  Future<Book> getBookById(int id) {
    return (_db.select(_db.books)..where((t) => t.id.equals(id))).getSingle();
  }

  //get a book with currently reading set to true
  Stream<Book?> getCurrentlyReading() {
    return (_db.select(_db.books)..where((t) => t.lastRead.equals(true)))
        .watch()
        .map((list) => list.isNotEmpty ? list.first : null);
  }

  //set a books currently reading attribute
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

  //Insert Single Book
  Future<int> addBook({
    required String name,
    String? author,
    required String path,
    required String extension,
    int? page,
    String? coverPath,
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
          ),
        );
  }

  //Insert Wishlist Book or Saved Book
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

  //deleteBook
  Future deleteBook(int id) {
    return (_db.delete(_db.books)..where((b) => b.id.equals(id))).go();
  }

  //deleteSavedBook
  Future deleteSavedBook(int id) {
    return (_db.delete(_db.savedBooks)..where((b) => b.id.equals(id))).go();
  }

  // Watch all saved books
  Stream<List<SavedBook>> watchAllSavedBooks() {
    return _db.select(_db.savedBooks).watch();
  }

  //Update Page
  Future updatePage(int id, int page) {
    return (_db.update(
      _db.books,
    )..where((b) => b.id.equals(id))).write(BooksCompanion(page: Value(page)));
  }

  //Update Epub Position
  Future updatePositionAndProgress(int id, String position) {
    return (_db.update(_db.books)..where((b) => b.id.equals(id))).write(
      BooksCompanion(cfi: Value(position)),
    );
  }

  //Update Epub Progress
  Future updateProgress(int id, double progress) {
    return (_db.update(_db.books)..where((b) => b.id.equals(id))).write(
      BooksCompanion(progress: Value(progress)),
    );
  }

  /* === COLLECTIONS === */
  // Update categories
  Future updateCategories(int id, int categories) {
    return (_db.update(_db.books)..where((b) => b.id.equals(id))).write(
      BooksCompanion(collection: Value(categories)),
    );
  }

  // Set Collections for single book
  Future<int> setBookCollection(int bookId, int collectionId) async {
    return await (_db.update(_db.books)..where((t) => t.id.equals(bookId)))
        .write(BooksCompanion(collection: Value(collectionId)));
  }

  //Set Collection for Multiple Books
  Future<int> batchUpdateCollection(Set<int> bookIds, int collectionId) async {
    return await (_db.update(_db.books)..where((t) => t.id.isIn(bookIds)))
    .write(BooksCompanion(collection: Value(collectionId)));
  }

  // Remove Collection on a single book
  Future<int> removeCollection(int bookId) async {
    return await (_db.update(_db.books)..where((t) => t.id.equals(bookId)))
        .write(BooksCompanion(collection: Value(null)));
  }

  // Set Collections for all saved books
  Future<int> setSavedBookCollection(int bookId, int collectionId) async {
    return await (_db.update(_db.savedBooks)..where((t) => t.id.equals(bookId)))
        .write(SavedBooksCompanion(collection: Value(collectionId)));
  }

  // Get Collections Stream
  Stream<List<Collection>> getCategories() {
    return (_db.select(
      _db.collections,
    )..where((t) => t.isSavedCollection.equals(false))).watch();
  }

  Stream<List<Collection>> getSavedCategories() {
    return (_db.select(
      _db.collections,
    )..where((t) => t.isSavedCollection.equals(true))).watch();
  }

  //Get Single Collection
  Future<Collection?> getCollection(String name) async {
    return await (_db.select(
      _db.collections,
    )..where((t) => t.name.equals(name))).getSingleOrNull();
  }

  //Add Single Collection
  Future<int> addCollection(String name, {bool isSavedCollection = false}) async {
    if(isSavedCollection){
      return await (_db
          .into(_db.collections)
          .insert(CollectionsCompanion(name: Value(name), isSavedCollection: Value(isSavedCollection))));
    }
    return await (_db
        .into(_db.collections)
        .insert(CollectionsCompanion(name: Value(name))));
  }

  // Delete a collection and clear the reference on any books that used it.
  Future<void> deleteCollection(int collectionId) async {
    await (_db.update(_db.books)
          ..where((b) => b.collection.equals(collectionId)))
        .write(BooksCompanion(collection: const Value(null)));
    await (_db.delete(
      _db.collections,
    )..where((c) => c.id.equals(collectionId))).go();
  }
}
