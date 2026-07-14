import 'package:drift/drift.dart';
import 'package:ps_books/dbs/database.dart';
import 'package:ps_books/dbs/initdb.dart';
import 'package:uuid/uuid.dart';

class NotesToDB {
  final _db = DBProvider().db;
  final _uuid = const Uuid();

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

  //Get all notes as a one-shot list
  Future<List<Note>> getAllNotesList() {
    return _db.select(_db.notes).get();
  }

  //Find a note by uuid (for import matching)
  Future<Note?> getNoteByUuid(String uuid) {
    return (_db.select(_db.notes)..where((t) => t.uuid.equals(uuid))).getSingleOrNull();
  }

  //Update a note's title, content, and lastModified (for import)
  Future<void> editNote(int id, String title, String content, DateTime lastModified) {
    return (_db.update(_db.notes)..where((t) => t.id.equals(id))).write(
      NotesCompanion(
        title: Value(title),
        content: Value(content),
        lastModified: Value(lastModified),
      ),
    );
  }

  Future<int> createNewNote({required String title, String? content, int? bookId, int? collection, String? uuid, DateTime? lastModified}) {
    return _db.into(_db.notes).insert(
      NotesCompanion(
        uuid: Value(uuid ?? _uuid.v4()),
        title: Value(title),
        content: Value(content ?? ''),
        lastModified: Value(lastModified ?? DateTime.now()),
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
