// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $BookTable extends Book with TableInfo<$BookTable, BookData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BookTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pathMeta = const VerificationMeta('path');
  @override
  late final GeneratedColumn<String> path = GeneratedColumn<String>(
    'path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cfiMeta = const VerificationMeta('cfi');
  @override
  late final GeneratedColumn<String> cfi = GeneratedColumn<String>(
    'cfi',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _extensionMeta = const VerificationMeta(
    'extension',
  );
  @override
  late final GeneratedColumn<String> extension = GeneratedColumn<String>(
    'extension',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pageMeta = const VerificationMeta('page');
  @override
  late final GeneratedColumn<int> page = GeneratedColumn<int>(
    'page',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalPagesMeta = const VerificationMeta(
    'totalPages',
  );
  @override
  late final GeneratedColumn<int> totalPages = GeneratedColumn<int>(
    'total_pages',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _progressMeta = const VerificationMeta(
    'progress',
  );
  @override
  late final GeneratedColumn<double> progress = GeneratedColumn<double>(
    'progress',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: Constant(0.0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    path,
    cfi,
    extension,
    page,
    totalPages,
    progress,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'book';
  @override
  VerificationContext validateIntegrity(
    Insertable<BookData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('path')) {
      context.handle(
        _pathMeta,
        path.isAcceptableOrUnknown(data['path']!, _pathMeta),
      );
    } else if (isInserting) {
      context.missing(_pathMeta);
    }
    if (data.containsKey('cfi')) {
      context.handle(
        _cfiMeta,
        cfi.isAcceptableOrUnknown(data['cfi']!, _cfiMeta),
      );
    }
    if (data.containsKey('extension')) {
      context.handle(
        _extensionMeta,
        extension.isAcceptableOrUnknown(data['extension']!, _extensionMeta),
      );
    } else if (isInserting) {
      context.missing(_extensionMeta);
    }
    if (data.containsKey('page')) {
      context.handle(
        _pageMeta,
        page.isAcceptableOrUnknown(data['page']!, _pageMeta),
      );
    }
    if (data.containsKey('total_pages')) {
      context.handle(
        _totalPagesMeta,
        totalPages.isAcceptableOrUnknown(data['total_pages']!, _totalPagesMeta),
      );
    }
    if (data.containsKey('progress')) {
      context.handle(
        _progressMeta,
        progress.isAcceptableOrUnknown(data['progress']!, _progressMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BookData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BookData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      path: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}path'],
      )!,
      cfi: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cfi'],
      ),
      extension: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}extension'],
      )!,
      page: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}page'],
      ),
      totalPages: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_pages'],
      ),
      progress: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}progress'],
      )!,
    );
  }

  @override
  $BookTable createAlias(String alias) {
    return $BookTable(attachedDatabase, alias);
  }
}

class BookData extends DataClass implements Insertable<BookData> {
  final int id;
  final String name;
  final String path;
  final String? cfi;
  final String extension;
  final int? page;
  final int? totalPages;
  final double progress;
  const BookData({
    required this.id,
    required this.name,
    required this.path,
    this.cfi,
    required this.extension,
    this.page,
    this.totalPages,
    required this.progress,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['path'] = Variable<String>(path);
    if (!nullToAbsent || cfi != null) {
      map['cfi'] = Variable<String>(cfi);
    }
    map['extension'] = Variable<String>(extension);
    if (!nullToAbsent || page != null) {
      map['page'] = Variable<int>(page);
    }
    if (!nullToAbsent || totalPages != null) {
      map['total_pages'] = Variable<int>(totalPages);
    }
    map['progress'] = Variable<double>(progress);
    return map;
  }

  BookCompanion toCompanion(bool nullToAbsent) {
    return BookCompanion(
      id: Value(id),
      name: Value(name),
      path: Value(path),
      cfi: cfi == null && nullToAbsent ? const Value.absent() : Value(cfi),
      extension: Value(extension),
      page: page == null && nullToAbsent ? const Value.absent() : Value(page),
      totalPages: totalPages == null && nullToAbsent
          ? const Value.absent()
          : Value(totalPages),
      progress: Value(progress),
    );
  }

  factory BookData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BookData(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      path: serializer.fromJson<String>(json['path']),
      cfi: serializer.fromJson<String?>(json['cfi']),
      extension: serializer.fromJson<String>(json['extension']),
      page: serializer.fromJson<int?>(json['page']),
      totalPages: serializer.fromJson<int?>(json['totalPages']),
      progress: serializer.fromJson<double>(json['progress']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'path': serializer.toJson<String>(path),
      'cfi': serializer.toJson<String?>(cfi),
      'extension': serializer.toJson<String>(extension),
      'page': serializer.toJson<int?>(page),
      'totalPages': serializer.toJson<int?>(totalPages),
      'progress': serializer.toJson<double>(progress),
    };
  }

  BookData copyWith({
    int? id,
    String? name,
    String? path,
    Value<String?> cfi = const Value.absent(),
    String? extension,
    Value<int?> page = const Value.absent(),
    Value<int?> totalPages = const Value.absent(),
    double? progress,
  }) => BookData(
    id: id ?? this.id,
    name: name ?? this.name,
    path: path ?? this.path,
    cfi: cfi.present ? cfi.value : this.cfi,
    extension: extension ?? this.extension,
    page: page.present ? page.value : this.page,
    totalPages: totalPages.present ? totalPages.value : this.totalPages,
    progress: progress ?? this.progress,
  );
  BookData copyWithCompanion(BookCompanion data) {
    return BookData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      path: data.path.present ? data.path.value : this.path,
      cfi: data.cfi.present ? data.cfi.value : this.cfi,
      extension: data.extension.present ? data.extension.value : this.extension,
      page: data.page.present ? data.page.value : this.page,
      totalPages: data.totalPages.present
          ? data.totalPages.value
          : this.totalPages,
      progress: data.progress.present ? data.progress.value : this.progress,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BookData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('path: $path, ')
          ..write('cfi: $cfi, ')
          ..write('extension: $extension, ')
          ..write('page: $page, ')
          ..write('totalPages: $totalPages, ')
          ..write('progress: $progress')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, path, cfi, extension, page, totalPages, progress);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BookData &&
          other.id == this.id &&
          other.name == this.name &&
          other.path == this.path &&
          other.cfi == this.cfi &&
          other.extension == this.extension &&
          other.page == this.page &&
          other.totalPages == this.totalPages &&
          other.progress == this.progress);
}

class BookCompanion extends UpdateCompanion<BookData> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> path;
  final Value<String?> cfi;
  final Value<String> extension;
  final Value<int?> page;
  final Value<int?> totalPages;
  final Value<double> progress;
  const BookCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.path = const Value.absent(),
    this.cfi = const Value.absent(),
    this.extension = const Value.absent(),
    this.page = const Value.absent(),
    this.totalPages = const Value.absent(),
    this.progress = const Value.absent(),
  });
  BookCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String path,
    this.cfi = const Value.absent(),
    required String extension,
    this.page = const Value.absent(),
    this.totalPages = const Value.absent(),
    this.progress = const Value.absent(),
  }) : name = Value(name),
       path = Value(path),
       extension = Value(extension);
  static Insertable<BookData> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? path,
    Expression<String>? cfi,
    Expression<String>? extension,
    Expression<int>? page,
    Expression<int>? totalPages,
    Expression<double>? progress,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (path != null) 'path': path,
      if (cfi != null) 'cfi': cfi,
      if (extension != null) 'extension': extension,
      if (page != null) 'page': page,
      if (totalPages != null) 'total_pages': totalPages,
      if (progress != null) 'progress': progress,
    });
  }

  BookCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? path,
    Value<String?>? cfi,
    Value<String>? extension,
    Value<int?>? page,
    Value<int?>? totalPages,
    Value<double>? progress,
  }) {
    return BookCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      path: path ?? this.path,
      cfi: cfi ?? this.cfi,
      extension: extension ?? this.extension,
      page: page ?? this.page,
      totalPages: totalPages ?? this.totalPages,
      progress: progress ?? this.progress,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (path.present) {
      map['path'] = Variable<String>(path.value);
    }
    if (cfi.present) {
      map['cfi'] = Variable<String>(cfi.value);
    }
    if (extension.present) {
      map['extension'] = Variable<String>(extension.value);
    }
    if (page.present) {
      map['page'] = Variable<int>(page.value);
    }
    if (totalPages.present) {
      map['total_pages'] = Variable<int>(totalPages.value);
    }
    if (progress.present) {
      map['progress'] = Variable<double>(progress.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BookCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('path: $path, ')
          ..write('cfi: $cfi, ')
          ..write('extension: $extension, ')
          ..write('page: $page, ')
          ..write('totalPages: $totalPages, ')
          ..write('progress: $progress')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $BookTable book = $BookTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [book];
}

typedef $$BookTableCreateCompanionBuilder =
    BookCompanion Function({
      Value<int> id,
      required String name,
      required String path,
      Value<String?> cfi,
      required String extension,
      Value<int?> page,
      Value<int?> totalPages,
      Value<double> progress,
    });
typedef $$BookTableUpdateCompanionBuilder =
    BookCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> path,
      Value<String?> cfi,
      Value<String> extension,
      Value<int?> page,
      Value<int?> totalPages,
      Value<double> progress,
    });

class $$BookTableFilterComposer extends Composer<_$AppDatabase, $BookTable> {
  $$BookTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cfi => $composableBuilder(
    column: $table.cfi,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get extension => $composableBuilder(
    column: $table.extension,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get page => $composableBuilder(
    column: $table.page,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalPages => $composableBuilder(
    column: $table.totalPages,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get progress => $composableBuilder(
    column: $table.progress,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BookTableOrderingComposer extends Composer<_$AppDatabase, $BookTable> {
  $$BookTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cfi => $composableBuilder(
    column: $table.cfi,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get extension => $composableBuilder(
    column: $table.extension,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get page => $composableBuilder(
    column: $table.page,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalPages => $composableBuilder(
    column: $table.totalPages,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get progress => $composableBuilder(
    column: $table.progress,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BookTableAnnotationComposer
    extends Composer<_$AppDatabase, $BookTable> {
  $$BookTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get path =>
      $composableBuilder(column: $table.path, builder: (column) => column);

  GeneratedColumn<String> get cfi =>
      $composableBuilder(column: $table.cfi, builder: (column) => column);

  GeneratedColumn<String> get extension =>
      $composableBuilder(column: $table.extension, builder: (column) => column);

  GeneratedColumn<int> get page =>
      $composableBuilder(column: $table.page, builder: (column) => column);

  GeneratedColumn<int> get totalPages => $composableBuilder(
    column: $table.totalPages,
    builder: (column) => column,
  );

  GeneratedColumn<double> get progress =>
      $composableBuilder(column: $table.progress, builder: (column) => column);
}

class $$BookTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BookTable,
          BookData,
          $$BookTableFilterComposer,
          $$BookTableOrderingComposer,
          $$BookTableAnnotationComposer,
          $$BookTableCreateCompanionBuilder,
          $$BookTableUpdateCompanionBuilder,
          (BookData, BaseReferences<_$AppDatabase, $BookTable, BookData>),
          BookData,
          PrefetchHooks Function()
        > {
  $$BookTableTableManager(_$AppDatabase db, $BookTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BookTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BookTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BookTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> path = const Value.absent(),
                Value<String?> cfi = const Value.absent(),
                Value<String> extension = const Value.absent(),
                Value<int?> page = const Value.absent(),
                Value<int?> totalPages = const Value.absent(),
                Value<double> progress = const Value.absent(),
              }) => BookCompanion(
                id: id,
                name: name,
                path: path,
                cfi: cfi,
                extension: extension,
                page: page,
                totalPages: totalPages,
                progress: progress,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String path,
                Value<String?> cfi = const Value.absent(),
                required String extension,
                Value<int?> page = const Value.absent(),
                Value<int?> totalPages = const Value.absent(),
                Value<double> progress = const Value.absent(),
              }) => BookCompanion.insert(
                id: id,
                name: name,
                path: path,
                cfi: cfi,
                extension: extension,
                page: page,
                totalPages: totalPages,
                progress: progress,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BookTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BookTable,
      BookData,
      $$BookTableFilterComposer,
      $$BookTableOrderingComposer,
      $$BookTableAnnotationComposer,
      $$BookTableCreateCompanionBuilder,
      $$BookTableUpdateCompanionBuilder,
      (BookData, BaseReferences<_$AppDatabase, $BookTable, BookData>),
      BookData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$BookTableTableManager get book => $$BookTableTableManager(_db, _db.book);
}
