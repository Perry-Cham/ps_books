import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

class Book extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get path => text()();
  //cfi for epubs
  TextColumn get cfi => text().nullable()();
  //Whether the book is an epub or pdf
  TextColumn get extension => text()();
  //Current page for pdfs
  IntColumn get page => integer().nullable()();
  //Total pages for pdfs
  IntColumn get totalPages => integer().nullable()();
  //Progress
  RealColumn get progress => real().withDefault(Constant(0.0))();
}

@DriftDatabase(tables: [Book])
class AppDatabase extends _$AppDatabase {
  // After generating code, this class needs to define a `schemaVersion` getter
  // and a constructor telling drift where the database should be stored.
  // These are described in the getting started guide: https://drift.simonbinder.eu/setup/
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'ps_books',
      native: const DriftNativeOptions(
        // By default, `driftDatabase` from `package:drift_flutter` stores the
        // database files in `getApplicationDocumentsDirectory()`.
        databaseDirectory: getApplicationSupportDirectory,
      ),
      // If you need web support, see https://drift.simonbinder.eu/platforms/web/
    );
  }

  // Or as a reactive Stream (recommended for Flutter UI)
  Stream<List<BookData>> watchAllBooks() {
    return select(book).watch(); // Auto-updates when data changes
  }

  //Get single Book
  Future<BookData> getBookById(int id) {
    return (select(book)..where((t) => t.id.equals(id))).getSingle();
  }

  //Insert Single Book returns the generated id
  Future<int> addBook(BookData entry) {
    return into(book).insert(entry);
  }
  //deleteBook
  Future deleteBook(int id){
    return (delete(book)..where((b) => b.id.equals(id))).go();
  }
  //Update Page
  Future updatePage(int id, int page){
    return (update(book)..where((b) => b.id.equals(id))).write(BookCompanion(
      page: Value(page)
    ));
  }
}
