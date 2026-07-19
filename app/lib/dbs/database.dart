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
  // Whether this book belongs to a series
  IntColumn get series => integer().references(Series, #id).nullable()();
  BoolColumn get isSeries => boolean().withDefault(Constant(false))();
}

// A series differs from a collection in that a series groups books that would clutter the library if they appeared there individually e.g comic issues or manga chapters when the user has hundreds of them. It can also include books that belong to the same standard ebooks opds catalogue.This is typically created when books are downloaded or added for the first time. A collection appears as a single book on the library page and can even be added to a collection just like ordinary books.
class Series extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get cover => text().nullable()();
  TextColumn get description => text().nullable()();
  IntColumn get collection =>
      integer().references(Collections, #id).nullable()();
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
  TextColumn get uuid => text().withDefault(Constant(""))();
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
    Notes,
    Series,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

 /* @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          // Type-safe column rename
          await m.renameColumn(
            timetables,
            'last_modified',
            timetables.lastModified,
          );
          // Type-safe table creation
          await m.createTable(notes);
        }
        if (from < 3) {
          //Adds Notes and UUID columns to notes table

          m.alterTable(
            TableMigration(
              notes,
              columnTransformer: {
                notes.uuid: CustomExpression<String>('hex(randomblob(16))'),
                notes.lastModified: CustomExpression<DateTime>(
                  'CAST(strftime("%s", "now") AS INTEGER',
                ),
              },
            ),
          );
        }
      },
    );
  }*/

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'ps_books',
      native: const DriftNativeOptions(
        databaseDirectory: getApplicationSupportDirectory,
      ),
    );
  }
}
