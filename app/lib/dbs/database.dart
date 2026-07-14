import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

class Books extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get author => text().nullable()();
  TextColumn get path => text()();
  //cfi for epubs
  TextColumn get cfi => text().nullable()();
  //Whether the book is an epub or pdf
  TextColumn get extension => text()();
  //Current page for pdfs
  IntColumn get page => integer().nullable()();
  //Progress
  RealColumn get progress => real().withDefault(Constant(0.0))();
  //Collections
  IntColumn get collection =>
  integer().references(Collections, #id).nullable()();
  //Is set to true if it was the last read book,
  BoolColumn get lastRead => boolean().withDefault(Constant(false))();
  //Image cover path
  TextColumn get coverPath => text().nullable()();
}

class Collections extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  BoolColumn get isSavedCollection => boolean().withDefault(Constant(false))();
}

class Timetables extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get version => integer()();
  DateTimeColumn get lastModified => dateTime()();
}

class TimetableDays extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get timetableId => integer().references(Timetables, #id)();
  TextColumn get day => text()();
  BoolColumn get isBreakDay => boolean().withDefault(Constant(false))();
}

class TimetableSessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get dayId => integer().references(TimetableDays, #id)();
  TextColumn get start => text()();
  TextColumn get end => text()();
  TextColumn get subjects => text()();
}

class TargetSubjects extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uuid => text().unique()();
  TextColumn get name => text()();
  DateTimeColumn get syncedAt => dateTime().nullable()();
}

class TargetTopics extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uuid => text().unique()();
  TextColumn get name => text()();
  BoolColumn get isCompleted => boolean()();
  DateTimeColumn get lastModified => dateTime()();
  IntColumn get subjectId => integer().references(TargetSubjects, #id)();
}

class SavedBooks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get author => text()();
  IntColumn get collection =>
  integer().references(Collections, #id).nullable()();
}

class Notes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uuid => text()();
  TextColumn get title => text()();
  TextColumn get content => text()();
  DateTimeColumn get lastModified => dateTime()();
  IntColumn get bookId => integer().references(Books, #id).nullable()();
  IntColumn get collection =>
  integer().references(Collections, #id).nullable()();
}

@DriftDatabase(
  tables: [
    Books,
    Collections,
    Timetables,
    TimetableDays,
    TimetableSessions,
    TargetSubjects,
    TargetTopics,
    SavedBooks,
    Notes, // Added Notes table
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          // Type-safe column rename
          await m.renameColumn(timetables, 'last_modified', timetables.lastModified);
          // Type-safe table creation
          await m.createTable(notes);
        }
        if (from < 3) {
          // 1. Add new columns in a type-safe way using the Migrator API
          await m.addColumn(notes, notes.uuid);
          await m.addColumn(notes, notes.lastModified);

          // 2. Populate defaults for existing rows (since Dart can't easily execute hex(randomblob) natively)
          await transaction(() async {
            await customStatement(
              'UPDATE notes SET uuid = hex(randomblob(16)), last_modified = CAST(strftime("%s", "now") AS INTEGER)'
            );
          });

          // 3. Create the unique index on uuid in a type-safe way
          await m.createIndex(
            Index('idx_notes_uuid', 'CREATE UNIQUE INDEX idx_notes_uuid ON notes(uuid)')
          );
        }
      },
    );
  }

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'ps_books',
      native: const DriftNativeOptions(
        databaseDirectory: getApplicationSupportDirectory,
      ),
    );
  }

}
