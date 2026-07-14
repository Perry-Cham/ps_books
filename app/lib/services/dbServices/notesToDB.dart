import 'package:drift/drift.dart';
import 'package:ps_books/dbs/database.dart';
import 'package:ps_books/dbs/initdb.dart';

class NotesToDB {
  final _db = DBProvider().db;

  Stream<List<Note>> getAllNotes() {
    return _db.select(_db.notes).watch();
  }

  Stream<List<Note>> getNotesByBookId(int bookId) {
    return (_db.select(_db.notes)..where((t) => t.bookId.equals(bookId))).watch();
  }

  Stream<List<Note>> getNotesByCollectionId(int collectionId) {
    return (_db.select(_db.notes)..where((t) => t.collection.equals(collectionId))).watch();
  }

  Future<Note?> getSingleNote(int id) async {
    return (_db.select(_db.notes)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<int> createNewNote({required String title, String? content, int? bookId, int? collection}) {
    return _db.into(_db.notes).insert(
      NotesCompanion(
        title: Value(title),
        content: Value(content ?? ''),
        bookId: Value(bookId),
        collection: Value(collection),
      ),
    );
  }

  Future editTitle(int id, String title) {
    return (_db.update(_db.notes)..where((t) => t.id.equals(id))).write(
      NotesCompanion(title: Value(title)),
    );
  }

  Future editContent(int id, String content) {
    return (_db.update(_db.notes)..where((t) => t.id.equals(id))).write(
      NotesCompanion(content: Value(content)),
    );
  }

  Future editCollection(int id, int? collectionId) {
    return (_db.update(_db.notes)..where((t) => t.id.equals(id))).write(
      NotesCompanion(collection: Value(collectionId)),
    );
  }

  Future deleteNote(int id) {
    return (_db.delete(_db.notes)..where((t) => t.id.equals(id))).go();
  }

  Future setNoteBookId(int id, int? bookId) {
    return (_db.update(_db.notes)..where((t) => t.id.equals(id))).write(
      NotesCompanion(bookId: Value(bookId)),
    );
  }

  Stream<List<Collection>> getAllNoteCategories() {
    return _db.select(_db.collections).watch();
  }
}
