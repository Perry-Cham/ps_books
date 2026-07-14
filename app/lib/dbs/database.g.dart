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
  static const VerificationMeta _isSavedCollectionMeta = const VerificationMeta(
    'isSavedCollection',
  );
  @override
  late final GeneratedColumn<bool> isSavedCollection = GeneratedColumn<bool>(
    'is_saved_collection',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_saved_collection" IN (0, 1))',
    ),
    defaultValue: Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, isSavedCollection];
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
    if (data.containsKey('is_saved_collection')) {
      context.handle(
        _isSavedCollectionMeta,
        isSavedCollection.isAcceptableOrUnknown(
          data['is_saved_collection']!,
          _isSavedCollectionMeta,
        ),
      );
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
      isSavedCollection: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_saved_collection'],
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
  final bool isSavedCollection;
  const Collection({
    required this.id,
    required this.name,
    required this.isSavedCollection,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['is_saved_collection'] = Variable<bool>(isSavedCollection);
    return map;
  }

  CollectionsCompanion toCompanion(bool nullToAbsent) {
    return CollectionsCompanion(
      id: Value(id),
      name: Value(name),
      isSavedCollection: Value(isSavedCollection),
    );
  }

  factory Collection.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Collection(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      isSavedCollection: serializer.fromJson<bool>(json['isSavedCollection']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'isSavedCollection': serializer.toJson<bool>(isSavedCollection),
    };
  }

  Collection copyWith({int? id, String? name, bool? isSavedCollection}) =>
      Collection(
        id: id ?? this.id,
        name: name ?? this.name,
        isSavedCollection: isSavedCollection ?? this.isSavedCollection,
      );
  Collection copyWithCompanion(CollectionsCompanion data) {
    return Collection(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      isSavedCollection: data.isSavedCollection.present
          ? data.isSavedCollection.value
          : this.isSavedCollection,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Collection(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('isSavedCollection: $isSavedCollection')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, isSavedCollection);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Collection &&
          other.id == this.id &&
          other.name == this.name &&
          other.isSavedCollection == this.isSavedCollection);
}

class CollectionsCompanion extends UpdateCompanion<Collection> {
  final Value<int> id;
  final Value<String> name;
  final Value<bool> isSavedCollection;
  const CollectionsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.isSavedCollection = const Value.absent(),
  });
  CollectionsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.isSavedCollection = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Collection> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<bool>? isSavedCollection,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (isSavedCollection != null) 'is_saved_collection': isSavedCollection,
    });
  }

  CollectionsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<bool>? isSavedCollection,
  }) {
    return CollectionsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      isSavedCollection: isSavedCollection ?? this.isSavedCollection,
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
    if (isSavedCollection.present) {
      map['is_saved_collection'] = Variable<bool>(isSavedCollection.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CollectionsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('isSavedCollection: $isSavedCollection')
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
  static const VerificationMeta _authorMeta = const VerificationMeta('author');
  @override
  late final GeneratedColumn<String> author = GeneratedColumn<String>(
    'author',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _lastReadMeta = const VerificationMeta(
    'lastRead',
  );
  @override
  late final GeneratedColumn<bool> lastRead = GeneratedColumn<bool>(
    'last_read',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("last_read" IN (0, 1))',
    ),
    defaultValue: Constant(false),
  );
  static const VerificationMeta _coverPathMeta = const VerificationMeta(
    'coverPath',
  );
  @override
  late final GeneratedColumn<String> coverPath = GeneratedColumn<String>(
    'cover_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    author,
    path,
    cfi,
    extension,
    page,
    progress,
    collection,
    lastRead,
    coverPath,
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
    if (data.containsKey('author')) {
      context.handle(
        _authorMeta,
        author.isAcceptableOrUnknown(data['author']!, _authorMeta),
      );
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
    if (data.containsKey('last_read')) {
      context.handle(
        _lastReadMeta,
        lastRead.isAcceptableOrUnknown(data['last_read']!, _lastReadMeta),
      );
    }
    if (data.containsKey('cover_path')) {
      context.handle(
        _coverPathMeta,
        coverPath.isAcceptableOrUnknown(data['cover_path']!, _coverPathMeta),
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
      author: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author'],
      ),
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
      lastRead: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}last_read'],
      )!,
      coverPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_path'],
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
  final String? author;
  final String path;
  final String? cfi;
  final String extension;
  final int? page;
  final double progress;
  final int? collection;
  final bool lastRead;
  final String? coverPath;
  const Book({
    required this.id,
    required this.name,
    this.author,
    required this.path,
    this.cfi,
    required this.extension,
    this.page,
    required this.progress,
    this.collection,
    required this.lastRead,
    this.coverPath,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || author != null) {
      map['author'] = Variable<String>(author);
    }
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
    map['last_read'] = Variable<bool>(lastRead);
    if (!nullToAbsent || coverPath != null) {
      map['cover_path'] = Variable<String>(coverPath);
    }
    return map;
  }

  BooksCompanion toCompanion(bool nullToAbsent) {
    return BooksCompanion(
      id: Value(id),
      name: Value(name),
      author: author == null && nullToAbsent
          ? const Value.absent()
          : Value(author),
      path: Value(path),
      cfi: cfi == null && nullToAbsent ? const Value.absent() : Value(cfi),
      extension: Value(extension),
      page: page == null && nullToAbsent ? const Value.absent() : Value(page),
      progress: Value(progress),
      collection: collection == null && nullToAbsent
          ? const Value.absent()
          : Value(collection),
      lastRead: Value(lastRead),
      coverPath: coverPath == null && nullToAbsent
          ? const Value.absent()
          : Value(coverPath),
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
      author: serializer.fromJson<String?>(json['author']),
      path: serializer.fromJson<String>(json['path']),
      cfi: serializer.fromJson<String?>(json['cfi']),
      extension: serializer.fromJson<String>(json['extension']),
      page: serializer.fromJson<int?>(json['page']),
      progress: serializer.fromJson<double>(json['progress']),
      collection: serializer.fromJson<int?>(json['collection']),
      lastRead: serializer.fromJson<bool>(json['lastRead']),
      coverPath: serializer.fromJson<String?>(json['coverPath']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'author': serializer.toJson<String?>(author),
      'path': serializer.toJson<String>(path),
      'cfi': serializer.toJson<String?>(cfi),
      'extension': serializer.toJson<String>(extension),
      'page': serializer.toJson<int?>(page),
      'progress': serializer.toJson<double>(progress),
      'collection': serializer.toJson<int?>(collection),
      'lastRead': serializer.toJson<bool>(lastRead),
      'coverPath': serializer.toJson<String?>(coverPath),
    };
  }

  Book copyWith({
    int? id,
    String? name,
    Value<String?> author = const Value.absent(),
    String? path,
    Value<String?> cfi = const Value.absent(),
    String? extension,
    Value<int?> page = const Value.absent(),
    double? progress,
    Value<int?> collection = const Value.absent(),
    bool? lastRead,
    Value<String?> coverPath = const Value.absent(),
  }) => Book(
    id: id ?? this.id,
    name: name ?? this.name,
    author: author.present ? author.value : this.author,
    path: path ?? this.path,
    cfi: cfi.present ? cfi.value : this.cfi,
    extension: extension ?? this.extension,
    page: page.present ? page.value : this.page,
    progress: progress ?? this.progress,
    collection: collection.present ? collection.value : this.collection,
    lastRead: lastRead ?? this.lastRead,
    coverPath: coverPath.present ? coverPath.value : this.coverPath,
  );
  Book copyWithCompanion(BooksCompanion data) {
    return Book(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      author: data.author.present ? data.author.value : this.author,
      path: data.path.present ? data.path.value : this.path,
      cfi: data.cfi.present ? data.cfi.value : this.cfi,
      extension: data.extension.present ? data.extension.value : this.extension,
      page: data.page.present ? data.page.value : this.page,
      progress: data.progress.present ? data.progress.value : this.progress,
      collection: data.collection.present
          ? data.collection.value
          : this.collection,
      lastRead: data.lastRead.present ? data.lastRead.value : this.lastRead,
      coverPath: data.coverPath.present ? data.coverPath.value : this.coverPath,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Book(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('author: $author, ')
          ..write('path: $path, ')
          ..write('cfi: $cfi, ')
          ..write('extension: $extension, ')
          ..write('page: $page, ')
          ..write('progress: $progress, ')
          ..write('collection: $collection, ')
          ..write('lastRead: $lastRead, ')
          ..write('coverPath: $coverPath')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    author,
    path,
    cfi,
    extension,
    page,
    progress,
    collection,
    lastRead,
    coverPath,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Book &&
          other.id == this.id &&
          other.name == this.name &&
          other.author == this.author &&
          other.path == this.path &&
          other.cfi == this.cfi &&
          other.extension == this.extension &&
          other.page == this.page &&
          other.progress == this.progress &&
          other.collection == this.collection &&
          other.lastRead == this.lastRead &&
          other.coverPath == this.coverPath);
}

class BooksCompanion extends UpdateCompanion<Book> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> author;
  final Value<String> path;
  final Value<String?> cfi;
  final Value<String> extension;
  final Value<int?> page;
  final Value<double> progress;
  final Value<int?> collection;
  final Value<bool> lastRead;
  final Value<String?> coverPath;
  const BooksCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.author = const Value.absent(),
    this.path = const Value.absent(),
    this.cfi = const Value.absent(),
    this.extension = const Value.absent(),
    this.page = const Value.absent(),
    this.progress = const Value.absent(),
    this.collection = const Value.absent(),
    this.lastRead = const Value.absent(),
    this.coverPath = const Value.absent(),
  });
  BooksCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.author = const Value.absent(),
    required String path,
    this.cfi = const Value.absent(),
    required String extension,
    this.page = const Value.absent(),
    this.progress = const Value.absent(),
    this.collection = const Value.absent(),
    this.lastRead = const Value.absent(),
    this.coverPath = const Value.absent(),
  }) : name = Value(name),
       path = Value(path),
       extension = Value(extension);
  static Insertable<Book> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? author,
    Expression<String>? path,
    Expression<String>? cfi,
    Expression<String>? extension,
    Expression<int>? page,
    Expression<double>? progress,
    Expression<int>? collection,
    Expression<bool>? lastRead,
    Expression<String>? coverPath,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (author != null) 'author': author,
      if (path != null) 'path': path,
      if (cfi != null) 'cfi': cfi,
      if (extension != null) 'extension': extension,
      if (page != null) 'page': page,
      if (progress != null) 'progress': progress,
      if (collection != null) 'collection': collection,
      if (lastRead != null) 'last_read': lastRead,
      if (coverPath != null) 'cover_path': coverPath,
    });
  }

  BooksCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? author,
    Value<String>? path,
    Value<String?>? cfi,
    Value<String>? extension,
    Value<int?>? page,
    Value<double>? progress,
    Value<int?>? collection,
    Value<bool>? lastRead,
    Value<String?>? coverPath,
  }) {
    return BooksCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      author: author ?? this.author,
      path: path ?? this.path,
      cfi: cfi ?? this.cfi,
      extension: extension ?? this.extension,
      page: page ?? this.page,
      progress: progress ?? this.progress,
      collection: collection ?? this.collection,
      lastRead: lastRead ?? this.lastRead,
      coverPath: coverPath ?? this.coverPath,
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
    if (author.present) {
      map['author'] = Variable<String>(author.value);
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
    if (lastRead.present) {
      map['last_read'] = Variable<bool>(lastRead.value);
    }
    if (coverPath.present) {
      map['cover_path'] = Variable<String>(coverPath.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BooksCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('author: $author, ')
          ..write('path: $path, ')
          ..write('cfi: $cfi, ')
          ..write('extension: $extension, ')
          ..write('page: $page, ')
          ..write('progress: $progress, ')
          ..write('collection: $collection, ')
          ..write('lastRead: $lastRead, ')
          ..write('coverPath: $coverPath')
          ..write(')'))
        .toString();
  }
}

class $TimetablesTable extends Timetables
    with TableInfo<$TimetablesTable, Timetable> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TimetablesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastModifiedMeta = const VerificationMeta(
    'lastModified',
  );
  @override
  late final GeneratedColumn<DateTime> lastModified = GeneratedColumn<DateTime>(
    'last_modified',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, version, lastModified];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'timetables';
  @override
  VerificationContext validateIntegrity(
    Insertable<Timetable> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    } else if (isInserting) {
      context.missing(_versionMeta);
    }
    if (data.containsKey('last_modified')) {
      context.handle(
        _lastModifiedMeta,
        lastModified.isAcceptableOrUnknown(
          data['last_modified']!,
          _lastModifiedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastModifiedMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Timetable map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Timetable(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      lastModified: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_modified'],
      )!,
    );
  }

  @override
  $TimetablesTable createAlias(String alias) {
    return $TimetablesTable(attachedDatabase, alias);
  }
}

class Timetable extends DataClass implements Insertable<Timetable> {
  final int id;
  final int version;
  final DateTime lastModified;
  const Timetable({
    required this.id,
    required this.version,
    required this.lastModified,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['version'] = Variable<int>(version);
    map['last_modified'] = Variable<DateTime>(lastModified);
    return map;
  }

  TimetablesCompanion toCompanion(bool nullToAbsent) {
    return TimetablesCompanion(
      id: Value(id),
      version: Value(version),
      lastModified: Value(lastModified),
    );
  }

  factory Timetable.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Timetable(
      id: serializer.fromJson<int>(json['id']),
      version: serializer.fromJson<int>(json['version']),
      lastModified: serializer.fromJson<DateTime>(json['lastModified']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'version': serializer.toJson<int>(version),
      'lastModified': serializer.toJson<DateTime>(lastModified),
    };
  }

  Timetable copyWith({int? id, int? version, DateTime? lastModified}) =>
      Timetable(
        id: id ?? this.id,
        version: version ?? this.version,
        lastModified: lastModified ?? this.lastModified,
      );
  Timetable copyWithCompanion(TimetablesCompanion data) {
    return Timetable(
      id: data.id.present ? data.id.value : this.id,
      version: data.version.present ? data.version.value : this.version,
      lastModified: data.lastModified.present
          ? data.lastModified.value
          : this.lastModified,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Timetable(')
          ..write('id: $id, ')
          ..write('version: $version, ')
          ..write('lastModified: $lastModified')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, version, lastModified);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Timetable &&
          other.id == this.id &&
          other.version == this.version &&
          other.lastModified == this.lastModified);
}

class TimetablesCompanion extends UpdateCompanion<Timetable> {
  final Value<int> id;
  final Value<int> version;
  final Value<DateTime> lastModified;
  const TimetablesCompanion({
    this.id = const Value.absent(),
    this.version = const Value.absent(),
    this.lastModified = const Value.absent(),
  });
  TimetablesCompanion.insert({
    this.id = const Value.absent(),
    required int version,
    required DateTime lastModified,
  }) : version = Value(version),
       lastModified = Value(lastModified);
  static Insertable<Timetable> custom({
    Expression<int>? id,
    Expression<int>? version,
    Expression<DateTime>? lastModified,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (version != null) 'version': version,
      if (lastModified != null) 'last_modified': lastModified,
    });
  }

  TimetablesCompanion copyWith({
    Value<int>? id,
    Value<int>? version,
    Value<DateTime>? lastModified,
  }) {
    return TimetablesCompanion(
      id: id ?? this.id,
      version: version ?? this.version,
      lastModified: lastModified ?? this.lastModified,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (lastModified.present) {
      map['last_modified'] = Variable<DateTime>(lastModified.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TimetablesCompanion(')
          ..write('id: $id, ')
          ..write('version: $version, ')
          ..write('lastModified: $lastModified')
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
  static const VerificationMeta _timetableIdMeta = const VerificationMeta(
    'timetableId',
  );
  @override
  late final GeneratedColumn<int> timetableId = GeneratedColumn<int>(
    'timetable_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES timetables (id)',
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
  List<GeneratedColumn> get $columns => [id, timetableId, day, isBreakDay];
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
    if (data.containsKey('timetable_id')) {
      context.handle(
        _timetableIdMeta,
        timetableId.isAcceptableOrUnknown(
          data['timetable_id']!,
          _timetableIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_timetableIdMeta);
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
      timetableId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}timetable_id'],
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
  final int timetableId;
  final String day;
  final bool isBreakDay;
  const TimetableDay({
    required this.id,
    required this.timetableId,
    required this.day,
    required this.isBreakDay,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['timetable_id'] = Variable<int>(timetableId);
    map['day'] = Variable<String>(day);
    map['is_break_day'] = Variable<bool>(isBreakDay);
    return map;
  }

  TimetableDaysCompanion toCompanion(bool nullToAbsent) {
    return TimetableDaysCompanion(
      id: Value(id),
      timetableId: Value(timetableId),
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
      timetableId: serializer.fromJson<int>(json['timetableId']),
      day: serializer.fromJson<String>(json['day']),
      isBreakDay: serializer.fromJson<bool>(json['isBreakDay']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'timetableId': serializer.toJson<int>(timetableId),
      'day': serializer.toJson<String>(day),
      'isBreakDay': serializer.toJson<bool>(isBreakDay),
    };
  }

  TimetableDay copyWith({
    int? id,
    int? timetableId,
    String? day,
    bool? isBreakDay,
  }) => TimetableDay(
    id: id ?? this.id,
    timetableId: timetableId ?? this.timetableId,
    day: day ?? this.day,
    isBreakDay: isBreakDay ?? this.isBreakDay,
  );
  TimetableDay copyWithCompanion(TimetableDaysCompanion data) {
    return TimetableDay(
      id: data.id.present ? data.id.value : this.id,
      timetableId: data.timetableId.present
          ? data.timetableId.value
          : this.timetableId,
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
          ..write('timetableId: $timetableId, ')
          ..write('day: $day, ')
          ..write('isBreakDay: $isBreakDay')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, timetableId, day, isBreakDay);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TimetableDay &&
          other.id == this.id &&
          other.timetableId == this.timetableId &&
          other.day == this.day &&
          other.isBreakDay == this.isBreakDay);
}

class TimetableDaysCompanion extends UpdateCompanion<TimetableDay> {
  final Value<int> id;
  final Value<int> timetableId;
  final Value<String> day;
  final Value<bool> isBreakDay;
  const TimetableDaysCompanion({
    this.id = const Value.absent(),
    this.timetableId = const Value.absent(),
    this.day = const Value.absent(),
    this.isBreakDay = const Value.absent(),
  });
  TimetableDaysCompanion.insert({
    this.id = const Value.absent(),
    required int timetableId,
    required String day,
    this.isBreakDay = const Value.absent(),
  }) : timetableId = Value(timetableId),
       day = Value(day);
  static Insertable<TimetableDay> custom({
    Expression<int>? id,
    Expression<int>? timetableId,
    Expression<String>? day,
    Expression<bool>? isBreakDay,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (timetableId != null) 'timetable_id': timetableId,
      if (day != null) 'day': day,
      if (isBreakDay != null) 'is_break_day': isBreakDay,
    });
  }

  TimetableDaysCompanion copyWith({
    Value<int>? id,
    Value<int>? timetableId,
    Value<String>? day,
    Value<bool>? isBreakDay,
  }) {
    return TimetableDaysCompanion(
      id: id ?? this.id,
      timetableId: timetableId ?? this.timetableId,
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
    if (timetableId.present) {
      map['timetable_id'] = Variable<int>(timetableId.value);
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
          ..write('timetableId: $timetableId, ')
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
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
    'uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
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
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
    'synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, uuid, name, syncedAt];
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
    if (data.containsKey('uuid')) {
      context.handle(
        _uuidMeta,
        uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta),
      );
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
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
      uuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uuid'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}synced_at'],
      ),
    );
  }

  @override
  $TargetSubjectsTable createAlias(String alias) {
    return $TargetSubjectsTable(attachedDatabase, alias);
  }
}

class TargetSubject extends DataClass implements Insertable<TargetSubject> {
  final int id;
  final String uuid;
  final String name;
  final DateTime? syncedAt;
  const TargetSubject({
    required this.id,
    required this.uuid,
    required this.name,
    this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['uuid'] = Variable<String>(uuid);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<DateTime>(syncedAt);
    }
    return map;
  }

  TargetSubjectsCompanion toCompanion(bool nullToAbsent) {
    return TargetSubjectsCompanion(
      id: Value(id),
      uuid: Value(uuid),
      name: Value(name),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
    );
  }

  factory TargetSubject.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TargetSubject(
      id: serializer.fromJson<int>(json['id']),
      uuid: serializer.fromJson<String>(json['uuid']),
      name: serializer.fromJson<String>(json['name']),
      syncedAt: serializer.fromJson<DateTime?>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'uuid': serializer.toJson<String>(uuid),
      'name': serializer.toJson<String>(name),
      'syncedAt': serializer.toJson<DateTime?>(syncedAt),
    };
  }

  TargetSubject copyWith({
    int? id,
    String? uuid,
    String? name,
    Value<DateTime?> syncedAt = const Value.absent(),
  }) => TargetSubject(
    id: id ?? this.id,
    uuid: uuid ?? this.uuid,
    name: name ?? this.name,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
  );
  TargetSubject copyWithCompanion(TargetSubjectsCompanion data) {
    return TargetSubject(
      id: data.id.present ? data.id.value : this.id,
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      name: data.name.present ? data.name.value : this.name,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TargetSubject(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('name: $name, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, uuid, name, syncedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TargetSubject &&
          other.id == this.id &&
          other.uuid == this.uuid &&
          other.name == this.name &&
          other.syncedAt == this.syncedAt);
}

class TargetSubjectsCompanion extends UpdateCompanion<TargetSubject> {
  final Value<int> id;
  final Value<String> uuid;
  final Value<String> name;
  final Value<DateTime?> syncedAt;
  const TargetSubjectsCompanion({
    this.id = const Value.absent(),
    this.uuid = const Value.absent(),
    this.name = const Value.absent(),
    this.syncedAt = const Value.absent(),
  });
  TargetSubjectsCompanion.insert({
    this.id = const Value.absent(),
    required String uuid,
    required String name,
    this.syncedAt = const Value.absent(),
  }) : uuid = Value(uuid),
       name = Value(name);
  static Insertable<TargetSubject> custom({
    Expression<int>? id,
    Expression<String>? uuid,
    Expression<String>? name,
    Expression<DateTime>? syncedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (uuid != null) 'uuid': uuid,
      if (name != null) 'name': name,
      if (syncedAt != null) 'synced_at': syncedAt,
    });
  }

  TargetSubjectsCompanion copyWith({
    Value<int>? id,
    Value<String>? uuid,
    Value<String>? name,
    Value<DateTime?>? syncedAt,
  }) {
    return TargetSubjectsCompanion(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      name: name ?? this.name,
      syncedAt: syncedAt ?? this.syncedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TargetSubjectsCompanion(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('name: $name, ')
          ..write('syncedAt: $syncedAt')
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
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
    'uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
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
  static const VerificationMeta _lastModifiedMeta = const VerificationMeta(
    'lastModified',
  );
  @override
  late final GeneratedColumn<DateTime> lastModified = GeneratedColumn<DateTime>(
    'last_modified',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
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
  List<GeneratedColumn> get $columns => [
    id,
    uuid,
    name,
    isCompleted,
    lastModified,
    subjectId,
  ];
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
    if (data.containsKey('uuid')) {
      context.handle(
        _uuidMeta,
        uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta),
      );
    } else if (isInserting) {
      context.missing(_uuidMeta);
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
    if (data.containsKey('last_modified')) {
      context.handle(
        _lastModifiedMeta,
        lastModified.isAcceptableOrUnknown(
          data['last_modified']!,
          _lastModifiedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastModifiedMeta);
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
      uuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uuid'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      isCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_completed'],
      )!,
      lastModified: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_modified'],
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
  final String uuid;
  final String name;
  final bool isCompleted;
  final DateTime lastModified;
  final int subjectId;
  const TargetTopic({
    required this.id,
    required this.uuid,
    required this.name,
    required this.isCompleted,
    required this.lastModified,
    required this.subjectId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['uuid'] = Variable<String>(uuid);
    map['name'] = Variable<String>(name);
    map['is_completed'] = Variable<bool>(isCompleted);
    map['last_modified'] = Variable<DateTime>(lastModified);
    map['subject_id'] = Variable<int>(subjectId);
    return map;
  }

  TargetTopicsCompanion toCompanion(bool nullToAbsent) {
    return TargetTopicsCompanion(
      id: Value(id),
      uuid: Value(uuid),
      name: Value(name),
      isCompleted: Value(isCompleted),
      lastModified: Value(lastModified),
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
      uuid: serializer.fromJson<String>(json['uuid']),
      name: serializer.fromJson<String>(json['name']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      lastModified: serializer.fromJson<DateTime>(json['lastModified']),
      subjectId: serializer.fromJson<int>(json['subjectId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'uuid': serializer.toJson<String>(uuid),
      'name': serializer.toJson<String>(name),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'lastModified': serializer.toJson<DateTime>(lastModified),
      'subjectId': serializer.toJson<int>(subjectId),
    };
  }

  TargetTopic copyWith({
    int? id,
    String? uuid,
    String? name,
    bool? isCompleted,
    DateTime? lastModified,
    int? subjectId,
  }) => TargetTopic(
    id: id ?? this.id,
    uuid: uuid ?? this.uuid,
    name: name ?? this.name,
    isCompleted: isCompleted ?? this.isCompleted,
    lastModified: lastModified ?? this.lastModified,
    subjectId: subjectId ?? this.subjectId,
  );
  TargetTopic copyWithCompanion(TargetTopicsCompanion data) {
    return TargetTopic(
      id: data.id.present ? data.id.value : this.id,
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      name: data.name.present ? data.name.value : this.name,
      isCompleted: data.isCompleted.present
          ? data.isCompleted.value
          : this.isCompleted,
      lastModified: data.lastModified.present
          ? data.lastModified.value
          : this.lastModified,
      subjectId: data.subjectId.present ? data.subjectId.value : this.subjectId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TargetTopic(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('name: $name, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('lastModified: $lastModified, ')
          ..write('subjectId: $subjectId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, uuid, name, isCompleted, lastModified, subjectId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TargetTopic &&
          other.id == this.id &&
          other.uuid == this.uuid &&
          other.name == this.name &&
          other.isCompleted == this.isCompleted &&
          other.lastModified == this.lastModified &&
          other.subjectId == this.subjectId);
}

class TargetTopicsCompanion extends UpdateCompanion<TargetTopic> {
  final Value<int> id;
  final Value<String> uuid;
  final Value<String> name;
  final Value<bool> isCompleted;
  final Value<DateTime> lastModified;
  final Value<int> subjectId;
  const TargetTopicsCompanion({
    this.id = const Value.absent(),
    this.uuid = const Value.absent(),
    this.name = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.lastModified = const Value.absent(),
    this.subjectId = const Value.absent(),
  });
  TargetTopicsCompanion.insert({
    this.id = const Value.absent(),
    required String uuid,
    required String name,
    required bool isCompleted,
    required DateTime lastModified,
    required int subjectId,
  }) : uuid = Value(uuid),
       name = Value(name),
       isCompleted = Value(isCompleted),
       lastModified = Value(lastModified),
       subjectId = Value(subjectId);
  static Insertable<TargetTopic> custom({
    Expression<int>? id,
    Expression<String>? uuid,
    Expression<String>? name,
    Expression<bool>? isCompleted,
    Expression<DateTime>? lastModified,
    Expression<int>? subjectId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (uuid != null) 'uuid': uuid,
      if (name != null) 'name': name,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (lastModified != null) 'last_modified': lastModified,
      if (subjectId != null) 'subject_id': subjectId,
    });
  }

  TargetTopicsCompanion copyWith({
    Value<int>? id,
    Value<String>? uuid,
    Value<String>? name,
    Value<bool>? isCompleted,
    Value<DateTime>? lastModified,
    Value<int>? subjectId,
  }) {
    return TargetTopicsCompanion(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      name: name ?? this.name,
      isCompleted: isCompleted ?? this.isCompleted,
      lastModified: lastModified ?? this.lastModified,
      subjectId: subjectId ?? this.subjectId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (lastModified.present) {
      map['last_modified'] = Variable<DateTime>(lastModified.value);
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
          ..write('uuid: $uuid, ')
          ..write('name: $name, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('lastModified: $lastModified, ')
          ..write('subjectId: $subjectId')
          ..write(')'))
        .toString();
  }
}

class $SavedBooksTable extends SavedBooks
    with TableInfo<$SavedBooksTable, SavedBook> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SavedBooksTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _authorMeta = const VerificationMeta('author');
  @override
  late final GeneratedColumn<String> author = GeneratedColumn<String>(
    'author',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  List<GeneratedColumn> get $columns => [id, title, author, collection];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'saved_books';
  @override
  VerificationContext validateIntegrity(
    Insertable<SavedBook> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('author')) {
      context.handle(
        _authorMeta,
        author.isAcceptableOrUnknown(data['author']!, _authorMeta),
      );
    } else if (isInserting) {
      context.missing(_authorMeta);
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
  SavedBook map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SavedBook(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      author: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author'],
      )!,
      collection: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}collection'],
      ),
    );
  }

  @override
  $SavedBooksTable createAlias(String alias) {
    return $SavedBooksTable(attachedDatabase, alias);
  }
}

class SavedBook extends DataClass implements Insertable<SavedBook> {
  final int id;
  final String title;
  final String author;
  final int? collection;
  const SavedBook({
    required this.id,
    required this.title,
    required this.author,
    this.collection,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['author'] = Variable<String>(author);
    if (!nullToAbsent || collection != null) {
      map['collection'] = Variable<int>(collection);
    }
    return map;
  }

  SavedBooksCompanion toCompanion(bool nullToAbsent) {
    return SavedBooksCompanion(
      id: Value(id),
      title: Value(title),
      author: Value(author),
      collection: collection == null && nullToAbsent
          ? const Value.absent()
          : Value(collection),
    );
  }

  factory SavedBook.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SavedBook(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      author: serializer.fromJson<String>(json['author']),
      collection: serializer.fromJson<int?>(json['collection']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'author': serializer.toJson<String>(author),
      'collection': serializer.toJson<int?>(collection),
    };
  }

  SavedBook copyWith({
    int? id,
    String? title,
    String? author,
    Value<int?> collection = const Value.absent(),
  }) => SavedBook(
    id: id ?? this.id,
    title: title ?? this.title,
    author: author ?? this.author,
    collection: collection.present ? collection.value : this.collection,
  );
  SavedBook copyWithCompanion(SavedBooksCompanion data) {
    return SavedBook(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      author: data.author.present ? data.author.value : this.author,
      collection: data.collection.present
          ? data.collection.value
          : this.collection,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SavedBook(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('author: $author, ')
          ..write('collection: $collection')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, author, collection);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SavedBook &&
          other.id == this.id &&
          other.title == this.title &&
          other.author == this.author &&
          other.collection == this.collection);
}

class SavedBooksCompanion extends UpdateCompanion<SavedBook> {
  final Value<int> id;
  final Value<String> title;
  final Value<String> author;
  final Value<int?> collection;
  const SavedBooksCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.author = const Value.absent(),
    this.collection = const Value.absent(),
  });
  SavedBooksCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    required String author,
    this.collection = const Value.absent(),
  }) : title = Value(title),
       author = Value(author);
  static Insertable<SavedBook> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? author,
    Expression<int>? collection,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (author != null) 'author': author,
      if (collection != null) 'collection': collection,
    });
  }

  SavedBooksCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<String>? author,
    Value<int?>? collection,
  }) {
    return SavedBooksCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      collection: collection ?? this.collection,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (author.present) {
      map['author'] = Variable<String>(author.value);
    }
    if (collection.present) {
      map['collection'] = Variable<int>(collection.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SavedBooksCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('author: $author, ')
          ..write('collection: $collection')
          ..write(')'))
        .toString();
  }
}

class $NotesTable extends Notes with TableInfo<$NotesTable, Note> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
    'uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastModifiedMeta = const VerificationMeta(
    'lastModified',
  );
  @override
  late final GeneratedColumn<DateTime> lastModified = GeneratedColumn<DateTime>(
    'last_modified',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<int> bookId = GeneratedColumn<int>(
    'book_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES books (id)',
    ),
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
    uuid,
    title,
    content,
    lastModified,
    bookId,
    collection,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notes';
  @override
  VerificationContext validateIntegrity(
    Insertable<Note> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('uuid')) {
      context.handle(
        _uuidMeta,
        uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta),
      );
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('last_modified')) {
      context.handle(
        _lastModifiedMeta,
        lastModified.isAcceptableOrUnknown(
          data['last_modified']!,
          _lastModifiedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastModifiedMeta);
    }
    if (data.containsKey('book_id')) {
      context.handle(
        _bookIdMeta,
        bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta),
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
  Note map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Note(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      uuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uuid'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      lastModified: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_modified'],
      )!,
      bookId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}book_id'],
      ),
      collection: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}collection'],
      ),
    );
  }

  @override
  $NotesTable createAlias(String alias) {
    return $NotesTable(attachedDatabase, alias);
  }
}

class Note extends DataClass implements Insertable<Note> {
  final int id;
  final String uuid;
  final String title;
  final String content;
  final DateTime lastModified;
  final int? bookId;
  final int? collection;
  const Note({
    required this.id,
    required this.uuid,
    required this.title,
    required this.content,
    required this.lastModified,
    this.bookId,
    this.collection,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['uuid'] = Variable<String>(uuid);
    map['title'] = Variable<String>(title);
    map['content'] = Variable<String>(content);
    map['last_modified'] = Variable<DateTime>(lastModified);
    if (!nullToAbsent || bookId != null) {
      map['book_id'] = Variable<int>(bookId);
    }
    if (!nullToAbsent || collection != null) {
      map['collection'] = Variable<int>(collection);
    }
    return map;
  }

  NotesCompanion toCompanion(bool nullToAbsent) {
    return NotesCompanion(
      id: Value(id),
      uuid: Value(uuid),
      title: Value(title),
      content: Value(content),
      lastModified: Value(lastModified),
      bookId: bookId == null && nullToAbsent
          ? const Value.absent()
          : Value(bookId),
      collection: collection == null && nullToAbsent
          ? const Value.absent()
          : Value(collection),
    );
  }

  factory Note.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Note(
      id: serializer.fromJson<int>(json['id']),
      uuid: serializer.fromJson<String>(json['uuid']),
      title: serializer.fromJson<String>(json['title']),
      content: serializer.fromJson<String>(json['content']),
      lastModified: serializer.fromJson<DateTime>(json['lastModified']),
      bookId: serializer.fromJson<int?>(json['bookId']),
      collection: serializer.fromJson<int?>(json['collection']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'uuid': serializer.toJson<String>(uuid),
      'title': serializer.toJson<String>(title),
      'content': serializer.toJson<String>(content),
      'lastModified': serializer.toJson<DateTime>(lastModified),
      'bookId': serializer.toJson<int?>(bookId),
      'collection': serializer.toJson<int?>(collection),
    };
  }

  Note copyWith({
    int? id,
    String? uuid,
    String? title,
    String? content,
    DateTime? lastModified,
    Value<int?> bookId = const Value.absent(),
    Value<int?> collection = const Value.absent(),
  }) => Note(
    id: id ?? this.id,
    uuid: uuid ?? this.uuid,
    title: title ?? this.title,
    content: content ?? this.content,
    lastModified: lastModified ?? this.lastModified,
    bookId: bookId.present ? bookId.value : this.bookId,
    collection: collection.present ? collection.value : this.collection,
  );
  Note copyWithCompanion(NotesCompanion data) {
    return Note(
      id: data.id.present ? data.id.value : this.id,
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      title: data.title.present ? data.title.value : this.title,
      content: data.content.present ? data.content.value : this.content,
      lastModified: data.lastModified.present
          ? data.lastModified.value
          : this.lastModified,
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      collection: data.collection.present
          ? data.collection.value
          : this.collection,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Note(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('title: $title, ')
          ..write('content: $content, ')
          ..write('lastModified: $lastModified, ')
          ..write('bookId: $bookId, ')
          ..write('collection: $collection')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, uuid, title, content, lastModified, bookId, collection);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Note &&
          other.id == this.id &&
          other.uuid == this.uuid &&
          other.title == this.title &&
          other.content == this.content &&
          other.lastModified == this.lastModified &&
          other.bookId == this.bookId &&
          other.collection == this.collection);
}

class NotesCompanion extends UpdateCompanion<Note> {
  final Value<int> id;
  final Value<String> uuid;
  final Value<String> title;
  final Value<String> content;
  final Value<DateTime> lastModified;
  final Value<int?> bookId;
  final Value<int?> collection;
  const NotesCompanion({
    this.id = const Value.absent(),
    this.uuid = const Value.absent(),
    this.title = const Value.absent(),
    this.content = const Value.absent(),
    this.lastModified = const Value.absent(),
    this.bookId = const Value.absent(),
    this.collection = const Value.absent(),
  });
  NotesCompanion.insert({
    this.id = const Value.absent(),
    required String uuid,
    required String title,
    required String content,
    required DateTime lastModified,
    this.bookId = const Value.absent(),
    this.collection = const Value.absent(),
  }) : uuid = Value(uuid),
       title = Value(title),
       content = Value(content),
       lastModified = Value(lastModified);
  static Insertable<Note> custom({
    Expression<int>? id,
    Expression<String>? uuid,
    Expression<String>? title,
    Expression<String>? content,
    Expression<DateTime>? lastModified,
    Expression<int>? bookId,
    Expression<int>? collection,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (uuid != null) 'uuid': uuid,
      if (title != null) 'title': title,
      if (content != null) 'content': content,
      if (lastModified != null) 'last_modified': lastModified,
      if (bookId != null) 'book_id': bookId,
      if (collection != null) 'collection': collection,
    });
  }

  NotesCompanion copyWith({
    Value<int>? id,
    Value<String>? uuid,
    Value<String>? title,
    Value<String>? content,
    Value<DateTime>? lastModified,
    Value<int?>? bookId,
    Value<int?>? collection,
  }) {
    return NotesCompanion(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      title: title ?? this.title,
      content: content ?? this.content,
      lastModified: lastModified ?? this.lastModified,
      bookId: bookId ?? this.bookId,
      collection: collection ?? this.collection,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (lastModified.present) {
      map['last_modified'] = Variable<DateTime>(lastModified.value);
    }
    if (bookId.present) {
      map['book_id'] = Variable<int>(bookId.value);
    }
    if (collection.present) {
      map['collection'] = Variable<int>(collection.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotesCompanion(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('title: $title, ')
          ..write('content: $content, ')
          ..write('lastModified: $lastModified, ')
          ..write('bookId: $bookId, ')
          ..write('collection: $collection')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CollectionsTable collections = $CollectionsTable(this);
  late final $BooksTable books = $BooksTable(this);
  late final $TimetablesTable timetables = $TimetablesTable(this);
  late final $TimetableDaysTable timetableDays = $TimetableDaysTable(this);
  late final $TimetableSessionsTable timetableSessions =
      $TimetableSessionsTable(this);
  late final $TargetSubjectsTable targetSubjects = $TargetSubjectsTable(this);
  late final $TargetTopicsTable targetTopics = $TargetTopicsTable(this);
  late final $SavedBooksTable savedBooks = $SavedBooksTable(this);
  late final $NotesTable notes = $NotesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    collections,
    books,
    timetables,
    timetableDays,
    timetableSessions,
    targetSubjects,
    targetTopics,
    savedBooks,
    notes,
  ];
}

typedef $$CollectionsTableCreateCompanionBuilder =
    CollectionsCompanion Function({
      Value<int> id,
      required String name,
      Value<bool> isSavedCollection,
    });
typedef $$CollectionsTableUpdateCompanionBuilder =
    CollectionsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<bool> isSavedCollection,
    });

final class $$CollectionsTableReferences
    extends BaseReferences<_$AppDatabase, $CollectionsTable, Collection> {
  $$CollectionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$BooksTable, List<Book>> _booksRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.books,
    aliasName: 'collections__id__books__collection',
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

  static MultiTypedResultKey<$SavedBooksTable, List<SavedBook>>
  _savedBooksRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.savedBooks,
    aliasName: 'collections__id__saved_books__collection',
  );

  $$SavedBooksTableProcessedTableManager get savedBooksRefs {
    final manager = $$SavedBooksTableTableManager(
      $_db,
      $_db.savedBooks,
    ).filter((f) => f.collection.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_savedBooksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$NotesTable, List<Note>> _notesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.notes,
    aliasName: 'collections__id__notes__collection',
  );

  $$NotesTableProcessedTableManager get notesRefs {
    final manager = $$NotesTableTableManager(
      $_db,
      $_db.notes,
    ).filter((f) => f.collection.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_notesRefsTable($_db));
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

  ColumnFilters<bool> get isSavedCollection => $composableBuilder(
    column: $table.isSavedCollection,
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

  Expression<bool> savedBooksRefs(
    Expression<bool> Function($$SavedBooksTableFilterComposer f) f,
  ) {
    final $$SavedBooksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.savedBooks,
      getReferencedColumn: (t) => t.collection,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SavedBooksTableFilterComposer(
            $db: $db,
            $table: $db.savedBooks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> notesRefs(
    Expression<bool> Function($$NotesTableFilterComposer f) f,
  ) {
    final $$NotesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.notes,
      getReferencedColumn: (t) => t.collection,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotesTableFilterComposer(
            $db: $db,
            $table: $db.notes,
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

  ColumnOrderings<bool> get isSavedCollection => $composableBuilder(
    column: $table.isSavedCollection,
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

  GeneratedColumn<bool> get isSavedCollection => $composableBuilder(
    column: $table.isSavedCollection,
    builder: (column) => column,
  );

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

  Expression<T> savedBooksRefs<T extends Object>(
    Expression<T> Function($$SavedBooksTableAnnotationComposer a) f,
  ) {
    final $$SavedBooksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.savedBooks,
      getReferencedColumn: (t) => t.collection,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SavedBooksTableAnnotationComposer(
            $db: $db,
            $table: $db.savedBooks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> notesRefs<T extends Object>(
    Expression<T> Function($$NotesTableAnnotationComposer a) f,
  ) {
    final $$NotesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.notes,
      getReferencedColumn: (t) => t.collection,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotesTableAnnotationComposer(
            $db: $db,
            $table: $db.notes,
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
          PrefetchHooks Function({
            bool booksRefs,
            bool savedBooksRefs,
            bool notesRefs,
          })
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
                Value<bool> isSavedCollection = const Value.absent(),
              }) => CollectionsCompanion(
                id: id,
                name: name,
                isSavedCollection: isSavedCollection,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<bool> isSavedCollection = const Value.absent(),
              }) => CollectionsCompanion.insert(
                id: id,
                name: name,
                isSavedCollection: isSavedCollection,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CollectionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({booksRefs = false, savedBooksRefs = false, notesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (booksRefs) db.books,
                    if (savedBooksRefs) db.savedBooks,
                    if (notesRefs) db.notes,
                  ],
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
                              $$CollectionsTableReferences(
                                db,
                                table,
                                p0,
                              ).booksRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.collection == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (savedBooksRefs)
                        await $_getPrefetchedData<
                          Collection,
                          $CollectionsTable,
                          SavedBook
                        >(
                          currentTable: table,
                          referencedTable: $$CollectionsTableReferences
                              ._savedBooksRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CollectionsTableReferences(
                                db,
                                table,
                                p0,
                              ).savedBooksRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.collection == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (notesRefs)
                        await $_getPrefetchedData<
                          Collection,
                          $CollectionsTable,
                          Note
                        >(
                          currentTable: table,
                          referencedTable: $$CollectionsTableReferences
                              ._notesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CollectionsTableReferences(
                                db,
                                table,
                                p0,
                              ).notesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.collection == item.id,
                              ),
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
      PrefetchHooks Function({
        bool booksRefs,
        bool savedBooksRefs,
        bool notesRefs,
      })
    >;
typedef $$BooksTableCreateCompanionBuilder =
    BooksCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> author,
      required String path,
      Value<String?> cfi,
      required String extension,
      Value<int?> page,
      Value<double> progress,
      Value<int?> collection,
      Value<bool> lastRead,
      Value<String?> coverPath,
    });
typedef $$BooksTableUpdateCompanionBuilder =
    BooksCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> author,
      Value<String> path,
      Value<String?> cfi,
      Value<String> extension,
      Value<int?> page,
      Value<double> progress,
      Value<int?> collection,
      Value<bool> lastRead,
      Value<String?> coverPath,
    });

final class $$BooksTableReferences
    extends BaseReferences<_$AppDatabase, $BooksTable, Book> {
  $$BooksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CollectionsTable _collectionTable(_$AppDatabase db) =>
      db.collections.createAlias('books__collection__collections__id');

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

  static MultiTypedResultKey<$NotesTable, List<Note>> _notesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.notes,
    aliasName: 'books__id__notes__book_id',
  );

  $$NotesTableProcessedTableManager get notesRefs {
    final manager = $$NotesTableTableManager(
      $_db,
      $_db.notes,
    ).filter((f) => f.bookId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_notesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
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

  ColumnFilters<String> get author => $composableBuilder(
    column: $table.author,
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

  ColumnFilters<bool> get lastRead => $composableBuilder(
    column: $table.lastRead,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverPath => $composableBuilder(
    column: $table.coverPath,
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

  Expression<bool> notesRefs(
    Expression<bool> Function($$NotesTableFilterComposer f) f,
  ) {
    final $$NotesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.notes,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotesTableFilterComposer(
            $db: $db,
            $table: $db.notes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
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

  ColumnOrderings<String> get author => $composableBuilder(
    column: $table.author,
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

  ColumnOrderings<bool> get lastRead => $composableBuilder(
    column: $table.lastRead,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverPath => $composableBuilder(
    column: $table.coverPath,
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

  GeneratedColumn<String> get author =>
      $composableBuilder(column: $table.author, builder: (column) => column);

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

  GeneratedColumn<bool> get lastRead =>
      $composableBuilder(column: $table.lastRead, builder: (column) => column);

  GeneratedColumn<String> get coverPath =>
      $composableBuilder(column: $table.coverPath, builder: (column) => column);

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

  Expression<T> notesRefs<T extends Object>(
    Expression<T> Function($$NotesTableAnnotationComposer a) f,
  ) {
    final $$NotesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.notes,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotesTableAnnotationComposer(
            $db: $db,
            $table: $db.notes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
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
          PrefetchHooks Function({bool collection, bool notesRefs})
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
                Value<String?> author = const Value.absent(),
                Value<String> path = const Value.absent(),
                Value<String?> cfi = const Value.absent(),
                Value<String> extension = const Value.absent(),
                Value<int?> page = const Value.absent(),
                Value<double> progress = const Value.absent(),
                Value<int?> collection = const Value.absent(),
                Value<bool> lastRead = const Value.absent(),
                Value<String?> coverPath = const Value.absent(),
              }) => BooksCompanion(
                id: id,
                name: name,
                author: author,
                path: path,
                cfi: cfi,
                extension: extension,
                page: page,
                progress: progress,
                collection: collection,
                lastRead: lastRead,
                coverPath: coverPath,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> author = const Value.absent(),
                required String path,
                Value<String?> cfi = const Value.absent(),
                required String extension,
                Value<int?> page = const Value.absent(),
                Value<double> progress = const Value.absent(),
                Value<int?> collection = const Value.absent(),
                Value<bool> lastRead = const Value.absent(),
                Value<String?> coverPath = const Value.absent(),
              }) => BooksCompanion.insert(
                id: id,
                name: name,
                author: author,
                path: path,
                cfi: cfi,
                extension: extension,
                page: page,
                progress: progress,
                collection: collection,
                lastRead: lastRead,
                coverPath: coverPath,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$BooksTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({collection = false, notesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (notesRefs) db.notes],
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
                return [
                  if (notesRefs)
                    await $_getPrefetchedData<Book, $BooksTable, Note>(
                      currentTable: table,
                      referencedTable: $$BooksTableReferences._notesRefsTable(
                        db,
                      ),
                      managerFromTypedResult: (p0) =>
                          $$BooksTableReferences(db, table, p0).notesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.bookId == item.id),
                      typedResults: items,
                    ),
                ];
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
      PrefetchHooks Function({bool collection, bool notesRefs})
    >;
typedef $$TimetablesTableCreateCompanionBuilder =
    TimetablesCompanion Function({
      Value<int> id,
      required int version,
      required DateTime lastModified,
    });
typedef $$TimetablesTableUpdateCompanionBuilder =
    TimetablesCompanion Function({
      Value<int> id,
      Value<int> version,
      Value<DateTime> lastModified,
    });

final class $$TimetablesTableReferences
    extends BaseReferences<_$AppDatabase, $TimetablesTable, Timetable> {
  $$TimetablesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TimetableDaysTable, List<TimetableDay>>
  _timetableDaysRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.timetableDays,
    aliasName: 'timetables__id__timetable_days__timetable_id',
  );

  $$TimetableDaysTableProcessedTableManager get timetableDaysRefs {
    final manager = $$TimetableDaysTableTableManager(
      $_db,
      $_db.timetableDays,
    ).filter((f) => f.timetableId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_timetableDaysRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TimetablesTableFilterComposer
    extends Composer<_$AppDatabase, $TimetablesTable> {
  $$TimetablesTableFilterComposer({
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

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastModified => $composableBuilder(
    column: $table.lastModified,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> timetableDaysRefs(
    Expression<bool> Function($$TimetableDaysTableFilterComposer f) f,
  ) {
    final $$TimetableDaysTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.timetableDays,
      getReferencedColumn: (t) => t.timetableId,
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
    return f(composer);
  }
}

class $$TimetablesTableOrderingComposer
    extends Composer<_$AppDatabase, $TimetablesTable> {
  $$TimetablesTableOrderingComposer({
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

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastModified => $composableBuilder(
    column: $table.lastModified,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TimetablesTableAnnotationComposer
    extends Composer<_$AppDatabase, $TimetablesTable> {
  $$TimetablesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<DateTime> get lastModified => $composableBuilder(
    column: $table.lastModified,
    builder: (column) => column,
  );

  Expression<T> timetableDaysRefs<T extends Object>(
    Expression<T> Function($$TimetableDaysTableAnnotationComposer a) f,
  ) {
    final $$TimetableDaysTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.timetableDays,
      getReferencedColumn: (t) => t.timetableId,
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
    return f(composer);
  }
}

class $$TimetablesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TimetablesTable,
          Timetable,
          $$TimetablesTableFilterComposer,
          $$TimetablesTableOrderingComposer,
          $$TimetablesTableAnnotationComposer,
          $$TimetablesTableCreateCompanionBuilder,
          $$TimetablesTableUpdateCompanionBuilder,
          (Timetable, $$TimetablesTableReferences),
          Timetable,
          PrefetchHooks Function({bool timetableDaysRefs})
        > {
  $$TimetablesTableTableManager(_$AppDatabase db, $TimetablesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TimetablesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TimetablesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TimetablesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<DateTime> lastModified = const Value.absent(),
              }) => TimetablesCompanion(
                id: id,
                version: version,
                lastModified: lastModified,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int version,
                required DateTime lastModified,
              }) => TimetablesCompanion.insert(
                id: id,
                version: version,
                lastModified: lastModified,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TimetablesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({timetableDaysRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (timetableDaysRefs) db.timetableDays,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (timetableDaysRefs)
                    await $_getPrefetchedData<
                      Timetable,
                      $TimetablesTable,
                      TimetableDay
                    >(
                      currentTable: table,
                      referencedTable: $$TimetablesTableReferences
                          ._timetableDaysRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$TimetablesTableReferences(
                            db,
                            table,
                            p0,
                          ).timetableDaysRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.timetableId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$TimetablesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TimetablesTable,
      Timetable,
      $$TimetablesTableFilterComposer,
      $$TimetablesTableOrderingComposer,
      $$TimetablesTableAnnotationComposer,
      $$TimetablesTableCreateCompanionBuilder,
      $$TimetablesTableUpdateCompanionBuilder,
      (Timetable, $$TimetablesTableReferences),
      Timetable,
      PrefetchHooks Function({bool timetableDaysRefs})
    >;
typedef $$TimetableDaysTableCreateCompanionBuilder =
    TimetableDaysCompanion Function({
      Value<int> id,
      required int timetableId,
      required String day,
      Value<bool> isBreakDay,
    });
typedef $$TimetableDaysTableUpdateCompanionBuilder =
    TimetableDaysCompanion Function({
      Value<int> id,
      Value<int> timetableId,
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

  static $TimetablesTable _timetableIdTable(_$AppDatabase db) =>
      db.timetables.createAlias('timetable_days__timetable_id__timetables__id');

  $$TimetablesTableProcessedTableManager get timetableId {
    final $_column = $_itemColumn<int>('timetable_id')!;

    final manager = $$TimetablesTableTableManager(
      $_db,
      $_db.timetables,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_timetableIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$TimetableSessionsTable, List<TimetableSession>>
  _timetableSessionsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.timetableSessions,
        aliasName: 'timetable_days__id__timetable_sessions__day_id',
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

  $$TimetablesTableFilterComposer get timetableId {
    final $$TimetablesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.timetableId,
      referencedTable: $db.timetables,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TimetablesTableFilterComposer(
            $db: $db,
            $table: $db.timetables,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

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

  $$TimetablesTableOrderingComposer get timetableId {
    final $$TimetablesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.timetableId,
      referencedTable: $db.timetables,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TimetablesTableOrderingComposer(
            $db: $db,
            $table: $db.timetables,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
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

  $$TimetablesTableAnnotationComposer get timetableId {
    final $$TimetablesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.timetableId,
      referencedTable: $db.timetables,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TimetablesTableAnnotationComposer(
            $db: $db,
            $table: $db.timetables,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

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
          PrefetchHooks Function({bool timetableId, bool timetableSessionsRefs})
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
                Value<int> timetableId = const Value.absent(),
                Value<String> day = const Value.absent(),
                Value<bool> isBreakDay = const Value.absent(),
              }) => TimetableDaysCompanion(
                id: id,
                timetableId: timetableId,
                day: day,
                isBreakDay: isBreakDay,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int timetableId,
                required String day,
                Value<bool> isBreakDay = const Value.absent(),
              }) => TimetableDaysCompanion.insert(
                id: id,
                timetableId: timetableId,
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
          prefetchHooksCallback:
              ({timetableId = false, timetableSessionsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (timetableSessionsRefs) db.timetableSessions,
                  ],
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
                        if (timetableId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.timetableId,
                                    referencedTable:
                                        $$TimetableDaysTableReferences
                                            ._timetableIdTable(db),
                                    referencedColumn:
                                        $$TimetableDaysTableReferences
                                            ._timetableIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
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
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.dayId == item.id,
                              ),
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
      PrefetchHooks Function({bool timetableId, bool timetableSessionsRefs})
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

  static $TimetableDaysTable _dayIdTable(_$AppDatabase db) => db.timetableDays
      .createAlias('timetable_sessions__day_id__timetable_days__id');

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
    TargetSubjectsCompanion Function({
      Value<int> id,
      required String uuid,
      required String name,
      Value<DateTime?> syncedAt,
    });
typedef $$TargetSubjectsTableUpdateCompanionBuilder =
    TargetSubjectsCompanion Function({
      Value<int> id,
      Value<String> uuid,
      Value<String> name,
      Value<DateTime?> syncedAt,
    });

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
    aliasName: 'target_subjects__id__target_topics__subject_id',
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

  ColumnFilters<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
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

  ColumnOrderings<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
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

  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);

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
                Value<String> uuid = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<DateTime?> syncedAt = const Value.absent(),
              }) => TargetSubjectsCompanion(
                id: id,
                uuid: uuid,
                name: name,
                syncedAt: syncedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String uuid,
                required String name,
                Value<DateTime?> syncedAt = const Value.absent(),
              }) => TargetSubjectsCompanion.insert(
                id: id,
                uuid: uuid,
                name: name,
                syncedAt: syncedAt,
              ),
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
      required String uuid,
      required String name,
      required bool isCompleted,
      required DateTime lastModified,
      required int subjectId,
    });
typedef $$TargetTopicsTableUpdateCompanionBuilder =
    TargetTopicsCompanion Function({
      Value<int> id,
      Value<String> uuid,
      Value<String> name,
      Value<bool> isCompleted,
      Value<DateTime> lastModified,
      Value<int> subjectId,
    });

final class $$TargetTopicsTableReferences
    extends BaseReferences<_$AppDatabase, $TargetTopicsTable, TargetTopic> {
  $$TargetTopicsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TargetSubjectsTable _subjectIdTable(_$AppDatabase db) => db
      .targetSubjects
      .createAlias('target_topics__subject_id__target_subjects__id');

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

  ColumnFilters<String> get uuid => $composableBuilder(
    column: $table.uuid,
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

  ColumnFilters<DateTime> get lastModified => $composableBuilder(
    column: $table.lastModified,
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

  ColumnOrderings<String> get uuid => $composableBuilder(
    column: $table.uuid,
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

  ColumnOrderings<DateTime> get lastModified => $composableBuilder(
    column: $table.lastModified,
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

  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastModified => $composableBuilder(
    column: $table.lastModified,
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
                Value<String> uuid = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                Value<DateTime> lastModified = const Value.absent(),
                Value<int> subjectId = const Value.absent(),
              }) => TargetTopicsCompanion(
                id: id,
                uuid: uuid,
                name: name,
                isCompleted: isCompleted,
                lastModified: lastModified,
                subjectId: subjectId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String uuid,
                required String name,
                required bool isCompleted,
                required DateTime lastModified,
                required int subjectId,
              }) => TargetTopicsCompanion.insert(
                id: id,
                uuid: uuid,
                name: name,
                isCompleted: isCompleted,
                lastModified: lastModified,
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
typedef $$SavedBooksTableCreateCompanionBuilder =
    SavedBooksCompanion Function({
      Value<int> id,
      required String title,
      required String author,
      Value<int?> collection,
    });
typedef $$SavedBooksTableUpdateCompanionBuilder =
    SavedBooksCompanion Function({
      Value<int> id,
      Value<String> title,
      Value<String> author,
      Value<int?> collection,
    });

final class $$SavedBooksTableReferences
    extends BaseReferences<_$AppDatabase, $SavedBooksTable, SavedBook> {
  $$SavedBooksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CollectionsTable _collectionTable(_$AppDatabase db) =>
      db.collections.createAlias('saved_books__collection__collections__id');

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

class $$SavedBooksTableFilterComposer
    extends Composer<_$AppDatabase, $SavedBooksTable> {
  $$SavedBooksTableFilterComposer({
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

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get author => $composableBuilder(
    column: $table.author,
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

class $$SavedBooksTableOrderingComposer
    extends Composer<_$AppDatabase, $SavedBooksTable> {
  $$SavedBooksTableOrderingComposer({
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

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get author => $composableBuilder(
    column: $table.author,
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

class $$SavedBooksTableAnnotationComposer
    extends Composer<_$AppDatabase, $SavedBooksTable> {
  $$SavedBooksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get author =>
      $composableBuilder(column: $table.author, builder: (column) => column);

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

class $$SavedBooksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SavedBooksTable,
          SavedBook,
          $$SavedBooksTableFilterComposer,
          $$SavedBooksTableOrderingComposer,
          $$SavedBooksTableAnnotationComposer,
          $$SavedBooksTableCreateCompanionBuilder,
          $$SavedBooksTableUpdateCompanionBuilder,
          (SavedBook, $$SavedBooksTableReferences),
          SavedBook,
          PrefetchHooks Function({bool collection})
        > {
  $$SavedBooksTableTableManager(_$AppDatabase db, $SavedBooksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SavedBooksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SavedBooksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SavedBooksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> author = const Value.absent(),
                Value<int?> collection = const Value.absent(),
              }) => SavedBooksCompanion(
                id: id,
                title: title,
                author: author,
                collection: collection,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                required String author,
                Value<int?> collection = const Value.absent(),
              }) => SavedBooksCompanion.insert(
                id: id,
                title: title,
                author: author,
                collection: collection,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SavedBooksTableReferences(db, table, e),
                ),
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
                                referencedTable: $$SavedBooksTableReferences
                                    ._collectionTable(db),
                                referencedColumn: $$SavedBooksTableReferences
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

typedef $$SavedBooksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SavedBooksTable,
      SavedBook,
      $$SavedBooksTableFilterComposer,
      $$SavedBooksTableOrderingComposer,
      $$SavedBooksTableAnnotationComposer,
      $$SavedBooksTableCreateCompanionBuilder,
      $$SavedBooksTableUpdateCompanionBuilder,
      (SavedBook, $$SavedBooksTableReferences),
      SavedBook,
      PrefetchHooks Function({bool collection})
    >;
typedef $$NotesTableCreateCompanionBuilder =
    NotesCompanion Function({
      Value<int> id,
      required String uuid,
      required String title,
      required String content,
      required DateTime lastModified,
      Value<int?> bookId,
      Value<int?> collection,
    });
typedef $$NotesTableUpdateCompanionBuilder =
    NotesCompanion Function({
      Value<int> id,
      Value<String> uuid,
      Value<String> title,
      Value<String> content,
      Value<DateTime> lastModified,
      Value<int?> bookId,
      Value<int?> collection,
    });

final class $$NotesTableReferences
    extends BaseReferences<_$AppDatabase, $NotesTable, Note> {
  $$NotesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $BooksTable _bookIdTable(_$AppDatabase db) =>
      db.books.createAlias('notes__book_id__books__id');

  $$BooksTableProcessedTableManager? get bookId {
    final $_column = $_itemColumn<int>('book_id');
    if ($_column == null) return null;
    final manager = $$BooksTableTableManager(
      $_db,
      $_db.books,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_bookIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CollectionsTable _collectionTable(_$AppDatabase db) =>
      db.collections.createAlias('notes__collection__collections__id');

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

class $$NotesTableFilterComposer extends Composer<_$AppDatabase, $NotesTable> {
  $$NotesTableFilterComposer({
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

  ColumnFilters<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastModified => $composableBuilder(
    column: $table.lastModified,
    builder: (column) => ColumnFilters(column),
  );

  $$BooksTableFilterComposer get bookId {
    final $$BooksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
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
    return composer;
  }

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

class $$NotesTableOrderingComposer
    extends Composer<_$AppDatabase, $NotesTable> {
  $$NotesTableOrderingComposer({
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

  ColumnOrderings<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastModified => $composableBuilder(
    column: $table.lastModified,
    builder: (column) => ColumnOrderings(column),
  );

  $$BooksTableOrderingComposer get bookId {
    final $$BooksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableOrderingComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

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

class $$NotesTableAnnotationComposer
    extends Composer<_$AppDatabase, $NotesTable> {
  $$NotesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<DateTime> get lastModified => $composableBuilder(
    column: $table.lastModified,
    builder: (column) => column,
  );

  $$BooksTableAnnotationComposer get bookId {
    final $$BooksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
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
    return composer;
  }

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

class $$NotesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NotesTable,
          Note,
          $$NotesTableFilterComposer,
          $$NotesTableOrderingComposer,
          $$NotesTableAnnotationComposer,
          $$NotesTableCreateCompanionBuilder,
          $$NotesTableUpdateCompanionBuilder,
          (Note, $$NotesTableReferences),
          Note,
          PrefetchHooks Function({bool bookId, bool collection})
        > {
  $$NotesTableTableManager(_$AppDatabase db, $NotesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NotesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NotesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NotesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> uuid = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<DateTime> lastModified = const Value.absent(),
                Value<int?> bookId = const Value.absent(),
                Value<int?> collection = const Value.absent(),
              }) => NotesCompanion(
                id: id,
                uuid: uuid,
                title: title,
                content: content,
                lastModified: lastModified,
                bookId: bookId,
                collection: collection,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String uuid,
                required String title,
                required String content,
                required DateTime lastModified,
                Value<int?> bookId = const Value.absent(),
                Value<int?> collection = const Value.absent(),
              }) => NotesCompanion.insert(
                id: id,
                uuid: uuid,
                title: title,
                content: content,
                lastModified: lastModified,
                bookId: bookId,
                collection: collection,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$NotesTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({bookId = false, collection = false}) {
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
                    if (bookId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.bookId,
                                referencedTable: $$NotesTableReferences
                                    ._bookIdTable(db),
                                referencedColumn: $$NotesTableReferences
                                    ._bookIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (collection) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.collection,
                                referencedTable: $$NotesTableReferences
                                    ._collectionTable(db),
                                referencedColumn: $$NotesTableReferences
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

typedef $$NotesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NotesTable,
      Note,
      $$NotesTableFilterComposer,
      $$NotesTableOrderingComposer,
      $$NotesTableAnnotationComposer,
      $$NotesTableCreateCompanionBuilder,
      $$NotesTableUpdateCompanionBuilder,
      (Note, $$NotesTableReferences),
      Note,
      PrefetchHooks Function({bool bookId, bool collection})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CollectionsTableTableManager get collections =>
      $$CollectionsTableTableManager(_db, _db.collections);
  $$BooksTableTableManager get books =>
      $$BooksTableTableManager(_db, _db.books);
  $$TimetablesTableTableManager get timetables =>
      $$TimetablesTableTableManager(_db, _db.timetables);
  $$TimetableDaysTableTableManager get timetableDays =>
      $$TimetableDaysTableTableManager(_db, _db.timetableDays);
  $$TimetableSessionsTableTableManager get timetableSessions =>
      $$TimetableSessionsTableTableManager(_db, _db.timetableSessions);
  $$TargetSubjectsTableTableManager get targetSubjects =>
      $$TargetSubjectsTableTableManager(_db, _db.targetSubjects);
  $$TargetTopicsTableTableManager get targetTopics =>
      $$TargetTopicsTableTableManager(_db, _db.targetTopics);
  $$SavedBooksTableTableManager get savedBooks =>
      $$SavedBooksTableTableManager(_db, _db.savedBooks);
  $$NotesTableTableManager get notes =>
      $$NotesTableTableManager(_db, _db.notes);
}
