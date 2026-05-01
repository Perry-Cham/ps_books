// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $CollectionsTable extends Collections
    with TableInfo<$CollectionsTable, Collection> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CollectionsTable(this.attachedDatabase, [this._alias]);
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
  @override
  List<GeneratedColumn> get $columns => [id, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'collections';
  @override
  VerificationContext validateIntegrity(
    Insertable<Collection> instance, {
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Collection map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Collection(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
    );
  }

  @override
  $CollectionsTable createAlias(String alias) {
    return $CollectionsTable(attachedDatabase, alias);
  }
}

class Collection extends DataClass implements Insertable<Collection> {
  final int id;
  final String name;
  const Collection({required this.id, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    return map;
  }

  CollectionsCompanion toCompanion(bool nullToAbsent) {
    return CollectionsCompanion(id: Value(id), name: Value(name));
  }

  factory Collection.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Collection(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
    };
  }

  Collection copyWith({int? id, String? name}) =>
      Collection(id: id ?? this.id, name: name ?? this.name);
  Collection copyWithCompanion(CollectionsCompanion data) {
    return Collection(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Collection(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Collection && other.id == this.id && other.name == this.name);
}

class CollectionsCompanion extends UpdateCompanion<Collection> {
  final Value<int> id;
  final Value<String> name;
  const CollectionsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
  });
  CollectionsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
  }) : name = Value(name);
  static Insertable<Collection> custom({
    Expression<int>? id,
    Expression<String>? name,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
    });
  }

  CollectionsCompanion copyWith({Value<int>? id, Value<String>? name}) {
    return CollectionsCompanion(id: id ?? this.id, name: name ?? this.name);
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
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CollectionsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }
}

class $BooksTable extends Books with TableInfo<$BooksTable, Book> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BooksTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _collectionMeta = const VerificationMeta(
    'collection',
  );
  @override
  late final GeneratedColumn<int> collection = GeneratedColumn<int>(
    'collection',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES collections (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    path,
    cfi,
    extension,
    page,
    progress,
    collection,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'books';
  @override
  VerificationContext validateIntegrity(
    Insertable<Book> instance, {
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
    if (data.containsKey('progress')) {
      context.handle(
        _progressMeta,
        progress.isAcceptableOrUnknown(data['progress']!, _progressMeta),
      );
    }
    if (data.containsKey('collection')) {
      context.handle(
        _collectionMeta,
        collection.isAcceptableOrUnknown(data['collection']!, _collectionMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Book map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Book(
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
      progress: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}progress'],
      )!,
      collection: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}collection'],
      ),
    );
  }

  @override
  $BooksTable createAlias(String alias) {
    return $BooksTable(attachedDatabase, alias);
  }
}

class Book extends DataClass implements Insertable<Book> {
  final int id;
  final String name;
  final String path;
  final String? cfi;
  final String extension;
  final int? page;
  final double progress;
  final int? collection;
  const Book({
    required this.id,
    required this.name,
    required this.path,
    this.cfi,
    required this.extension,
    this.page,
    required this.progress,
    this.collection,
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
    map['progress'] = Variable<double>(progress);
    if (!nullToAbsent || collection != null) {
      map['collection'] = Variable<int>(collection);
    }
    return map;
  }

  BooksCompanion toCompanion(bool nullToAbsent) {
    return BooksCompanion(
      id: Value(id),
      name: Value(name),
      path: Value(path),
      cfi: cfi == null && nullToAbsent ? const Value.absent() : Value(cfi),
      extension: Value(extension),
      page: page == null && nullToAbsent ? const Value.absent() : Value(page),
      progress: Value(progress),
      collection: collection == null && nullToAbsent
          ? const Value.absent()
          : Value(collection),
    );
  }

  factory Book.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Book(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      path: serializer.fromJson<String>(json['path']),
      cfi: serializer.fromJson<String?>(json['cfi']),
      extension: serializer.fromJson<String>(json['extension']),
      page: serializer.fromJson<int?>(json['page']),
      progress: serializer.fromJson<double>(json['progress']),
      collection: serializer.fromJson<int?>(json['collection']),
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
      'progress': serializer.toJson<double>(progress),
      'collection': serializer.toJson<int?>(collection),
    };
  }

  Book copyWith({
    int? id,
    String? name,
    String? path,
    Value<String?> cfi = const Value.absent(),
    String? extension,
    Value<int?> page = const Value.absent(),
    double? progress,
    Value<int?> collection = const Value.absent(),
  }) => Book(
    id: id ?? this.id,
    name: name ?? this.name,
    path: path ?? this.path,
    cfi: cfi.present ? cfi.value : this.cfi,
    extension: extension ?? this.extension,
    page: page.present ? page.value : this.page,
    progress: progress ?? this.progress,
    collection: collection.present ? collection.value : this.collection,
  );
  Book copyWithCompanion(BooksCompanion data) {
    return Book(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      path: data.path.present ? data.path.value : this.path,
      cfi: data.cfi.present ? data.cfi.value : this.cfi,
      extension: data.extension.present ? data.extension.value : this.extension,
      page: data.page.present ? data.page.value : this.page,
      progress: data.progress.present ? data.progress.value : this.progress,
      collection: data.collection.present
          ? data.collection.value
          : this.collection,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Book(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('path: $path, ')
          ..write('cfi: $cfi, ')
          ..write('extension: $extension, ')
          ..write('page: $page, ')
          ..write('progress: $progress, ')
          ..write('collection: $collection')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, path, cfi, extension, page, progress, collection);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Book &&
          other.id == this.id &&
          other.name == this.name &&
          other.path == this.path &&
          other.cfi == this.cfi &&
          other.extension == this.extension &&
          other.page == this.page &&
          other.progress == this.progress &&
          other.collection == this.collection);
}

class BooksCompanion extends UpdateCompanion<Book> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> path;
  final Value<String?> cfi;
  final Value<String> extension;
  final Value<int?> page;
  final Value<double> progress;
  final Value<int?> collection;
  const BooksCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.path = const Value.absent(),
    this.cfi = const Value.absent(),
    this.extension = const Value.absent(),
    this.page = const Value.absent(),
    this.progress = const Value.absent(),
    this.collection = const Value.absent(),
  });
  BooksCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String path,
    this.cfi = const Value.absent(),
    required String extension,
    this.page = const Value.absent(),
    this.progress = const Value.absent(),
    this.collection = const Value.absent(),
  }) : name = Value(name),
       path = Value(path),
       extension = Value(extension);
  static Insertable<Book> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? path,
    Expression<String>? cfi,
    Expression<String>? extension,
    Expression<int>? page,
    Expression<double>? progress,
    Expression<int>? collection,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (path != null) 'path': path,
      if (cfi != null) 'cfi': cfi,
      if (extension != null) 'extension': extension,
      if (page != null) 'page': page,
      if (progress != null) 'progress': progress,
      if (collection != null) 'collection': collection,
    });
  }

  BooksCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? path,
    Value<String?>? cfi,
    Value<String>? extension,
    Value<int?>? page,
    Value<double>? progress,
    Value<int?>? collection,
  }) {
    return BooksCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      path: path ?? this.path,
      cfi: cfi ?? this.cfi,
      extension: extension ?? this.extension,
      page: page ?? this.page,
      progress: progress ?? this.progress,
      collection: collection ?? this.collection,
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
    if (progress.present) {
      map['progress'] = Variable<double>(progress.value);
    }
    if (collection.present) {
      map['collection'] = Variable<int>(collection.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BooksCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('path: $path, ')
          ..write('cfi: $cfi, ')
          ..write('extension: $extension, ')
          ..write('page: $page, ')
          ..write('progress: $progress, ')
          ..write('collection: $collection')
          ..write(')'))
        .toString();
  }
}

class $TimetableDaysTable extends TimetableDays
    with TableInfo<$TimetableDaysTable, TimetableDay> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TimetableDaysTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<String> day = GeneratedColumn<String>(
    'day',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isBreakDayMeta = const VerificationMeta(
    'isBreakDay',
  );
  @override
  late final GeneratedColumn<bool> isBreakDay = GeneratedColumn<bool>(
    'is_break_day',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_break_day" IN (0, 1))',
    ),
    defaultValue: Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [id, day, isBreakDay];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'timetable_days';
  @override
  VerificationContext validateIntegrity(
    Insertable<TimetableDay> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('day')) {
      context.handle(
        _dayMeta,
        day.isAcceptableOrUnknown(data['day']!, _dayMeta),
      );
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    if (data.containsKey('is_break_day')) {
      context.handle(
        _isBreakDayMeta,
        isBreakDay.isAcceptableOrUnknown(
          data['is_break_day']!,
          _isBreakDayMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TimetableDay map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TimetableDay(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      day: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day'],
      )!,
      isBreakDay: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_break_day'],
      )!,
    );
  }

  @override
  $TimetableDaysTable createAlias(String alias) {
    return $TimetableDaysTable(attachedDatabase, alias);
  }
}

class TimetableDay extends DataClass implements Insertable<TimetableDay> {
  final int id;
  final String day;
  final bool isBreakDay;
  const TimetableDay({
    required this.id,
    required this.day,
    required this.isBreakDay,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['day'] = Variable<String>(day);
    map['is_break_day'] = Variable<bool>(isBreakDay);
    return map;
  }

  TimetableDaysCompanion toCompanion(bool nullToAbsent) {
    return TimetableDaysCompanion(
      id: Value(id),
      day: Value(day),
      isBreakDay: Value(isBreakDay),
    );
  }

  factory TimetableDay.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TimetableDay(
      id: serializer.fromJson<int>(json['id']),
      day: serializer.fromJson<String>(json['day']),
      isBreakDay: serializer.fromJson<bool>(json['isBreakDay']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'day': serializer.toJson<String>(day),
      'isBreakDay': serializer.toJson<bool>(isBreakDay),
    };
  }

  TimetableDay copyWith({int? id, String? day, bool? isBreakDay}) =>
      TimetableDay(
        id: id ?? this.id,
        day: day ?? this.day,
        isBreakDay: isBreakDay ?? this.isBreakDay,
      );
  TimetableDay copyWithCompanion(TimetableDaysCompanion data) {
    return TimetableDay(
      id: data.id.present ? data.id.value : this.id,
      day: data.day.present ? data.day.value : this.day,
      isBreakDay: data.isBreakDay.present
          ? data.isBreakDay.value
          : this.isBreakDay,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TimetableDay(')
          ..write('id: $id, ')
          ..write('day: $day, ')
          ..write('isBreakDay: $isBreakDay')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, day, isBreakDay);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TimetableDay &&
          other.id == this.id &&
          other.day == this.day &&
          other.isBreakDay == this.isBreakDay);
}

class TimetableDaysCompanion extends UpdateCompanion<TimetableDay> {
  final Value<int> id;
  final Value<String> day;
  final Value<bool> isBreakDay;
  const TimetableDaysCompanion({
    this.id = const Value.absent(),
    this.day = const Value.absent(),
    this.isBreakDay = const Value.absent(),
  });
  TimetableDaysCompanion.insert({
    this.id = const Value.absent(),
    required String day,
    this.isBreakDay = const Value.absent(),
  }) : day = Value(day);
  static Insertable<TimetableDay> custom({
    Expression<int>? id,
    Expression<String>? day,
    Expression<bool>? isBreakDay,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (day != null) 'day': day,
      if (isBreakDay != null) 'is_break_day': isBreakDay,
    });
  }

  TimetableDaysCompanion copyWith({
    Value<int>? id,
    Value<String>? day,
    Value<bool>? isBreakDay,
  }) {
    return TimetableDaysCompanion(
      id: id ?? this.id,
      day: day ?? this.day,
      isBreakDay: isBreakDay ?? this.isBreakDay,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (day.present) {
      map['day'] = Variable<String>(day.value);
    }
    if (isBreakDay.present) {
      map['is_break_day'] = Variable<bool>(isBreakDay.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TimetableDaysCompanion(')
          ..write('id: $id, ')
          ..write('day: $day, ')
          ..write('isBreakDay: $isBreakDay')
          ..write(')'))
        .toString();
  }
}

class $TimetableSessionsTable extends TimetableSessions
    with TableInfo<$TimetableSessionsTable, TimetableSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TimetableSessionsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _dayIdMeta = const VerificationMeta('dayId');
  @override
  late final GeneratedColumn<int> dayId = GeneratedColumn<int>(
    'day_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES timetable_days (id)',
    ),
  );
  static const VerificationMeta _startMeta = const VerificationMeta('start');
  @override
  late final GeneratedColumn<String> start = GeneratedColumn<String>(
    'start',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endMeta = const VerificationMeta('end');
  @override
  late final GeneratedColumn<String> end = GeneratedColumn<String>(
    'end',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subjectsMeta = const VerificationMeta(
    'subjects',
  );
  @override
  late final GeneratedColumn<String> subjects = GeneratedColumn<String>(
    'subjects',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, dayId, start, end, subjects];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'timetable_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<TimetableSession> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('day_id')) {
      context.handle(
        _dayIdMeta,
        dayId.isAcceptableOrUnknown(data['day_id']!, _dayIdMeta),
      );
    } else if (isInserting) {
      context.missing(_dayIdMeta);
    }
    if (data.containsKey('start')) {
      context.handle(
        _startMeta,
        start.isAcceptableOrUnknown(data['start']!, _startMeta),
      );
    } else if (isInserting) {
      context.missing(_startMeta);
    }
    if (data.containsKey('end')) {
      context.handle(
        _endMeta,
        end.isAcceptableOrUnknown(data['end']!, _endMeta),
      );
    } else if (isInserting) {
      context.missing(_endMeta);
    }
    if (data.containsKey('subjects')) {
      context.handle(
        _subjectsMeta,
        subjects.isAcceptableOrUnknown(data['subjects']!, _subjectsMeta),
      );
    } else if (isInserting) {
      context.missing(_subjectsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TimetableSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TimetableSession(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      dayId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}day_id'],
      )!,
      start: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}start'],
      )!,
      end: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}end'],
      )!,
      subjects: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subjects'],
      )!,
    );
  }

  @override
  $TimetableSessionsTable createAlias(String alias) {
    return $TimetableSessionsTable(attachedDatabase, alias);
  }
}

class TimetableSession extends DataClass
    implements Insertable<TimetableSession> {
  final int id;
  final int dayId;
  final String start;
  final String end;
  final String subjects;
  const TimetableSession({
    required this.id,
    required this.dayId,
    required this.start,
    required this.end,
    required this.subjects,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['day_id'] = Variable<int>(dayId);
    map['start'] = Variable<String>(start);
    map['end'] = Variable<String>(end);
    map['subjects'] = Variable<String>(subjects);
    return map;
  }

  TimetableSessionsCompanion toCompanion(bool nullToAbsent) {
    return TimetableSessionsCompanion(
      id: Value(id),
      dayId: Value(dayId),
      start: Value(start),
      end: Value(end),
      subjects: Value(subjects),
    );
  }

  factory TimetableSession.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TimetableSession(
      id: serializer.fromJson<int>(json['id']),
      dayId: serializer.fromJson<int>(json['dayId']),
      start: serializer.fromJson<String>(json['start']),
      end: serializer.fromJson<String>(json['end']),
      subjects: serializer.fromJson<String>(json['subjects']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'dayId': serializer.toJson<int>(dayId),
      'start': serializer.toJson<String>(start),
      'end': serializer.toJson<String>(end),
      'subjects': serializer.toJson<String>(subjects),
    };
  }

  TimetableSession copyWith({
    int? id,
    int? dayId,
    String? start,
    String? end,
    String? subjects,
  }) => TimetableSession(
    id: id ?? this.id,
    dayId: dayId ?? this.dayId,
    start: start ?? this.start,
    end: end ?? this.end,
    subjects: subjects ?? this.subjects,
  );
  TimetableSession copyWithCompanion(TimetableSessionsCompanion data) {
    return TimetableSession(
      id: data.id.present ? data.id.value : this.id,
      dayId: data.dayId.present ? data.dayId.value : this.dayId,
      start: data.start.present ? data.start.value : this.start,
      end: data.end.present ? data.end.value : this.end,
      subjects: data.subjects.present ? data.subjects.value : this.subjects,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TimetableSession(')
          ..write('id: $id, ')
          ..write('dayId: $dayId, ')
          ..write('start: $start, ')
          ..write('end: $end, ')
          ..write('subjects: $subjects')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, dayId, start, end, subjects);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TimetableSession &&
          other.id == this.id &&
          other.dayId == this.dayId &&
          other.start == this.start &&
          other.end == this.end &&
          other.subjects == this.subjects);
}

class TimetableSessionsCompanion extends UpdateCompanion<TimetableSession> {
  final Value<int> id;
  final Value<int> dayId;
  final Value<String> start;
  final Value<String> end;
  final Value<String> subjects;
  const TimetableSessionsCompanion({
    this.id = const Value.absent(),
    this.dayId = const Value.absent(),
    this.start = const Value.absent(),
    this.end = const Value.absent(),
    this.subjects = const Value.absent(),
  });
  TimetableSessionsCompanion.insert({
    this.id = const Value.absent(),
    required int dayId,
    required String start,
    required String end,
    required String subjects,
  }) : dayId = Value(dayId),
       start = Value(start),
       end = Value(end),
       subjects = Value(subjects);
  static Insertable<TimetableSession> custom({
    Expression<int>? id,
    Expression<int>? dayId,
    Expression<String>? start,
    Expression<String>? end,
    Expression<String>? subjects,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (dayId != null) 'day_id': dayId,
      if (start != null) 'start': start,
      if (end != null) 'end': end,
      if (subjects != null) 'subjects': subjects,
    });
  }

  TimetableSessionsCompanion copyWith({
    Value<int>? id,
    Value<int>? dayId,
    Value<String>? start,
    Value<String>? end,
    Value<String>? subjects,
  }) {
    return TimetableSessionsCompanion(
      id: id ?? this.id,
      dayId: dayId ?? this.dayId,
      start: start ?? this.start,
      end: end ?? this.end,
      subjects: subjects ?? this.subjects,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (dayId.present) {
      map['day_id'] = Variable<int>(dayId.value);
    }
    if (start.present) {
      map['start'] = Variable<String>(start.value);
    }
    if (end.present) {
      map['end'] = Variable<String>(end.value);
    }
    if (subjects.present) {
      map['subjects'] = Variable<String>(subjects.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TimetableSessionsCompanion(')
          ..write('id: $id, ')
          ..write('dayId: $dayId, ')
          ..write('start: $start, ')
          ..write('end: $end, ')
          ..write('subjects: $subjects')
          ..write(')'))
        .toString();
  }
}

class $TargetSubjectsTable extends TargetSubjects
    with TableInfo<$TargetSubjectsTable, TargetSubject> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TargetSubjectsTable(this.attachedDatabase, [this._alias]);
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
  @override
  List<GeneratedColumn> get $columns => [id, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'target_subjects';
  @override
  VerificationContext validateIntegrity(
    Insertable<TargetSubject> instance, {
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TargetSubject map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TargetSubject(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
    );
  }

  @override
  $TargetSubjectsTable createAlias(String alias) {
    return $TargetSubjectsTable(attachedDatabase, alias);
  }
}

class TargetSubject extends DataClass implements Insertable<TargetSubject> {
  final int id;
  final String name;
  const TargetSubject({required this.id, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    return map;
  }

  TargetSubjectsCompanion toCompanion(bool nullToAbsent) {
    return TargetSubjectsCompanion(id: Value(id), name: Value(name));
  }

  factory TargetSubject.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TargetSubject(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
    };
  }

  TargetSubject copyWith({int? id, String? name}) =>
      TargetSubject(id: id ?? this.id, name: name ?? this.name);
  TargetSubject copyWithCompanion(TargetSubjectsCompanion data) {
    return TargetSubject(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TargetSubject(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TargetSubject &&
          other.id == this.id &&
          other.name == this.name);
}

class TargetSubjectsCompanion extends UpdateCompanion<TargetSubject> {
  final Value<int> id;
  final Value<String> name;
  const TargetSubjectsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
  });
  TargetSubjectsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
  }) : name = Value(name);
  static Insertable<TargetSubject> custom({
    Expression<int>? id,
    Expression<String>? name,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
    });
  }

  TargetSubjectsCompanion copyWith({Value<int>? id, Value<String>? name}) {
    return TargetSubjectsCompanion(id: id ?? this.id, name: name ?? this.name);
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
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TargetSubjectsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }
}

class $TargetTopicsTable extends TargetTopics
    with TableInfo<$TargetTopicsTable, TargetTopic> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TargetTopicsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _isCompletedMeta = const VerificationMeta(
    'isCompleted',
  );
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
    'is_completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_completed" IN (0, 1))',
    ),
  );
  static const VerificationMeta _subjectIdMeta = const VerificationMeta(
    'subjectId',
  );
  @override
  late final GeneratedColumn<int> subjectId = GeneratedColumn<int>(
    'subject_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES target_subjects (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, isCompleted, subjectId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'target_topics';
  @override
  VerificationContext validateIntegrity(
    Insertable<TargetTopic> instance, {
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
    if (data.containsKey('is_completed')) {
      context.handle(
        _isCompletedMeta,
        isCompleted.isAcceptableOrUnknown(
          data['is_completed']!,
          _isCompletedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_isCompletedMeta);
    }
    if (data.containsKey('subject_id')) {
      context.handle(
        _subjectIdMeta,
        subjectId.isAcceptableOrUnknown(data['subject_id']!, _subjectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_subjectIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TargetTopic map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TargetTopic(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      isCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_completed'],
      )!,
      subjectId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}subject_id'],
      )!,
    );
  }

  @override
  $TargetTopicsTable createAlias(String alias) {
    return $TargetTopicsTable(attachedDatabase, alias);
  }
}

class TargetTopic extends DataClass implements Insertable<TargetTopic> {
  final int id;
  final String name;
  final bool isCompleted;
  final int subjectId;
  const TargetTopic({
    required this.id,
    required this.name,
    required this.isCompleted,
    required this.subjectId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['is_completed'] = Variable<bool>(isCompleted);
    map['subject_id'] = Variable<int>(subjectId);
    return map;
  }

  TargetTopicsCompanion toCompanion(bool nullToAbsent) {
    return TargetTopicsCompanion(
      id: Value(id),
      name: Value(name),
      isCompleted: Value(isCompleted),
      subjectId: Value(subjectId),
    );
  }

  factory TargetTopic.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TargetTopic(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      subjectId: serializer.fromJson<int>(json['subjectId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'subjectId': serializer.toJson<int>(subjectId),
    };
  }

  TargetTopic copyWith({
    int? id,
    String? name,
    bool? isCompleted,
    int? subjectId,
  }) => TargetTopic(
    id: id ?? this.id,
    name: name ?? this.name,
    isCompleted: isCompleted ?? this.isCompleted,
    subjectId: subjectId ?? this.subjectId,
  );
  TargetTopic copyWithCompanion(TargetTopicsCompanion data) {
    return TargetTopic(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      isCompleted: data.isCompleted.present
          ? data.isCompleted.value
          : this.isCompleted,
      subjectId: data.subjectId.present ? data.subjectId.value : this.subjectId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TargetTopic(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('subjectId: $subjectId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, isCompleted, subjectId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TargetTopic &&
          other.id == this.id &&
          other.name == this.name &&
          other.isCompleted == this.isCompleted &&
          other.subjectId == this.subjectId);
}

class TargetTopicsCompanion extends UpdateCompanion<TargetTopic> {
  final Value<int> id;
  final Value<String> name;
  final Value<bool> isCompleted;
  final Value<int> subjectId;
  const TargetTopicsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.subjectId = const Value.absent(),
  });
  TargetTopicsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required bool isCompleted,
    required int subjectId,
  }) : name = Value(name),
       isCompleted = Value(isCompleted),
       subjectId = Value(subjectId);
  static Insertable<TargetTopic> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<bool>? isCompleted,
    Expression<int>? subjectId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (subjectId != null) 'subject_id': subjectId,
    });
  }

  TargetTopicsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<bool>? isCompleted,
    Value<int>? subjectId,
  }) {
    return TargetTopicsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      isCompleted: isCompleted ?? this.isCompleted,
      subjectId: subjectId ?? this.subjectId,
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
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (subjectId.present) {
      map['subject_id'] = Variable<int>(subjectId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TargetTopicsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('subjectId: $subjectId')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CollectionsTable collections = $CollectionsTable(this);
  late final $BooksTable books = $BooksTable(this);
  late final $TimetableDaysTable timetableDays = $TimetableDaysTable(this);
  late final $TimetableSessionsTable timetableSessions =
      $TimetableSessionsTable(this);
  late final $TargetSubjectsTable targetSubjects = $TargetSubjectsTable(this);
  late final $TargetTopicsTable targetTopics = $TargetTopicsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    collections,
    books,
    timetableDays,
    timetableSessions,
    targetSubjects,
    targetTopics,
  ];
}

typedef $$CollectionsTableCreateCompanionBuilder =
    CollectionsCompanion Function({Value<int> id, required String name});
typedef $$CollectionsTableUpdateCompanionBuilder =
    CollectionsCompanion Function({Value<int> id, Value<String> name});

final class $$CollectionsTableReferences
    extends BaseReferences<_$AppDatabase, $CollectionsTable, Collection> {
  $$CollectionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$BooksTable, List<Book>> _booksRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.books,
    aliasName: $_aliasNameGenerator(db.collections.id, db.books.collection),
  );

  $$BooksTableProcessedTableManager get booksRefs {
    final manager = $$BooksTableTableManager(
      $_db,
      $_db.books,
    ).filter((f) => f.collection.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_booksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CollectionsTableFilterComposer
    extends Composer<_$AppDatabase, $CollectionsTable> {
  $$CollectionsTableFilterComposer({
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

  Expression<bool> booksRefs(
    Expression<bool> Function($$BooksTableFilterComposer f) f,
  ) {
    final $$BooksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.collection,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableFilterComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CollectionsTableOrderingComposer
    extends Composer<_$AppDatabase, $CollectionsTable> {
  $$CollectionsTableOrderingComposer({
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
}

class $$CollectionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CollectionsTable> {
  $$CollectionsTableAnnotationComposer({
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

  Expression<T> booksRefs<T extends Object>(
    Expression<T> Function($$BooksTableAnnotationComposer a) f,
  ) {
    final $$BooksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.collection,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableAnnotationComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CollectionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CollectionsTable,
          Collection,
          $$CollectionsTableFilterComposer,
          $$CollectionsTableOrderingComposer,
          $$CollectionsTableAnnotationComposer,
          $$CollectionsTableCreateCompanionBuilder,
          $$CollectionsTableUpdateCompanionBuilder,
          (Collection, $$CollectionsTableReferences),
          Collection,
          PrefetchHooks Function({bool booksRefs})
        > {
  $$CollectionsTableTableManager(_$AppDatabase db, $CollectionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CollectionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CollectionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CollectionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
              }) => CollectionsCompanion(id: id, name: name),
          createCompanionCallback:
              ({Value<int> id = const Value.absent(), required String name}) =>
                  CollectionsCompanion.insert(id: id, name: name),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CollectionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({booksRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (booksRefs) db.books],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (booksRefs)
                    await $_getPrefetchedData<
                      Collection,
                      $CollectionsTable,
                      Book
                    >(
                      currentTable: table,
                      referencedTable: $$CollectionsTableReferences
                          ._booksRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$CollectionsTableReferences(db, table, p0).booksRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.collection == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$CollectionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CollectionsTable,
      Collection,
      $$CollectionsTableFilterComposer,
      $$CollectionsTableOrderingComposer,
      $$CollectionsTableAnnotationComposer,
      $$CollectionsTableCreateCompanionBuilder,
      $$CollectionsTableUpdateCompanionBuilder,
      (Collection, $$CollectionsTableReferences),
      Collection,
      PrefetchHooks Function({bool booksRefs})
    >;
typedef $$BooksTableCreateCompanionBuilder =
    BooksCompanion Function({
      Value<int> id,
      required String name,
      required String path,
      Value<String?> cfi,
      required String extension,
      Value<int?> page,
      Value<double> progress,
      Value<int?> collection,
    });
typedef $$BooksTableUpdateCompanionBuilder =
    BooksCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> path,
      Value<String?> cfi,
      Value<String> extension,
      Value<int?> page,
      Value<double> progress,
      Value<int?> collection,
    });

final class $$BooksTableReferences
    extends BaseReferences<_$AppDatabase, $BooksTable, Book> {
  $$BooksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CollectionsTable _collectionTable(_$AppDatabase db) =>
      db.collections.createAlias(
        $_aliasNameGenerator(db.books.collection, db.collections.id),
      );

  $$CollectionsTableProcessedTableManager? get collection {
    final $_column = $_itemColumn<int>('collection');
    if ($_column == null) return null;
    final manager = $$CollectionsTableTableManager(
      $_db,
      $_db.collections,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_collectionTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$BooksTableFilterComposer extends Composer<_$AppDatabase, $BooksTable> {
  $$BooksTableFilterComposer({
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

  ColumnFilters<double> get progress => $composableBuilder(
    column: $table.progress,
    builder: (column) => ColumnFilters(column),
  );

  $$CollectionsTableFilterComposer get collection {
    final $$CollectionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.collection,
      referencedTable: $db.collections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CollectionsTableFilterComposer(
            $db: $db,
            $table: $db.collections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BooksTableOrderingComposer
    extends Composer<_$AppDatabase, $BooksTable> {
  $$BooksTableOrderingComposer({
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

  ColumnOrderings<double> get progress => $composableBuilder(
    column: $table.progress,
    builder: (column) => ColumnOrderings(column),
  );

  $$CollectionsTableOrderingComposer get collection {
    final $$CollectionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.collection,
      referencedTable: $db.collections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CollectionsTableOrderingComposer(
            $db: $db,
            $table: $db.collections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BooksTableAnnotationComposer
    extends Composer<_$AppDatabase, $BooksTable> {
  $$BooksTableAnnotationComposer({
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

  GeneratedColumn<double> get progress =>
      $composableBuilder(column: $table.progress, builder: (column) => column);

  $$CollectionsTableAnnotationComposer get collection {
    final $$CollectionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.collection,
      referencedTable: $db.collections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CollectionsTableAnnotationComposer(
            $db: $db,
            $table: $db.collections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BooksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BooksTable,
          Book,
          $$BooksTableFilterComposer,
          $$BooksTableOrderingComposer,
          $$BooksTableAnnotationComposer,
          $$BooksTableCreateCompanionBuilder,
          $$BooksTableUpdateCompanionBuilder,
          (Book, $$BooksTableReferences),
          Book,
          PrefetchHooks Function({bool collection})
        > {
  $$BooksTableTableManager(_$AppDatabase db, $BooksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BooksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BooksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BooksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> path = const Value.absent(),
                Value<String?> cfi = const Value.absent(),
                Value<String> extension = const Value.absent(),
                Value<int?> page = const Value.absent(),
                Value<double> progress = const Value.absent(),
                Value<int?> collection = const Value.absent(),
              }) => BooksCompanion(
                id: id,
                name: name,
                path: path,
                cfi: cfi,
                extension: extension,
                page: page,
                progress: progress,
                collection: collection,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String path,
                Value<String?> cfi = const Value.absent(),
                required String extension,
                Value<int?> page = const Value.absent(),
                Value<double> progress = const Value.absent(),
                Value<int?> collection = const Value.absent(),
              }) => BooksCompanion.insert(
                id: id,
                name: name,
                path: path,
                cfi: cfi,
                extension: extension,
                page: page,
                progress: progress,
                collection: collection,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$BooksTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({collection = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (collection) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.collection,
                                referencedTable: $$BooksTableReferences
                                    ._collectionTable(db),
                                referencedColumn: $$BooksTableReferences
                                    ._collectionTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$BooksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BooksTable,
      Book,
      $$BooksTableFilterComposer,
      $$BooksTableOrderingComposer,
      $$BooksTableAnnotationComposer,
      $$BooksTableCreateCompanionBuilder,
      $$BooksTableUpdateCompanionBuilder,
      (Book, $$BooksTableReferences),
      Book,
      PrefetchHooks Function({bool collection})
    >;
typedef $$TimetableDaysTableCreateCompanionBuilder =
    TimetableDaysCompanion Function({
      Value<int> id,
      required String day,
      Value<bool> isBreakDay,
    });
typedef $$TimetableDaysTableUpdateCompanionBuilder =
    TimetableDaysCompanion Function({
      Value<int> id,
      Value<String> day,
      Value<bool> isBreakDay,
    });

final class $$TimetableDaysTableReferences
    extends BaseReferences<_$AppDatabase, $TimetableDaysTable, TimetableDay> {
  $$TimetableDaysTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$TimetableSessionsTable, List<TimetableSession>>
  _timetableSessionsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.timetableSessions,
        aliasName: $_aliasNameGenerator(
          db.timetableDays.id,
          db.timetableSessions.dayId,
        ),
      );

  $$TimetableSessionsTableProcessedTableManager get timetableSessionsRefs {
    final manager = $$TimetableSessionsTableTableManager(
      $_db,
      $_db.timetableSessions,
    ).filter((f) => f.dayId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _timetableSessionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TimetableDaysTableFilterComposer
    extends Composer<_$AppDatabase, $TimetableDaysTable> {
  $$TimetableDaysTableFilterComposer({
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

  ColumnFilters<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isBreakDay => $composableBuilder(
    column: $table.isBreakDay,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> timetableSessionsRefs(
    Expression<bool> Function($$TimetableSessionsTableFilterComposer f) f,
  ) {
    final $$TimetableSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.timetableSessions,
      getReferencedColumn: (t) => t.dayId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TimetableSessionsTableFilterComposer(
            $db: $db,
            $table: $db.timetableSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TimetableDaysTableOrderingComposer
    extends Composer<_$AppDatabase, $TimetableDaysTable> {
  $$TimetableDaysTableOrderingComposer({
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

  ColumnOrderings<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isBreakDay => $composableBuilder(
    column: $table.isBreakDay,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TimetableDaysTableAnnotationComposer
    extends Composer<_$AppDatabase, $TimetableDaysTable> {
  $$TimetableDaysTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<bool> get isBreakDay => $composableBuilder(
    column: $table.isBreakDay,
    builder: (column) => column,
  );

  Expression<T> timetableSessionsRefs<T extends Object>(
    Expression<T> Function($$TimetableSessionsTableAnnotationComposer a) f,
  ) {
    final $$TimetableSessionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.timetableSessions,
          getReferencedColumn: (t) => t.dayId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TimetableSessionsTableAnnotationComposer(
                $db: $db,
                $table: $db.timetableSessions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$TimetableDaysTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TimetableDaysTable,
          TimetableDay,
          $$TimetableDaysTableFilterComposer,
          $$TimetableDaysTableOrderingComposer,
          $$TimetableDaysTableAnnotationComposer,
          $$TimetableDaysTableCreateCompanionBuilder,
          $$TimetableDaysTableUpdateCompanionBuilder,
          (TimetableDay, $$TimetableDaysTableReferences),
          TimetableDay,
          PrefetchHooks Function({bool timetableSessionsRefs})
        > {
  $$TimetableDaysTableTableManager(_$AppDatabase db, $TimetableDaysTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TimetableDaysTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TimetableDaysTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TimetableDaysTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> day = const Value.absent(),
                Value<bool> isBreakDay = const Value.absent(),
              }) => TimetableDaysCompanion(
                id: id,
                day: day,
                isBreakDay: isBreakDay,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String day,
                Value<bool> isBreakDay = const Value.absent(),
              }) => TimetableDaysCompanion.insert(
                id: id,
                day: day,
                isBreakDay: isBreakDay,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TimetableDaysTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({timetableSessionsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (timetableSessionsRefs) db.timetableSessions,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (timetableSessionsRefs)
                    await $_getPrefetchedData<
                      TimetableDay,
                      $TimetableDaysTable,
                      TimetableSession
                    >(
                      currentTable: table,
                      referencedTable: $$TimetableDaysTableReferences
                          ._timetableSessionsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$TimetableDaysTableReferences(
                            db,
                            table,
                            p0,
                          ).timetableSessionsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.dayId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$TimetableDaysTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TimetableDaysTable,
      TimetableDay,
      $$TimetableDaysTableFilterComposer,
      $$TimetableDaysTableOrderingComposer,
      $$TimetableDaysTableAnnotationComposer,
      $$TimetableDaysTableCreateCompanionBuilder,
      $$TimetableDaysTableUpdateCompanionBuilder,
      (TimetableDay, $$TimetableDaysTableReferences),
      TimetableDay,
      PrefetchHooks Function({bool timetableSessionsRefs})
    >;
typedef $$TimetableSessionsTableCreateCompanionBuilder =
    TimetableSessionsCompanion Function({
      Value<int> id,
      required int dayId,
      required String start,
      required String end,
      required String subjects,
    });
typedef $$TimetableSessionsTableUpdateCompanionBuilder =
    TimetableSessionsCompanion Function({
      Value<int> id,
      Value<int> dayId,
      Value<String> start,
      Value<String> end,
      Value<String> subjects,
    });

final class $$TimetableSessionsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $TimetableSessionsTable,
          TimetableSession
        > {
  $$TimetableSessionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TimetableDaysTable _dayIdTable(_$AppDatabase db) =>
      db.timetableDays.createAlias(
        $_aliasNameGenerator(db.timetableSessions.dayId, db.timetableDays.id),
      );

  $$TimetableDaysTableProcessedTableManager get dayId {
    final $_column = $_itemColumn<int>('day_id')!;

    final manager = $$TimetableDaysTableTableManager(
      $_db,
      $_db.timetableDays,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_dayIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TimetableSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $TimetableSessionsTable> {
  $$TimetableSessionsTableFilterComposer({
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

  ColumnFilters<String> get start => $composableBuilder(
    column: $table.start,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get end => $composableBuilder(
    column: $table.end,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subjects => $composableBuilder(
    column: $table.subjects,
    builder: (column) => ColumnFilters(column),
  );

  $$TimetableDaysTableFilterComposer get dayId {
    final $$TimetableDaysTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.dayId,
      referencedTable: $db.timetableDays,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TimetableDaysTableFilterComposer(
            $db: $db,
            $table: $db.timetableDays,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TimetableSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $TimetableSessionsTable> {
  $$TimetableSessionsTableOrderingComposer({
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

  ColumnOrderings<String> get start => $composableBuilder(
    column: $table.start,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get end => $composableBuilder(
    column: $table.end,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subjects => $composableBuilder(
    column: $table.subjects,
    builder: (column) => ColumnOrderings(column),
  );

  $$TimetableDaysTableOrderingComposer get dayId {
    final $$TimetableDaysTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.dayId,
      referencedTable: $db.timetableDays,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TimetableDaysTableOrderingComposer(
            $db: $db,
            $table: $db.timetableDays,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TimetableSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TimetableSessionsTable> {
  $$TimetableSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get start =>
      $composableBuilder(column: $table.start, builder: (column) => column);

  GeneratedColumn<String> get end =>
      $composableBuilder(column: $table.end, builder: (column) => column);

  GeneratedColumn<String> get subjects =>
      $composableBuilder(column: $table.subjects, builder: (column) => column);

  $$TimetableDaysTableAnnotationComposer get dayId {
    final $$TimetableDaysTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.dayId,
      referencedTable: $db.timetableDays,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TimetableDaysTableAnnotationComposer(
            $db: $db,
            $table: $db.timetableDays,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TimetableSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TimetableSessionsTable,
          TimetableSession,
          $$TimetableSessionsTableFilterComposer,
          $$TimetableSessionsTableOrderingComposer,
          $$TimetableSessionsTableAnnotationComposer,
          $$TimetableSessionsTableCreateCompanionBuilder,
          $$TimetableSessionsTableUpdateCompanionBuilder,
          (TimetableSession, $$TimetableSessionsTableReferences),
          TimetableSession,
          PrefetchHooks Function({bool dayId})
        > {
  $$TimetableSessionsTableTableManager(
    _$AppDatabase db,
    $TimetableSessionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TimetableSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TimetableSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TimetableSessionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> dayId = const Value.absent(),
                Value<String> start = const Value.absent(),
                Value<String> end = const Value.absent(),
                Value<String> subjects = const Value.absent(),
              }) => TimetableSessionsCompanion(
                id: id,
                dayId: dayId,
                start: start,
                end: end,
                subjects: subjects,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int dayId,
                required String start,
                required String end,
                required String subjects,
              }) => TimetableSessionsCompanion.insert(
                id: id,
                dayId: dayId,
                start: start,
                end: end,
                subjects: subjects,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TimetableSessionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({dayId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (dayId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.dayId,
                                referencedTable:
                                    $$TimetableSessionsTableReferences
                                        ._dayIdTable(db),
                                referencedColumn:
                                    $$TimetableSessionsTableReferences
                                        ._dayIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TimetableSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TimetableSessionsTable,
      TimetableSession,
      $$TimetableSessionsTableFilterComposer,
      $$TimetableSessionsTableOrderingComposer,
      $$TimetableSessionsTableAnnotationComposer,
      $$TimetableSessionsTableCreateCompanionBuilder,
      $$TimetableSessionsTableUpdateCompanionBuilder,
      (TimetableSession, $$TimetableSessionsTableReferences),
      TimetableSession,
      PrefetchHooks Function({bool dayId})
    >;
typedef $$TargetSubjectsTableCreateCompanionBuilder =
    TargetSubjectsCompanion Function({Value<int> id, required String name});
typedef $$TargetSubjectsTableUpdateCompanionBuilder =
    TargetSubjectsCompanion Function({Value<int> id, Value<String> name});

final class $$TargetSubjectsTableReferences
    extends BaseReferences<_$AppDatabase, $TargetSubjectsTable, TargetSubject> {
  $$TargetSubjectsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$TargetTopicsTable, List<TargetTopic>>
  _targetTopicsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.targetTopics,
    aliasName: $_aliasNameGenerator(
      db.targetSubjects.id,
      db.targetTopics.subjectId,
    ),
  );

  $$TargetTopicsTableProcessedTableManager get targetTopicsRefs {
    final manager = $$TargetTopicsTableTableManager(
      $_db,
      $_db.targetTopics,
    ).filter((f) => f.subjectId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_targetTopicsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TargetSubjectsTableFilterComposer
    extends Composer<_$AppDatabase, $TargetSubjectsTable> {
  $$TargetSubjectsTableFilterComposer({
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

  Expression<bool> targetTopicsRefs(
    Expression<bool> Function($$TargetTopicsTableFilterComposer f) f,
  ) {
    final $$TargetTopicsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.targetTopics,
      getReferencedColumn: (t) => t.subjectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TargetTopicsTableFilterComposer(
            $db: $db,
            $table: $db.targetTopics,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TargetSubjectsTableOrderingComposer
    extends Composer<_$AppDatabase, $TargetSubjectsTable> {
  $$TargetSubjectsTableOrderingComposer({
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
}

class $$TargetSubjectsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TargetSubjectsTable> {
  $$TargetSubjectsTableAnnotationComposer({
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

  Expression<T> targetTopicsRefs<T extends Object>(
    Expression<T> Function($$TargetTopicsTableAnnotationComposer a) f,
  ) {
    final $$TargetTopicsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.targetTopics,
      getReferencedColumn: (t) => t.subjectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TargetTopicsTableAnnotationComposer(
            $db: $db,
            $table: $db.targetTopics,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TargetSubjectsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TargetSubjectsTable,
          TargetSubject,
          $$TargetSubjectsTableFilterComposer,
          $$TargetSubjectsTableOrderingComposer,
          $$TargetSubjectsTableAnnotationComposer,
          $$TargetSubjectsTableCreateCompanionBuilder,
          $$TargetSubjectsTableUpdateCompanionBuilder,
          (TargetSubject, $$TargetSubjectsTableReferences),
          TargetSubject,
          PrefetchHooks Function({bool targetTopicsRefs})
        > {
  $$TargetSubjectsTableTableManager(
    _$AppDatabase db,
    $TargetSubjectsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TargetSubjectsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TargetSubjectsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TargetSubjectsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
              }) => TargetSubjectsCompanion(id: id, name: name),
          createCompanionCallback:
              ({Value<int> id = const Value.absent(), required String name}) =>
                  TargetSubjectsCompanion.insert(id: id, name: name),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TargetSubjectsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({targetTopicsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (targetTopicsRefs) db.targetTopics],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (targetTopicsRefs)
                    await $_getPrefetchedData<
                      TargetSubject,
                      $TargetSubjectsTable,
                      TargetTopic
                    >(
                      currentTable: table,
                      referencedTable: $$TargetSubjectsTableReferences
                          ._targetTopicsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$TargetSubjectsTableReferences(
                            db,
                            table,
                            p0,
                          ).targetTopicsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.subjectId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$TargetSubjectsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TargetSubjectsTable,
      TargetSubject,
      $$TargetSubjectsTableFilterComposer,
      $$TargetSubjectsTableOrderingComposer,
      $$TargetSubjectsTableAnnotationComposer,
      $$TargetSubjectsTableCreateCompanionBuilder,
      $$TargetSubjectsTableUpdateCompanionBuilder,
      (TargetSubject, $$TargetSubjectsTableReferences),
      TargetSubject,
      PrefetchHooks Function({bool targetTopicsRefs})
    >;
typedef $$TargetTopicsTableCreateCompanionBuilder =
    TargetTopicsCompanion Function({
      Value<int> id,
      required String name,
      required bool isCompleted,
      required int subjectId,
    });
typedef $$TargetTopicsTableUpdateCompanionBuilder =
    TargetTopicsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<bool> isCompleted,
      Value<int> subjectId,
    });

final class $$TargetTopicsTableReferences
    extends BaseReferences<_$AppDatabase, $TargetTopicsTable, TargetTopic> {
  $$TargetTopicsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TargetSubjectsTable _subjectIdTable(_$AppDatabase db) =>
      db.targetSubjects.createAlias(
        $_aliasNameGenerator(db.targetTopics.subjectId, db.targetSubjects.id),
      );

  $$TargetSubjectsTableProcessedTableManager get subjectId {
    final $_column = $_itemColumn<int>('subject_id')!;

    final manager = $$TargetSubjectsTableTableManager(
      $_db,
      $_db.targetSubjects,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_subjectIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TargetTopicsTableFilterComposer
    extends Composer<_$AppDatabase, $TargetTopicsTable> {
  $$TargetTopicsTableFilterComposer({
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

  ColumnFilters<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnFilters(column),
  );

  $$TargetSubjectsTableFilterComposer get subjectId {
    final $$TargetSubjectsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.subjectId,
      referencedTable: $db.targetSubjects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TargetSubjectsTableFilterComposer(
            $db: $db,
            $table: $db.targetSubjects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TargetTopicsTableOrderingComposer
    extends Composer<_$AppDatabase, $TargetTopicsTable> {
  $$TargetTopicsTableOrderingComposer({
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

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  $$TargetSubjectsTableOrderingComposer get subjectId {
    final $$TargetSubjectsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.subjectId,
      referencedTable: $db.targetSubjects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TargetSubjectsTableOrderingComposer(
            $db: $db,
            $table: $db.targetSubjects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TargetTopicsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TargetTopicsTable> {
  $$TargetTopicsTableAnnotationComposer({
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

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => column,
  );

  $$TargetSubjectsTableAnnotationComposer get subjectId {
    final $$TargetSubjectsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.subjectId,
      referencedTable: $db.targetSubjects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TargetSubjectsTableAnnotationComposer(
            $db: $db,
            $table: $db.targetSubjects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TargetTopicsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TargetTopicsTable,
          TargetTopic,
          $$TargetTopicsTableFilterComposer,
          $$TargetTopicsTableOrderingComposer,
          $$TargetTopicsTableAnnotationComposer,
          $$TargetTopicsTableCreateCompanionBuilder,
          $$TargetTopicsTableUpdateCompanionBuilder,
          (TargetTopic, $$TargetTopicsTableReferences),
          TargetTopic,
          PrefetchHooks Function({bool subjectId})
        > {
  $$TargetTopicsTableTableManager(_$AppDatabase db, $TargetTopicsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TargetTopicsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TargetTopicsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TargetTopicsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                Value<int> subjectId = const Value.absent(),
              }) => TargetTopicsCompanion(
                id: id,
                name: name,
                isCompleted: isCompleted,
                subjectId: subjectId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required bool isCompleted,
                required int subjectId,
              }) => TargetTopicsCompanion.insert(
                id: id,
                name: name,
                isCompleted: isCompleted,
                subjectId: subjectId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TargetTopicsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({subjectId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (subjectId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.subjectId,
                                referencedTable: $$TargetTopicsTableReferences
                                    ._subjectIdTable(db),
                                referencedColumn: $$TargetTopicsTableReferences
                                    ._subjectIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TargetTopicsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TargetTopicsTable,
      TargetTopic,
      $$TargetTopicsTableFilterComposer,
      $$TargetTopicsTableOrderingComposer,
      $$TargetTopicsTableAnnotationComposer,
      $$TargetTopicsTableCreateCompanionBuilder,
      $$TargetTopicsTableUpdateCompanionBuilder,
      (TargetTopic, $$TargetTopicsTableReferences),
      TargetTopic,
      PrefetchHooks Function({bool subjectId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CollectionsTableTableManager get collections =>
      $$CollectionsTableTableManager(_db, _db.collections);
  $$BooksTableTableManager get books =>
      $$BooksTableTableManager(_db, _db.books);
  $$TimetableDaysTableTableManager get timetableDays =>
      $$TimetableDaysTableTableManager(_db, _db.timetableDays);
  $$TimetableSessionsTableTableManager get timetableSessions =>
      $$TimetableSessionsTableTableManager(_db, _db.timetableSessions);
  $$TargetSubjectsTableTableManager get targetSubjects =>
      $$TargetSubjectsTableTableManager(_db, _db.targetSubjects);
  $$TargetTopicsTableTableManager get targetTopics =>
      $$TargetTopicsTableTableManager(_db, _db.targetTopics);
}
