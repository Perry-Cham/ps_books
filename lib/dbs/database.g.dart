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
  final double progress;
  const BookData({
    required this.id,
    required this.name,
    required this.path,
    this.cfi,
    required this.extension,
    this.page,
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
    double? progress,
  }) => BookData(
    id: id ?? this.id,
    name: name ?? this.name,
    path: path ?? this.path,
    cfi: cfi.present ? cfi.value : this.cfi,
    extension: extension ?? this.extension,
    page: page.present ? page.value : this.page,
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
          ..write('progress: $progress')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, path, cfi, extension, page, progress);
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
          other.progress == this.progress);
}

class BookCompanion extends UpdateCompanion<BookData> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> path;
  final Value<String?> cfi;
  final Value<String> extension;
  final Value<int?> page;
  final Value<double> progress;
  const BookCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.path = const Value.absent(),
    this.cfi = const Value.absent(),
    this.extension = const Value.absent(),
    this.page = const Value.absent(),
    this.progress = const Value.absent(),
  });
  BookCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String path,
    this.cfi = const Value.absent(),
    required String extension,
    this.page = const Value.absent(),
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
    Expression<double>? progress,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (path != null) 'path': path,
      if (cfi != null) 'cfi': cfi,
      if (extension != null) 'extension': extension,
      if (page != null) 'page': page,
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
    Value<double>? progress,
  }) {
    return BookCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      path: path ?? this.path,
      cfi: cfi ?? this.cfi,
      extension: extension ?? this.extension,
      page: page ?? this.page,
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
          ..write('progress: $progress')
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

class $GoalSubjectsTable extends GoalSubjects
    with TableInfo<$GoalSubjectsTable, GoalSubject> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GoalSubjectsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES timetable_sessions (id)',
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
  @override
  List<GeneratedColumn> get $columns => [id, sessionId, name, isCompleted];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'goal_subjects';
  @override
  VerificationContext validateIntegrity(
    Insertable<GoalSubject> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GoalSubject map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GoalSubject(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      isCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_completed'],
      )!,
    );
  }

  @override
  $GoalSubjectsTable createAlias(String alias) {
    return $GoalSubjectsTable(attachedDatabase, alias);
  }
}

class GoalSubject extends DataClass implements Insertable<GoalSubject> {
  final int id;
  final int sessionId;
  final String name;
  final bool isCompleted;
  const GoalSubject({
    required this.id,
    required this.sessionId,
    required this.name,
    required this.isCompleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_id'] = Variable<int>(sessionId);
    map['name'] = Variable<String>(name);
    map['is_completed'] = Variable<bool>(isCompleted);
    return map;
  }

  GoalSubjectsCompanion toCompanion(bool nullToAbsent) {
    return GoalSubjectsCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      name: Value(name),
      isCompleted: Value(isCompleted),
    );
  }

  factory GoalSubject.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GoalSubject(
      id: serializer.fromJson<int>(json['id']),
      sessionId: serializer.fromJson<int>(json['sessionId']),
      name: serializer.fromJson<String>(json['name']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionId': serializer.toJson<int>(sessionId),
      'name': serializer.toJson<String>(name),
      'isCompleted': serializer.toJson<bool>(isCompleted),
    };
  }

  GoalSubject copyWith({
    int? id,
    int? sessionId,
    String? name,
    bool? isCompleted,
  }) => GoalSubject(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    name: name ?? this.name,
    isCompleted: isCompleted ?? this.isCompleted,
  );
  GoalSubject copyWithCompanion(GoalSubjectsCompanion data) {
    return GoalSubject(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      name: data.name.present ? data.name.value : this.name,
      isCompleted: data.isCompleted.present
          ? data.isCompleted.value
          : this.isCompleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GoalSubject(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('name: $name, ')
          ..write('isCompleted: $isCompleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, sessionId, name, isCompleted);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GoalSubject &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.name == this.name &&
          other.isCompleted == this.isCompleted);
}

class GoalSubjectsCompanion extends UpdateCompanion<GoalSubject> {
  final Value<int> id;
  final Value<int> sessionId;
  final Value<String> name;
  final Value<bool> isCompleted;
  const GoalSubjectsCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.name = const Value.absent(),
    this.isCompleted = const Value.absent(),
  });
  GoalSubjectsCompanion.insert({
    this.id = const Value.absent(),
    required int sessionId,
    required String name,
    required bool isCompleted,
  }) : sessionId = Value(sessionId),
       name = Value(name),
       isCompleted = Value(isCompleted);
  static Insertable<GoalSubject> custom({
    Expression<int>? id,
    Expression<int>? sessionId,
    Expression<String>? name,
    Expression<bool>? isCompleted,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (name != null) 'name': name,
      if (isCompleted != null) 'is_completed': isCompleted,
    });
  }

  GoalSubjectsCompanion copyWith({
    Value<int>? id,
    Value<int>? sessionId,
    Value<String>? name,
    Value<bool>? isCompleted,
  }) {
    return GoalSubjectsCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      name: name ?? this.name,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GoalSubjectsCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('name: $name, ')
          ..write('isCompleted: $isCompleted')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $BookTable book = $BookTable(this);
  late final $TimetableDaysTable timetableDays = $TimetableDaysTable(this);
  late final $TimetableSessionsTable timetableSessions =
      $TimetableSessionsTable(this);
  late final $GoalSubjectsTable goalSubjects = $GoalSubjectsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    book,
    timetableDays,
    timetableSessions,
    goalSubjects,
  ];
}

typedef $$BookTableCreateCompanionBuilder =
    BookCompanion Function({
      Value<int> id,
      required String name,
      required String path,
      Value<String?> cfi,
      required String extension,
      Value<int?> page,
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
                Value<double> progress = const Value.absent(),
              }) => BookCompanion(
                id: id,
                name: name,
                path: path,
                cfi: cfi,
                extension: extension,
                page: page,
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
                Value<double> progress = const Value.absent(),
              }) => BookCompanion.insert(
                id: id,
                name: name,
                path: path,
                cfi: cfi,
                extension: extension,
                page: page,
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

  static MultiTypedResultKey<$GoalSubjectsTable, List<GoalSubject>>
  _goalSubjectsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.goalSubjects,
    aliasName: $_aliasNameGenerator(
      db.timetableSessions.id,
      db.goalSubjects.sessionId,
    ),
  );

  $$GoalSubjectsTableProcessedTableManager get goalSubjectsRefs {
    final manager = $$GoalSubjectsTableTableManager(
      $_db,
      $_db.goalSubjects,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_goalSubjectsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
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

  Expression<bool> goalSubjectsRefs(
    Expression<bool> Function($$GoalSubjectsTableFilterComposer f) f,
  ) {
    final $$GoalSubjectsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.goalSubjects,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GoalSubjectsTableFilterComposer(
            $db: $db,
            $table: $db.goalSubjects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
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

  Expression<T> goalSubjectsRefs<T extends Object>(
    Expression<T> Function($$GoalSubjectsTableAnnotationComposer a) f,
  ) {
    final $$GoalSubjectsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.goalSubjects,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GoalSubjectsTableAnnotationComposer(
            $db: $db,
            $table: $db.goalSubjects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
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
          PrefetchHooks Function({bool dayId, bool goalSubjectsRefs})
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
          prefetchHooksCallback: ({dayId = false, goalSubjectsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (goalSubjectsRefs) db.goalSubjects],
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
                return [
                  if (goalSubjectsRefs)
                    await $_getPrefetchedData<
                      TimetableSession,
                      $TimetableSessionsTable,
                      GoalSubject
                    >(
                      currentTable: table,
                      referencedTable: $$TimetableSessionsTableReferences
                          ._goalSubjectsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$TimetableSessionsTableReferences(
                            db,
                            table,
                            p0,
                          ).goalSubjectsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.sessionId == item.id),
                      typedResults: items,
                    ),
                ];
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
      PrefetchHooks Function({bool dayId, bool goalSubjectsRefs})
    >;
typedef $$GoalSubjectsTableCreateCompanionBuilder =
    GoalSubjectsCompanion Function({
      Value<int> id,
      required int sessionId,
      required String name,
      required bool isCompleted,
    });
typedef $$GoalSubjectsTableUpdateCompanionBuilder =
    GoalSubjectsCompanion Function({
      Value<int> id,
      Value<int> sessionId,
      Value<String> name,
      Value<bool> isCompleted,
    });

final class $$GoalSubjectsTableReferences
    extends BaseReferences<_$AppDatabase, $GoalSubjectsTable, GoalSubject> {
  $$GoalSubjectsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TimetableSessionsTable _sessionIdTable(_$AppDatabase db) =>
      db.timetableSessions.createAlias(
        $_aliasNameGenerator(
          db.goalSubjects.sessionId,
          db.timetableSessions.id,
        ),
      );

  $$TimetableSessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<int>('session_id')!;

    final manager = $$TimetableSessionsTableTableManager(
      $_db,
      $_db.timetableSessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$GoalSubjectsTableFilterComposer
    extends Composer<_$AppDatabase, $GoalSubjectsTable> {
  $$GoalSubjectsTableFilterComposer({
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

  $$TimetableSessionsTableFilterComposer get sessionId {
    final $$TimetableSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.timetableSessions,
      getReferencedColumn: (t) => t.id,
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
    return composer;
  }
}

class $$GoalSubjectsTableOrderingComposer
    extends Composer<_$AppDatabase, $GoalSubjectsTable> {
  $$GoalSubjectsTableOrderingComposer({
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

  $$TimetableSessionsTableOrderingComposer get sessionId {
    final $$TimetableSessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.timetableSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TimetableSessionsTableOrderingComposer(
            $db: $db,
            $table: $db.timetableSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GoalSubjectsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GoalSubjectsTable> {
  $$GoalSubjectsTableAnnotationComposer({
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

  $$TimetableSessionsTableAnnotationComposer get sessionId {
    final $$TimetableSessionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.sessionId,
          referencedTable: $db.timetableSessions,
          getReferencedColumn: (t) => t.id,
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
    return composer;
  }
}

class $$GoalSubjectsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GoalSubjectsTable,
          GoalSubject,
          $$GoalSubjectsTableFilterComposer,
          $$GoalSubjectsTableOrderingComposer,
          $$GoalSubjectsTableAnnotationComposer,
          $$GoalSubjectsTableCreateCompanionBuilder,
          $$GoalSubjectsTableUpdateCompanionBuilder,
          (GoalSubject, $$GoalSubjectsTableReferences),
          GoalSubject,
          PrefetchHooks Function({bool sessionId})
        > {
  $$GoalSubjectsTableTableManager(_$AppDatabase db, $GoalSubjectsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GoalSubjectsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GoalSubjectsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GoalSubjectsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> sessionId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
              }) => GoalSubjectsCompanion(
                id: id,
                sessionId: sessionId,
                name: name,
                isCompleted: isCompleted,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int sessionId,
                required String name,
                required bool isCompleted,
              }) => GoalSubjectsCompanion.insert(
                id: id,
                sessionId: sessionId,
                name: name,
                isCompleted: isCompleted,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$GoalSubjectsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false}) {
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
                    if (sessionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sessionId,
                                referencedTable: $$GoalSubjectsTableReferences
                                    ._sessionIdTable(db),
                                referencedColumn: $$GoalSubjectsTableReferences
                                    ._sessionIdTable(db)
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

typedef $$GoalSubjectsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GoalSubjectsTable,
      GoalSubject,
      $$GoalSubjectsTableFilterComposer,
      $$GoalSubjectsTableOrderingComposer,
      $$GoalSubjectsTableAnnotationComposer,
      $$GoalSubjectsTableCreateCompanionBuilder,
      $$GoalSubjectsTableUpdateCompanionBuilder,
      (GoalSubject, $$GoalSubjectsTableReferences),
      GoalSubject,
      PrefetchHooks Function({bool sessionId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$BookTableTableManager get book => $$BookTableTableManager(_db, _db.book);
  $$TimetableDaysTableTableManager get timetableDays =>
      $$TimetableDaysTableTableManager(_db, _db.timetableDays);
  $$TimetableSessionsTableTableManager get timetableSessions =>
      $$TimetableSessionsTableTableManager(_db, _db.timetableSessions);
  $$GoalSubjectsTableTableManager get goalSubjects =>
      $$GoalSubjectsTableTableManager(_db, _db.goalSubjects);
}
