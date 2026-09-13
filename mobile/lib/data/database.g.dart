part of 'database.dart';


class $SubjectsTable extends Subjects with TableInfo<$SubjectsTable, Subject> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SubjectsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accentIndexMeta = const VerificationMeta(
    'accentIndex',
  );
  @override
  late final GeneratedColumn<int> accentIndex = GeneratedColumn<int>(
    'accent_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _archivedAtMeta = const VerificationMeta(
    'archivedAt',
  );
  @override
  late final GeneratedColumn<DateTime> archivedAt = GeneratedColumn<DateTime>(
    'archived_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    accentIndex,
    createdAt,
    archivedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'subjects';
  @override
  VerificationContext validateIntegrity(
    Insertable<Subject> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('accent_index')) {
      context.handle(
        _accentIndexMeta,
        accentIndex.isAcceptableOrUnknown(
          data['accent_index']!,
          _accentIndexMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('archived_at')) {
      context.handle(
        _archivedAtMeta,
        archivedAt.isAcceptableOrUnknown(data['archived_at']!, _archivedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Subject map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Subject(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      accentIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}accent_index'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      archivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}archived_at'],
      ),
    );
  }

  @override
  $SubjectsTable createAlias(String alias) {
    return $SubjectsTable(attachedDatabase, alias);
  }
}

class Subject extends DataClass implements Insertable<Subject> {
  final String id;
  final String name;


  final int accentIndex;
  final DateTime createdAt;
  final DateTime? archivedAt;
  const Subject({
    required this.id,
    required this.name,
    required this.accentIndex,
    required this.createdAt,
    this.archivedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['accent_index'] = Variable<int>(accentIndex);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || archivedAt != null) {
      map['archived_at'] = Variable<DateTime>(archivedAt);
    }
    return map;
  }

  SubjectsCompanion toCompanion(bool nullToAbsent) {
    return SubjectsCompanion(
      id: Value(id),
      name: Value(name),
      accentIndex: Value(accentIndex),
      createdAt: Value(createdAt),
      archivedAt: archivedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(archivedAt),
    );
  }

  factory Subject.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Subject(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      accentIndex: serializer.fromJson<int>(json['accentIndex']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      archivedAt: serializer.fromJson<DateTime?>(json['archivedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'accentIndex': serializer.toJson<int>(accentIndex),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'archivedAt': serializer.toJson<DateTime?>(archivedAt),
    };
  }

  Subject copyWith({
    String? id,
    String? name,
    int? accentIndex,
    DateTime? createdAt,
    Value<DateTime?> archivedAt = const Value.absent(),
  }) => Subject(
    id: id ?? this.id,
    name: name ?? this.name,
    accentIndex: accentIndex ?? this.accentIndex,
    createdAt: createdAt ?? this.createdAt,
    archivedAt: archivedAt.present ? archivedAt.value : this.archivedAt,
  );
  Subject copyWithCompanion(SubjectsCompanion data) {
    return Subject(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      accentIndex: data.accentIndex.present
          ? data.accentIndex.value
          : this.accentIndex,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      archivedAt: data.archivedAt.present
          ? data.archivedAt.value
          : this.archivedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Subject(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('accentIndex: $accentIndex, ')
          ..write('createdAt: $createdAt, ')
          ..write('archivedAt: $archivedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, accentIndex, createdAt, archivedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Subject &&
          other.id == this.id &&
          other.name == this.name &&
          other.accentIndex == this.accentIndex &&
          other.createdAt == this.createdAt &&
          other.archivedAt == this.archivedAt);
}

class SubjectsCompanion extends UpdateCompanion<Subject> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> accentIndex;
  final Value<DateTime> createdAt;
  final Value<DateTime?> archivedAt;
  final Value<int> rowid;
  const SubjectsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.accentIndex = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SubjectsCompanion.insert({
    required String id,
    required String name,
    this.accentIndex = const Value.absent(),
    required DateTime createdAt,
    this.archivedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAt = Value(createdAt);
  static Insertable<Subject> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? accentIndex,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? archivedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (accentIndex != null) 'accent_index': accentIndex,
      if (createdAt != null) 'created_at': createdAt,
      if (archivedAt != null) 'archived_at': archivedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SubjectsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<int>? accentIndex,
    Value<DateTime>? createdAt,
    Value<DateTime?>? archivedAt,
    Value<int>? rowid,
  }) {
    return SubjectsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      accentIndex: accentIndex ?? this.accentIndex,
      createdAt: createdAt ?? this.createdAt,
      archivedAt: archivedAt ?? this.archivedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (accentIndex.present) {
      map['accent_index'] = Variable<int>(accentIndex.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (archivedAt.present) {
      map['archived_at'] = Variable<DateTime>(archivedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SubjectsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('accentIndex: $accentIndex, ')
          ..write('createdAt: $createdAt, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SourcesTable extends Sources with TableInfo<$SourcesTable, Source> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SourcesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subjectIdMeta = const VerificationMeta(
    'subjectId',
  );
  @override
  late final GeneratedColumn<String> subjectId = GeneratedColumn<String>(
    'subject_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES subjects (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 300,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _filePathMeta = const VerificationMeta(
    'filePath',
  );
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
    'file_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bytesMeta = const VerificationMeta('bytes');
  @override
  late final GeneratedColumn<int> bytes = GeneratedColumn<int>(
    'bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _pageCountMeta = const VerificationMeta(
    'pageCount',
  );
  @override
  late final GeneratedColumn<int> pageCount = GeneratedColumn<int>(
    'page_count',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastPageMeta = const VerificationMeta(
    'lastPage',
  );
  @override
  late final GeneratedColumn<int> lastPage = GeneratedColumn<int>(
    'last_page',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addedAtMeta = const VerificationMeta(
    'addedAt',
  );
  @override
  late final GeneratedColumn<DateTime> addedAt = GeneratedColumn<DateTime>(
    'added_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastOpenedAtMeta = const VerificationMeta(
    'lastOpenedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastOpenedAt = GeneratedColumn<DateTime>(
    'last_opened_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    subjectId,
    title,
    filePath,
    bytes,
    pageCount,
    lastPage,
    addedAt,
    lastOpenedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sources';
  @override
  VerificationContext validateIntegrity(
    Insertable<Source> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('subject_id')) {
      context.handle(
        _subjectIdMeta,
        subjectId.isAcceptableOrUnknown(data['subject_id']!, _subjectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_subjectIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('file_path')) {
      context.handle(
        _filePathMeta,
        filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta),
      );
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    if (data.containsKey('bytes')) {
      context.handle(
        _bytesMeta,
        bytes.isAcceptableOrUnknown(data['bytes']!, _bytesMeta),
      );
    }
    if (data.containsKey('page_count')) {
      context.handle(
        _pageCountMeta,
        pageCount.isAcceptableOrUnknown(data['page_count']!, _pageCountMeta),
      );
    }
    if (data.containsKey('last_page')) {
      context.handle(
        _lastPageMeta,
        lastPage.isAcceptableOrUnknown(data['last_page']!, _lastPageMeta),
      );
    }
    if (data.containsKey('added_at')) {
      context.handle(
        _addedAtMeta,
        addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_addedAtMeta);
    }
    if (data.containsKey('last_opened_at')) {
      context.handle(
        _lastOpenedAtMeta,
        lastOpenedAt.isAcceptableOrUnknown(
          data['last_opened_at']!,
          _lastOpenedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Source map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Source(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      subjectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subject_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      filePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_path'],
      )!,
      bytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bytes'],
      )!,
      pageCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}page_count'],
      ),
      lastPage: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_page'],
      ),
      addedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}added_at'],
      )!,
      lastOpenedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_opened_at'],
      ),
    );
  }

  @override
  $SourcesTable createAlias(String alias) {
    return $SourcesTable(attachedDatabase, alias);
  }
}

class Source extends DataClass implements Insertable<Source> {
  final String id;
  final String subjectId;
  final String title;


  final String filePath;
  final int bytes;
  final int? pageCount;


  final int? lastPage;
  final DateTime addedAt;
  final DateTime? lastOpenedAt;
  const Source({
    required this.id,
    required this.subjectId,
    required this.title,
    required this.filePath,
    required this.bytes,
    this.pageCount,
    this.lastPage,
    required this.addedAt,
    this.lastOpenedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['subject_id'] = Variable<String>(subjectId);
    map['title'] = Variable<String>(title);
    map['file_path'] = Variable<String>(filePath);
    map['bytes'] = Variable<int>(bytes);
    if (!nullToAbsent || pageCount != null) {
      map['page_count'] = Variable<int>(pageCount);
    }
    if (!nullToAbsent || lastPage != null) {
      map['last_page'] = Variable<int>(lastPage);
    }
    map['added_at'] = Variable<DateTime>(addedAt);
    if (!nullToAbsent || lastOpenedAt != null) {
      map['last_opened_at'] = Variable<DateTime>(lastOpenedAt);
    }
    return map;
  }

  SourcesCompanion toCompanion(bool nullToAbsent) {
    return SourcesCompanion(
      id: Value(id),
      subjectId: Value(subjectId),
      title: Value(title),
      filePath: Value(filePath),
      bytes: Value(bytes),
      pageCount: pageCount == null && nullToAbsent
          ? const Value.absent()
          : Value(pageCount),
      lastPage: lastPage == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPage),
      addedAt: Value(addedAt),
      lastOpenedAt: lastOpenedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastOpenedAt),
    );
  }

  factory Source.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Source(
      id: serializer.fromJson<String>(json['id']),
      subjectId: serializer.fromJson<String>(json['subjectId']),
      title: serializer.fromJson<String>(json['title']),
      filePath: serializer.fromJson<String>(json['filePath']),
      bytes: serializer.fromJson<int>(json['bytes']),
      pageCount: serializer.fromJson<int?>(json['pageCount']),
      lastPage: serializer.fromJson<int?>(json['lastPage']),
      addedAt: serializer.fromJson<DateTime>(json['addedAt']),
      lastOpenedAt: serializer.fromJson<DateTime?>(json['lastOpenedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'subjectId': serializer.toJson<String>(subjectId),
      'title': serializer.toJson<String>(title),
      'filePath': serializer.toJson<String>(filePath),
      'bytes': serializer.toJson<int>(bytes),
      'pageCount': serializer.toJson<int?>(pageCount),
      'lastPage': serializer.toJson<int?>(lastPage),
      'addedAt': serializer.toJson<DateTime>(addedAt),
      'lastOpenedAt': serializer.toJson<DateTime?>(lastOpenedAt),
    };
  }

  Source copyWith({
    String? id,
    String? subjectId,
    String? title,
    String? filePath,
    int? bytes,
    Value<int?> pageCount = const Value.absent(),
    Value<int?> lastPage = const Value.absent(),
    DateTime? addedAt,
    Value<DateTime?> lastOpenedAt = const Value.absent(),
  }) => Source(
    id: id ?? this.id,
    subjectId: subjectId ?? this.subjectId,
    title: title ?? this.title,
    filePath: filePath ?? this.filePath,
    bytes: bytes ?? this.bytes,
    pageCount: pageCount.present ? pageCount.value : this.pageCount,
    lastPage: lastPage.present ? lastPage.value : this.lastPage,
    addedAt: addedAt ?? this.addedAt,
    lastOpenedAt: lastOpenedAt.present ? lastOpenedAt.value : this.lastOpenedAt,
  );
  Source copyWithCompanion(SourcesCompanion data) {
    return Source(
      id: data.id.present ? data.id.value : this.id,
      subjectId: data.subjectId.present ? data.subjectId.value : this.subjectId,
      title: data.title.present ? data.title.value : this.title,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      bytes: data.bytes.present ? data.bytes.value : this.bytes,
      pageCount: data.pageCount.present ? data.pageCount.value : this.pageCount,
      lastPage: data.lastPage.present ? data.lastPage.value : this.lastPage,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
      lastOpenedAt: data.lastOpenedAt.present
          ? data.lastOpenedAt.value
          : this.lastOpenedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Source(')
          ..write('id: $id, ')
          ..write('subjectId: $subjectId, ')
          ..write('title: $title, ')
          ..write('filePath: $filePath, ')
          ..write('bytes: $bytes, ')
          ..write('pageCount: $pageCount, ')
          ..write('lastPage: $lastPage, ')
          ..write('addedAt: $addedAt, ')
          ..write('lastOpenedAt: $lastOpenedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    subjectId,
    title,
    filePath,
    bytes,
    pageCount,
    lastPage,
    addedAt,
    lastOpenedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Source &&
          other.id == this.id &&
          other.subjectId == this.subjectId &&
          other.title == this.title &&
          other.filePath == this.filePath &&
          other.bytes == this.bytes &&
          other.pageCount == this.pageCount &&
          other.lastPage == this.lastPage &&
          other.addedAt == this.addedAt &&
          other.lastOpenedAt == this.lastOpenedAt);
}

class SourcesCompanion extends UpdateCompanion<Source> {
  final Value<String> id;
  final Value<String> subjectId;
  final Value<String> title;
  final Value<String> filePath;
  final Value<int> bytes;
  final Value<int?> pageCount;
  final Value<int?> lastPage;
  final Value<DateTime> addedAt;
  final Value<DateTime?> lastOpenedAt;
  final Value<int> rowid;
  const SourcesCompanion({
    this.id = const Value.absent(),
    this.subjectId = const Value.absent(),
    this.title = const Value.absent(),
    this.filePath = const Value.absent(),
    this.bytes = const Value.absent(),
    this.pageCount = const Value.absent(),
    this.lastPage = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.lastOpenedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SourcesCompanion.insert({
    required String id,
    required String subjectId,
    required String title,
    required String filePath,
    this.bytes = const Value.absent(),
    this.pageCount = const Value.absent(),
    this.lastPage = const Value.absent(),
    required DateTime addedAt,
    this.lastOpenedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       subjectId = Value(subjectId),
       title = Value(title),
       filePath = Value(filePath),
       addedAt = Value(addedAt);
  static Insertable<Source> custom({
    Expression<String>? id,
    Expression<String>? subjectId,
    Expression<String>? title,
    Expression<String>? filePath,
    Expression<int>? bytes,
    Expression<int>? pageCount,
    Expression<int>? lastPage,
    Expression<DateTime>? addedAt,
    Expression<DateTime>? lastOpenedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (subjectId != null) 'subject_id': subjectId,
      if (title != null) 'title': title,
      if (filePath != null) 'file_path': filePath,
      if (bytes != null) 'bytes': bytes,
      if (pageCount != null) 'page_count': pageCount,
      if (lastPage != null) 'last_page': lastPage,
      if (addedAt != null) 'added_at': addedAt,
      if (lastOpenedAt != null) 'last_opened_at': lastOpenedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SourcesCompanion copyWith({
    Value<String>? id,
    Value<String>? subjectId,
    Value<String>? title,
    Value<String>? filePath,
    Value<int>? bytes,
    Value<int?>? pageCount,
    Value<int?>? lastPage,
    Value<DateTime>? addedAt,
    Value<DateTime?>? lastOpenedAt,
    Value<int>? rowid,
  }) {
    return SourcesCompanion(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      title: title ?? this.title,
      filePath: filePath ?? this.filePath,
      bytes: bytes ?? this.bytes,
      pageCount: pageCount ?? this.pageCount,
      lastPage: lastPage ?? this.lastPage,
      addedAt: addedAt ?? this.addedAt,
      lastOpenedAt: lastOpenedAt ?? this.lastOpenedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (subjectId.present) {
      map['subject_id'] = Variable<String>(subjectId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (bytes.present) {
      map['bytes'] = Variable<int>(bytes.value);
    }
    if (pageCount.present) {
      map['page_count'] = Variable<int>(pageCount.value);
    }
    if (lastPage.present) {
      map['last_page'] = Variable<int>(lastPage.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<DateTime>(addedAt.value);
    }
    if (lastOpenedAt.present) {
      map['last_opened_at'] = Variable<DateTime>(lastOpenedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SourcesCompanion(')
          ..write('id: $id, ')
          ..write('subjectId: $subjectId, ')
          ..write('title: $title, ')
          ..write('filePath: $filePath, ')
          ..write('bytes: $bytes, ')
          ..write('pageCount: $pageCount, ')
          ..write('lastPage: $lastPage, ')
          ..write('addedAt: $addedAt, ')
          ..write('lastOpenedAt: $lastOpenedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SessionsTable extends Sessions with TableInfo<$SessionsTable, Session> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subjectIdMeta = const VerificationMeta(
    'subjectId',
  );
  @override
  late final GeneratedColumn<String> subjectId = GeneratedColumn<String>(
    'subject_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES subjects (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _sourceIdMeta = const VerificationMeta(
    'sourceId',
  );
  @override
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
    'source_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sources (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _canonicalStartedAtMeta =
      const VerificationMeta('canonicalStartedAt');
  @override
  late final GeneratedColumn<DateTime> canonicalStartedAt =
      GeneratedColumn<DateTime>(
        'canonical_started_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _plannedEndAtMeta = const VerificationMeta(
    'plannedEndAt',
  );
  @override
  late final GeneratedColumn<DateTime> plannedEndAt = GeneratedColumn<DateTime>(
    'planned_end_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
    'ended_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _plannedMinutesMeta = const VerificationMeta(
    'plannedMinutes',
  );
  @override
  late final GeneratedColumn<int> plannedMinutes = GeneratedColumn<int>(
    'planned_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(25),
  );
  static const VerificationMeta _focusedMinutesMeta = const VerificationMeta(
    'focusedMinutes',
  );
  @override
  late final GeneratedColumn<int> focusedMinutes = GeneratedColumn<int>(
    'focused_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _pausedSecondsMeta = const VerificationMeta(
    'pausedSeconds',
  );
  @override
  late final GeneratedColumn<int> pausedSeconds = GeneratedColumn<int>(
    'paused_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _pauseStartedAtMeta = const VerificationMeta(
    'pauseStartedAt',
  );
  @override
  late final GeneratedColumn<DateTime> pauseStartedAt =
      GeneratedColumn<DateTime>(
        'pause_started_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  late final GeneratedColumnWithTypeConverter<SessionStatus, int> status =
      GeneratedColumn<int>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<SessionStatus>($SessionsTable.$converterstatus);
  @override
  late final GeneratedColumnWithTypeConverter<SignalOrigin, int> signalOrigin =
      GeneratedColumn<int>(
        'signal_origin',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<SignalOrigin>($SessionsTable.$convertersignalOrigin);
  static const VerificationMeta _hsiFocusMeta = const VerificationMeta(
    'hsiFocus',
  );
  @override
  late final GeneratedColumn<double> hsiFocus = GeneratedColumn<double>(
    'hsi_focus',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hsiFocusConfidenceMeta =
      const VerificationMeta('hsiFocusConfidence');
  @override
  late final GeneratedColumn<double> hsiFocusConfidence =
      GeneratedColumn<double>(
        'hsi_focus_confidence',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _hsiCapacityMeta = const VerificationMeta(
    'hsiCapacity',
  );
  @override
  late final GeneratedColumn<double> hsiCapacity = GeneratedColumn<double>(
    'hsi_capacity',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hsiCapacityConfidenceMeta =
      const VerificationMeta('hsiCapacityConfidence');
  @override
  late final GeneratedColumn<double> hsiCapacityConfidence =
      GeneratedColumn<double>(
        'hsi_capacity_confidence',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _hsiArousalMeta = const VerificationMeta(
    'hsiArousal',
  );
  @override
  late final GeneratedColumn<double> hsiArousal = GeneratedColumn<double>(
    'hsi_arousal',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hsiArousalConfidenceMeta =
      const VerificationMeta('hsiArousalConfidence');
  @override
  late final GeneratedColumn<double> hsiArousalConfidence =
      GeneratedColumn<double>(
        'hsi_arousal_confidence',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _hsiStressMeta = const VerificationMeta(
    'hsiStress',
  );
  @override
  late final GeneratedColumn<double> hsiStress = GeneratedColumn<double>(
    'hsi_stress',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hsiStressConfidenceMeta =
      const VerificationMeta('hsiStressConfidence');
  @override
  late final GeneratedColumn<double> hsiStressConfidence =
      GeneratedColumn<double>(
        'hsi_stress_confidence',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _hsiQualityMeta = const VerificationMeta(
    'hsiQuality',
  );
  @override
  late final GeneratedColumn<double> hsiQuality = GeneratedColumn<double>(
    'hsi_quality',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _synheartSessionIdMeta = const VerificationMeta(
    'synheartSessionId',
  );
  @override
  late final GeneratedColumn<String> synheartSessionId =
      GeneratedColumn<String>(
        'synheart_session_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _watchSessionIdMeta = const VerificationMeta(
    'watchSessionId',
  );
  @override
  late final GeneratedColumn<String> watchSessionId = GeneratedColumn<String>(
    'watch_session_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _acceptedSamplesMeta = const VerificationMeta(
    'acceptedSamples',
  );
  @override
  late final GeneratedColumn<int> acceptedSamples = GeneratedColumn<int>(
    'accepted_samples',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _totalSamplesMeta = const VerificationMeta(
    'totalSamples',
  );
  @override
  late final GeneratedColumn<int> totalSamples = GeneratedColumn<int>(
    'total_samples',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _coverageSecondsMeta = const VerificationMeta(
    'coverageSeconds',
  );
  @override
  late final GeneratedColumn<int> coverageSeconds = GeneratedColumn<int>(
    'coverage_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _accuracyHighMeta = const VerificationMeta(
    'accuracyHigh',
  );
  @override
  late final GeneratedColumn<int> accuracyHigh = GeneratedColumn<int>(
    'accuracy_high',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _accuracyMediumMeta = const VerificationMeta(
    'accuracyMedium',
  );
  @override
  late final GeneratedColumn<int> accuracyMedium = GeneratedColumn<int>(
    'accuracy_medium',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _accuracyLowMeta = const VerificationMeta(
    'accuracyLow',
  );
  @override
  late final GeneratedColumn<int> accuracyLow = GeneratedColumn<int>(
    'accuracy_low',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _hsiWindowCountMeta = const VerificationMeta(
    'hsiWindowCount',
  );
  @override
  late final GeneratedColumn<int> hsiWindowCount = GeneratedColumn<int>(
    'hsi_window_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  late final GeneratedColumnWithTypeConverter<SyncState, int> syncState =
      GeneratedColumn<int>(
        'sync_state',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: Constant(SyncState.localOnly.index),
      ).withConverter<SyncState>($SessionsTable.$convertersyncState);
  static const VerificationMeta _uploadedCountMeta = const VerificationMeta(
    'uploadedCount',
  );
  @override
  late final GeneratedColumn<int> uploadedCount = GeneratedColumn<int>(
    'uploaded_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _uploadAttemptedAtMeta = const VerificationMeta(
    'uploadAttemptedAt',
  );
  @override
  late final GeneratedColumn<DateTime> uploadAttemptedAt =
      GeneratedColumn<DateTime>(
        'upload_attempted_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _syncErrorMeta = const VerificationMeta(
    'syncError',
  );
  @override
  late final GeneratedColumn<String> syncError = GeneratedColumn<String>(
    'sync_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    subjectId,
    sourceId,
    startedAt,
    canonicalStartedAt,
    plannedEndAt,
    endedAt,
    plannedMinutes,
    focusedMinutes,
    pausedSeconds,
    pauseStartedAt,
    status,
    signalOrigin,
    hsiFocus,
    hsiFocusConfidence,
    hsiCapacity,
    hsiCapacityConfidence,
    hsiArousal,
    hsiArousalConfidence,
    hsiStress,
    hsiStressConfidence,
    hsiQuality,
    synheartSessionId,
    watchSessionId,
    acceptedSamples,
    totalSamples,
    coverageSeconds,
    accuracyHigh,
    accuracyMedium,
    accuracyLow,
    hsiWindowCount,
    syncState,
    uploadedCount,
    uploadAttemptedAt,
    syncError,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Session> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('subject_id')) {
      context.handle(
        _subjectIdMeta,
        subjectId.isAcceptableOrUnknown(data['subject_id']!, _subjectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_subjectIdMeta);
    }
    if (data.containsKey('source_id')) {
      context.handle(
        _sourceIdMeta,
        sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta),
      );
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('canonical_started_at')) {
      context.handle(
        _canonicalStartedAtMeta,
        canonicalStartedAt.isAcceptableOrUnknown(
          data['canonical_started_at']!,
          _canonicalStartedAtMeta,
        ),
      );
    }
    if (data.containsKey('planned_end_at')) {
      context.handle(
        _plannedEndAtMeta,
        plannedEndAt.isAcceptableOrUnknown(
          data['planned_end_at']!,
          _plannedEndAtMeta,
        ),
      );
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    }
    if (data.containsKey('planned_minutes')) {
      context.handle(
        _plannedMinutesMeta,
        plannedMinutes.isAcceptableOrUnknown(
          data['planned_minutes']!,
          _plannedMinutesMeta,
        ),
      );
    }
    if (data.containsKey('focused_minutes')) {
      context.handle(
        _focusedMinutesMeta,
        focusedMinutes.isAcceptableOrUnknown(
          data['focused_minutes']!,
          _focusedMinutesMeta,
        ),
      );
    }
    if (data.containsKey('paused_seconds')) {
      context.handle(
        _pausedSecondsMeta,
        pausedSeconds.isAcceptableOrUnknown(
          data['paused_seconds']!,
          _pausedSecondsMeta,
        ),
      );
    }
    if (data.containsKey('pause_started_at')) {
      context.handle(
        _pauseStartedAtMeta,
        pauseStartedAt.isAcceptableOrUnknown(
          data['pause_started_at']!,
          _pauseStartedAtMeta,
        ),
      );
    }
    if (data.containsKey('hsi_focus')) {
      context.handle(
        _hsiFocusMeta,
        hsiFocus.isAcceptableOrUnknown(data['hsi_focus']!, _hsiFocusMeta),
      );
    }
    if (data.containsKey('hsi_focus_confidence')) {
      context.handle(
        _hsiFocusConfidenceMeta,
        hsiFocusConfidence.isAcceptableOrUnknown(
          data['hsi_focus_confidence']!,
          _hsiFocusConfidenceMeta,
        ),
      );
    }
    if (data.containsKey('hsi_capacity')) {
      context.handle(
        _hsiCapacityMeta,
        hsiCapacity.isAcceptableOrUnknown(
          data['hsi_capacity']!,
          _hsiCapacityMeta,
        ),
      );
    }
    if (data.containsKey('hsi_capacity_confidence')) {
      context.handle(
        _hsiCapacityConfidenceMeta,
        hsiCapacityConfidence.isAcceptableOrUnknown(
          data['hsi_capacity_confidence']!,
          _hsiCapacityConfidenceMeta,
        ),
      );
    }
    if (data.containsKey('hsi_arousal')) {
      context.handle(
        _hsiArousalMeta,
        hsiArousal.isAcceptableOrUnknown(data['hsi_arousal']!, _hsiArousalMeta),
      );
    }
    if (data.containsKey('hsi_arousal_confidence')) {
      context.handle(
        _hsiArousalConfidenceMeta,
        hsiArousalConfidence.isAcceptableOrUnknown(
          data['hsi_arousal_confidence']!,
          _hsiArousalConfidenceMeta,
        ),
      );
    }
    if (data.containsKey('hsi_stress')) {
      context.handle(
        _hsiStressMeta,
        hsiStress.isAcceptableOrUnknown(data['hsi_stress']!, _hsiStressMeta),
      );
    }
    if (data.containsKey('hsi_stress_confidence')) {
      context.handle(
        _hsiStressConfidenceMeta,
        hsiStressConfidence.isAcceptableOrUnknown(
          data['hsi_stress_confidence']!,
          _hsiStressConfidenceMeta,
        ),
      );
    }
    if (data.containsKey('hsi_quality')) {
      context.handle(
        _hsiQualityMeta,
        hsiQuality.isAcceptableOrUnknown(data['hsi_quality']!, _hsiQualityMeta),
      );
    }
    if (data.containsKey('synheart_session_id')) {
      context.handle(
        _synheartSessionIdMeta,
        synheartSessionId.isAcceptableOrUnknown(
          data['synheart_session_id']!,
          _synheartSessionIdMeta,
        ),
      );
    }
    if (data.containsKey('watch_session_id')) {
      context.handle(
        _watchSessionIdMeta,
        watchSessionId.isAcceptableOrUnknown(
          data['watch_session_id']!,
          _watchSessionIdMeta,
        ),
      );
    }
    if (data.containsKey('accepted_samples')) {
      context.handle(
        _acceptedSamplesMeta,
        acceptedSamples.isAcceptableOrUnknown(
          data['accepted_samples']!,
          _acceptedSamplesMeta,
        ),
      );
    }
    if (data.containsKey('total_samples')) {
      context.handle(
        _totalSamplesMeta,
        totalSamples.isAcceptableOrUnknown(
          data['total_samples']!,
          _totalSamplesMeta,
        ),
      );
    }
    if (data.containsKey('coverage_seconds')) {
      context.handle(
        _coverageSecondsMeta,
        coverageSeconds.isAcceptableOrUnknown(
          data['coverage_seconds']!,
          _coverageSecondsMeta,
        ),
      );
    }
    if (data.containsKey('accuracy_high')) {
      context.handle(
        _accuracyHighMeta,
        accuracyHigh.isAcceptableOrUnknown(
          data['accuracy_high']!,
          _accuracyHighMeta,
        ),
      );
    }
    if (data.containsKey('accuracy_medium')) {
      context.handle(
        _accuracyMediumMeta,
        accuracyMedium.isAcceptableOrUnknown(
          data['accuracy_medium']!,
          _accuracyMediumMeta,
        ),
      );
    }
    if (data.containsKey('accuracy_low')) {
      context.handle(
        _accuracyLowMeta,
        accuracyLow.isAcceptableOrUnknown(
          data['accuracy_low']!,
          _accuracyLowMeta,
        ),
      );
    }
    if (data.containsKey('hsi_window_count')) {
      context.handle(
        _hsiWindowCountMeta,
        hsiWindowCount.isAcceptableOrUnknown(
          data['hsi_window_count']!,
          _hsiWindowCountMeta,
        ),
      );
    }
    if (data.containsKey('uploaded_count')) {
      context.handle(
        _uploadedCountMeta,
        uploadedCount.isAcceptableOrUnknown(
          data['uploaded_count']!,
          _uploadedCountMeta,
        ),
      );
    }
    if (data.containsKey('upload_attempted_at')) {
      context.handle(
        _uploadAttemptedAtMeta,
        uploadAttemptedAt.isAcceptableOrUnknown(
          data['upload_attempted_at']!,
          _uploadAttemptedAtMeta,
        ),
      );
    }
    if (data.containsKey('sync_error')) {
      context.handle(
        _syncErrorMeta,
        syncError.isAcceptableOrUnknown(data['sync_error']!, _syncErrorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Session map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Session(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      subjectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subject_id'],
      )!,
      sourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_id'],
      ),
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      canonicalStartedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}canonical_started_at'],
      ),
      plannedEndAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}planned_end_at'],
      ),
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ended_at'],
      ),
      plannedMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}planned_minutes'],
      )!,
      focusedMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}focused_minutes'],
      )!,
      pausedSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}paused_seconds'],
      )!,
      pauseStartedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}pause_started_at'],
      ),
      status: $SessionsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}status'],
        )!,
      ),
      signalOrigin: $SessionsTable.$convertersignalOrigin.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}signal_origin'],
        )!,
      ),
      hsiFocus: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}hsi_focus'],
      ),
      hsiFocusConfidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}hsi_focus_confidence'],
      ),
      hsiCapacity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}hsi_capacity'],
      ),
      hsiCapacityConfidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}hsi_capacity_confidence'],
      ),
      hsiArousal: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}hsi_arousal'],
      ),
      hsiArousalConfidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}hsi_arousal_confidence'],
      ),
      hsiStress: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}hsi_stress'],
      ),
      hsiStressConfidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}hsi_stress_confidence'],
      ),
      hsiQuality: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}hsi_quality'],
      ),
      synheartSessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}synheart_session_id'],
      ),
      watchSessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}watch_session_id'],
      ),
      acceptedSamples: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}accepted_samples'],
      )!,
      totalSamples: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_samples'],
      )!,
      coverageSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}coverage_seconds'],
      )!,
      accuracyHigh: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}accuracy_high'],
      )!,
      accuracyMedium: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}accuracy_medium'],
      )!,
      accuracyLow: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}accuracy_low'],
      )!,
      hsiWindowCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hsi_window_count'],
      )!,
      syncState: $SessionsTable.$convertersyncState.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}sync_state'],
        )!,
      ),
      uploadedCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}uploaded_count'],
      )!,
      uploadAttemptedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}upload_attempted_at'],
      ),
      syncError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_error'],
      ),
    );
  }

  @override
  $SessionsTable createAlias(String alias) {
    return $SessionsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SessionStatus, int, int> $converterstatus =
      const EnumIndexConverter<SessionStatus>(SessionStatus.values);
  static JsonTypeConverter2<SignalOrigin, int, int> $convertersignalOrigin =
      const EnumIndexConverter<SignalOrigin>(SignalOrigin.values);
  static JsonTypeConverter2<SyncState, int, int> $convertersyncState =
      const EnumIndexConverter<SyncState>(SyncState.values);
}

class Session extends DataClass implements Insertable<Session> {
  final String id;
  final String subjectId;


  final String? sourceId;
  final DateTime startedAt;
  final DateTime? canonicalStartedAt;
  final DateTime? plannedEndAt;
  final DateTime? endedAt;
  final int plannedMinutes;


  final int focusedMinutes;


  final int pausedSeconds;
  final DateTime? pauseStartedAt;
  final SessionStatus status;
  final SignalOrigin signalOrigin;


  final double? hsiFocus;
  final double? hsiFocusConfidence;
  final double? hsiCapacity;
  final double? hsiCapacityConfidence;
  final double? hsiArousal;
  final double? hsiArousalConfidence;
  final double? hsiStress;
  final double? hsiStressConfidence;
  final double? hsiQuality;


  final String? synheartSessionId;
  final String? watchSessionId;
  final int acceptedSamples;
  final int totalSamples;
  final int coverageSeconds;
  final int accuracyHigh;
  final int accuracyMedium;
  final int accuracyLow;
  final int hsiWindowCount;
  final SyncState syncState;
  final int uploadedCount;
  final DateTime? uploadAttemptedAt;
  final String? syncError;
  const Session({
    required this.id,
    required this.subjectId,
    this.sourceId,
    required this.startedAt,
    this.canonicalStartedAt,
    this.plannedEndAt,
    this.endedAt,
    required this.plannedMinutes,
    required this.focusedMinutes,
    required this.pausedSeconds,
    this.pauseStartedAt,
    required this.status,
    required this.signalOrigin,
    this.hsiFocus,
    this.hsiFocusConfidence,
    this.hsiCapacity,
    this.hsiCapacityConfidence,
    this.hsiArousal,
    this.hsiArousalConfidence,
    this.hsiStress,
    this.hsiStressConfidence,
    this.hsiQuality,
    this.synheartSessionId,
    this.watchSessionId,
    required this.acceptedSamples,
    required this.totalSamples,
    required this.coverageSeconds,
    required this.accuracyHigh,
    required this.accuracyMedium,
    required this.accuracyLow,
    required this.hsiWindowCount,
    required this.syncState,
    required this.uploadedCount,
    this.uploadAttemptedAt,
    this.syncError,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['subject_id'] = Variable<String>(subjectId);
    if (!nullToAbsent || sourceId != null) {
      map['source_id'] = Variable<String>(sourceId);
    }
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || canonicalStartedAt != null) {
      map['canonical_started_at'] = Variable<DateTime>(canonicalStartedAt);
    }
    if (!nullToAbsent || plannedEndAt != null) {
      map['planned_end_at'] = Variable<DateTime>(plannedEndAt);
    }
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<DateTime>(endedAt);
    }
    map['planned_minutes'] = Variable<int>(plannedMinutes);
    map['focused_minutes'] = Variable<int>(focusedMinutes);
    map['paused_seconds'] = Variable<int>(pausedSeconds);
    if (!nullToAbsent || pauseStartedAt != null) {
      map['pause_started_at'] = Variable<DateTime>(pauseStartedAt);
    }
    {
      map['status'] = Variable<int>(
        $SessionsTable.$converterstatus.toSql(status),
      );
    }
    {
      map['signal_origin'] = Variable<int>(
        $SessionsTable.$convertersignalOrigin.toSql(signalOrigin),
      );
    }
    if (!nullToAbsent || hsiFocus != null) {
      map['hsi_focus'] = Variable<double>(hsiFocus);
    }
    if (!nullToAbsent || hsiFocusConfidence != null) {
      map['hsi_focus_confidence'] = Variable<double>(hsiFocusConfidence);
    }
    if (!nullToAbsent || hsiCapacity != null) {
      map['hsi_capacity'] = Variable<double>(hsiCapacity);
    }
    if (!nullToAbsent || hsiCapacityConfidence != null) {
      map['hsi_capacity_confidence'] = Variable<double>(hsiCapacityConfidence);
    }
    if (!nullToAbsent || hsiArousal != null) {
      map['hsi_arousal'] = Variable<double>(hsiArousal);
    }
    if (!nullToAbsent || hsiArousalConfidence != null) {
      map['hsi_arousal_confidence'] = Variable<double>(hsiArousalConfidence);
    }
    if (!nullToAbsent || hsiStress != null) {
      map['hsi_stress'] = Variable<double>(hsiStress);
    }
    if (!nullToAbsent || hsiStressConfidence != null) {
      map['hsi_stress_confidence'] = Variable<double>(hsiStressConfidence);
    }
    if (!nullToAbsent || hsiQuality != null) {
      map['hsi_quality'] = Variable<double>(hsiQuality);
    }
    if (!nullToAbsent || synheartSessionId != null) {
      map['synheart_session_id'] = Variable<String>(synheartSessionId);
    }
    if (!nullToAbsent || watchSessionId != null) {
      map['watch_session_id'] = Variable<String>(watchSessionId);
    }
    map['accepted_samples'] = Variable<int>(acceptedSamples);
    map['total_samples'] = Variable<int>(totalSamples);
    map['coverage_seconds'] = Variable<int>(coverageSeconds);
    map['accuracy_high'] = Variable<int>(accuracyHigh);
    map['accuracy_medium'] = Variable<int>(accuracyMedium);
    map['accuracy_low'] = Variable<int>(accuracyLow);
    map['hsi_window_count'] = Variable<int>(hsiWindowCount);
    {
      map['sync_state'] = Variable<int>(
        $SessionsTable.$convertersyncState.toSql(syncState),
      );
    }
    map['uploaded_count'] = Variable<int>(uploadedCount);
    if (!nullToAbsent || uploadAttemptedAt != null) {
      map['upload_attempted_at'] = Variable<DateTime>(uploadAttemptedAt);
    }
    if (!nullToAbsent || syncError != null) {
      map['sync_error'] = Variable<String>(syncError);
    }
    return map;
  }

  SessionsCompanion toCompanion(bool nullToAbsent) {
    return SessionsCompanion(
      id: Value(id),
      subjectId: Value(subjectId),
      sourceId: sourceId == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceId),
      startedAt: Value(startedAt),
      canonicalStartedAt: canonicalStartedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(canonicalStartedAt),
      plannedEndAt: plannedEndAt == null && nullToAbsent
          ? const Value.absent()
          : Value(plannedEndAt),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
      plannedMinutes: Value(plannedMinutes),
      focusedMinutes: Value(focusedMinutes),
      pausedSeconds: Value(pausedSeconds),
      pauseStartedAt: pauseStartedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(pauseStartedAt),
      status: Value(status),
      signalOrigin: Value(signalOrigin),
      hsiFocus: hsiFocus == null && nullToAbsent
          ? const Value.absent()
          : Value(hsiFocus),
      hsiFocusConfidence: hsiFocusConfidence == null && nullToAbsent
          ? const Value.absent()
          : Value(hsiFocusConfidence),
      hsiCapacity: hsiCapacity == null && nullToAbsent
          ? const Value.absent()
          : Value(hsiCapacity),
      hsiCapacityConfidence: hsiCapacityConfidence == null && nullToAbsent
          ? const Value.absent()
          : Value(hsiCapacityConfidence),
      hsiArousal: hsiArousal == null && nullToAbsent
          ? const Value.absent()
          : Value(hsiArousal),
      hsiArousalConfidence: hsiArousalConfidence == null && nullToAbsent
          ? const Value.absent()
          : Value(hsiArousalConfidence),
      hsiStress: hsiStress == null && nullToAbsent
          ? const Value.absent()
          : Value(hsiStress),
      hsiStressConfidence: hsiStressConfidence == null && nullToAbsent
          ? const Value.absent()
          : Value(hsiStressConfidence),
      hsiQuality: hsiQuality == null && nullToAbsent
          ? const Value.absent()
          : Value(hsiQuality),
      synheartSessionId: synheartSessionId == null && nullToAbsent
          ? const Value.absent()
          : Value(synheartSessionId),
      watchSessionId: watchSessionId == null && nullToAbsent
          ? const Value.absent()
          : Value(watchSessionId),
      acceptedSamples: Value(acceptedSamples),
      totalSamples: Value(totalSamples),
      coverageSeconds: Value(coverageSeconds),
      accuracyHigh: Value(accuracyHigh),
      accuracyMedium: Value(accuracyMedium),
      accuracyLow: Value(accuracyLow),
      hsiWindowCount: Value(hsiWindowCount),
      syncState: Value(syncState),
      uploadedCount: Value(uploadedCount),
      uploadAttemptedAt: uploadAttemptedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(uploadAttemptedAt),
      syncError: syncError == null && nullToAbsent
          ? const Value.absent()
          : Value(syncError),
    );
  }

  factory Session.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Session(
      id: serializer.fromJson<String>(json['id']),
      subjectId: serializer.fromJson<String>(json['subjectId']),
      sourceId: serializer.fromJson<String?>(json['sourceId']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      canonicalStartedAt: serializer.fromJson<DateTime?>(
        json['canonicalStartedAt'],
      ),
      plannedEndAt: serializer.fromJson<DateTime?>(json['plannedEndAt']),
      endedAt: serializer.fromJson<DateTime?>(json['endedAt']),
      plannedMinutes: serializer.fromJson<int>(json['plannedMinutes']),
      focusedMinutes: serializer.fromJson<int>(json['focusedMinutes']),
      pausedSeconds: serializer.fromJson<int>(json['pausedSeconds']),
      pauseStartedAt: serializer.fromJson<DateTime?>(json['pauseStartedAt']),
      status: $SessionsTable.$converterstatus.fromJson(
        serializer.fromJson<int>(json['status']),
      ),
      signalOrigin: $SessionsTable.$convertersignalOrigin.fromJson(
        serializer.fromJson<int>(json['signalOrigin']),
      ),
      hsiFocus: serializer.fromJson<double?>(json['hsiFocus']),
      hsiFocusConfidence: serializer.fromJson<double?>(
        json['hsiFocusConfidence'],
      ),
      hsiCapacity: serializer.fromJson<double?>(json['hsiCapacity']),
      hsiCapacityConfidence: serializer.fromJson<double?>(
        json['hsiCapacityConfidence'],
      ),
      hsiArousal: serializer.fromJson<double?>(json['hsiArousal']),
      hsiArousalConfidence: serializer.fromJson<double?>(
        json['hsiArousalConfidence'],
      ),
      hsiStress: serializer.fromJson<double?>(json['hsiStress']),
      hsiStressConfidence: serializer.fromJson<double?>(
        json['hsiStressConfidence'],
      ),
      hsiQuality: serializer.fromJson<double?>(json['hsiQuality']),
      synheartSessionId: serializer.fromJson<String?>(
        json['synheartSessionId'],
      ),
      watchSessionId: serializer.fromJson<String?>(json['watchSessionId']),
      acceptedSamples: serializer.fromJson<int>(json['acceptedSamples']),
      totalSamples: serializer.fromJson<int>(json['totalSamples']),
      coverageSeconds: serializer.fromJson<int>(json['coverageSeconds']),
      accuracyHigh: serializer.fromJson<int>(json['accuracyHigh']),
      accuracyMedium: serializer.fromJson<int>(json['accuracyMedium']),
      accuracyLow: serializer.fromJson<int>(json['accuracyLow']),
      hsiWindowCount: serializer.fromJson<int>(json['hsiWindowCount']),
      syncState: $SessionsTable.$convertersyncState.fromJson(
        serializer.fromJson<int>(json['syncState']),
      ),
      uploadedCount: serializer.fromJson<int>(json['uploadedCount']),
      uploadAttemptedAt: serializer.fromJson<DateTime?>(
        json['uploadAttemptedAt'],
      ),
      syncError: serializer.fromJson<String?>(json['syncError']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'subjectId': serializer.toJson<String>(subjectId),
      'sourceId': serializer.toJson<String?>(sourceId),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'canonicalStartedAt': serializer.toJson<DateTime?>(canonicalStartedAt),
      'plannedEndAt': serializer.toJson<DateTime?>(plannedEndAt),
      'endedAt': serializer.toJson<DateTime?>(endedAt),
      'plannedMinutes': serializer.toJson<int>(plannedMinutes),
      'focusedMinutes': serializer.toJson<int>(focusedMinutes),
      'pausedSeconds': serializer.toJson<int>(pausedSeconds),
      'pauseStartedAt': serializer.toJson<DateTime?>(pauseStartedAt),
      'status': serializer.toJson<int>(
        $SessionsTable.$converterstatus.toJson(status),
      ),
      'signalOrigin': serializer.toJson<int>(
        $SessionsTable.$convertersignalOrigin.toJson(signalOrigin),
      ),
      'hsiFocus': serializer.toJson<double?>(hsiFocus),
      'hsiFocusConfidence': serializer.toJson<double?>(hsiFocusConfidence),
      'hsiCapacity': serializer.toJson<double?>(hsiCapacity),
      'hsiCapacityConfidence': serializer.toJson<double?>(
        hsiCapacityConfidence,
      ),
      'hsiArousal': serializer.toJson<double?>(hsiArousal),
      'hsiArousalConfidence': serializer.toJson<double?>(hsiArousalConfidence),
      'hsiStress': serializer.toJson<double?>(hsiStress),
      'hsiStressConfidence': serializer.toJson<double?>(hsiStressConfidence),
      'hsiQuality': serializer.toJson<double?>(hsiQuality),
      'synheartSessionId': serializer.toJson<String?>(synheartSessionId),
      'watchSessionId': serializer.toJson<String?>(watchSessionId),
      'acceptedSamples': serializer.toJson<int>(acceptedSamples),
      'totalSamples': serializer.toJson<int>(totalSamples),
      'coverageSeconds': serializer.toJson<int>(coverageSeconds),
      'accuracyHigh': serializer.toJson<int>(accuracyHigh),
      'accuracyMedium': serializer.toJson<int>(accuracyMedium),
      'accuracyLow': serializer.toJson<int>(accuracyLow),
      'hsiWindowCount': serializer.toJson<int>(hsiWindowCount),
      'syncState': serializer.toJson<int>(
        $SessionsTable.$convertersyncState.toJson(syncState),
      ),
      'uploadedCount': serializer.toJson<int>(uploadedCount),
      'uploadAttemptedAt': serializer.toJson<DateTime?>(uploadAttemptedAt),
      'syncError': serializer.toJson<String?>(syncError),
    };
  }

  Session copyWith({
    String? id,
    String? subjectId,
    Value<String?> sourceId = const Value.absent(),
    DateTime? startedAt,
    Value<DateTime?> canonicalStartedAt = const Value.absent(),
    Value<DateTime?> plannedEndAt = const Value.absent(),
    Value<DateTime?> endedAt = const Value.absent(),
    int? plannedMinutes,
    int? focusedMinutes,
    int? pausedSeconds,
    Value<DateTime?> pauseStartedAt = const Value.absent(),
    SessionStatus? status,
    SignalOrigin? signalOrigin,
    Value<double?> hsiFocus = const Value.absent(),
    Value<double?> hsiFocusConfidence = const Value.absent(),
    Value<double?> hsiCapacity = const Value.absent(),
    Value<double?> hsiCapacityConfidence = const Value.absent(),
    Value<double?> hsiArousal = const Value.absent(),
    Value<double?> hsiArousalConfidence = const Value.absent(),
    Value<double?> hsiStress = const Value.absent(),
    Value<double?> hsiStressConfidence = const Value.absent(),
    Value<double?> hsiQuality = const Value.absent(),
    Value<String?> synheartSessionId = const Value.absent(),
    Value<String?> watchSessionId = const Value.absent(),
    int? acceptedSamples,
    int? totalSamples,
    int? coverageSeconds,
    int? accuracyHigh,
    int? accuracyMedium,
    int? accuracyLow,
    int? hsiWindowCount,
    SyncState? syncState,
    int? uploadedCount,
    Value<DateTime?> uploadAttemptedAt = const Value.absent(),
    Value<String?> syncError = const Value.absent(),
  }) => Session(
    id: id ?? this.id,
    subjectId: subjectId ?? this.subjectId,
    sourceId: sourceId.present ? sourceId.value : this.sourceId,
    startedAt: startedAt ?? this.startedAt,
    canonicalStartedAt: canonicalStartedAt.present
        ? canonicalStartedAt.value
        : this.canonicalStartedAt,
    plannedEndAt: plannedEndAt.present ? plannedEndAt.value : this.plannedEndAt,
    endedAt: endedAt.present ? endedAt.value : this.endedAt,
    plannedMinutes: plannedMinutes ?? this.plannedMinutes,
    focusedMinutes: focusedMinutes ?? this.focusedMinutes,
    pausedSeconds: pausedSeconds ?? this.pausedSeconds,
    pauseStartedAt: pauseStartedAt.present
        ? pauseStartedAt.value
        : this.pauseStartedAt,
    status: status ?? this.status,
    signalOrigin: signalOrigin ?? this.signalOrigin,
    hsiFocus: hsiFocus.present ? hsiFocus.value : this.hsiFocus,
    hsiFocusConfidence: hsiFocusConfidence.present
        ? hsiFocusConfidence.value
        : this.hsiFocusConfidence,
    hsiCapacity: hsiCapacity.present ? hsiCapacity.value : this.hsiCapacity,
    hsiCapacityConfidence: hsiCapacityConfidence.present
        ? hsiCapacityConfidence.value
        : this.hsiCapacityConfidence,
    hsiArousal: hsiArousal.present ? hsiArousal.value : this.hsiArousal,
    hsiArousalConfidence: hsiArousalConfidence.present
        ? hsiArousalConfidence.value
        : this.hsiArousalConfidence,
    hsiStress: hsiStress.present ? hsiStress.value : this.hsiStress,
    hsiStressConfidence: hsiStressConfidence.present
        ? hsiStressConfidence.value
        : this.hsiStressConfidence,
    hsiQuality: hsiQuality.present ? hsiQuality.value : this.hsiQuality,
    synheartSessionId: synheartSessionId.present
        ? synheartSessionId.value
        : this.synheartSessionId,
    watchSessionId: watchSessionId.present
        ? watchSessionId.value
        : this.watchSessionId,
    acceptedSamples: acceptedSamples ?? this.acceptedSamples,
    totalSamples: totalSamples ?? this.totalSamples,
    coverageSeconds: coverageSeconds ?? this.coverageSeconds,
    accuracyHigh: accuracyHigh ?? this.accuracyHigh,
    accuracyMedium: accuracyMedium ?? this.accuracyMedium,
    accuracyLow: accuracyLow ?? this.accuracyLow,
    hsiWindowCount: hsiWindowCount ?? this.hsiWindowCount,
    syncState: syncState ?? this.syncState,
    uploadedCount: uploadedCount ?? this.uploadedCount,
    uploadAttemptedAt: uploadAttemptedAt.present
        ? uploadAttemptedAt.value
        : this.uploadAttemptedAt,
    syncError: syncError.present ? syncError.value : this.syncError,
  );
  Session copyWithCompanion(SessionsCompanion data) {
    return Session(
      id: data.id.present ? data.id.value : this.id,
      subjectId: data.subjectId.present ? data.subjectId.value : this.subjectId,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      canonicalStartedAt: data.canonicalStartedAt.present
          ? data.canonicalStartedAt.value
          : this.canonicalStartedAt,
      plannedEndAt: data.plannedEndAt.present
          ? data.plannedEndAt.value
          : this.plannedEndAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      plannedMinutes: data.plannedMinutes.present
          ? data.plannedMinutes.value
          : this.plannedMinutes,
      focusedMinutes: data.focusedMinutes.present
          ? data.focusedMinutes.value
          : this.focusedMinutes,
      pausedSeconds: data.pausedSeconds.present
          ? data.pausedSeconds.value
          : this.pausedSeconds,
      pauseStartedAt: data.pauseStartedAt.present
          ? data.pauseStartedAt.value
          : this.pauseStartedAt,
      status: data.status.present ? data.status.value : this.status,
      signalOrigin: data.signalOrigin.present
          ? data.signalOrigin.value
          : this.signalOrigin,
      hsiFocus: data.hsiFocus.present ? data.hsiFocus.value : this.hsiFocus,
      hsiFocusConfidence: data.hsiFocusConfidence.present
          ? data.hsiFocusConfidence.value
          : this.hsiFocusConfidence,
      hsiCapacity: data.hsiCapacity.present
          ? data.hsiCapacity.value
          : this.hsiCapacity,
      hsiCapacityConfidence: data.hsiCapacityConfidence.present
          ? data.hsiCapacityConfidence.value
          : this.hsiCapacityConfidence,
      hsiArousal: data.hsiArousal.present
          ? data.hsiArousal.value
          : this.hsiArousal,
      hsiArousalConfidence: data.hsiArousalConfidence.present
          ? data.hsiArousalConfidence.value
          : this.hsiArousalConfidence,
      hsiStress: data.hsiStress.present ? data.hsiStress.value : this.hsiStress,
      hsiStressConfidence: data.hsiStressConfidence.present
          ? data.hsiStressConfidence.value
          : this.hsiStressConfidence,
      hsiQuality: data.hsiQuality.present
          ? data.hsiQuality.value
          : this.hsiQuality,
      synheartSessionId: data.synheartSessionId.present
          ? data.synheartSessionId.value
          : this.synheartSessionId,
      watchSessionId: data.watchSessionId.present
          ? data.watchSessionId.value
          : this.watchSessionId,
      acceptedSamples: data.acceptedSamples.present
          ? data.acceptedSamples.value
          : this.acceptedSamples,
      totalSamples: data.totalSamples.present
          ? data.totalSamples.value
          : this.totalSamples,
      coverageSeconds: data.coverageSeconds.present
          ? data.coverageSeconds.value
          : this.coverageSeconds,
      accuracyHigh: data.accuracyHigh.present
          ? data.accuracyHigh.value
          : this.accuracyHigh,
      accuracyMedium: data.accuracyMedium.present
          ? data.accuracyMedium.value
          : this.accuracyMedium,
      accuracyLow: data.accuracyLow.present
          ? data.accuracyLow.value
          : this.accuracyLow,
      hsiWindowCount: data.hsiWindowCount.present
          ? data.hsiWindowCount.value
          : this.hsiWindowCount,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      uploadedCount: data.uploadedCount.present
          ? data.uploadedCount.value
          : this.uploadedCount,
      uploadAttemptedAt: data.uploadAttemptedAt.present
          ? data.uploadAttemptedAt.value
          : this.uploadAttemptedAt,
      syncError: data.syncError.present ? data.syncError.value : this.syncError,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Session(')
          ..write('id: $id, ')
          ..write('subjectId: $subjectId, ')
          ..write('sourceId: $sourceId, ')
          ..write('startedAt: $startedAt, ')
          ..write('canonicalStartedAt: $canonicalStartedAt, ')
          ..write('plannedEndAt: $plannedEndAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('plannedMinutes: $plannedMinutes, ')
          ..write('focusedMinutes: $focusedMinutes, ')
          ..write('pausedSeconds: $pausedSeconds, ')
          ..write('pauseStartedAt: $pauseStartedAt, ')
          ..write('status: $status, ')
          ..write('signalOrigin: $signalOrigin, ')
          ..write('hsiFocus: $hsiFocus, ')
          ..write('hsiFocusConfidence: $hsiFocusConfidence, ')
          ..write('hsiCapacity: $hsiCapacity, ')
          ..write('hsiCapacityConfidence: $hsiCapacityConfidence, ')
          ..write('hsiArousal: $hsiArousal, ')
          ..write('hsiArousalConfidence: $hsiArousalConfidence, ')
          ..write('hsiStress: $hsiStress, ')
          ..write('hsiStressConfidence: $hsiStressConfidence, ')
          ..write('hsiQuality: $hsiQuality, ')
          ..write('synheartSessionId: $synheartSessionId, ')
          ..write('watchSessionId: $watchSessionId, ')
          ..write('acceptedSamples: $acceptedSamples, ')
          ..write('totalSamples: $totalSamples, ')
          ..write('coverageSeconds: $coverageSeconds, ')
          ..write('accuracyHigh: $accuracyHigh, ')
          ..write('accuracyMedium: $accuracyMedium, ')
          ..write('accuracyLow: $accuracyLow, ')
          ..write('hsiWindowCount: $hsiWindowCount, ')
          ..write('syncState: $syncState, ')
          ..write('uploadedCount: $uploadedCount, ')
          ..write('uploadAttemptedAt: $uploadAttemptedAt, ')
          ..write('syncError: $syncError')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    subjectId,
    sourceId,
    startedAt,
    canonicalStartedAt,
    plannedEndAt,
    endedAt,
    plannedMinutes,
    focusedMinutes,
    pausedSeconds,
    pauseStartedAt,
    status,
    signalOrigin,
    hsiFocus,
    hsiFocusConfidence,
    hsiCapacity,
    hsiCapacityConfidence,
    hsiArousal,
    hsiArousalConfidence,
    hsiStress,
    hsiStressConfidence,
    hsiQuality,
    synheartSessionId,
    watchSessionId,
    acceptedSamples,
    totalSamples,
    coverageSeconds,
    accuracyHigh,
    accuracyMedium,
    accuracyLow,
    hsiWindowCount,
    syncState,
    uploadedCount,
    uploadAttemptedAt,
    syncError,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Session &&
          other.id == this.id &&
          other.subjectId == this.subjectId &&
          other.sourceId == this.sourceId &&
          other.startedAt == this.startedAt &&
          other.canonicalStartedAt == this.canonicalStartedAt &&
          other.plannedEndAt == this.plannedEndAt &&
          other.endedAt == this.endedAt &&
          other.plannedMinutes == this.plannedMinutes &&
          other.focusedMinutes == this.focusedMinutes &&
          other.pausedSeconds == this.pausedSeconds &&
          other.pauseStartedAt == this.pauseStartedAt &&
          other.status == this.status &&
          other.signalOrigin == this.signalOrigin &&
          other.hsiFocus == this.hsiFocus &&
          other.hsiFocusConfidence == this.hsiFocusConfidence &&
          other.hsiCapacity == this.hsiCapacity &&
          other.hsiCapacityConfidence == this.hsiCapacityConfidence &&
          other.hsiArousal == this.hsiArousal &&
          other.hsiArousalConfidence == this.hsiArousalConfidence &&
          other.hsiStress == this.hsiStress &&
          other.hsiStressConfidence == this.hsiStressConfidence &&
          other.hsiQuality == this.hsiQuality &&
          other.synheartSessionId == this.synheartSessionId &&
          other.watchSessionId == this.watchSessionId &&
          other.acceptedSamples == this.acceptedSamples &&
          other.totalSamples == this.totalSamples &&
          other.coverageSeconds == this.coverageSeconds &&
          other.accuracyHigh == this.accuracyHigh &&
          other.accuracyMedium == this.accuracyMedium &&
          other.accuracyLow == this.accuracyLow &&
          other.hsiWindowCount == this.hsiWindowCount &&
          other.syncState == this.syncState &&
          other.uploadedCount == this.uploadedCount &&
          other.uploadAttemptedAt == this.uploadAttemptedAt &&
          other.syncError == this.syncError);
}

class SessionsCompanion extends UpdateCompanion<Session> {
  final Value<String> id;
  final Value<String> subjectId;
  final Value<String?> sourceId;
  final Value<DateTime> startedAt;
  final Value<DateTime?> canonicalStartedAt;
  final Value<DateTime?> plannedEndAt;
  final Value<DateTime?> endedAt;
  final Value<int> plannedMinutes;
  final Value<int> focusedMinutes;
  final Value<int> pausedSeconds;
  final Value<DateTime?> pauseStartedAt;
  final Value<SessionStatus> status;
  final Value<SignalOrigin> signalOrigin;
  final Value<double?> hsiFocus;
  final Value<double?> hsiFocusConfidence;
  final Value<double?> hsiCapacity;
  final Value<double?> hsiCapacityConfidence;
  final Value<double?> hsiArousal;
  final Value<double?> hsiArousalConfidence;
  final Value<double?> hsiStress;
  final Value<double?> hsiStressConfidence;
  final Value<double?> hsiQuality;
  final Value<String?> synheartSessionId;
  final Value<String?> watchSessionId;
  final Value<int> acceptedSamples;
  final Value<int> totalSamples;
  final Value<int> coverageSeconds;
  final Value<int> accuracyHigh;
  final Value<int> accuracyMedium;
  final Value<int> accuracyLow;
  final Value<int> hsiWindowCount;
  final Value<SyncState> syncState;
  final Value<int> uploadedCount;
  final Value<DateTime?> uploadAttemptedAt;
  final Value<String?> syncError;
  final Value<int> rowid;
  const SessionsCompanion({
    this.id = const Value.absent(),
    this.subjectId = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.canonicalStartedAt = const Value.absent(),
    this.plannedEndAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.plannedMinutes = const Value.absent(),
    this.focusedMinutes = const Value.absent(),
    this.pausedSeconds = const Value.absent(),
    this.pauseStartedAt = const Value.absent(),
    this.status = const Value.absent(),
    this.signalOrigin = const Value.absent(),
    this.hsiFocus = const Value.absent(),
    this.hsiFocusConfidence = const Value.absent(),
    this.hsiCapacity = const Value.absent(),
    this.hsiCapacityConfidence = const Value.absent(),
    this.hsiArousal = const Value.absent(),
    this.hsiArousalConfidence = const Value.absent(),
    this.hsiStress = const Value.absent(),
    this.hsiStressConfidence = const Value.absent(),
    this.hsiQuality = const Value.absent(),
    this.synheartSessionId = const Value.absent(),
    this.watchSessionId = const Value.absent(),
    this.acceptedSamples = const Value.absent(),
    this.totalSamples = const Value.absent(),
    this.coverageSeconds = const Value.absent(),
    this.accuracyHigh = const Value.absent(),
    this.accuracyMedium = const Value.absent(),
    this.accuracyLow = const Value.absent(),
    this.hsiWindowCount = const Value.absent(),
    this.syncState = const Value.absent(),
    this.uploadedCount = const Value.absent(),
    this.uploadAttemptedAt = const Value.absent(),
    this.syncError = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SessionsCompanion.insert({
    required String id,
    required String subjectId,
    this.sourceId = const Value.absent(),
    required DateTime startedAt,
    this.canonicalStartedAt = const Value.absent(),
    this.plannedEndAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.plannedMinutes = const Value.absent(),
    this.focusedMinutes = const Value.absent(),
    this.pausedSeconds = const Value.absent(),
    this.pauseStartedAt = const Value.absent(),
    required SessionStatus status,
    required SignalOrigin signalOrigin,
    this.hsiFocus = const Value.absent(),
    this.hsiFocusConfidence = const Value.absent(),
    this.hsiCapacity = const Value.absent(),
    this.hsiCapacityConfidence = const Value.absent(),
    this.hsiArousal = const Value.absent(),
    this.hsiArousalConfidence = const Value.absent(),
    this.hsiStress = const Value.absent(),
    this.hsiStressConfidence = const Value.absent(),
    this.hsiQuality = const Value.absent(),
    this.synheartSessionId = const Value.absent(),
    this.watchSessionId = const Value.absent(),
    this.acceptedSamples = const Value.absent(),
    this.totalSamples = const Value.absent(),
    this.coverageSeconds = const Value.absent(),
    this.accuracyHigh = const Value.absent(),
    this.accuracyMedium = const Value.absent(),
    this.accuracyLow = const Value.absent(),
    this.hsiWindowCount = const Value.absent(),
    this.syncState = const Value.absent(),
    this.uploadedCount = const Value.absent(),
    this.uploadAttemptedAt = const Value.absent(),
    this.syncError = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       subjectId = Value(subjectId),
       startedAt = Value(startedAt),
       status = Value(status),
       signalOrigin = Value(signalOrigin);
  static Insertable<Session> custom({
    Expression<String>? id,
    Expression<String>? subjectId,
    Expression<String>? sourceId,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? canonicalStartedAt,
    Expression<DateTime>? plannedEndAt,
    Expression<DateTime>? endedAt,
    Expression<int>? plannedMinutes,
    Expression<int>? focusedMinutes,
    Expression<int>? pausedSeconds,
    Expression<DateTime>? pauseStartedAt,
    Expression<int>? status,
    Expression<int>? signalOrigin,
    Expression<double>? hsiFocus,
    Expression<double>? hsiFocusConfidence,
    Expression<double>? hsiCapacity,
    Expression<double>? hsiCapacityConfidence,
    Expression<double>? hsiArousal,
    Expression<double>? hsiArousalConfidence,
    Expression<double>? hsiStress,
    Expression<double>? hsiStressConfidence,
    Expression<double>? hsiQuality,
    Expression<String>? synheartSessionId,
    Expression<String>? watchSessionId,
    Expression<int>? acceptedSamples,
    Expression<int>? totalSamples,
    Expression<int>? coverageSeconds,
    Expression<int>? accuracyHigh,
    Expression<int>? accuracyMedium,
    Expression<int>? accuracyLow,
    Expression<int>? hsiWindowCount,
    Expression<int>? syncState,
    Expression<int>? uploadedCount,
    Expression<DateTime>? uploadAttemptedAt,
    Expression<String>? syncError,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (subjectId != null) 'subject_id': subjectId,
      if (sourceId != null) 'source_id': sourceId,
      if (startedAt != null) 'started_at': startedAt,
      if (canonicalStartedAt != null)
        'canonical_started_at': canonicalStartedAt,
      if (plannedEndAt != null) 'planned_end_at': plannedEndAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (plannedMinutes != null) 'planned_minutes': plannedMinutes,
      if (focusedMinutes != null) 'focused_minutes': focusedMinutes,
      if (pausedSeconds != null) 'paused_seconds': pausedSeconds,
      if (pauseStartedAt != null) 'pause_started_at': pauseStartedAt,
      if (status != null) 'status': status,
      if (signalOrigin != null) 'signal_origin': signalOrigin,
      if (hsiFocus != null) 'hsi_focus': hsiFocus,
      if (hsiFocusConfidence != null)
        'hsi_focus_confidence': hsiFocusConfidence,
      if (hsiCapacity != null) 'hsi_capacity': hsiCapacity,
      if (hsiCapacityConfidence != null)
        'hsi_capacity_confidence': hsiCapacityConfidence,
      if (hsiArousal != null) 'hsi_arousal': hsiArousal,
      if (hsiArousalConfidence != null)
        'hsi_arousal_confidence': hsiArousalConfidence,
      if (hsiStress != null) 'hsi_stress': hsiStress,
      if (hsiStressConfidence != null)
        'hsi_stress_confidence': hsiStressConfidence,
      if (hsiQuality != null) 'hsi_quality': hsiQuality,
      if (synheartSessionId != null) 'synheart_session_id': synheartSessionId,
      if (watchSessionId != null) 'watch_session_id': watchSessionId,
      if (acceptedSamples != null) 'accepted_samples': acceptedSamples,
      if (totalSamples != null) 'total_samples': totalSamples,
      if (coverageSeconds != null) 'coverage_seconds': coverageSeconds,
      if (accuracyHigh != null) 'accuracy_high': accuracyHigh,
      if (accuracyMedium != null) 'accuracy_medium': accuracyMedium,
      if (accuracyLow != null) 'accuracy_low': accuracyLow,
      if (hsiWindowCount != null) 'hsi_window_count': hsiWindowCount,
      if (syncState != null) 'sync_state': syncState,
      if (uploadedCount != null) 'uploaded_count': uploadedCount,
      if (uploadAttemptedAt != null) 'upload_attempted_at': uploadAttemptedAt,
      if (syncError != null) 'sync_error': syncError,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SessionsCompanion copyWith({
    Value<String>? id,
    Value<String>? subjectId,
    Value<String?>? sourceId,
    Value<DateTime>? startedAt,
    Value<DateTime?>? canonicalStartedAt,
    Value<DateTime?>? plannedEndAt,
    Value<DateTime?>? endedAt,
    Value<int>? plannedMinutes,
    Value<int>? focusedMinutes,
    Value<int>? pausedSeconds,
    Value<DateTime?>? pauseStartedAt,
    Value<SessionStatus>? status,
    Value<SignalOrigin>? signalOrigin,
    Value<double?>? hsiFocus,
    Value<double?>? hsiFocusConfidence,
    Value<double?>? hsiCapacity,
    Value<double?>? hsiCapacityConfidence,
    Value<double?>? hsiArousal,
    Value<double?>? hsiArousalConfidence,
    Value<double?>? hsiStress,
    Value<double?>? hsiStressConfidence,
    Value<double?>? hsiQuality,
    Value<String?>? synheartSessionId,
    Value<String?>? watchSessionId,
    Value<int>? acceptedSamples,
    Value<int>? totalSamples,
    Value<int>? coverageSeconds,
    Value<int>? accuracyHigh,
    Value<int>? accuracyMedium,
    Value<int>? accuracyLow,
    Value<int>? hsiWindowCount,
    Value<SyncState>? syncState,
    Value<int>? uploadedCount,
    Value<DateTime?>? uploadAttemptedAt,
    Value<String?>? syncError,
    Value<int>? rowid,
  }) {
    return SessionsCompanion(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      sourceId: sourceId ?? this.sourceId,
      startedAt: startedAt ?? this.startedAt,
      canonicalStartedAt: canonicalStartedAt ?? this.canonicalStartedAt,
      plannedEndAt: plannedEndAt ?? this.plannedEndAt,
      endedAt: endedAt ?? this.endedAt,
      plannedMinutes: plannedMinutes ?? this.plannedMinutes,
      focusedMinutes: focusedMinutes ?? this.focusedMinutes,
      pausedSeconds: pausedSeconds ?? this.pausedSeconds,
      pauseStartedAt: pauseStartedAt ?? this.pauseStartedAt,
      status: status ?? this.status,
      signalOrigin: signalOrigin ?? this.signalOrigin,
      hsiFocus: hsiFocus ?? this.hsiFocus,
      hsiFocusConfidence: hsiFocusConfidence ?? this.hsiFocusConfidence,
      hsiCapacity: hsiCapacity ?? this.hsiCapacity,
      hsiCapacityConfidence:
          hsiCapacityConfidence ?? this.hsiCapacityConfidence,
      hsiArousal: hsiArousal ?? this.hsiArousal,
      hsiArousalConfidence: hsiArousalConfidence ?? this.hsiArousalConfidence,
      hsiStress: hsiStress ?? this.hsiStress,
      hsiStressConfidence: hsiStressConfidence ?? this.hsiStressConfidence,
      hsiQuality: hsiQuality ?? this.hsiQuality,
      synheartSessionId: synheartSessionId ?? this.synheartSessionId,
      watchSessionId: watchSessionId ?? this.watchSessionId,
      acceptedSamples: acceptedSamples ?? this.acceptedSamples,
      totalSamples: totalSamples ?? this.totalSamples,
      coverageSeconds: coverageSeconds ?? this.coverageSeconds,
      accuracyHigh: accuracyHigh ?? this.accuracyHigh,
      accuracyMedium: accuracyMedium ?? this.accuracyMedium,
      accuracyLow: accuracyLow ?? this.accuracyLow,
      hsiWindowCount: hsiWindowCount ?? this.hsiWindowCount,
      syncState: syncState ?? this.syncState,
      uploadedCount: uploadedCount ?? this.uploadedCount,
      uploadAttemptedAt: uploadAttemptedAt ?? this.uploadAttemptedAt,
      syncError: syncError ?? this.syncError,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (subjectId.present) {
      map['subject_id'] = Variable<String>(subjectId.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (canonicalStartedAt.present) {
      map['canonical_started_at'] = Variable<DateTime>(
        canonicalStartedAt.value,
      );
    }
    if (plannedEndAt.present) {
      map['planned_end_at'] = Variable<DateTime>(plannedEndAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    if (plannedMinutes.present) {
      map['planned_minutes'] = Variable<int>(plannedMinutes.value);
    }
    if (focusedMinutes.present) {
      map['focused_minutes'] = Variable<int>(focusedMinutes.value);
    }
    if (pausedSeconds.present) {
      map['paused_seconds'] = Variable<int>(pausedSeconds.value);
    }
    if (pauseStartedAt.present) {
      map['pause_started_at'] = Variable<DateTime>(pauseStartedAt.value);
    }
    if (status.present) {
      map['status'] = Variable<int>(
        $SessionsTable.$converterstatus.toSql(status.value),
      );
    }
    if (signalOrigin.present) {
      map['signal_origin'] = Variable<int>(
        $SessionsTable.$convertersignalOrigin.toSql(signalOrigin.value),
      );
    }
    if (hsiFocus.present) {
      map['hsi_focus'] = Variable<double>(hsiFocus.value);
    }
    if (hsiFocusConfidence.present) {
      map['hsi_focus_confidence'] = Variable<double>(hsiFocusConfidence.value);
    }
    if (hsiCapacity.present) {
      map['hsi_capacity'] = Variable<double>(hsiCapacity.value);
    }
    if (hsiCapacityConfidence.present) {
      map['hsi_capacity_confidence'] = Variable<double>(
        hsiCapacityConfidence.value,
      );
    }
    if (hsiArousal.present) {
      map['hsi_arousal'] = Variable<double>(hsiArousal.value);
    }
    if (hsiArousalConfidence.present) {
      map['hsi_arousal_confidence'] = Variable<double>(
        hsiArousalConfidence.value,
      );
    }
    if (hsiStress.present) {
      map['hsi_stress'] = Variable<double>(hsiStress.value);
    }
    if (hsiStressConfidence.present) {
      map['hsi_stress_confidence'] = Variable<double>(
        hsiStressConfidence.value,
      );
    }
    if (hsiQuality.present) {
      map['hsi_quality'] = Variable<double>(hsiQuality.value);
    }
    if (synheartSessionId.present) {
      map['synheart_session_id'] = Variable<String>(synheartSessionId.value);
    }
    if (watchSessionId.present) {
      map['watch_session_id'] = Variable<String>(watchSessionId.value);
    }
    if (acceptedSamples.present) {
      map['accepted_samples'] = Variable<int>(acceptedSamples.value);
    }
    if (totalSamples.present) {
      map['total_samples'] = Variable<int>(totalSamples.value);
    }
    if (coverageSeconds.present) {
      map['coverage_seconds'] = Variable<int>(coverageSeconds.value);
    }
    if (accuracyHigh.present) {
      map['accuracy_high'] = Variable<int>(accuracyHigh.value);
    }
    if (accuracyMedium.present) {
      map['accuracy_medium'] = Variable<int>(accuracyMedium.value);
    }
    if (accuracyLow.present) {
      map['accuracy_low'] = Variable<int>(accuracyLow.value);
    }
    if (hsiWindowCount.present) {
      map['hsi_window_count'] = Variable<int>(hsiWindowCount.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<int>(
        $SessionsTable.$convertersyncState.toSql(syncState.value),
      );
    }
    if (uploadedCount.present) {
      map['uploaded_count'] = Variable<int>(uploadedCount.value);
    }
    if (uploadAttemptedAt.present) {
      map['upload_attempted_at'] = Variable<DateTime>(uploadAttemptedAt.value);
    }
    if (syncError.present) {
      map['sync_error'] = Variable<String>(syncError.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionsCompanion(')
          ..write('id: $id, ')
          ..write('subjectId: $subjectId, ')
          ..write('sourceId: $sourceId, ')
          ..write('startedAt: $startedAt, ')
          ..write('canonicalStartedAt: $canonicalStartedAt, ')
          ..write('plannedEndAt: $plannedEndAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('plannedMinutes: $plannedMinutes, ')
          ..write('focusedMinutes: $focusedMinutes, ')
          ..write('pausedSeconds: $pausedSeconds, ')
          ..write('pauseStartedAt: $pauseStartedAt, ')
          ..write('status: $status, ')
          ..write('signalOrigin: $signalOrigin, ')
          ..write('hsiFocus: $hsiFocus, ')
          ..write('hsiFocusConfidence: $hsiFocusConfidence, ')
          ..write('hsiCapacity: $hsiCapacity, ')
          ..write('hsiCapacityConfidence: $hsiCapacityConfidence, ')
          ..write('hsiArousal: $hsiArousal, ')
          ..write('hsiArousalConfidence: $hsiArousalConfidence, ')
          ..write('hsiStress: $hsiStress, ')
          ..write('hsiStressConfidence: $hsiStressConfidence, ')
          ..write('hsiQuality: $hsiQuality, ')
          ..write('synheartSessionId: $synheartSessionId, ')
          ..write('watchSessionId: $watchSessionId, ')
          ..write('acceptedSamples: $acceptedSamples, ')
          ..write('totalSamples: $totalSamples, ')
          ..write('coverageSeconds: $coverageSeconds, ')
          ..write('accuracyHigh: $accuracyHigh, ')
          ..write('accuracyMedium: $accuracyMedium, ')
          ..write('accuracyLow: $accuracyLow, ')
          ..write('hsiWindowCount: $hsiWindowCount, ')
          ..write('syncState: $syncState, ')
          ..write('uploadedCount: $uploadedCount, ')
          ..write('uploadAttemptedAt: $uploadAttemptedAt, ')
          ..write('syncError: $syncError, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HsiWindowsTable extends HsiWindows
    with TableInfo<$HsiWindowsTable, HsiWindow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HsiWindowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _rowIdMeta = const VerificationMeta('rowId');
  @override
  late final GeneratedColumn<int> rowId = GeneratedColumn<int>(
    'row_id',
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
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sessions (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _atMeta = const VerificationMeta('at');
  @override
  late final GeneratedColumn<DateTime> at = GeneratedColumn<DateTime>(
    'at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<SignalOrigin, int> signalOrigin =
      GeneratedColumn<int>(
        'signal_origin',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: Constant(SignalOrigin.unmeasured.index),
      ).withConverter<SignalOrigin>($HsiWindowsTable.$convertersignalOrigin);
  static const VerificationMeta _hsiVersionMeta = const VerificationMeta(
    'hsiVersion',
  );
  @override
  late final GeneratedColumn<String> hsiVersion = GeneratedColumn<String>(
    'hsi_version',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _focusMeta = const VerificationMeta('focus');
  @override
  late final GeneratedColumn<double> focus = GeneratedColumn<double>(
    'focus',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _focusConfidenceMeta = const VerificationMeta(
    'focusConfidence',
  );
  @override
  late final GeneratedColumn<double> focusConfidence = GeneratedColumn<double>(
    'focus_confidence',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _capacityMeta = const VerificationMeta(
    'capacity',
  );
  @override
  late final GeneratedColumn<double> capacity = GeneratedColumn<double>(
    'capacity',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _capacityConfidenceMeta =
      const VerificationMeta('capacityConfidence');
  @override
  late final GeneratedColumn<double> capacityConfidence =
      GeneratedColumn<double>(
        'capacity_confidence',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _arousalMeta = const VerificationMeta(
    'arousal',
  );
  @override
  late final GeneratedColumn<double> arousal = GeneratedColumn<double>(
    'arousal',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _arousalConfidenceMeta = const VerificationMeta(
    'arousalConfidence',
  );
  @override
  late final GeneratedColumn<double> arousalConfidence =
      GeneratedColumn<double>(
        'arousal_confidence',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _stressMeta = const VerificationMeta('stress');
  @override
  late final GeneratedColumn<double> stress = GeneratedColumn<double>(
    'stress',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stressConfidenceMeta = const VerificationMeta(
    'stressConfidence',
  );
  @override
  late final GeneratedColumn<double> stressConfidence = GeneratedColumn<double>(
    'stress_confidence',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _qualityMeta = const VerificationMeta(
    'quality',
  );
  @override
  late final GeneratedColumn<double> quality = GeneratedColumn<double>(
    'quality',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    rowId,
    sessionId,
    at,
    signalOrigin,
    hsiVersion,
    focus,
    focusConfidence,
    capacity,
    capacityConfidence,
    arousal,
    arousalConfidence,
    stress,
    stressConfidence,
    quality,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'hsi_windows';
  @override
  VerificationContext validateIntegrity(
    Insertable<HsiWindow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('row_id')) {
      context.handle(
        _rowIdMeta,
        rowId.isAcceptableOrUnknown(data['row_id']!, _rowIdMeta),
      );
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('at')) {
      context.handle(_atMeta, at.isAcceptableOrUnknown(data['at']!, _atMeta));
    } else if (isInserting) {
      context.missing(_atMeta);
    }
    if (data.containsKey('hsi_version')) {
      context.handle(
        _hsiVersionMeta,
        hsiVersion.isAcceptableOrUnknown(data['hsi_version']!, _hsiVersionMeta),
      );
    }
    if (data.containsKey('focus')) {
      context.handle(
        _focusMeta,
        focus.isAcceptableOrUnknown(data['focus']!, _focusMeta),
      );
    }
    if (data.containsKey('focus_confidence')) {
      context.handle(
        _focusConfidenceMeta,
        focusConfidence.isAcceptableOrUnknown(
          data['focus_confidence']!,
          _focusConfidenceMeta,
        ),
      );
    }
    if (data.containsKey('capacity')) {
      context.handle(
        _capacityMeta,
        capacity.isAcceptableOrUnknown(data['capacity']!, _capacityMeta),
      );
    }
    if (data.containsKey('capacity_confidence')) {
      context.handle(
        _capacityConfidenceMeta,
        capacityConfidence.isAcceptableOrUnknown(
          data['capacity_confidence']!,
          _capacityConfidenceMeta,
        ),
      );
    }
    if (data.containsKey('arousal')) {
      context.handle(
        _arousalMeta,
        arousal.isAcceptableOrUnknown(data['arousal']!, _arousalMeta),
      );
    }
    if (data.containsKey('arousal_confidence')) {
      context.handle(
        _arousalConfidenceMeta,
        arousalConfidence.isAcceptableOrUnknown(
          data['arousal_confidence']!,
          _arousalConfidenceMeta,
        ),
      );
    }
    if (data.containsKey('stress')) {
      context.handle(
        _stressMeta,
        stress.isAcceptableOrUnknown(data['stress']!, _stressMeta),
      );
    }
    if (data.containsKey('stress_confidence')) {
      context.handle(
        _stressConfidenceMeta,
        stressConfidence.isAcceptableOrUnknown(
          data['stress_confidence']!,
          _stressConfidenceMeta,
        ),
      );
    }
    if (data.containsKey('quality')) {
      context.handle(
        _qualityMeta,
        quality.isAcceptableOrUnknown(data['quality']!, _qualityMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {rowId};
  @override
  HsiWindow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HsiWindow(
      rowId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}row_id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      at: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}at'],
      )!,
      signalOrigin: $HsiWindowsTable.$convertersignalOrigin.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}signal_origin'],
        )!,
      ),
      hsiVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hsi_version'],
      ),
      focus: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}focus'],
      ),
      focusConfidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}focus_confidence'],
      ),
      capacity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}capacity'],
      ),
      capacityConfidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}capacity_confidence'],
      ),
      arousal: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}arousal'],
      ),
      arousalConfidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}arousal_confidence'],
      ),
      stress: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}stress'],
      ),
      stressConfidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}stress_confidence'],
      ),
      quality: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quality'],
      ),
    );
  }

  @override
  $HsiWindowsTable createAlias(String alias) {
    return $HsiWindowsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SignalOrigin, int, int> $convertersignalOrigin =
      const EnumIndexConverter<SignalOrigin>(SignalOrigin.values);
}

class HsiWindow extends DataClass implements Insertable<HsiWindow> {
  final int rowId;
  final String sessionId;
  final DateTime at;
  final SignalOrigin signalOrigin;
  final String? hsiVersion;
  final double? focus;
  final double? focusConfidence;
  final double? capacity;
  final double? capacityConfidence;
  final double? arousal;
  final double? arousalConfidence;
  final double? stress;
  final double? stressConfidence;
  final double? quality;
  const HsiWindow({
    required this.rowId,
    required this.sessionId,
    required this.at,
    required this.signalOrigin,
    this.hsiVersion,
    this.focus,
    this.focusConfidence,
    this.capacity,
    this.capacityConfidence,
    this.arousal,
    this.arousalConfidence,
    this.stress,
    this.stressConfidence,
    this.quality,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['row_id'] = Variable<int>(rowId);
    map['session_id'] = Variable<String>(sessionId);
    map['at'] = Variable<DateTime>(at);
    {
      map['signal_origin'] = Variable<int>(
        $HsiWindowsTable.$convertersignalOrigin.toSql(signalOrigin),
      );
    }
    if (!nullToAbsent || hsiVersion != null) {
      map['hsi_version'] = Variable<String>(hsiVersion);
    }
    if (!nullToAbsent || focus != null) {
      map['focus'] = Variable<double>(focus);
    }
    if (!nullToAbsent || focusConfidence != null) {
      map['focus_confidence'] = Variable<double>(focusConfidence);
    }
    if (!nullToAbsent || capacity != null) {
      map['capacity'] = Variable<double>(capacity);
    }
    if (!nullToAbsent || capacityConfidence != null) {
      map['capacity_confidence'] = Variable<double>(capacityConfidence);
    }
    if (!nullToAbsent || arousal != null) {
      map['arousal'] = Variable<double>(arousal);
    }
    if (!nullToAbsent || arousalConfidence != null) {
      map['arousal_confidence'] = Variable<double>(arousalConfidence);
    }
    if (!nullToAbsent || stress != null) {
      map['stress'] = Variable<double>(stress);
    }
    if (!nullToAbsent || stressConfidence != null) {
      map['stress_confidence'] = Variable<double>(stressConfidence);
    }
    if (!nullToAbsent || quality != null) {
      map['quality'] = Variable<double>(quality);
    }
    return map;
  }

  HsiWindowsCompanion toCompanion(bool nullToAbsent) {
    return HsiWindowsCompanion(
      rowId: Value(rowId),
      sessionId: Value(sessionId),
      at: Value(at),
      signalOrigin: Value(signalOrigin),
      hsiVersion: hsiVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(hsiVersion),
      focus: focus == null && nullToAbsent
          ? const Value.absent()
          : Value(focus),
      focusConfidence: focusConfidence == null && nullToAbsent
          ? const Value.absent()
          : Value(focusConfidence),
      capacity: capacity == null && nullToAbsent
          ? const Value.absent()
          : Value(capacity),
      capacityConfidence: capacityConfidence == null && nullToAbsent
          ? const Value.absent()
          : Value(capacityConfidence),
      arousal: arousal == null && nullToAbsent
          ? const Value.absent()
          : Value(arousal),
      arousalConfidence: arousalConfidence == null && nullToAbsent
          ? const Value.absent()
          : Value(arousalConfidence),
      stress: stress == null && nullToAbsent
          ? const Value.absent()
          : Value(stress),
      stressConfidence: stressConfidence == null && nullToAbsent
          ? const Value.absent()
          : Value(stressConfidence),
      quality: quality == null && nullToAbsent
          ? const Value.absent()
          : Value(quality),
    );
  }

  factory HsiWindow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HsiWindow(
      rowId: serializer.fromJson<int>(json['rowId']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      at: serializer.fromJson<DateTime>(json['at']),
      signalOrigin: $HsiWindowsTable.$convertersignalOrigin.fromJson(
        serializer.fromJson<int>(json['signalOrigin']),
      ),
      hsiVersion: serializer.fromJson<String?>(json['hsiVersion']),
      focus: serializer.fromJson<double?>(json['focus']),
      focusConfidence: serializer.fromJson<double?>(json['focusConfidence']),
      capacity: serializer.fromJson<double?>(json['capacity']),
      capacityConfidence: serializer.fromJson<double?>(
        json['capacityConfidence'],
      ),
      arousal: serializer.fromJson<double?>(json['arousal']),
      arousalConfidence: serializer.fromJson<double?>(
        json['arousalConfidence'],
      ),
      stress: serializer.fromJson<double?>(json['stress']),
      stressConfidence: serializer.fromJson<double?>(json['stressConfidence']),
      quality: serializer.fromJson<double?>(json['quality']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'rowId': serializer.toJson<int>(rowId),
      'sessionId': serializer.toJson<String>(sessionId),
      'at': serializer.toJson<DateTime>(at),
      'signalOrigin': serializer.toJson<int>(
        $HsiWindowsTable.$convertersignalOrigin.toJson(signalOrigin),
      ),
      'hsiVersion': serializer.toJson<String?>(hsiVersion),
      'focus': serializer.toJson<double?>(focus),
      'focusConfidence': serializer.toJson<double?>(focusConfidence),
      'capacity': serializer.toJson<double?>(capacity),
      'capacityConfidence': serializer.toJson<double?>(capacityConfidence),
      'arousal': serializer.toJson<double?>(arousal),
      'arousalConfidence': serializer.toJson<double?>(arousalConfidence),
      'stress': serializer.toJson<double?>(stress),
      'stressConfidence': serializer.toJson<double?>(stressConfidence),
      'quality': serializer.toJson<double?>(quality),
    };
  }

  HsiWindow copyWith({
    int? rowId,
    String? sessionId,
    DateTime? at,
    SignalOrigin? signalOrigin,
    Value<String?> hsiVersion = const Value.absent(),
    Value<double?> focus = const Value.absent(),
    Value<double?> focusConfidence = const Value.absent(),
    Value<double?> capacity = const Value.absent(),
    Value<double?> capacityConfidence = const Value.absent(),
    Value<double?> arousal = const Value.absent(),
    Value<double?> arousalConfidence = const Value.absent(),
    Value<double?> stress = const Value.absent(),
    Value<double?> stressConfidence = const Value.absent(),
    Value<double?> quality = const Value.absent(),
  }) => HsiWindow(
    rowId: rowId ?? this.rowId,
    sessionId: sessionId ?? this.sessionId,
    at: at ?? this.at,
    signalOrigin: signalOrigin ?? this.signalOrigin,
    hsiVersion: hsiVersion.present ? hsiVersion.value : this.hsiVersion,
    focus: focus.present ? focus.value : this.focus,
    focusConfidence: focusConfidence.present
        ? focusConfidence.value
        : this.focusConfidence,
    capacity: capacity.present ? capacity.value : this.capacity,
    capacityConfidence: capacityConfidence.present
        ? capacityConfidence.value
        : this.capacityConfidence,
    arousal: arousal.present ? arousal.value : this.arousal,
    arousalConfidence: arousalConfidence.present
        ? arousalConfidence.value
        : this.arousalConfidence,
    stress: stress.present ? stress.value : this.stress,
    stressConfidence: stressConfidence.present
        ? stressConfidence.value
        : this.stressConfidence,
    quality: quality.present ? quality.value : this.quality,
  );
  HsiWindow copyWithCompanion(HsiWindowsCompanion data) {
    return HsiWindow(
      rowId: data.rowId.present ? data.rowId.value : this.rowId,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      at: data.at.present ? data.at.value : this.at,
      signalOrigin: data.signalOrigin.present
          ? data.signalOrigin.value
          : this.signalOrigin,
      hsiVersion: data.hsiVersion.present
          ? data.hsiVersion.value
          : this.hsiVersion,
      focus: data.focus.present ? data.focus.value : this.focus,
      focusConfidence: data.focusConfidence.present
          ? data.focusConfidence.value
          : this.focusConfidence,
      capacity: data.capacity.present ? data.capacity.value : this.capacity,
      capacityConfidence: data.capacityConfidence.present
          ? data.capacityConfidence.value
          : this.capacityConfidence,
      arousal: data.arousal.present ? data.arousal.value : this.arousal,
      arousalConfidence: data.arousalConfidence.present
          ? data.arousalConfidence.value
          : this.arousalConfidence,
      stress: data.stress.present ? data.stress.value : this.stress,
      stressConfidence: data.stressConfidence.present
          ? data.stressConfidence.value
          : this.stressConfidence,
      quality: data.quality.present ? data.quality.value : this.quality,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HsiWindow(')
          ..write('rowId: $rowId, ')
          ..write('sessionId: $sessionId, ')
          ..write('at: $at, ')
          ..write('signalOrigin: $signalOrigin, ')
          ..write('hsiVersion: $hsiVersion, ')
          ..write('focus: $focus, ')
          ..write('focusConfidence: $focusConfidence, ')
          ..write('capacity: $capacity, ')
          ..write('capacityConfidence: $capacityConfidence, ')
          ..write('arousal: $arousal, ')
          ..write('arousalConfidence: $arousalConfidence, ')
          ..write('stress: $stress, ')
          ..write('stressConfidence: $stressConfidence, ')
          ..write('quality: $quality')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    rowId,
    sessionId,
    at,
    signalOrigin,
    hsiVersion,
    focus,
    focusConfidence,
    capacity,
    capacityConfidence,
    arousal,
    arousalConfidence,
    stress,
    stressConfidence,
    quality,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HsiWindow &&
          other.rowId == this.rowId &&
          other.sessionId == this.sessionId &&
          other.at == this.at &&
          other.signalOrigin == this.signalOrigin &&
          other.hsiVersion == this.hsiVersion &&
          other.focus == this.focus &&
          other.focusConfidence == this.focusConfidence &&
          other.capacity == this.capacity &&
          other.capacityConfidence == this.capacityConfidence &&
          other.arousal == this.arousal &&
          other.arousalConfidence == this.arousalConfidence &&
          other.stress == this.stress &&
          other.stressConfidence == this.stressConfidence &&
          other.quality == this.quality);
}

class HsiWindowsCompanion extends UpdateCompanion<HsiWindow> {
  final Value<int> rowId;
  final Value<String> sessionId;
  final Value<DateTime> at;
  final Value<SignalOrigin> signalOrigin;
  final Value<String?> hsiVersion;
  final Value<double?> focus;
  final Value<double?> focusConfidence;
  final Value<double?> capacity;
  final Value<double?> capacityConfidence;
  final Value<double?> arousal;
  final Value<double?> arousalConfidence;
  final Value<double?> stress;
  final Value<double?> stressConfidence;
  final Value<double?> quality;
  const HsiWindowsCompanion({
    this.rowId = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.at = const Value.absent(),
    this.signalOrigin = const Value.absent(),
    this.hsiVersion = const Value.absent(),
    this.focus = const Value.absent(),
    this.focusConfidence = const Value.absent(),
    this.capacity = const Value.absent(),
    this.capacityConfidence = const Value.absent(),
    this.arousal = const Value.absent(),
    this.arousalConfidence = const Value.absent(),
    this.stress = const Value.absent(),
    this.stressConfidence = const Value.absent(),
    this.quality = const Value.absent(),
  });
  HsiWindowsCompanion.insert({
    this.rowId = const Value.absent(),
    required String sessionId,
    required DateTime at,
    this.signalOrigin = const Value.absent(),
    this.hsiVersion = const Value.absent(),
    this.focus = const Value.absent(),
    this.focusConfidence = const Value.absent(),
    this.capacity = const Value.absent(),
    this.capacityConfidence = const Value.absent(),
    this.arousal = const Value.absent(),
    this.arousalConfidence = const Value.absent(),
    this.stress = const Value.absent(),
    this.stressConfidence = const Value.absent(),
    this.quality = const Value.absent(),
  }) : sessionId = Value(sessionId),
       at = Value(at);
  static Insertable<HsiWindow> custom({
    Expression<int>? rowId,
    Expression<String>? sessionId,
    Expression<DateTime>? at,
    Expression<int>? signalOrigin,
    Expression<String>? hsiVersion,
    Expression<double>? focus,
    Expression<double>? focusConfidence,
    Expression<double>? capacity,
    Expression<double>? capacityConfidence,
    Expression<double>? arousal,
    Expression<double>? arousalConfidence,
    Expression<double>? stress,
    Expression<double>? stressConfidence,
    Expression<double>? quality,
  }) {
    return RawValuesInsertable({
      if (rowId != null) 'row_id': rowId,
      if (sessionId != null) 'session_id': sessionId,
      if (at != null) 'at': at,
      if (signalOrigin != null) 'signal_origin': signalOrigin,
      if (hsiVersion != null) 'hsi_version': hsiVersion,
      if (focus != null) 'focus': focus,
      if (focusConfidence != null) 'focus_confidence': focusConfidence,
      if (capacity != null) 'capacity': capacity,
      if (capacityConfidence != null) 'capacity_confidence': capacityConfidence,
      if (arousal != null) 'arousal': arousal,
      if (arousalConfidence != null) 'arousal_confidence': arousalConfidence,
      if (stress != null) 'stress': stress,
      if (stressConfidence != null) 'stress_confidence': stressConfidence,
      if (quality != null) 'quality': quality,
    });
  }

  HsiWindowsCompanion copyWith({
    Value<int>? rowId,
    Value<String>? sessionId,
    Value<DateTime>? at,
    Value<SignalOrigin>? signalOrigin,
    Value<String?>? hsiVersion,
    Value<double?>? focus,
    Value<double?>? focusConfidence,
    Value<double?>? capacity,
    Value<double?>? capacityConfidence,
    Value<double?>? arousal,
    Value<double?>? arousalConfidence,
    Value<double?>? stress,
    Value<double?>? stressConfidence,
    Value<double?>? quality,
  }) {
    return HsiWindowsCompanion(
      rowId: rowId ?? this.rowId,
      sessionId: sessionId ?? this.sessionId,
      at: at ?? this.at,
      signalOrigin: signalOrigin ?? this.signalOrigin,
      hsiVersion: hsiVersion ?? this.hsiVersion,
      focus: focus ?? this.focus,
      focusConfidence: focusConfidence ?? this.focusConfidence,
      capacity: capacity ?? this.capacity,
      capacityConfidence: capacityConfidence ?? this.capacityConfidence,
      arousal: arousal ?? this.arousal,
      arousalConfidence: arousalConfidence ?? this.arousalConfidence,
      stress: stress ?? this.stress,
      stressConfidence: stressConfidence ?? this.stressConfidence,
      quality: quality ?? this.quality,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (rowId.present) {
      map['row_id'] = Variable<int>(rowId.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (at.present) {
      map['at'] = Variable<DateTime>(at.value);
    }
    if (signalOrigin.present) {
      map['signal_origin'] = Variable<int>(
        $HsiWindowsTable.$convertersignalOrigin.toSql(signalOrigin.value),
      );
    }
    if (hsiVersion.present) {
      map['hsi_version'] = Variable<String>(hsiVersion.value);
    }
    if (focus.present) {
      map['focus'] = Variable<double>(focus.value);
    }
    if (focusConfidence.present) {
      map['focus_confidence'] = Variable<double>(focusConfidence.value);
    }
    if (capacity.present) {
      map['capacity'] = Variable<double>(capacity.value);
    }
    if (capacityConfidence.present) {
      map['capacity_confidence'] = Variable<double>(capacityConfidence.value);
    }
    if (arousal.present) {
      map['arousal'] = Variable<double>(arousal.value);
    }
    if (arousalConfidence.present) {
      map['arousal_confidence'] = Variable<double>(arousalConfidence.value);
    }
    if (stress.present) {
      map['stress'] = Variable<double>(stress.value);
    }
    if (stressConfidence.present) {
      map['stress_confidence'] = Variable<double>(stressConfidence.value);
    }
    if (quality.present) {
      map['quality'] = Variable<double>(quality.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HsiWindowsCompanion(')
          ..write('rowId: $rowId, ')
          ..write('sessionId: $sessionId, ')
          ..write('at: $at, ')
          ..write('signalOrigin: $signalOrigin, ')
          ..write('hsiVersion: $hsiVersion, ')
          ..write('focus: $focus, ')
          ..write('focusConfidence: $focusConfidence, ')
          ..write('capacity: $capacity, ')
          ..write('capacityConfidence: $capacityConfidence, ')
          ..write('arousal: $arousal, ')
          ..write('arousalConfidence: $arousalConfidence, ')
          ..write('stress: $stress, ')
          ..write('stressConfidence: $stressConfidence, ')
          ..write('quality: $quality')
          ..write(')'))
        .toString();
  }
}

class $CaptureSummariesTable extends CaptureSummaries
    with TableInfo<$CaptureSummariesTable, CaptureSummary> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CaptureSummariesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _rowIdMeta = const VerificationMeta('rowId');
  @override
  late final GeneratedColumn<int> rowId = GeneratedColumn<int>(
    'row_id',
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
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sessions (id) ON DELETE CASCADE',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<CapturePhase, int> phase =
      GeneratedColumn<int>(
        'phase',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<CapturePhase>($CaptureSummariesTable.$converterphase);
  @override
  late final GeneratedColumnWithTypeConverter<SignalOrigin, int> signalOrigin =
      GeneratedColumn<int>(
        'signal_origin',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<SignalOrigin>(
        $CaptureSummariesTable.$convertersignalOrigin,
      );
  static const VerificationMeta _watchSessionIdMeta = const VerificationMeta(
    'watchSessionId',
  );
  @override
  late final GeneratedColumn<String> watchSessionId = GeneratedColumn<String>(
    'watch_session_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _coreSessionIdMeta = const VerificationMeta(
    'coreSessionId',
  );
  @override
  late final GeneratedColumn<String> coreSessionId = GeneratedColumn<String>(
    'core_session_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _acceptedSamplesMeta = const VerificationMeta(
    'acceptedSamples',
  );
  @override
  late final GeneratedColumn<int> acceptedSamples = GeneratedColumn<int>(
    'accepted_samples',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _totalSamplesMeta = const VerificationMeta(
    'totalSamples',
  );
  @override
  late final GeneratedColumn<int> totalSamples = GeneratedColumn<int>(
    'total_samples',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _coverageSecondsMeta = const VerificationMeta(
    'coverageSeconds',
  );
  @override
  late final GeneratedColumn<int> coverageSeconds = GeneratedColumn<int>(
    'coverage_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _accuracyHighMeta = const VerificationMeta(
    'accuracyHigh',
  );
  @override
  late final GeneratedColumn<int> accuracyHigh = GeneratedColumn<int>(
    'accuracy_high',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _accuracyMediumMeta = const VerificationMeta(
    'accuracyMedium',
  );
  @override
  late final GeneratedColumn<int> accuracyMedium = GeneratedColumn<int>(
    'accuracy_medium',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _accuracyLowMeta = const VerificationMeta(
    'accuracyLow',
  );
  @override
  late final GeneratedColumn<int> accuracyLow = GeneratedColumn<int>(
    'accuracy_low',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _hsiWindowCountMeta = const VerificationMeta(
    'hsiWindowCount',
  );
  @override
  late final GeneratedColumn<int> hsiWindowCount = GeneratedColumn<int>(
    'hsi_window_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _hsiFocusMeta = const VerificationMeta(
    'hsiFocus',
  );
  @override
  late final GeneratedColumn<double> hsiFocus = GeneratedColumn<double>(
    'hsi_focus',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hsiFocusConfidenceMeta =
      const VerificationMeta('hsiFocusConfidence');
  @override
  late final GeneratedColumn<double> hsiFocusConfidence =
      GeneratedColumn<double>(
        'hsi_focus_confidence',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _hsiCapacityMeta = const VerificationMeta(
    'hsiCapacity',
  );
  @override
  late final GeneratedColumn<double> hsiCapacity = GeneratedColumn<double>(
    'hsi_capacity',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hsiCapacityConfidenceMeta =
      const VerificationMeta('hsiCapacityConfidence');
  @override
  late final GeneratedColumn<double> hsiCapacityConfidence =
      GeneratedColumn<double>(
        'hsi_capacity_confidence',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _hsiArousalMeta = const VerificationMeta(
    'hsiArousal',
  );
  @override
  late final GeneratedColumn<double> hsiArousal = GeneratedColumn<double>(
    'hsi_arousal',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hsiArousalConfidenceMeta =
      const VerificationMeta('hsiArousalConfidence');
  @override
  late final GeneratedColumn<double> hsiArousalConfidence =
      GeneratedColumn<double>(
        'hsi_arousal_confidence',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _hsiStressMeta = const VerificationMeta(
    'hsiStress',
  );
  @override
  late final GeneratedColumn<double> hsiStress = GeneratedColumn<double>(
    'hsi_stress',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hsiStressConfidenceMeta =
      const VerificationMeta('hsiStressConfidence');
  @override
  late final GeneratedColumn<double> hsiStressConfidence =
      GeneratedColumn<double>(
        'hsi_stress_confidence',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _qualityMeta = const VerificationMeta(
    'quality',
  );
  @override
  late final GeneratedColumn<double> quality = GeneratedColumn<double>(
    'quality',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _diagnosticErrorMeta = const VerificationMeta(
    'diagnosticError',
  );
  @override
  late final GeneratedColumn<String> diagnosticError = GeneratedColumn<String>(
    'diagnostic_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    rowId,
    sessionId,
    phase,
    signalOrigin,
    watchSessionId,
    coreSessionId,
    acceptedSamples,
    totalSamples,
    coverageSeconds,
    accuracyHigh,
    accuracyMedium,
    accuracyLow,
    hsiWindowCount,
    hsiFocus,
    hsiFocusConfidence,
    hsiCapacity,
    hsiCapacityConfidence,
    hsiArousal,
    hsiArousalConfidence,
    hsiStress,
    hsiStressConfidence,
    quality,
    diagnosticError,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'capture_summaries';
  @override
  VerificationContext validateIntegrity(
    Insertable<CaptureSummary> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('row_id')) {
      context.handle(
        _rowIdMeta,
        rowId.isAcceptableOrUnknown(data['row_id']!, _rowIdMeta),
      );
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('watch_session_id')) {
      context.handle(
        _watchSessionIdMeta,
        watchSessionId.isAcceptableOrUnknown(
          data['watch_session_id']!,
          _watchSessionIdMeta,
        ),
      );
    }
    if (data.containsKey('core_session_id')) {
      context.handle(
        _coreSessionIdMeta,
        coreSessionId.isAcceptableOrUnknown(
          data['core_session_id']!,
          _coreSessionIdMeta,
        ),
      );
    }
    if (data.containsKey('accepted_samples')) {
      context.handle(
        _acceptedSamplesMeta,
        acceptedSamples.isAcceptableOrUnknown(
          data['accepted_samples']!,
          _acceptedSamplesMeta,
        ),
      );
    }
    if (data.containsKey('total_samples')) {
      context.handle(
        _totalSamplesMeta,
        totalSamples.isAcceptableOrUnknown(
          data['total_samples']!,
          _totalSamplesMeta,
        ),
      );
    }
    if (data.containsKey('coverage_seconds')) {
      context.handle(
        _coverageSecondsMeta,
        coverageSeconds.isAcceptableOrUnknown(
          data['coverage_seconds']!,
          _coverageSecondsMeta,
        ),
      );
    }
    if (data.containsKey('accuracy_high')) {
      context.handle(
        _accuracyHighMeta,
        accuracyHigh.isAcceptableOrUnknown(
          data['accuracy_high']!,
          _accuracyHighMeta,
        ),
      );
    }
    if (data.containsKey('accuracy_medium')) {
      context.handle(
        _accuracyMediumMeta,
        accuracyMedium.isAcceptableOrUnknown(
          data['accuracy_medium']!,
          _accuracyMediumMeta,
        ),
      );
    }
    if (data.containsKey('accuracy_low')) {
      context.handle(
        _accuracyLowMeta,
        accuracyLow.isAcceptableOrUnknown(
          data['accuracy_low']!,
          _accuracyLowMeta,
        ),
      );
    }
    if (data.containsKey('hsi_window_count')) {
      context.handle(
        _hsiWindowCountMeta,
        hsiWindowCount.isAcceptableOrUnknown(
          data['hsi_window_count']!,
          _hsiWindowCountMeta,
        ),
      );
    }
    if (data.containsKey('hsi_focus')) {
      context.handle(
        _hsiFocusMeta,
        hsiFocus.isAcceptableOrUnknown(data['hsi_focus']!, _hsiFocusMeta),
      );
    }
    if (data.containsKey('hsi_focus_confidence')) {
      context.handle(
        _hsiFocusConfidenceMeta,
        hsiFocusConfidence.isAcceptableOrUnknown(
          data['hsi_focus_confidence']!,
          _hsiFocusConfidenceMeta,
        ),
      );
    }
    if (data.containsKey('hsi_capacity')) {
      context.handle(
        _hsiCapacityMeta,
        hsiCapacity.isAcceptableOrUnknown(
          data['hsi_capacity']!,
          _hsiCapacityMeta,
        ),
      );
    }
    if (data.containsKey('hsi_capacity_confidence')) {
      context.handle(
        _hsiCapacityConfidenceMeta,
        hsiCapacityConfidence.isAcceptableOrUnknown(
          data['hsi_capacity_confidence']!,
          _hsiCapacityConfidenceMeta,
        ),
      );
    }
    if (data.containsKey('hsi_arousal')) {
      context.handle(
        _hsiArousalMeta,
        hsiArousal.isAcceptableOrUnknown(data['hsi_arousal']!, _hsiArousalMeta),
      );
    }
    if (data.containsKey('hsi_arousal_confidence')) {
      context.handle(
        _hsiArousalConfidenceMeta,
        hsiArousalConfidence.isAcceptableOrUnknown(
          data['hsi_arousal_confidence']!,
          _hsiArousalConfidenceMeta,
        ),
      );
    }
    if (data.containsKey('hsi_stress')) {
      context.handle(
        _hsiStressMeta,
        hsiStress.isAcceptableOrUnknown(data['hsi_stress']!, _hsiStressMeta),
      );
    }
    if (data.containsKey('hsi_stress_confidence')) {
      context.handle(
        _hsiStressConfidenceMeta,
        hsiStressConfidence.isAcceptableOrUnknown(
          data['hsi_stress_confidence']!,
          _hsiStressConfidenceMeta,
        ),
      );
    }
    if (data.containsKey('quality')) {
      context.handle(
        _qualityMeta,
        quality.isAcceptableOrUnknown(data['quality']!, _qualityMeta),
      );
    }
    if (data.containsKey('diagnostic_error')) {
      context.handle(
        _diagnosticErrorMeta,
        diagnosticError.isAcceptableOrUnknown(
          data['diagnostic_error']!,
          _diagnosticErrorMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {rowId};
  @override
  CaptureSummary map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CaptureSummary(
      rowId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}row_id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      phase: $CaptureSummariesTable.$converterphase.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}phase'],
        )!,
      ),
      signalOrigin: $CaptureSummariesTable.$convertersignalOrigin.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}signal_origin'],
        )!,
      ),
      watchSessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}watch_session_id'],
      ),
      coreSessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}core_session_id'],
      ),
      acceptedSamples: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}accepted_samples'],
      )!,
      totalSamples: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_samples'],
      )!,
      coverageSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}coverage_seconds'],
      )!,
      accuracyHigh: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}accuracy_high'],
      )!,
      accuracyMedium: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}accuracy_medium'],
      )!,
      accuracyLow: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}accuracy_low'],
      )!,
      hsiWindowCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hsi_window_count'],
      )!,
      hsiFocus: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}hsi_focus'],
      ),
      hsiFocusConfidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}hsi_focus_confidence'],
      ),
      hsiCapacity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}hsi_capacity'],
      ),
      hsiCapacityConfidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}hsi_capacity_confidence'],
      ),
      hsiArousal: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}hsi_arousal'],
      ),
      hsiArousalConfidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}hsi_arousal_confidence'],
      ),
      hsiStress: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}hsi_stress'],
      ),
      hsiStressConfidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}hsi_stress_confidence'],
      ),
      quality: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quality'],
      ),
      diagnosticError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}diagnostic_error'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CaptureSummariesTable createAlias(String alias) {
    return $CaptureSummariesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<CapturePhase, int, int> $converterphase =
      const EnumIndexConverter<CapturePhase>(CapturePhase.values);
  static JsonTypeConverter2<SignalOrigin, int, int> $convertersignalOrigin =
      const EnumIndexConverter<SignalOrigin>(SignalOrigin.values);
}

class CaptureSummary extends DataClass implements Insertable<CaptureSummary> {
  final int rowId;
  final String sessionId;
  final CapturePhase phase;
  final SignalOrigin signalOrigin;
  final String? watchSessionId;
  final String? coreSessionId;
  final int acceptedSamples;
  final int totalSamples;
  final int coverageSeconds;
  final int accuracyHigh;
  final int accuracyMedium;
  final int accuracyLow;
  final int hsiWindowCount;
  final double? hsiFocus;
  final double? hsiFocusConfidence;
  final double? hsiCapacity;
  final double? hsiCapacityConfidence;
  final double? hsiArousal;
  final double? hsiArousalConfidence;
  final double? hsiStress;
  final double? hsiStressConfidence;
  final double? quality;
  final String? diagnosticError;
  final DateTime createdAt;
  const CaptureSummary({
    required this.rowId,
    required this.sessionId,
    required this.phase,
    required this.signalOrigin,
    this.watchSessionId,
    this.coreSessionId,
    required this.acceptedSamples,
    required this.totalSamples,
    required this.coverageSeconds,
    required this.accuracyHigh,
    required this.accuracyMedium,
    required this.accuracyLow,
    required this.hsiWindowCount,
    this.hsiFocus,
    this.hsiFocusConfidence,
    this.hsiCapacity,
    this.hsiCapacityConfidence,
    this.hsiArousal,
    this.hsiArousalConfidence,
    this.hsiStress,
    this.hsiStressConfidence,
    this.quality,
    this.diagnosticError,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['row_id'] = Variable<int>(rowId);
    map['session_id'] = Variable<String>(sessionId);
    {
      map['phase'] = Variable<int>(
        $CaptureSummariesTable.$converterphase.toSql(phase),
      );
    }
    {
      map['signal_origin'] = Variable<int>(
        $CaptureSummariesTable.$convertersignalOrigin.toSql(signalOrigin),
      );
    }
    if (!nullToAbsent || watchSessionId != null) {
      map['watch_session_id'] = Variable<String>(watchSessionId);
    }
    if (!nullToAbsent || coreSessionId != null) {
      map['core_session_id'] = Variable<String>(coreSessionId);
    }
    map['accepted_samples'] = Variable<int>(acceptedSamples);
    map['total_samples'] = Variable<int>(totalSamples);
    map['coverage_seconds'] = Variable<int>(coverageSeconds);
    map['accuracy_high'] = Variable<int>(accuracyHigh);
    map['accuracy_medium'] = Variable<int>(accuracyMedium);
    map['accuracy_low'] = Variable<int>(accuracyLow);
    map['hsi_window_count'] = Variable<int>(hsiWindowCount);
    if (!nullToAbsent || hsiFocus != null) {
      map['hsi_focus'] = Variable<double>(hsiFocus);
    }
    if (!nullToAbsent || hsiFocusConfidence != null) {
      map['hsi_focus_confidence'] = Variable<double>(hsiFocusConfidence);
    }
    if (!nullToAbsent || hsiCapacity != null) {
      map['hsi_capacity'] = Variable<double>(hsiCapacity);
    }
    if (!nullToAbsent || hsiCapacityConfidence != null) {
      map['hsi_capacity_confidence'] = Variable<double>(hsiCapacityConfidence);
    }
    if (!nullToAbsent || hsiArousal != null) {
      map['hsi_arousal'] = Variable<double>(hsiArousal);
    }
    if (!nullToAbsent || hsiArousalConfidence != null) {
      map['hsi_arousal_confidence'] = Variable<double>(hsiArousalConfidence);
    }
    if (!nullToAbsent || hsiStress != null) {
      map['hsi_stress'] = Variable<double>(hsiStress);
    }
    if (!nullToAbsent || hsiStressConfidence != null) {
      map['hsi_stress_confidence'] = Variable<double>(hsiStressConfidence);
    }
    if (!nullToAbsent || quality != null) {
      map['quality'] = Variable<double>(quality);
    }
    if (!nullToAbsent || diagnosticError != null) {
      map['diagnostic_error'] = Variable<String>(diagnosticError);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CaptureSummariesCompanion toCompanion(bool nullToAbsent) {
    return CaptureSummariesCompanion(
      rowId: Value(rowId),
      sessionId: Value(sessionId),
      phase: Value(phase),
      signalOrigin: Value(signalOrigin),
      watchSessionId: watchSessionId == null && nullToAbsent
          ? const Value.absent()
          : Value(watchSessionId),
      coreSessionId: coreSessionId == null && nullToAbsent
          ? const Value.absent()
          : Value(coreSessionId),
      acceptedSamples: Value(acceptedSamples),
      totalSamples: Value(totalSamples),
      coverageSeconds: Value(coverageSeconds),
      accuracyHigh: Value(accuracyHigh),
      accuracyMedium: Value(accuracyMedium),
      accuracyLow: Value(accuracyLow),
      hsiWindowCount: Value(hsiWindowCount),
      hsiFocus: hsiFocus == null && nullToAbsent
          ? const Value.absent()
          : Value(hsiFocus),
      hsiFocusConfidence: hsiFocusConfidence == null && nullToAbsent
          ? const Value.absent()
          : Value(hsiFocusConfidence),
      hsiCapacity: hsiCapacity == null && nullToAbsent
          ? const Value.absent()
          : Value(hsiCapacity),
      hsiCapacityConfidence: hsiCapacityConfidence == null && nullToAbsent
          ? const Value.absent()
          : Value(hsiCapacityConfidence),
      hsiArousal: hsiArousal == null && nullToAbsent
          ? const Value.absent()
          : Value(hsiArousal),
      hsiArousalConfidence: hsiArousalConfidence == null && nullToAbsent
          ? const Value.absent()
          : Value(hsiArousalConfidence),
      hsiStress: hsiStress == null && nullToAbsent
          ? const Value.absent()
          : Value(hsiStress),
      hsiStressConfidence: hsiStressConfidence == null && nullToAbsent
          ? const Value.absent()
          : Value(hsiStressConfidence),
      quality: quality == null && nullToAbsent
          ? const Value.absent()
          : Value(quality),
      diagnosticError: diagnosticError == null && nullToAbsent
          ? const Value.absent()
          : Value(diagnosticError),
      createdAt: Value(createdAt),
    );
  }

  factory CaptureSummary.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CaptureSummary(
      rowId: serializer.fromJson<int>(json['rowId']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      phase: $CaptureSummariesTable.$converterphase.fromJson(
        serializer.fromJson<int>(json['phase']),
      ),
      signalOrigin: $CaptureSummariesTable.$convertersignalOrigin.fromJson(
        serializer.fromJson<int>(json['signalOrigin']),
      ),
      watchSessionId: serializer.fromJson<String?>(json['watchSessionId']),
      coreSessionId: serializer.fromJson<String?>(json['coreSessionId']),
      acceptedSamples: serializer.fromJson<int>(json['acceptedSamples']),
      totalSamples: serializer.fromJson<int>(json['totalSamples']),
      coverageSeconds: serializer.fromJson<int>(json['coverageSeconds']),
      accuracyHigh: serializer.fromJson<int>(json['accuracyHigh']),
      accuracyMedium: serializer.fromJson<int>(json['accuracyMedium']),
      accuracyLow: serializer.fromJson<int>(json['accuracyLow']),
      hsiWindowCount: serializer.fromJson<int>(json['hsiWindowCount']),
      hsiFocus: serializer.fromJson<double?>(json['hsiFocus']),
      hsiFocusConfidence: serializer.fromJson<double?>(
        json['hsiFocusConfidence'],
      ),
      hsiCapacity: serializer.fromJson<double?>(json['hsiCapacity']),
      hsiCapacityConfidence: serializer.fromJson<double?>(
        json['hsiCapacityConfidence'],
      ),
      hsiArousal: serializer.fromJson<double?>(json['hsiArousal']),
      hsiArousalConfidence: serializer.fromJson<double?>(
        json['hsiArousalConfidence'],
      ),
      hsiStress: serializer.fromJson<double?>(json['hsiStress']),
      hsiStressConfidence: serializer.fromJson<double?>(
        json['hsiStressConfidence'],
      ),
      quality: serializer.fromJson<double?>(json['quality']),
      diagnosticError: serializer.fromJson<String?>(json['diagnosticError']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'rowId': serializer.toJson<int>(rowId),
      'sessionId': serializer.toJson<String>(sessionId),
      'phase': serializer.toJson<int>(
        $CaptureSummariesTable.$converterphase.toJson(phase),
      ),
      'signalOrigin': serializer.toJson<int>(
        $CaptureSummariesTable.$convertersignalOrigin.toJson(signalOrigin),
      ),
      'watchSessionId': serializer.toJson<String?>(watchSessionId),
      'coreSessionId': serializer.toJson<String?>(coreSessionId),
      'acceptedSamples': serializer.toJson<int>(acceptedSamples),
      'totalSamples': serializer.toJson<int>(totalSamples),
      'coverageSeconds': serializer.toJson<int>(coverageSeconds),
      'accuracyHigh': serializer.toJson<int>(accuracyHigh),
      'accuracyMedium': serializer.toJson<int>(accuracyMedium),
      'accuracyLow': serializer.toJson<int>(accuracyLow),
      'hsiWindowCount': serializer.toJson<int>(hsiWindowCount),
      'hsiFocus': serializer.toJson<double?>(hsiFocus),
      'hsiFocusConfidence': serializer.toJson<double?>(hsiFocusConfidence),
      'hsiCapacity': serializer.toJson<double?>(hsiCapacity),
      'hsiCapacityConfidence': serializer.toJson<double?>(
        hsiCapacityConfidence,
      ),
      'hsiArousal': serializer.toJson<double?>(hsiArousal),
      'hsiArousalConfidence': serializer.toJson<double?>(hsiArousalConfidence),
      'hsiStress': serializer.toJson<double?>(hsiStress),
      'hsiStressConfidence': serializer.toJson<double?>(hsiStressConfidence),
      'quality': serializer.toJson<double?>(quality),
      'diagnosticError': serializer.toJson<String?>(diagnosticError),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  CaptureSummary copyWith({
    int? rowId,
    String? sessionId,
    CapturePhase? phase,
    SignalOrigin? signalOrigin,
    Value<String?> watchSessionId = const Value.absent(),
    Value<String?> coreSessionId = const Value.absent(),
    int? acceptedSamples,
    int? totalSamples,
    int? coverageSeconds,
    int? accuracyHigh,
    int? accuracyMedium,
    int? accuracyLow,
    int? hsiWindowCount,
    Value<double?> hsiFocus = const Value.absent(),
    Value<double?> hsiFocusConfidence = const Value.absent(),
    Value<double?> hsiCapacity = const Value.absent(),
    Value<double?> hsiCapacityConfidence = const Value.absent(),
    Value<double?> hsiArousal = const Value.absent(),
    Value<double?> hsiArousalConfidence = const Value.absent(),
    Value<double?> hsiStress = const Value.absent(),
    Value<double?> hsiStressConfidence = const Value.absent(),
    Value<double?> quality = const Value.absent(),
    Value<String?> diagnosticError = const Value.absent(),
    DateTime? createdAt,
  }) => CaptureSummary(
    rowId: rowId ?? this.rowId,
    sessionId: sessionId ?? this.sessionId,
    phase: phase ?? this.phase,
    signalOrigin: signalOrigin ?? this.signalOrigin,
    watchSessionId: watchSessionId.present
        ? watchSessionId.value
        : this.watchSessionId,
    coreSessionId: coreSessionId.present
        ? coreSessionId.value
        : this.coreSessionId,
    acceptedSamples: acceptedSamples ?? this.acceptedSamples,
    totalSamples: totalSamples ?? this.totalSamples,
    coverageSeconds: coverageSeconds ?? this.coverageSeconds,
    accuracyHigh: accuracyHigh ?? this.accuracyHigh,
    accuracyMedium: accuracyMedium ?? this.accuracyMedium,
    accuracyLow: accuracyLow ?? this.accuracyLow,
    hsiWindowCount: hsiWindowCount ?? this.hsiWindowCount,
    hsiFocus: hsiFocus.present ? hsiFocus.value : this.hsiFocus,
    hsiFocusConfidence: hsiFocusConfidence.present
        ? hsiFocusConfidence.value
        : this.hsiFocusConfidence,
    hsiCapacity: hsiCapacity.present ? hsiCapacity.value : this.hsiCapacity,
    hsiCapacityConfidence: hsiCapacityConfidence.present
        ? hsiCapacityConfidence.value
        : this.hsiCapacityConfidence,
    hsiArousal: hsiArousal.present ? hsiArousal.value : this.hsiArousal,
    hsiArousalConfidence: hsiArousalConfidence.present
        ? hsiArousalConfidence.value
        : this.hsiArousalConfidence,
    hsiStress: hsiStress.present ? hsiStress.value : this.hsiStress,
    hsiStressConfidence: hsiStressConfidence.present
        ? hsiStressConfidence.value
        : this.hsiStressConfidence,
    quality: quality.present ? quality.value : this.quality,
    diagnosticError: diagnosticError.present
        ? diagnosticError.value
        : this.diagnosticError,
    createdAt: createdAt ?? this.createdAt,
  );
  CaptureSummary copyWithCompanion(CaptureSummariesCompanion data) {
    return CaptureSummary(
      rowId: data.rowId.present ? data.rowId.value : this.rowId,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      phase: data.phase.present ? data.phase.value : this.phase,
      signalOrigin: data.signalOrigin.present
          ? data.signalOrigin.value
          : this.signalOrigin,
      watchSessionId: data.watchSessionId.present
          ? data.watchSessionId.value
          : this.watchSessionId,
      coreSessionId: data.coreSessionId.present
          ? data.coreSessionId.value
          : this.coreSessionId,
      acceptedSamples: data.acceptedSamples.present
          ? data.acceptedSamples.value
          : this.acceptedSamples,
      totalSamples: data.totalSamples.present
          ? data.totalSamples.value
          : this.totalSamples,
      coverageSeconds: data.coverageSeconds.present
          ? data.coverageSeconds.value
          : this.coverageSeconds,
      accuracyHigh: data.accuracyHigh.present
          ? data.accuracyHigh.value
          : this.accuracyHigh,
      accuracyMedium: data.accuracyMedium.present
          ? data.accuracyMedium.value
          : this.accuracyMedium,
      accuracyLow: data.accuracyLow.present
          ? data.accuracyLow.value
          : this.accuracyLow,
      hsiWindowCount: data.hsiWindowCount.present
          ? data.hsiWindowCount.value
          : this.hsiWindowCount,
      hsiFocus: data.hsiFocus.present ? data.hsiFocus.value : this.hsiFocus,
      hsiFocusConfidence: data.hsiFocusConfidence.present
          ? data.hsiFocusConfidence.value
          : this.hsiFocusConfidence,
      hsiCapacity: data.hsiCapacity.present
          ? data.hsiCapacity.value
          : this.hsiCapacity,
      hsiCapacityConfidence: data.hsiCapacityConfidence.present
          ? data.hsiCapacityConfidence.value
          : this.hsiCapacityConfidence,
      hsiArousal: data.hsiArousal.present
          ? data.hsiArousal.value
          : this.hsiArousal,
      hsiArousalConfidence: data.hsiArousalConfidence.present
          ? data.hsiArousalConfidence.value
          : this.hsiArousalConfidence,
      hsiStress: data.hsiStress.present ? data.hsiStress.value : this.hsiStress,
      hsiStressConfidence: data.hsiStressConfidence.present
          ? data.hsiStressConfidence.value
          : this.hsiStressConfidence,
      quality: data.quality.present ? data.quality.value : this.quality,
      diagnosticError: data.diagnosticError.present
          ? data.diagnosticError.value
          : this.diagnosticError,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CaptureSummary(')
          ..write('rowId: $rowId, ')
          ..write('sessionId: $sessionId, ')
          ..write('phase: $phase, ')
          ..write('signalOrigin: $signalOrigin, ')
          ..write('watchSessionId: $watchSessionId, ')
          ..write('coreSessionId: $coreSessionId, ')
          ..write('acceptedSamples: $acceptedSamples, ')
          ..write('totalSamples: $totalSamples, ')
          ..write('coverageSeconds: $coverageSeconds, ')
          ..write('accuracyHigh: $accuracyHigh, ')
          ..write('accuracyMedium: $accuracyMedium, ')
          ..write('accuracyLow: $accuracyLow, ')
          ..write('hsiWindowCount: $hsiWindowCount, ')
          ..write('hsiFocus: $hsiFocus, ')
          ..write('hsiFocusConfidence: $hsiFocusConfidence, ')
          ..write('hsiCapacity: $hsiCapacity, ')
          ..write('hsiCapacityConfidence: $hsiCapacityConfidence, ')
          ..write('hsiArousal: $hsiArousal, ')
          ..write('hsiArousalConfidence: $hsiArousalConfidence, ')
          ..write('hsiStress: $hsiStress, ')
          ..write('hsiStressConfidence: $hsiStressConfidence, ')
          ..write('quality: $quality, ')
          ..write('diagnosticError: $diagnosticError, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    rowId,
    sessionId,
    phase,
    signalOrigin,
    watchSessionId,
    coreSessionId,
    acceptedSamples,
    totalSamples,
    coverageSeconds,
    accuracyHigh,
    accuracyMedium,
    accuracyLow,
    hsiWindowCount,
    hsiFocus,
    hsiFocusConfidence,
    hsiCapacity,
    hsiCapacityConfidence,
    hsiArousal,
    hsiArousalConfidence,
    hsiStress,
    hsiStressConfidence,
    quality,
    diagnosticError,
    createdAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CaptureSummary &&
          other.rowId == this.rowId &&
          other.sessionId == this.sessionId &&
          other.phase == this.phase &&
          other.signalOrigin == this.signalOrigin &&
          other.watchSessionId == this.watchSessionId &&
          other.coreSessionId == this.coreSessionId &&
          other.acceptedSamples == this.acceptedSamples &&
          other.totalSamples == this.totalSamples &&
          other.coverageSeconds == this.coverageSeconds &&
          other.accuracyHigh == this.accuracyHigh &&
          other.accuracyMedium == this.accuracyMedium &&
          other.accuracyLow == this.accuracyLow &&
          other.hsiWindowCount == this.hsiWindowCount &&
          other.hsiFocus == this.hsiFocus &&
          other.hsiFocusConfidence == this.hsiFocusConfidence &&
          other.hsiCapacity == this.hsiCapacity &&
          other.hsiCapacityConfidence == this.hsiCapacityConfidence &&
          other.hsiArousal == this.hsiArousal &&
          other.hsiArousalConfidence == this.hsiArousalConfidence &&
          other.hsiStress == this.hsiStress &&
          other.hsiStressConfidence == this.hsiStressConfidence &&
          other.quality == this.quality &&
          other.diagnosticError == this.diagnosticError &&
          other.createdAt == this.createdAt);
}

class CaptureSummariesCompanion extends UpdateCompanion<CaptureSummary> {
  final Value<int> rowId;
  final Value<String> sessionId;
  final Value<CapturePhase> phase;
  final Value<SignalOrigin> signalOrigin;
  final Value<String?> watchSessionId;
  final Value<String?> coreSessionId;
  final Value<int> acceptedSamples;
  final Value<int> totalSamples;
  final Value<int> coverageSeconds;
  final Value<int> accuracyHigh;
  final Value<int> accuracyMedium;
  final Value<int> accuracyLow;
  final Value<int> hsiWindowCount;
  final Value<double?> hsiFocus;
  final Value<double?> hsiFocusConfidence;
  final Value<double?> hsiCapacity;
  final Value<double?> hsiCapacityConfidence;
  final Value<double?> hsiArousal;
  final Value<double?> hsiArousalConfidence;
  final Value<double?> hsiStress;
  final Value<double?> hsiStressConfidence;
  final Value<double?> quality;
  final Value<String?> diagnosticError;
  final Value<DateTime> createdAt;
  const CaptureSummariesCompanion({
    this.rowId = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.phase = const Value.absent(),
    this.signalOrigin = const Value.absent(),
    this.watchSessionId = const Value.absent(),
    this.coreSessionId = const Value.absent(),
    this.acceptedSamples = const Value.absent(),
    this.totalSamples = const Value.absent(),
    this.coverageSeconds = const Value.absent(),
    this.accuracyHigh = const Value.absent(),
    this.accuracyMedium = const Value.absent(),
    this.accuracyLow = const Value.absent(),
    this.hsiWindowCount = const Value.absent(),
    this.hsiFocus = const Value.absent(),
    this.hsiFocusConfidence = const Value.absent(),
    this.hsiCapacity = const Value.absent(),
    this.hsiCapacityConfidence = const Value.absent(),
    this.hsiArousal = const Value.absent(),
    this.hsiArousalConfidence = const Value.absent(),
    this.hsiStress = const Value.absent(),
    this.hsiStressConfidence = const Value.absent(),
    this.quality = const Value.absent(),
    this.diagnosticError = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  CaptureSummariesCompanion.insert({
    this.rowId = const Value.absent(),
    required String sessionId,
    required CapturePhase phase,
    required SignalOrigin signalOrigin,
    this.watchSessionId = const Value.absent(),
    this.coreSessionId = const Value.absent(),
    this.acceptedSamples = const Value.absent(),
    this.totalSamples = const Value.absent(),
    this.coverageSeconds = const Value.absent(),
    this.accuracyHigh = const Value.absent(),
    this.accuracyMedium = const Value.absent(),
    this.accuracyLow = const Value.absent(),
    this.hsiWindowCount = const Value.absent(),
    this.hsiFocus = const Value.absent(),
    this.hsiFocusConfidence = const Value.absent(),
    this.hsiCapacity = const Value.absent(),
    this.hsiCapacityConfidence = const Value.absent(),
    this.hsiArousal = const Value.absent(),
    this.hsiArousalConfidence = const Value.absent(),
    this.hsiStress = const Value.absent(),
    this.hsiStressConfidence = const Value.absent(),
    this.quality = const Value.absent(),
    this.diagnosticError = const Value.absent(),
    required DateTime createdAt,
  }) : sessionId = Value(sessionId),
       phase = Value(phase),
       signalOrigin = Value(signalOrigin),
       createdAt = Value(createdAt);
  static Insertable<CaptureSummary> custom({
    Expression<int>? rowId,
    Expression<String>? sessionId,
    Expression<int>? phase,
    Expression<int>? signalOrigin,
    Expression<String>? watchSessionId,
    Expression<String>? coreSessionId,
    Expression<int>? acceptedSamples,
    Expression<int>? totalSamples,
    Expression<int>? coverageSeconds,
    Expression<int>? accuracyHigh,
    Expression<int>? accuracyMedium,
    Expression<int>? accuracyLow,
    Expression<int>? hsiWindowCount,
    Expression<double>? hsiFocus,
    Expression<double>? hsiFocusConfidence,
    Expression<double>? hsiCapacity,
    Expression<double>? hsiCapacityConfidence,
    Expression<double>? hsiArousal,
    Expression<double>? hsiArousalConfidence,
    Expression<double>? hsiStress,
    Expression<double>? hsiStressConfidence,
    Expression<double>? quality,
    Expression<String>? diagnosticError,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (rowId != null) 'row_id': rowId,
      if (sessionId != null) 'session_id': sessionId,
      if (phase != null) 'phase': phase,
      if (signalOrigin != null) 'signal_origin': signalOrigin,
      if (watchSessionId != null) 'watch_session_id': watchSessionId,
      if (coreSessionId != null) 'core_session_id': coreSessionId,
      if (acceptedSamples != null) 'accepted_samples': acceptedSamples,
      if (totalSamples != null) 'total_samples': totalSamples,
      if (coverageSeconds != null) 'coverage_seconds': coverageSeconds,
      if (accuracyHigh != null) 'accuracy_high': accuracyHigh,
      if (accuracyMedium != null) 'accuracy_medium': accuracyMedium,
      if (accuracyLow != null) 'accuracy_low': accuracyLow,
      if (hsiWindowCount != null) 'hsi_window_count': hsiWindowCount,
      if (hsiFocus != null) 'hsi_focus': hsiFocus,
      if (hsiFocusConfidence != null)
        'hsi_focus_confidence': hsiFocusConfidence,
      if (hsiCapacity != null) 'hsi_capacity': hsiCapacity,
      if (hsiCapacityConfidence != null)
        'hsi_capacity_confidence': hsiCapacityConfidence,
      if (hsiArousal != null) 'hsi_arousal': hsiArousal,
      if (hsiArousalConfidence != null)
        'hsi_arousal_confidence': hsiArousalConfidence,
      if (hsiStress != null) 'hsi_stress': hsiStress,
      if (hsiStressConfidence != null)
        'hsi_stress_confidence': hsiStressConfidence,
      if (quality != null) 'quality': quality,
      if (diagnosticError != null) 'diagnostic_error': diagnosticError,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  CaptureSummariesCompanion copyWith({
    Value<int>? rowId,
    Value<String>? sessionId,
    Value<CapturePhase>? phase,
    Value<SignalOrigin>? signalOrigin,
    Value<String?>? watchSessionId,
    Value<String?>? coreSessionId,
    Value<int>? acceptedSamples,
    Value<int>? totalSamples,
    Value<int>? coverageSeconds,
    Value<int>? accuracyHigh,
    Value<int>? accuracyMedium,
    Value<int>? accuracyLow,
    Value<int>? hsiWindowCount,
    Value<double?>? hsiFocus,
    Value<double?>? hsiFocusConfidence,
    Value<double?>? hsiCapacity,
    Value<double?>? hsiCapacityConfidence,
    Value<double?>? hsiArousal,
    Value<double?>? hsiArousalConfidence,
    Value<double?>? hsiStress,
    Value<double?>? hsiStressConfidence,
    Value<double?>? quality,
    Value<String?>? diagnosticError,
    Value<DateTime>? createdAt,
  }) {
    return CaptureSummariesCompanion(
      rowId: rowId ?? this.rowId,
      sessionId: sessionId ?? this.sessionId,
      phase: phase ?? this.phase,
      signalOrigin: signalOrigin ?? this.signalOrigin,
      watchSessionId: watchSessionId ?? this.watchSessionId,
      coreSessionId: coreSessionId ?? this.coreSessionId,
      acceptedSamples: acceptedSamples ?? this.acceptedSamples,
      totalSamples: totalSamples ?? this.totalSamples,
      coverageSeconds: coverageSeconds ?? this.coverageSeconds,
      accuracyHigh: accuracyHigh ?? this.accuracyHigh,
      accuracyMedium: accuracyMedium ?? this.accuracyMedium,
      accuracyLow: accuracyLow ?? this.accuracyLow,
      hsiWindowCount: hsiWindowCount ?? this.hsiWindowCount,
      hsiFocus: hsiFocus ?? this.hsiFocus,
      hsiFocusConfidence: hsiFocusConfidence ?? this.hsiFocusConfidence,
      hsiCapacity: hsiCapacity ?? this.hsiCapacity,
      hsiCapacityConfidence:
          hsiCapacityConfidence ?? this.hsiCapacityConfidence,
      hsiArousal: hsiArousal ?? this.hsiArousal,
      hsiArousalConfidence: hsiArousalConfidence ?? this.hsiArousalConfidence,
      hsiStress: hsiStress ?? this.hsiStress,
      hsiStressConfidence: hsiStressConfidence ?? this.hsiStressConfidence,
      quality: quality ?? this.quality,
      diagnosticError: diagnosticError ?? this.diagnosticError,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (rowId.present) {
      map['row_id'] = Variable<int>(rowId.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (phase.present) {
      map['phase'] = Variable<int>(
        $CaptureSummariesTable.$converterphase.toSql(phase.value),
      );
    }
    if (signalOrigin.present) {
      map['signal_origin'] = Variable<int>(
        $CaptureSummariesTable.$convertersignalOrigin.toSql(signalOrigin.value),
      );
    }
    if (watchSessionId.present) {
      map['watch_session_id'] = Variable<String>(watchSessionId.value);
    }
    if (coreSessionId.present) {
      map['core_session_id'] = Variable<String>(coreSessionId.value);
    }
    if (acceptedSamples.present) {
      map['accepted_samples'] = Variable<int>(acceptedSamples.value);
    }
    if (totalSamples.present) {
      map['total_samples'] = Variable<int>(totalSamples.value);
    }
    if (coverageSeconds.present) {
      map['coverage_seconds'] = Variable<int>(coverageSeconds.value);
    }
    if (accuracyHigh.present) {
      map['accuracy_high'] = Variable<int>(accuracyHigh.value);
    }
    if (accuracyMedium.present) {
      map['accuracy_medium'] = Variable<int>(accuracyMedium.value);
    }
    if (accuracyLow.present) {
      map['accuracy_low'] = Variable<int>(accuracyLow.value);
    }
    if (hsiWindowCount.present) {
      map['hsi_window_count'] = Variable<int>(hsiWindowCount.value);
    }
    if (hsiFocus.present) {
      map['hsi_focus'] = Variable<double>(hsiFocus.value);
    }
    if (hsiFocusConfidence.present) {
      map['hsi_focus_confidence'] = Variable<double>(hsiFocusConfidence.value);
    }
    if (hsiCapacity.present) {
      map['hsi_capacity'] = Variable<double>(hsiCapacity.value);
    }
    if (hsiCapacityConfidence.present) {
      map['hsi_capacity_confidence'] = Variable<double>(
        hsiCapacityConfidence.value,
      );
    }
    if (hsiArousal.present) {
      map['hsi_arousal'] = Variable<double>(hsiArousal.value);
    }
    if (hsiArousalConfidence.present) {
      map['hsi_arousal_confidence'] = Variable<double>(
        hsiArousalConfidence.value,
      );
    }
    if (hsiStress.present) {
      map['hsi_stress'] = Variable<double>(hsiStress.value);
    }
    if (hsiStressConfidence.present) {
      map['hsi_stress_confidence'] = Variable<double>(
        hsiStressConfidence.value,
      );
    }
    if (quality.present) {
      map['quality'] = Variable<double>(quality.value);
    }
    if (diagnosticError.present) {
      map['diagnostic_error'] = Variable<String>(diagnosticError.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CaptureSummariesCompanion(')
          ..write('rowId: $rowId, ')
          ..write('sessionId: $sessionId, ')
          ..write('phase: $phase, ')
          ..write('signalOrigin: $signalOrigin, ')
          ..write('watchSessionId: $watchSessionId, ')
          ..write('coreSessionId: $coreSessionId, ')
          ..write('acceptedSamples: $acceptedSamples, ')
          ..write('totalSamples: $totalSamples, ')
          ..write('coverageSeconds: $coverageSeconds, ')
          ..write('accuracyHigh: $accuracyHigh, ')
          ..write('accuracyMedium: $accuracyMedium, ')
          ..write('accuracyLow: $accuracyLow, ')
          ..write('hsiWindowCount: $hsiWindowCount, ')
          ..write('hsiFocus: $hsiFocus, ')
          ..write('hsiFocusConfidence: $hsiFocusConfidence, ')
          ..write('hsiCapacity: $hsiCapacity, ')
          ..write('hsiCapacityConfidence: $hsiCapacityConfidence, ')
          ..write('hsiArousal: $hsiArousal, ')
          ..write('hsiArousalConfidence: $hsiArousalConfidence, ')
          ..write('hsiStress: $hsiStress, ')
          ..write('hsiStressConfidence: $hsiStressConfidence, ')
          ..write('quality: $quality, ')
          ..write('diagnosticError: $diagnosticError, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $ProfilesTable extends Profiles with TableInfo<$ProfilesTable, Profile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nicknameMeta = const VerificationMeta(
    'nickname',
  );
  @override
  late final GeneratedColumn<String> nickname = GeneratedColumn<String>(
    'nickname',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _setupCompleteMeta = const VerificationMeta(
    'setupComplete',
  );
  @override
  late final GeneratedColumn<bool> setupComplete = GeneratedColumn<bool>(
    'setup_complete',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("setup_complete" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _wearableConsentMeta = const VerificationMeta(
    'wearableConsent',
  );
  @override
  late final GeneratedColumn<bool> wearableConsent = GeneratedColumn<bool>(
    'wearable_consent',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("wearable_consent" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _cloudConsentMeta = const VerificationMeta(
    'cloudConsent',
  );
  @override
  late final GeneratedColumn<bool> cloudConsent = GeneratedColumn<bool>(
    'cloud_consent',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("cloud_consent" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    nickname,
    setupComplete,
    wearableConsent,
    cloudConsent,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<Profile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('nickname')) {
      context.handle(
        _nicknameMeta,
        nickname.isAcceptableOrUnknown(data['nickname']!, _nicknameMeta),
      );
    }
    if (data.containsKey('setup_complete')) {
      context.handle(
        _setupCompleteMeta,
        setupComplete.isAcceptableOrUnknown(
          data['setup_complete']!,
          _setupCompleteMeta,
        ),
      );
    }
    if (data.containsKey('wearable_consent')) {
      context.handle(
        _wearableConsentMeta,
        wearableConsent.isAcceptableOrUnknown(
          data['wearable_consent']!,
          _wearableConsentMeta,
        ),
      );
    }
    if (data.containsKey('cloud_consent')) {
      context.handle(
        _cloudConsentMeta,
        cloudConsent.isAcceptableOrUnknown(
          data['cloud_consent']!,
          _cloudConsentMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Profile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Profile(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      nickname: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nickname'],
      )!,
      setupComplete: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}setup_complete'],
      )!,
      wearableConsent: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}wearable_consent'],
      )!,
      cloudConsent: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}cloud_consent'],
      )!,
    );
  }

  @override
  $ProfilesTable createAlias(String alias) {
    return $ProfilesTable(attachedDatabase, alias);
  }
}

class Profile extends DataClass implements Insertable<Profile> {
  final int id;
  final String nickname;
  final bool setupComplete;
  final bool wearableConsent;
  final bool cloudConsent;
  const Profile({
    required this.id,
    required this.nickname,
    required this.setupComplete,
    required this.wearableConsent,
    required this.cloudConsent,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nickname'] = Variable<String>(nickname);
    map['setup_complete'] = Variable<bool>(setupComplete);
    map['wearable_consent'] = Variable<bool>(wearableConsent);
    map['cloud_consent'] = Variable<bool>(cloudConsent);
    return map;
  }

  ProfilesCompanion toCompanion(bool nullToAbsent) {
    return ProfilesCompanion(
      id: Value(id),
      nickname: Value(nickname),
      setupComplete: Value(setupComplete),
      wearableConsent: Value(wearableConsent),
      cloudConsent: Value(cloudConsent),
    );
  }

  factory Profile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Profile(
      id: serializer.fromJson<int>(json['id']),
      nickname: serializer.fromJson<String>(json['nickname']),
      setupComplete: serializer.fromJson<bool>(json['setupComplete']),
      wearableConsent: serializer.fromJson<bool>(json['wearableConsent']),
      cloudConsent: serializer.fromJson<bool>(json['cloudConsent']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nickname': serializer.toJson<String>(nickname),
      'setupComplete': serializer.toJson<bool>(setupComplete),
      'wearableConsent': serializer.toJson<bool>(wearableConsent),
      'cloudConsent': serializer.toJson<bool>(cloudConsent),
    };
  }

  Profile copyWith({
    int? id,
    String? nickname,
    bool? setupComplete,
    bool? wearableConsent,
    bool? cloudConsent,
  }) => Profile(
    id: id ?? this.id,
    nickname: nickname ?? this.nickname,
    setupComplete: setupComplete ?? this.setupComplete,
    wearableConsent: wearableConsent ?? this.wearableConsent,
    cloudConsent: cloudConsent ?? this.cloudConsent,
  );
  Profile copyWithCompanion(ProfilesCompanion data) {
    return Profile(
      id: data.id.present ? data.id.value : this.id,
      nickname: data.nickname.present ? data.nickname.value : this.nickname,
      setupComplete: data.setupComplete.present
          ? data.setupComplete.value
          : this.setupComplete,
      wearableConsent: data.wearableConsent.present
          ? data.wearableConsent.value
          : this.wearableConsent,
      cloudConsent: data.cloudConsent.present
          ? data.cloudConsent.value
          : this.cloudConsent,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Profile(')
          ..write('id: $id, ')
          ..write('nickname: $nickname, ')
          ..write('setupComplete: $setupComplete, ')
          ..write('wearableConsent: $wearableConsent, ')
          ..write('cloudConsent: $cloudConsent')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, nickname, setupComplete, wearableConsent, cloudConsent);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Profile &&
          other.id == this.id &&
          other.nickname == this.nickname &&
          other.setupComplete == this.setupComplete &&
          other.wearableConsent == this.wearableConsent &&
          other.cloudConsent == this.cloudConsent);
}

class ProfilesCompanion extends UpdateCompanion<Profile> {
  final Value<int> id;
  final Value<String> nickname;
  final Value<bool> setupComplete;
  final Value<bool> wearableConsent;
  final Value<bool> cloudConsent;
  const ProfilesCompanion({
    this.id = const Value.absent(),
    this.nickname = const Value.absent(),
    this.setupComplete = const Value.absent(),
    this.wearableConsent = const Value.absent(),
    this.cloudConsent = const Value.absent(),
  });
  ProfilesCompanion.insert({
    this.id = const Value.absent(),
    this.nickname = const Value.absent(),
    this.setupComplete = const Value.absent(),
    this.wearableConsent = const Value.absent(),
    this.cloudConsent = const Value.absent(),
  });
  static Insertable<Profile> custom({
    Expression<int>? id,
    Expression<String>? nickname,
    Expression<bool>? setupComplete,
    Expression<bool>? wearableConsent,
    Expression<bool>? cloudConsent,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nickname != null) 'nickname': nickname,
      if (setupComplete != null) 'setup_complete': setupComplete,
      if (wearableConsent != null) 'wearable_consent': wearableConsent,
      if (cloudConsent != null) 'cloud_consent': cloudConsent,
    });
  }

  ProfilesCompanion copyWith({
    Value<int>? id,
    Value<String>? nickname,
    Value<bool>? setupComplete,
    Value<bool>? wearableConsent,
    Value<bool>? cloudConsent,
  }) {
    return ProfilesCompanion(
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
      setupComplete: setupComplete ?? this.setupComplete,
      wearableConsent: wearableConsent ?? this.wearableConsent,
      cloudConsent: cloudConsent ?? this.cloudConsent,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nickname.present) {
      map['nickname'] = Variable<String>(nickname.value);
    }
    if (setupComplete.present) {
      map['setup_complete'] = Variable<bool>(setupComplete.value);
    }
    if (wearableConsent.present) {
      map['wearable_consent'] = Variable<bool>(wearableConsent.value);
    }
    if (cloudConsent.present) {
      map['cloud_consent'] = Variable<bool>(cloudConsent.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfilesCompanion(')
          ..write('id: $id, ')
          ..write('nickname: $nickname, ')
          ..write('setupComplete: $setupComplete, ')
          ..write('wearableConsent: $wearableConsent, ')
          ..write('cloudConsent: $cloudConsent')
          ..write(')'))
        .toString();
  }
}

class $PageEventsTable extends PageEvents
    with TableInfo<$PageEventsTable, PageEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PageEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _rowIdMeta = const VerificationMeta('rowId');
  @override
  late final GeneratedColumn<int> rowId = GeneratedColumn<int>(
    'row_id',
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
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sessions (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _sourceIdMeta = const VerificationMeta(
    'sourceId',
  );
  @override
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
    'source_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sources (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _pageMeta = const VerificationMeta('page');
  @override
  late final GeneratedColumn<int> page = GeneratedColumn<int>(
    'page',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _atMeta = const VerificationMeta('at');
  @override
  late final GeneratedColumn<DateTime> at = GeneratedColumn<DateTime>(
    'at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [rowId, sessionId, sourceId, page, at];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'page_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<PageEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('row_id')) {
      context.handle(
        _rowIdMeta,
        rowId.isAcceptableOrUnknown(data['row_id']!, _rowIdMeta),
      );
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('source_id')) {
      context.handle(
        _sourceIdMeta,
        sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceIdMeta);
    }
    if (data.containsKey('page')) {
      context.handle(
        _pageMeta,
        page.isAcceptableOrUnknown(data['page']!, _pageMeta),
      );
    } else if (isInserting) {
      context.missing(_pageMeta);
    }
    if (data.containsKey('at')) {
      context.handle(_atMeta, at.isAcceptableOrUnknown(data['at']!, _atMeta));
    } else if (isInserting) {
      context.missing(_atMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {rowId};
  @override
  PageEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PageEvent(
      rowId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}row_id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      sourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_id'],
      )!,
      page: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}page'],
      )!,
      at: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}at'],
      )!,
    );
  }

  @override
  $PageEventsTable createAlias(String alias) {
    return $PageEventsTable(attachedDatabase, alias);
  }
}

class PageEvent extends DataClass implements Insertable<PageEvent> {
  final int rowId;
  final String sessionId;
  final String sourceId;


  final int page;
  final DateTime at;
  const PageEvent({
    required this.rowId,
    required this.sessionId,
    required this.sourceId,
    required this.page,
    required this.at,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['row_id'] = Variable<int>(rowId);
    map['session_id'] = Variable<String>(sessionId);
    map['source_id'] = Variable<String>(sourceId);
    map['page'] = Variable<int>(page);
    map['at'] = Variable<DateTime>(at);
    return map;
  }

  PageEventsCompanion toCompanion(bool nullToAbsent) {
    return PageEventsCompanion(
      rowId: Value(rowId),
      sessionId: Value(sessionId),
      sourceId: Value(sourceId),
      page: Value(page),
      at: Value(at),
    );
  }

  factory PageEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PageEvent(
      rowId: serializer.fromJson<int>(json['rowId']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      sourceId: serializer.fromJson<String>(json['sourceId']),
      page: serializer.fromJson<int>(json['page']),
      at: serializer.fromJson<DateTime>(json['at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'rowId': serializer.toJson<int>(rowId),
      'sessionId': serializer.toJson<String>(sessionId),
      'sourceId': serializer.toJson<String>(sourceId),
      'page': serializer.toJson<int>(page),
      'at': serializer.toJson<DateTime>(at),
    };
  }

  PageEvent copyWith({
    int? rowId,
    String? sessionId,
    String? sourceId,
    int? page,
    DateTime? at,
  }) => PageEvent(
    rowId: rowId ?? this.rowId,
    sessionId: sessionId ?? this.sessionId,
    sourceId: sourceId ?? this.sourceId,
    page: page ?? this.page,
    at: at ?? this.at,
  );
  PageEvent copyWithCompanion(PageEventsCompanion data) {
    return PageEvent(
      rowId: data.rowId.present ? data.rowId.value : this.rowId,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      page: data.page.present ? data.page.value : this.page,
      at: data.at.present ? data.at.value : this.at,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PageEvent(')
          ..write('rowId: $rowId, ')
          ..write('sessionId: $sessionId, ')
          ..write('sourceId: $sourceId, ')
          ..write('page: $page, ')
          ..write('at: $at')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(rowId, sessionId, sourceId, page, at);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PageEvent &&
          other.rowId == this.rowId &&
          other.sessionId == this.sessionId &&
          other.sourceId == this.sourceId &&
          other.page == this.page &&
          other.at == this.at);
}

class PageEventsCompanion extends UpdateCompanion<PageEvent> {
  final Value<int> rowId;
  final Value<String> sessionId;
  final Value<String> sourceId;
  final Value<int> page;
  final Value<DateTime> at;
  const PageEventsCompanion({
    this.rowId = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.page = const Value.absent(),
    this.at = const Value.absent(),
  });
  PageEventsCompanion.insert({
    this.rowId = const Value.absent(),
    required String sessionId,
    required String sourceId,
    required int page,
    required DateTime at,
  }) : sessionId = Value(sessionId),
       sourceId = Value(sourceId),
       page = Value(page),
       at = Value(at);
  static Insertable<PageEvent> custom({
    Expression<int>? rowId,
    Expression<String>? sessionId,
    Expression<String>? sourceId,
    Expression<int>? page,
    Expression<DateTime>? at,
  }) {
    return RawValuesInsertable({
      if (rowId != null) 'row_id': rowId,
      if (sessionId != null) 'session_id': sessionId,
      if (sourceId != null) 'source_id': sourceId,
      if (page != null) 'page': page,
      if (at != null) 'at': at,
    });
  }

  PageEventsCompanion copyWith({
    Value<int>? rowId,
    Value<String>? sessionId,
    Value<String>? sourceId,
    Value<int>? page,
    Value<DateTime>? at,
  }) {
    return PageEventsCompanion(
      rowId: rowId ?? this.rowId,
      sessionId: sessionId ?? this.sessionId,
      sourceId: sourceId ?? this.sourceId,
      page: page ?? this.page,
      at: at ?? this.at,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (rowId.present) {
      map['row_id'] = Variable<int>(rowId.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (page.present) {
      map['page'] = Variable<int>(page.value);
    }
    if (at.present) {
      map['at'] = Variable<DateTime>(at.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PageEventsCompanion(')
          ..write('rowId: $rowId, ')
          ..write('sessionId: $sessionId, ')
          ..write('sourceId: $sourceId, ')
          ..write('page: $page, ')
          ..write('at: $at')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SubjectsTable subjects = $SubjectsTable(this);
  late final $SourcesTable sources = $SourcesTable(this);
  late final $SessionsTable sessions = $SessionsTable(this);
  late final $HsiWindowsTable hsiWindows = $HsiWindowsTable(this);
  late final $CaptureSummariesTable captureSummaries = $CaptureSummariesTable(
    this,
  );
  late final $ProfilesTable profiles = $ProfilesTable(this);
  late final $PageEventsTable pageEvents = $PageEventsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    subjects,
    sources,
    sessions,
    hsiWindows,
    captureSummaries,
    profiles,
    pageEvents,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'subjects',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('sources', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'subjects',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('sessions', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'sources',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('sessions', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'sessions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('hsi_windows', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'sessions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('capture_summaries', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'sessions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('page_events', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'sources',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('page_events', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$SubjectsTableCreateCompanionBuilder = SubjectsCompanion Function({
  required String id,
  required String name,
  Value<int> accentIndex,
  required DateTime createdAt,
  Value<DateTime?> archivedAt,
  Value<int> rowid,
});
typedef $$SubjectsTableUpdateCompanionBuilder = SubjectsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<int> accentIndex,
  Value<DateTime> createdAt,
  Value<DateTime?> archivedAt,
  Value<int> rowid,
});

final class $$SubjectsTableReferences
    extends BaseReferences<_$AppDatabase, $SubjectsTable, Subject> {
  $$SubjectsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SourcesTable, List<Source>> _sourcesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.sources,
    aliasName: 'subjects__id__sources__subject_id',
  );

  $$SourcesTableProcessedTableManager get sourcesRefs {
    final manager = $$SourcesTableTableManager(
      $_db,
      $_db.sources,
    ).filter((f) => f.subjectId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_sourcesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SessionsTable, List<Session>> _sessionsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.sessions,
    aliasName: 'subjects__id__sessions__subject_id',
  );

  $$SessionsTableProcessedTableManager get sessionsRefs {
    final manager = $$SessionsTableTableManager(
      $_db,
      $_db.sessions,
    ).filter((f) => f.subjectId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_sessionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SubjectsTableFilterComposer
    extends Composer<_$AppDatabase, $SubjectsTable> {
  $$SubjectsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get accentIndex => $composableBuilder(
    column: $table.accentIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> sourcesRefs(
    Expression<bool> Function($$SourcesTableFilterComposer f) f,
  ) {
    final $$SourcesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sources,
      getReferencedColumn: (t) => t.subjectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SourcesTableFilterComposer(
            $db: $db,
            $table: $db.sources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> sessionsRefs(
    Expression<bool> Function($$SessionsTableFilterComposer f) f,
  ) {
    final $$SessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.subjectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableFilterComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SubjectsTableOrderingComposer
    extends Composer<_$AppDatabase, $SubjectsTable> {
  $$SubjectsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get accentIndex => $composableBuilder(
    column: $table.accentIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SubjectsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SubjectsTable> {
  $$SubjectsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get accentIndex => $composableBuilder(
    column: $table.accentIndex,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => column,
  );

  Expression<T> sourcesRefs<T extends Object>(
    Expression<T> Function($$SourcesTableAnnotationComposer a) f,
  ) {
    final $$SourcesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sources,
      getReferencedColumn: (t) => t.subjectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SourcesTableAnnotationComposer(
            $db: $db,
            $table: $db.sources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> sessionsRefs<T extends Object>(
    Expression<T> Function($$SessionsTableAnnotationComposer a) f,
  ) {
    final $$SessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.subjectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SubjectsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SubjectsTable,
          Subject,
          $$SubjectsTableFilterComposer,
          $$SubjectsTableOrderingComposer,
          $$SubjectsTableAnnotationComposer,
          $$SubjectsTableCreateCompanionBuilder,
          $$SubjectsTableUpdateCompanionBuilder,
          (Subject, $$SubjectsTableReferences),
          Subject,
          PrefetchHooks Function({bool sourcesRefs, bool sessionsRefs})
        > {
  $$SubjectsTableTableManager(_$AppDatabase db, $SubjectsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SubjectsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SubjectsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SubjectsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> accentIndex = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> archivedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SubjectsCompanion(
                id: id,
                name: name,
                accentIndex: accentIndex,
                createdAt: createdAt,
                archivedAt: archivedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<int> accentIndex = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> archivedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SubjectsCompanion.insert(
                id: id,
                name: name,
                accentIndex: accentIndex,
                createdAt: createdAt,
                archivedAt: archivedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SubjectsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sourcesRefs = false, sessionsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (sourcesRefs) db.sources,
                if (sessionsRefs) db.sessions,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (sourcesRefs)
                    await $_getPrefetchedData<Subject, $SubjectsTable, Source>(
                      currentTable: table,
                      referencedTable: $$SubjectsTableReferences
                          ._sourcesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$SubjectsTableReferences(db, table, p0).sourcesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.subjectId == item.id),
                      typedResults: items,
                    ),
                  if (sessionsRefs)
                    await $_getPrefetchedData<Subject, $SubjectsTable, Session>(
                      currentTable: table,
                      referencedTable: $$SubjectsTableReferences
                          ._sessionsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$SubjectsTableReferences(db, table, p0).sessionsRefs,
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

typedef $$SubjectsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SubjectsTable,
      Subject,
      $$SubjectsTableFilterComposer,
      $$SubjectsTableOrderingComposer,
      $$SubjectsTableAnnotationComposer,
      $$SubjectsTableCreateCompanionBuilder,
      $$SubjectsTableUpdateCompanionBuilder,
      (Subject, $$SubjectsTableReferences),
      Subject,
      PrefetchHooks Function({bool sourcesRefs, bool sessionsRefs})
    >;
typedef $$SourcesTableCreateCompanionBuilder = SourcesCompanion Function({
  required String id,
  required String subjectId,
  required String title,
  required String filePath,
  Value<int> bytes,
  Value<int?> pageCount,
  Value<int?> lastPage,
  required DateTime addedAt,
  Value<DateTime?> lastOpenedAt,
  Value<int> rowid,
});
typedef $$SourcesTableUpdateCompanionBuilder = SourcesCompanion Function({
  Value<String> id,
  Value<String> subjectId,
  Value<String> title,
  Value<String> filePath,
  Value<int> bytes,
  Value<int?> pageCount,
  Value<int?> lastPage,
  Value<DateTime> addedAt,
  Value<DateTime?> lastOpenedAt,
  Value<int> rowid,
});

final class $$SourcesTableReferences
    extends BaseReferences<_$AppDatabase, $SourcesTable, Source> {
  $$SourcesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SubjectsTable _subjectIdTable(_$AppDatabase db) =>
      db.subjects.createAlias('sources__subject_id__subjects__id');

  $$SubjectsTableProcessedTableManager get subjectId {
    final $_column = $_itemColumn<String>('subject_id')!;

    final manager = $$SubjectsTableTableManager(
      $_db,
      $_db.subjects,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_subjectIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$SessionsTable, List<Session>> _sessionsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.sessions,
    aliasName: 'sources__id__sessions__source_id',
  );

  $$SessionsTableProcessedTableManager get sessionsRefs {
    final manager = $$SessionsTableTableManager(
      $_db,
      $_db.sessions,
    ).filter((f) => f.sourceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_sessionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PageEventsTable, List<PageEvent>>
  _pageEventsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.pageEvents,
    aliasName: 'sources__id__page_events__source_id',
  );

  $$PageEventsTableProcessedTableManager get pageEventsRefs {
    final manager = $$PageEventsTableTableManager(
      $_db,
      $_db.pageEvents,
    ).filter((f) => f.sourceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_pageEventsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SourcesTableFilterComposer
    extends Composer<_$AppDatabase, $SourcesTable> {
  $$SourcesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bytes => $composableBuilder(
    column: $table.bytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pageCount => $composableBuilder(
    column: $table.pageCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastPage => $composableBuilder(
    column: $table.lastPage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastOpenedAt => $composableBuilder(
    column: $table.lastOpenedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$SubjectsTableFilterComposer get subjectId {
    final $$SubjectsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.subjectId,
      referencedTable: $db.subjects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubjectsTableFilterComposer(
            $db: $db,
            $table: $db.subjects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> sessionsRefs(
    Expression<bool> Function($$SessionsTableFilterComposer f) f,
  ) {
    final $$SessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.sourceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableFilterComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> pageEventsRefs(
    Expression<bool> Function($$PageEventsTableFilterComposer f) f,
  ) {
    final $$PageEventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.pageEvents,
      getReferencedColumn: (t) => t.sourceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PageEventsTableFilterComposer(
            $db: $db,
            $table: $db.pageEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SourcesTableOrderingComposer
    extends Composer<_$AppDatabase, $SourcesTable> {
  $$SourcesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bytes => $composableBuilder(
    column: $table.bytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pageCount => $composableBuilder(
    column: $table.pageCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastPage => $composableBuilder(
    column: $table.lastPage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastOpenedAt => $composableBuilder(
    column: $table.lastOpenedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$SubjectsTableOrderingComposer get subjectId {
    final $$SubjectsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.subjectId,
      referencedTable: $db.subjects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubjectsTableOrderingComposer(
            $db: $db,
            $table: $db.subjects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SourcesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SourcesTable> {
  $$SourcesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<int> get bytes =>
      $composableBuilder(column: $table.bytes, builder: (column) => column);

  GeneratedColumn<int> get pageCount =>
      $composableBuilder(column: $table.pageCount, builder: (column) => column);

  GeneratedColumn<int> get lastPage =>
      $composableBuilder(column: $table.lastPage, builder: (column) => column);

  GeneratedColumn<DateTime> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastOpenedAt => $composableBuilder(
    column: $table.lastOpenedAt,
    builder: (column) => column,
  );

  $$SubjectsTableAnnotationComposer get subjectId {
    final $$SubjectsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.subjectId,
      referencedTable: $db.subjects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubjectsTableAnnotationComposer(
            $db: $db,
            $table: $db.subjects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> sessionsRefs<T extends Object>(
    Expression<T> Function($$SessionsTableAnnotationComposer a) f,
  ) {
    final $$SessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.sourceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> pageEventsRefs<T extends Object>(
    Expression<T> Function($$PageEventsTableAnnotationComposer a) f,
  ) {
    final $$PageEventsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.pageEvents,
      getReferencedColumn: (t) => t.sourceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PageEventsTableAnnotationComposer(
            $db: $db,
            $table: $db.pageEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SourcesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SourcesTable,
          Source,
          $$SourcesTableFilterComposer,
          $$SourcesTableOrderingComposer,
          $$SourcesTableAnnotationComposer,
          $$SourcesTableCreateCompanionBuilder,
          $$SourcesTableUpdateCompanionBuilder,
          (Source, $$SourcesTableReferences),
          Source,
          PrefetchHooks Function({
            bool subjectId,
            bool sessionsRefs,
            bool pageEventsRefs,
          })
        > {
  $$SourcesTableTableManager(_$AppDatabase db, $SourcesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SourcesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SourcesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SourcesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> subjectId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> filePath = const Value.absent(),
                Value<int> bytes = const Value.absent(),
                Value<int?> pageCount = const Value.absent(),
                Value<int?> lastPage = const Value.absent(),
                Value<DateTime> addedAt = const Value.absent(),
                Value<DateTime?> lastOpenedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SourcesCompanion(
                id: id,
                subjectId: subjectId,
                title: title,
                filePath: filePath,
                bytes: bytes,
                pageCount: pageCount,
                lastPage: lastPage,
                addedAt: addedAt,
                lastOpenedAt: lastOpenedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String subjectId,
                required String title,
                required String filePath,
                Value<int> bytes = const Value.absent(),
                Value<int?> pageCount = const Value.absent(),
                Value<int?> lastPage = const Value.absent(),
                required DateTime addedAt,
                Value<DateTime?> lastOpenedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SourcesCompanion.insert(
                id: id,
                subjectId: subjectId,
                title: title,
                filePath: filePath,
                bytes: bytes,
                pageCount: pageCount,
                lastPage: lastPage,
                addedAt: addedAt,
                lastOpenedAt: lastOpenedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SourcesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                subjectId = false,
                sessionsRefs = false,
                pageEventsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (sessionsRefs) db.sessions,
                    if (pageEventsRefs) db.pageEvents,
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
                        if (subjectId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.subjectId,
                            referencedTable: $$SourcesTableReferences
                                ._subjectIdTable(db),
                            referencedColumn: $$SourcesTableReferences
                                ._subjectIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (sessionsRefs)
                        await $_getPrefetchedData<
                          Source,
                          $SourcesTable,
                          Session
                        >(
                          currentTable: table,
                          referencedTable: $$SourcesTableReferences
                              ._sessionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SourcesTableReferences(
                                db,
                                table,
                                p0,
                              ).sessionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sourceId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (pageEventsRefs)
                        await $_getPrefetchedData<
                          Source,
                          $SourcesTable,
                          PageEvent
                        >(
                          currentTable: table,
                          referencedTable: $$SourcesTableReferences
                              ._pageEventsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SourcesTableReferences(
                                db,
                                table,
                                p0,
                              ).pageEventsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sourceId == item.id,
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

typedef $$SourcesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SourcesTable,
      Source,
      $$SourcesTableFilterComposer,
      $$SourcesTableOrderingComposer,
      $$SourcesTableAnnotationComposer,
      $$SourcesTableCreateCompanionBuilder,
      $$SourcesTableUpdateCompanionBuilder,
      (Source, $$SourcesTableReferences),
      Source,
      PrefetchHooks Function({
        bool subjectId,
        bool sessionsRefs,
        bool pageEventsRefs,
      })
    >;
typedef $$SessionsTableCreateCompanionBuilder = SessionsCompanion Function({
  required String id,
  required String subjectId,
  Value<String?> sourceId,
  required DateTime startedAt,
  Value<DateTime?> canonicalStartedAt,
  Value<DateTime?> plannedEndAt,
  Value<DateTime?> endedAt,
  Value<int> plannedMinutes,
  Value<int> focusedMinutes,
  Value<int> pausedSeconds,
  Value<DateTime?> pauseStartedAt,
  required SessionStatus status,
  required SignalOrigin signalOrigin,
  Value<double?> hsiFocus,
  Value<double?> hsiFocusConfidence,
  Value<double?> hsiCapacity,
  Value<double?> hsiCapacityConfidence,
  Value<double?> hsiArousal,
  Value<double?> hsiArousalConfidence,
  Value<double?> hsiStress,
  Value<double?> hsiStressConfidence,
  Value<double?> hsiQuality,
  Value<String?> synheartSessionId,
  Value<String?> watchSessionId,
  Value<int> acceptedSamples,
  Value<int> totalSamples,
  Value<int> coverageSeconds,
  Value<int> accuracyHigh,
  Value<int> accuracyMedium,
  Value<int> accuracyLow,
  Value<int> hsiWindowCount,
  Value<SyncState> syncState,
  Value<int> uploadedCount,
  Value<DateTime?> uploadAttemptedAt,
  Value<String?> syncError,
  Value<int> rowid,
});
typedef $$SessionsTableUpdateCompanionBuilder = SessionsCompanion Function({
  Value<String> id,
  Value<String> subjectId,
  Value<String?> sourceId,
  Value<DateTime> startedAt,
  Value<DateTime?> canonicalStartedAt,
  Value<DateTime?> plannedEndAt,
  Value<DateTime?> endedAt,
  Value<int> plannedMinutes,
  Value<int> focusedMinutes,
  Value<int> pausedSeconds,
  Value<DateTime?> pauseStartedAt,
  Value<SessionStatus> status,
  Value<SignalOrigin> signalOrigin,
  Value<double?> hsiFocus,
  Value<double?> hsiFocusConfidence,
  Value<double?> hsiCapacity,
  Value<double?> hsiCapacityConfidence,
  Value<double?> hsiArousal,
  Value<double?> hsiArousalConfidence,
  Value<double?> hsiStress,
  Value<double?> hsiStressConfidence,
  Value<double?> hsiQuality,
  Value<String?> synheartSessionId,
  Value<String?> watchSessionId,
  Value<int> acceptedSamples,
  Value<int> totalSamples,
  Value<int> coverageSeconds,
  Value<int> accuracyHigh,
  Value<int> accuracyMedium,
  Value<int> accuracyLow,
  Value<int> hsiWindowCount,
  Value<SyncState> syncState,
  Value<int> uploadedCount,
  Value<DateTime?> uploadAttemptedAt,
  Value<String?> syncError,
  Value<int> rowid,
});

final class $$SessionsTableReferences
    extends BaseReferences<_$AppDatabase, $SessionsTable, Session> {
  $$SessionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SubjectsTable _subjectIdTable(_$AppDatabase db) =>
      db.subjects.createAlias('sessions__subject_id__subjects__id');

  $$SubjectsTableProcessedTableManager get subjectId {
    final $_column = $_itemColumn<String>('subject_id')!;

    final manager = $$SubjectsTableTableManager(
      $_db,
      $_db.subjects,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_subjectIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $SourcesTable _sourceIdTable(_$AppDatabase db) =>
      db.sources.createAlias('sessions__source_id__sources__id');

  $$SourcesTableProcessedTableManager? get sourceId {
    final $_column = $_itemColumn<String>('source_id');
    if ($_column == null) return null;
    final manager = $$SourcesTableTableManager(
      $_db,
      $_db.sources,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sourceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$HsiWindowsTable, List<HsiWindow>>
  _hsiWindowsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.hsiWindows,
    aliasName: 'sessions__id__hsi_windows__session_id',
  );

  $$HsiWindowsTableProcessedTableManager get hsiWindowsRefs {
    final manager = $$HsiWindowsTableTableManager(
      $_db,
      $_db.hsiWindows,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_hsiWindowsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CaptureSummariesTable, List<CaptureSummary>>
  _captureSummariesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.captureSummaries,
    aliasName: 'sessions__id__capture_summaries__session_id',
  );

  $$CaptureSummariesTableProcessedTableManager get captureSummariesRefs {
    final manager = $$CaptureSummariesTableTableManager(
      $_db,
      $_db.captureSummaries,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _captureSummariesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PageEventsTable, List<PageEvent>>
  _pageEventsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.pageEvents,
    aliasName: 'sessions__id__page_events__session_id',
  );

  $$PageEventsTableProcessedTableManager get pageEventsRefs {
    final manager = $$PageEventsTableTableManager(
      $_db,
      $_db.pageEvents,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_pageEventsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SessionsTableFilterComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get canonicalStartedAt => $composableBuilder(
    column: $table.canonicalStartedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get plannedEndAt => $composableBuilder(
    column: $table.plannedEndAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get plannedMinutes => $composableBuilder(
    column: $table.plannedMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get focusedMinutes => $composableBuilder(
    column: $table.focusedMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pausedSeconds => $composableBuilder(
    column: $table.pausedSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get pauseStartedAt => $composableBuilder(
    column: $table.pauseStartedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SessionStatus, SessionStatus, int>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<SignalOrigin, SignalOrigin, int>
  get signalOrigin => $composableBuilder(
    column: $table.signalOrigin,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<double> get hsiFocus => $composableBuilder(
    column: $table.hsiFocus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get hsiFocusConfidence => $composableBuilder(
    column: $table.hsiFocusConfidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get hsiCapacity => $composableBuilder(
    column: $table.hsiCapacity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get hsiCapacityConfidence => $composableBuilder(
    column: $table.hsiCapacityConfidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get hsiArousal => $composableBuilder(
    column: $table.hsiArousal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get hsiArousalConfidence => $composableBuilder(
    column: $table.hsiArousalConfidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get hsiStress => $composableBuilder(
    column: $table.hsiStress,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get hsiStressConfidence => $composableBuilder(
    column: $table.hsiStressConfidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get hsiQuality => $composableBuilder(
    column: $table.hsiQuality,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get synheartSessionId => $composableBuilder(
    column: $table.synheartSessionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get watchSessionId => $composableBuilder(
    column: $table.watchSessionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get acceptedSamples => $composableBuilder(
    column: $table.acceptedSamples,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalSamples => $composableBuilder(
    column: $table.totalSamples,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get coverageSeconds => $composableBuilder(
    column: $table.coverageSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get accuracyHigh => $composableBuilder(
    column: $table.accuracyHigh,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get accuracyMedium => $composableBuilder(
    column: $table.accuracyMedium,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get accuracyLow => $composableBuilder(
    column: $table.accuracyLow,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hsiWindowCount => $composableBuilder(
    column: $table.hsiWindowCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SyncState, SyncState, int> get syncState =>
      $composableBuilder(
        column: $table.syncState,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get uploadedCount => $composableBuilder(
    column: $table.uploadedCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get uploadAttemptedAt => $composableBuilder(
    column: $table.uploadAttemptedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncError => $composableBuilder(
    column: $table.syncError,
    builder: (column) => ColumnFilters(column),
  );

  $$SubjectsTableFilterComposer get subjectId {
    final $$SubjectsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.subjectId,
      referencedTable: $db.subjects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubjectsTableFilterComposer(
            $db: $db,
            $table: $db.subjects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SourcesTableFilterComposer get sourceId {
    final $$SourcesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.sources,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SourcesTableFilterComposer(
            $db: $db,
            $table: $db.sources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> hsiWindowsRefs(
    Expression<bool> Function($$HsiWindowsTableFilterComposer f) f,
  ) {
    final $$HsiWindowsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.hsiWindows,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HsiWindowsTableFilterComposer(
            $db: $db,
            $table: $db.hsiWindows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> captureSummariesRefs(
    Expression<bool> Function($$CaptureSummariesTableFilterComposer f) f,
  ) {
    final $$CaptureSummariesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.captureSummaries,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CaptureSummariesTableFilterComposer(
            $db: $db,
            $table: $db.captureSummaries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> pageEventsRefs(
    Expression<bool> Function($$PageEventsTableFilterComposer f) f,
  ) {
    final $$PageEventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.pageEvents,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PageEventsTableFilterComposer(
            $db: $db,
            $table: $db.pageEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get canonicalStartedAt => $composableBuilder(
    column: $table.canonicalStartedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get plannedEndAt => $composableBuilder(
    column: $table.plannedEndAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get plannedMinutes => $composableBuilder(
    column: $table.plannedMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get focusedMinutes => $composableBuilder(
    column: $table.focusedMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pausedSeconds => $composableBuilder(
    column: $table.pausedSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get pauseStartedAt => $composableBuilder(
    column: $table.pauseStartedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get signalOrigin => $composableBuilder(
    column: $table.signalOrigin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get hsiFocus => $composableBuilder(
    column: $table.hsiFocus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get hsiFocusConfidence => $composableBuilder(
    column: $table.hsiFocusConfidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get hsiCapacity => $composableBuilder(
    column: $table.hsiCapacity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get hsiCapacityConfidence => $composableBuilder(
    column: $table.hsiCapacityConfidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get hsiArousal => $composableBuilder(
    column: $table.hsiArousal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get hsiArousalConfidence => $composableBuilder(
    column: $table.hsiArousalConfidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get hsiStress => $composableBuilder(
    column: $table.hsiStress,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get hsiStressConfidence => $composableBuilder(
    column: $table.hsiStressConfidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get hsiQuality => $composableBuilder(
    column: $table.hsiQuality,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get synheartSessionId => $composableBuilder(
    column: $table.synheartSessionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get watchSessionId => $composableBuilder(
    column: $table.watchSessionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get acceptedSamples => $composableBuilder(
    column: $table.acceptedSamples,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalSamples => $composableBuilder(
    column: $table.totalSamples,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get coverageSeconds => $composableBuilder(
    column: $table.coverageSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get accuracyHigh => $composableBuilder(
    column: $table.accuracyHigh,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get accuracyMedium => $composableBuilder(
    column: $table.accuracyMedium,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get accuracyLow => $composableBuilder(
    column: $table.accuracyLow,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hsiWindowCount => $composableBuilder(
    column: $table.hsiWindowCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get uploadedCount => $composableBuilder(
    column: $table.uploadedCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get uploadAttemptedAt => $composableBuilder(
    column: $table.uploadAttemptedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncError => $composableBuilder(
    column: $table.syncError,
    builder: (column) => ColumnOrderings(column),
  );

  $$SubjectsTableOrderingComposer get subjectId {
    final $$SubjectsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.subjectId,
      referencedTable: $db.subjects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubjectsTableOrderingComposer(
            $db: $db,
            $table: $db.subjects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SourcesTableOrderingComposer get sourceId {
    final $$SourcesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.sources,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SourcesTableOrderingComposer(
            $db: $db,
            $table: $db.sources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get canonicalStartedAt => $composableBuilder(
    column: $table.canonicalStartedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get plannedEndAt => $composableBuilder(
    column: $table.plannedEndAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<int> get plannedMinutes => $composableBuilder(
    column: $table.plannedMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get focusedMinutes => $composableBuilder(
    column: $table.focusedMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get pausedSeconds => $composableBuilder(
    column: $table.pausedSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get pauseStartedAt => $composableBuilder(
    column: $table.pauseStartedAt,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<SessionStatus, int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SignalOrigin, int> get signalOrigin =>
      $composableBuilder(
        column: $table.signalOrigin,
        builder: (column) => column,
      );

  GeneratedColumn<double> get hsiFocus =>
      $composableBuilder(column: $table.hsiFocus, builder: (column) => column);

  GeneratedColumn<double> get hsiFocusConfidence => $composableBuilder(
    column: $table.hsiFocusConfidence,
    builder: (column) => column,
  );

  GeneratedColumn<double> get hsiCapacity => $composableBuilder(
    column: $table.hsiCapacity,
    builder: (column) => column,
  );

  GeneratedColumn<double> get hsiCapacityConfidence => $composableBuilder(
    column: $table.hsiCapacityConfidence,
    builder: (column) => column,
  );

  GeneratedColumn<double> get hsiArousal => $composableBuilder(
    column: $table.hsiArousal,
    builder: (column) => column,
  );

  GeneratedColumn<double> get hsiArousalConfidence => $composableBuilder(
    column: $table.hsiArousalConfidence,
    builder: (column) => column,
  );

  GeneratedColumn<double> get hsiStress =>
      $composableBuilder(column: $table.hsiStress, builder: (column) => column);

  GeneratedColumn<double> get hsiStressConfidence => $composableBuilder(
    column: $table.hsiStressConfidence,
    builder: (column) => column,
  );

  GeneratedColumn<double> get hsiQuality => $composableBuilder(
    column: $table.hsiQuality,
    builder: (column) => column,
  );

  GeneratedColumn<String> get synheartSessionId => $composableBuilder(
    column: $table.synheartSessionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get watchSessionId => $composableBuilder(
    column: $table.watchSessionId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get acceptedSamples => $composableBuilder(
    column: $table.acceptedSamples,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalSamples => $composableBuilder(
    column: $table.totalSamples,
    builder: (column) => column,
  );

  GeneratedColumn<int> get coverageSeconds => $composableBuilder(
    column: $table.coverageSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get accuracyHigh => $composableBuilder(
    column: $table.accuracyHigh,
    builder: (column) => column,
  );

  GeneratedColumn<int> get accuracyMedium => $composableBuilder(
    column: $table.accuracyMedium,
    builder: (column) => column,
  );

  GeneratedColumn<int> get accuracyLow => $composableBuilder(
    column: $table.accuracyLow,
    builder: (column) => column,
  );

  GeneratedColumn<int> get hsiWindowCount => $composableBuilder(
    column: $table.hsiWindowCount,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<SyncState, int> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<int> get uploadedCount => $composableBuilder(
    column: $table.uploadedCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get uploadAttemptedAt => $composableBuilder(
    column: $table.uploadAttemptedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncError =>
      $composableBuilder(column: $table.syncError, builder: (column) => column);

  $$SubjectsTableAnnotationComposer get subjectId {
    final $$SubjectsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.subjectId,
      referencedTable: $db.subjects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubjectsTableAnnotationComposer(
            $db: $db,
            $table: $db.subjects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SourcesTableAnnotationComposer get sourceId {
    final $$SourcesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.sources,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SourcesTableAnnotationComposer(
            $db: $db,
            $table: $db.sources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> hsiWindowsRefs<T extends Object>(
    Expression<T> Function($$HsiWindowsTableAnnotationComposer a) f,
  ) {
    final $$HsiWindowsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.hsiWindows,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HsiWindowsTableAnnotationComposer(
            $db: $db,
            $table: $db.hsiWindows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> captureSummariesRefs<T extends Object>(
    Expression<T> Function($$CaptureSummariesTableAnnotationComposer a) f,
  ) {
    final $$CaptureSummariesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.captureSummaries,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CaptureSummariesTableAnnotationComposer(
            $db: $db,
            $table: $db.captureSummaries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> pageEventsRefs<T extends Object>(
    Expression<T> Function($$PageEventsTableAnnotationComposer a) f,
  ) {
    final $$PageEventsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.pageEvents,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PageEventsTableAnnotationComposer(
            $db: $db,
            $table: $db.pageEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SessionsTable,
          Session,
          $$SessionsTableFilterComposer,
          $$SessionsTableOrderingComposer,
          $$SessionsTableAnnotationComposer,
          $$SessionsTableCreateCompanionBuilder,
          $$SessionsTableUpdateCompanionBuilder,
          (Session, $$SessionsTableReferences),
          Session,
          PrefetchHooks Function({
            bool subjectId,
            bool sourceId,
            bool hsiWindowsRefs,
            bool captureSummariesRefs,
            bool pageEventsRefs,
          })
        > {
  $$SessionsTableTableManager(_$AppDatabase db, $SessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> subjectId = const Value.absent(),
                Value<String?> sourceId = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> canonicalStartedAt = const Value.absent(),
                Value<DateTime?> plannedEndAt = const Value.absent(),
                Value<DateTime?> endedAt = const Value.absent(),
                Value<int> plannedMinutes = const Value.absent(),
                Value<int> focusedMinutes = const Value.absent(),
                Value<int> pausedSeconds = const Value.absent(),
                Value<DateTime?> pauseStartedAt = const Value.absent(),
                Value<SessionStatus> status = const Value.absent(),
                Value<SignalOrigin> signalOrigin = const Value.absent(),
                Value<double?> hsiFocus = const Value.absent(),
                Value<double?> hsiFocusConfidence = const Value.absent(),
                Value<double?> hsiCapacity = const Value.absent(),
                Value<double?> hsiCapacityConfidence = const Value.absent(),
                Value<double?> hsiArousal = const Value.absent(),
                Value<double?> hsiArousalConfidence = const Value.absent(),
                Value<double?> hsiStress = const Value.absent(),
                Value<double?> hsiStressConfidence = const Value.absent(),
                Value<double?> hsiQuality = const Value.absent(),
                Value<String?> synheartSessionId = const Value.absent(),
                Value<String?> watchSessionId = const Value.absent(),
                Value<int> acceptedSamples = const Value.absent(),
                Value<int> totalSamples = const Value.absent(),
                Value<int> coverageSeconds = const Value.absent(),
                Value<int> accuracyHigh = const Value.absent(),
                Value<int> accuracyMedium = const Value.absent(),
                Value<int> accuracyLow = const Value.absent(),
                Value<int> hsiWindowCount = const Value.absent(),
                Value<SyncState> syncState = const Value.absent(),
                Value<int> uploadedCount = const Value.absent(),
                Value<DateTime?> uploadAttemptedAt = const Value.absent(),
                Value<String?> syncError = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionsCompanion(
                id: id,
                subjectId: subjectId,
                sourceId: sourceId,
                startedAt: startedAt,
                canonicalStartedAt: canonicalStartedAt,
                plannedEndAt: plannedEndAt,
                endedAt: endedAt,
                plannedMinutes: plannedMinutes,
                focusedMinutes: focusedMinutes,
                pausedSeconds: pausedSeconds,
                pauseStartedAt: pauseStartedAt,
                status: status,
                signalOrigin: signalOrigin,
                hsiFocus: hsiFocus,
                hsiFocusConfidence: hsiFocusConfidence,
                hsiCapacity: hsiCapacity,
                hsiCapacityConfidence: hsiCapacityConfidence,
                hsiArousal: hsiArousal,
                hsiArousalConfidence: hsiArousalConfidence,
                hsiStress: hsiStress,
                hsiStressConfidence: hsiStressConfidence,
                hsiQuality: hsiQuality,
                synheartSessionId: synheartSessionId,
                watchSessionId: watchSessionId,
                acceptedSamples: acceptedSamples,
                totalSamples: totalSamples,
                coverageSeconds: coverageSeconds,
                accuracyHigh: accuracyHigh,
                accuracyMedium: accuracyMedium,
                accuracyLow: accuracyLow,
                hsiWindowCount: hsiWindowCount,
                syncState: syncState,
                uploadedCount: uploadedCount,
                uploadAttemptedAt: uploadAttemptedAt,
                syncError: syncError,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String subjectId,
                Value<String?> sourceId = const Value.absent(),
                required DateTime startedAt,
                Value<DateTime?> canonicalStartedAt = const Value.absent(),
                Value<DateTime?> plannedEndAt = const Value.absent(),
                Value<DateTime?> endedAt = const Value.absent(),
                Value<int> plannedMinutes = const Value.absent(),
                Value<int> focusedMinutes = const Value.absent(),
                Value<int> pausedSeconds = const Value.absent(),
                Value<DateTime?> pauseStartedAt = const Value.absent(),
                required SessionStatus status,
                required SignalOrigin signalOrigin,
                Value<double?> hsiFocus = const Value.absent(),
                Value<double?> hsiFocusConfidence = const Value.absent(),
                Value<double?> hsiCapacity = const Value.absent(),
                Value<double?> hsiCapacityConfidence = const Value.absent(),
                Value<double?> hsiArousal = const Value.absent(),
                Value<double?> hsiArousalConfidence = const Value.absent(),
                Value<double?> hsiStress = const Value.absent(),
                Value<double?> hsiStressConfidence = const Value.absent(),
                Value<double?> hsiQuality = const Value.absent(),
                Value<String?> synheartSessionId = const Value.absent(),
                Value<String?> watchSessionId = const Value.absent(),
                Value<int> acceptedSamples = const Value.absent(),
                Value<int> totalSamples = const Value.absent(),
                Value<int> coverageSeconds = const Value.absent(),
                Value<int> accuracyHigh = const Value.absent(),
                Value<int> accuracyMedium = const Value.absent(),
                Value<int> accuracyLow = const Value.absent(),
                Value<int> hsiWindowCount = const Value.absent(),
                Value<SyncState> syncState = const Value.absent(),
                Value<int> uploadedCount = const Value.absent(),
                Value<DateTime?> uploadAttemptedAt = const Value.absent(),
                Value<String?> syncError = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionsCompanion.insert(
                id: id,
                subjectId: subjectId,
                sourceId: sourceId,
                startedAt: startedAt,
                canonicalStartedAt: canonicalStartedAt,
                plannedEndAt: plannedEndAt,
                endedAt: endedAt,
                plannedMinutes: plannedMinutes,
                focusedMinutes: focusedMinutes,
                pausedSeconds: pausedSeconds,
                pauseStartedAt: pauseStartedAt,
                status: status,
                signalOrigin: signalOrigin,
                hsiFocus: hsiFocus,
                hsiFocusConfidence: hsiFocusConfidence,
                hsiCapacity: hsiCapacity,
                hsiCapacityConfidence: hsiCapacityConfidence,
                hsiArousal: hsiArousal,
                hsiArousalConfidence: hsiArousalConfidence,
                hsiStress: hsiStress,
                hsiStressConfidence: hsiStressConfidence,
                hsiQuality: hsiQuality,
                synheartSessionId: synheartSessionId,
                watchSessionId: watchSessionId,
                acceptedSamples: acceptedSamples,
                totalSamples: totalSamples,
                coverageSeconds: coverageSeconds,
                accuracyHigh: accuracyHigh,
                accuracyMedium: accuracyMedium,
                accuracyLow: accuracyLow,
                hsiWindowCount: hsiWindowCount,
                syncState: syncState,
                uploadedCount: uploadedCount,
                uploadAttemptedAt: uploadAttemptedAt,
                syncError: syncError,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SessionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                subjectId = false,
                sourceId = false,
                hsiWindowsRefs = false,
                captureSummariesRefs = false,
                pageEventsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (hsiWindowsRefs) db.hsiWindows,
                    if (captureSummariesRefs) db.captureSummaries,
                    if (pageEventsRefs) db.pageEvents,
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
                        if (subjectId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.subjectId,
                            referencedTable: $$SessionsTableReferences
                                ._subjectIdTable(db),
                            referencedColumn: $$SessionsTableReferences
                                ._subjectIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (sourceId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.sourceId,
                            referencedTable: $$SessionsTableReferences
                                ._sourceIdTable(db),
                            referencedColumn: $$SessionsTableReferences
                                ._sourceIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (hsiWindowsRefs)
                        await $_getPrefetchedData<
                          Session,
                          $SessionsTable,
                          HsiWindow
                        >(
                          currentTable: table,
                          referencedTable: $$SessionsTableReferences
                              ._hsiWindowsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).hsiWindowsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sessionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (captureSummariesRefs)
                        await $_getPrefetchedData<
                          Session,
                          $SessionsTable,
                          CaptureSummary
                        >(
                          currentTable: table,
                          referencedTable: $$SessionsTableReferences
                              ._captureSummariesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).captureSummariesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sessionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (pageEventsRefs)
                        await $_getPrefetchedData<
                          Session,
                          $SessionsTable,
                          PageEvent
                        >(
                          currentTable: table,
                          referencedTable: $$SessionsTableReferences
                              ._pageEventsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).pageEventsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sessionId == item.id,
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

typedef $$SessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SessionsTable,
      Session,
      $$SessionsTableFilterComposer,
      $$SessionsTableOrderingComposer,
      $$SessionsTableAnnotationComposer,
      $$SessionsTableCreateCompanionBuilder,
      $$SessionsTableUpdateCompanionBuilder,
      (Session, $$SessionsTableReferences),
      Session,
      PrefetchHooks Function({
        bool subjectId,
        bool sourceId,
        bool hsiWindowsRefs,
        bool captureSummariesRefs,
        bool pageEventsRefs,
      })
    >;
typedef $$HsiWindowsTableCreateCompanionBuilder = HsiWindowsCompanion Function({
  Value<int> rowId,
  required String sessionId,
  required DateTime at,
  Value<SignalOrigin> signalOrigin,
  Value<String?> hsiVersion,
  Value<double?> focus,
  Value<double?> focusConfidence,
  Value<double?> capacity,
  Value<double?> capacityConfidence,
  Value<double?> arousal,
  Value<double?> arousalConfidence,
  Value<double?> stress,
  Value<double?> stressConfidence,
  Value<double?> quality,
});
typedef $$HsiWindowsTableUpdateCompanionBuilder = HsiWindowsCompanion Function({
  Value<int> rowId,
  Value<String> sessionId,
  Value<DateTime> at,
  Value<SignalOrigin> signalOrigin,
  Value<String?> hsiVersion,
  Value<double?> focus,
  Value<double?> focusConfidence,
  Value<double?> capacity,
  Value<double?> capacityConfidence,
  Value<double?> arousal,
  Value<double?> arousalConfidence,
  Value<double?> stress,
  Value<double?> stressConfidence,
  Value<double?> quality,
});

final class $$HsiWindowsTableReferences
    extends BaseReferences<_$AppDatabase, $HsiWindowsTable, HsiWindow> {
  $$HsiWindowsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SessionsTable _sessionIdTable(_$AppDatabase db) =>
      db.sessions.createAlias('hsi_windows__session_id__sessions__id');

  $$SessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<String>('session_id')!;

    final manager = $$SessionsTableTableManager(
      $_db,
      $_db.sessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$HsiWindowsTableFilterComposer
    extends Composer<_$AppDatabase, $HsiWindowsTable> {
  $$HsiWindowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get rowId => $composableBuilder(
    column: $table.rowId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SignalOrigin, SignalOrigin, int>
  get signalOrigin => $composableBuilder(
    column: $table.signalOrigin,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get hsiVersion => $composableBuilder(
    column: $table.hsiVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get focus => $composableBuilder(
    column: $table.focus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get focusConfidence => $composableBuilder(
    column: $table.focusConfidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get capacity => $composableBuilder(
    column: $table.capacity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get capacityConfidence => $composableBuilder(
    column: $table.capacityConfidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get arousal => $composableBuilder(
    column: $table.arousal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get arousalConfidence => $composableBuilder(
    column: $table.arousalConfidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get stress => $composableBuilder(
    column: $table.stress,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get stressConfidence => $composableBuilder(
    column: $table.stressConfidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quality => $composableBuilder(
    column: $table.quality,
    builder: (column) => ColumnFilters(column),
  );

  $$SessionsTableFilterComposer get sessionId {
    final $$SessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableFilterComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HsiWindowsTableOrderingComposer
    extends Composer<_$AppDatabase, $HsiWindowsTable> {
  $$HsiWindowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get rowId => $composableBuilder(
    column: $table.rowId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get signalOrigin => $composableBuilder(
    column: $table.signalOrigin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hsiVersion => $composableBuilder(
    column: $table.hsiVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get focus => $composableBuilder(
    column: $table.focus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get focusConfidence => $composableBuilder(
    column: $table.focusConfidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get capacity => $composableBuilder(
    column: $table.capacity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get capacityConfidence => $composableBuilder(
    column: $table.capacityConfidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get arousal => $composableBuilder(
    column: $table.arousal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get arousalConfidence => $composableBuilder(
    column: $table.arousalConfidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get stress => $composableBuilder(
    column: $table.stress,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get stressConfidence => $composableBuilder(
    column: $table.stressConfidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quality => $composableBuilder(
    column: $table.quality,
    builder: (column) => ColumnOrderings(column),
  );

  $$SessionsTableOrderingComposer get sessionId {
    final $$SessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableOrderingComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HsiWindowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $HsiWindowsTable> {
  $$HsiWindowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get rowId =>
      $composableBuilder(column: $table.rowId, builder: (column) => column);

  GeneratedColumn<DateTime> get at =>
      $composableBuilder(column: $table.at, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SignalOrigin, int> get signalOrigin =>
      $composableBuilder(
        column: $table.signalOrigin,
        builder: (column) => column,
      );

  GeneratedColumn<String> get hsiVersion => $composableBuilder(
    column: $table.hsiVersion,
    builder: (column) => column,
  );

  GeneratedColumn<double> get focus =>
      $composableBuilder(column: $table.focus, builder: (column) => column);

  GeneratedColumn<double> get focusConfidence => $composableBuilder(
    column: $table.focusConfidence,
    builder: (column) => column,
  );

  GeneratedColumn<double> get capacity =>
      $composableBuilder(column: $table.capacity, builder: (column) => column);

  GeneratedColumn<double> get capacityConfidence => $composableBuilder(
    column: $table.capacityConfidence,
    builder: (column) => column,
  );

  GeneratedColumn<double> get arousal =>
      $composableBuilder(column: $table.arousal, builder: (column) => column);

  GeneratedColumn<double> get arousalConfidence => $composableBuilder(
    column: $table.arousalConfidence,
    builder: (column) => column,
  );

  GeneratedColumn<double> get stress =>
      $composableBuilder(column: $table.stress, builder: (column) => column);

  GeneratedColumn<double> get stressConfidence => $composableBuilder(
    column: $table.stressConfidence,
    builder: (column) => column,
  );

  GeneratedColumn<double> get quality =>
      $composableBuilder(column: $table.quality, builder: (column) => column);

  $$SessionsTableAnnotationComposer get sessionId {
    final $$SessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HsiWindowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HsiWindowsTable,
          HsiWindow,
          $$HsiWindowsTableFilterComposer,
          $$HsiWindowsTableOrderingComposer,
          $$HsiWindowsTableAnnotationComposer,
          $$HsiWindowsTableCreateCompanionBuilder,
          $$HsiWindowsTableUpdateCompanionBuilder,
          (HsiWindow, $$HsiWindowsTableReferences),
          HsiWindow,
          PrefetchHooks Function({bool sessionId})
        > {
  $$HsiWindowsTableTableManager(_$AppDatabase db, $HsiWindowsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HsiWindowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HsiWindowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HsiWindowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> rowId = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<DateTime> at = const Value.absent(),
                Value<SignalOrigin> signalOrigin = const Value.absent(),
                Value<String?> hsiVersion = const Value.absent(),
                Value<double?> focus = const Value.absent(),
                Value<double?> focusConfidence = const Value.absent(),
                Value<double?> capacity = const Value.absent(),
                Value<double?> capacityConfidence = const Value.absent(),
                Value<double?> arousal = const Value.absent(),
                Value<double?> arousalConfidence = const Value.absent(),
                Value<double?> stress = const Value.absent(),
                Value<double?> stressConfidence = const Value.absent(),
                Value<double?> quality = const Value.absent(),
              }) => HsiWindowsCompanion(
                rowId: rowId,
                sessionId: sessionId,
                at: at,
                signalOrigin: signalOrigin,
                hsiVersion: hsiVersion,
                focus: focus,
                focusConfidence: focusConfidence,
                capacity: capacity,
                capacityConfidence: capacityConfidence,
                arousal: arousal,
                arousalConfidence: arousalConfidence,
                stress: stress,
                stressConfidence: stressConfidence,
                quality: quality,
              ),
          createCompanionCallback:
              ({
                Value<int> rowId = const Value.absent(),
                required String sessionId,
                required DateTime at,
                Value<SignalOrigin> signalOrigin = const Value.absent(),
                Value<String?> hsiVersion = const Value.absent(),
                Value<double?> focus = const Value.absent(),
                Value<double?> focusConfidence = const Value.absent(),
                Value<double?> capacity = const Value.absent(),
                Value<double?> capacityConfidence = const Value.absent(),
                Value<double?> arousal = const Value.absent(),
                Value<double?> arousalConfidence = const Value.absent(),
                Value<double?> stress = const Value.absent(),
                Value<double?> stressConfidence = const Value.absent(),
                Value<double?> quality = const Value.absent(),
              }) => HsiWindowsCompanion.insert(
                rowId: rowId,
                sessionId: sessionId,
                at: at,
                signalOrigin: signalOrigin,
                hsiVersion: hsiVersion,
                focus: focus,
                focusConfidence: focusConfidence,
                capacity: capacity,
                capacityConfidence: capacityConfidence,
                arousal: arousal,
                arousalConfidence: arousalConfidence,
                stress: stress,
                stressConfidence: stressConfidence,
                quality: quality,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$HsiWindowsTableReferences(db, table, e),
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
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.sessionId,
                        referencedTable: $$HsiWindowsTableReferences
                            ._sessionIdTable(db),
                        referencedColumn: $$HsiWindowsTableReferences
                            ._sessionIdTable(db)
                            .id,
                      ) as T;
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

typedef $$HsiWindowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HsiWindowsTable,
      HsiWindow,
      $$HsiWindowsTableFilterComposer,
      $$HsiWindowsTableOrderingComposer,
      $$HsiWindowsTableAnnotationComposer,
      $$HsiWindowsTableCreateCompanionBuilder,
      $$HsiWindowsTableUpdateCompanionBuilder,
      (HsiWindow, $$HsiWindowsTableReferences),
      HsiWindow,
      PrefetchHooks Function({bool sessionId})
    >;
typedef $$CaptureSummariesTableCreateCompanionBuilder =
    CaptureSummariesCompanion Function({
      Value<int> rowId,
      required String sessionId,
      required CapturePhase phase,
      required SignalOrigin signalOrigin,
      Value<String?> watchSessionId,
      Value<String?> coreSessionId,
      Value<int> acceptedSamples,
      Value<int> totalSamples,
      Value<int> coverageSeconds,
      Value<int> accuracyHigh,
      Value<int> accuracyMedium,
      Value<int> accuracyLow,
      Value<int> hsiWindowCount,
      Value<double?> hsiFocus,
      Value<double?> hsiFocusConfidence,
      Value<double?> hsiCapacity,
      Value<double?> hsiCapacityConfidence,
      Value<double?> hsiArousal,
      Value<double?> hsiArousalConfidence,
      Value<double?> hsiStress,
      Value<double?> hsiStressConfidence,
      Value<double?> quality,
      Value<String?> diagnosticError,
      required DateTime createdAt,
    });
typedef $$CaptureSummariesTableUpdateCompanionBuilder =
    CaptureSummariesCompanion Function({
      Value<int> rowId,
      Value<String> sessionId,
      Value<CapturePhase> phase,
      Value<SignalOrigin> signalOrigin,
      Value<String?> watchSessionId,
      Value<String?> coreSessionId,
      Value<int> acceptedSamples,
      Value<int> totalSamples,
      Value<int> coverageSeconds,
      Value<int> accuracyHigh,
      Value<int> accuracyMedium,
      Value<int> accuracyLow,
      Value<int> hsiWindowCount,
      Value<double?> hsiFocus,
      Value<double?> hsiFocusConfidence,
      Value<double?> hsiCapacity,
      Value<double?> hsiCapacityConfidence,
      Value<double?> hsiArousal,
      Value<double?> hsiArousalConfidence,
      Value<double?> hsiStress,
      Value<double?> hsiStressConfidence,
      Value<double?> quality,
      Value<String?> diagnosticError,
      Value<DateTime> createdAt,
    });

final class $$CaptureSummariesTableReferences
    extends
        BaseReferences<_$AppDatabase, $CaptureSummariesTable, CaptureSummary> {
  $$CaptureSummariesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SessionsTable _sessionIdTable(_$AppDatabase db) =>
      db.sessions.createAlias('capture_summaries__session_id__sessions__id');

  $$SessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<String>('session_id')!;

    final manager = $$SessionsTableTableManager(
      $_db,
      $_db.sessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CaptureSummariesTableFilterComposer
    extends Composer<_$AppDatabase, $CaptureSummariesTable> {
  $$CaptureSummariesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get rowId => $composableBuilder(
    column: $table.rowId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<CapturePhase, CapturePhase, int> get phase =>
      $composableBuilder(
        column: $table.phase,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<SignalOrigin, SignalOrigin, int>
  get signalOrigin => $composableBuilder(
    column: $table.signalOrigin,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get watchSessionId => $composableBuilder(
    column: $table.watchSessionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coreSessionId => $composableBuilder(
    column: $table.coreSessionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get acceptedSamples => $composableBuilder(
    column: $table.acceptedSamples,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalSamples => $composableBuilder(
    column: $table.totalSamples,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get coverageSeconds => $composableBuilder(
    column: $table.coverageSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get accuracyHigh => $composableBuilder(
    column: $table.accuracyHigh,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get accuracyMedium => $composableBuilder(
    column: $table.accuracyMedium,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get accuracyLow => $composableBuilder(
    column: $table.accuracyLow,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hsiWindowCount => $composableBuilder(
    column: $table.hsiWindowCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get hsiFocus => $composableBuilder(
    column: $table.hsiFocus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get hsiFocusConfidence => $composableBuilder(
    column: $table.hsiFocusConfidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get hsiCapacity => $composableBuilder(
    column: $table.hsiCapacity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get hsiCapacityConfidence => $composableBuilder(
    column: $table.hsiCapacityConfidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get hsiArousal => $composableBuilder(
    column: $table.hsiArousal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get hsiArousalConfidence => $composableBuilder(
    column: $table.hsiArousalConfidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get hsiStress => $composableBuilder(
    column: $table.hsiStress,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get hsiStressConfidence => $composableBuilder(
    column: $table.hsiStressConfidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quality => $composableBuilder(
    column: $table.quality,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get diagnosticError => $composableBuilder(
    column: $table.diagnosticError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$SessionsTableFilterComposer get sessionId {
    final $$SessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableFilterComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CaptureSummariesTableOrderingComposer
    extends Composer<_$AppDatabase, $CaptureSummariesTable> {
  $$CaptureSummariesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get rowId => $composableBuilder(
    column: $table.rowId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get phase => $composableBuilder(
    column: $table.phase,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get signalOrigin => $composableBuilder(
    column: $table.signalOrigin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get watchSessionId => $composableBuilder(
    column: $table.watchSessionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coreSessionId => $composableBuilder(
    column: $table.coreSessionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get acceptedSamples => $composableBuilder(
    column: $table.acceptedSamples,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalSamples => $composableBuilder(
    column: $table.totalSamples,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get coverageSeconds => $composableBuilder(
    column: $table.coverageSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get accuracyHigh => $composableBuilder(
    column: $table.accuracyHigh,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get accuracyMedium => $composableBuilder(
    column: $table.accuracyMedium,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get accuracyLow => $composableBuilder(
    column: $table.accuracyLow,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hsiWindowCount => $composableBuilder(
    column: $table.hsiWindowCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get hsiFocus => $composableBuilder(
    column: $table.hsiFocus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get hsiFocusConfidence => $composableBuilder(
    column: $table.hsiFocusConfidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get hsiCapacity => $composableBuilder(
    column: $table.hsiCapacity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get hsiCapacityConfidence => $composableBuilder(
    column: $table.hsiCapacityConfidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get hsiArousal => $composableBuilder(
    column: $table.hsiArousal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get hsiArousalConfidence => $composableBuilder(
    column: $table.hsiArousalConfidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get hsiStress => $composableBuilder(
    column: $table.hsiStress,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get hsiStressConfidence => $composableBuilder(
    column: $table.hsiStressConfidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quality => $composableBuilder(
    column: $table.quality,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get diagnosticError => $composableBuilder(
    column: $table.diagnosticError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$SessionsTableOrderingComposer get sessionId {
    final $$SessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableOrderingComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CaptureSummariesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CaptureSummariesTable> {
  $$CaptureSummariesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get rowId =>
      $composableBuilder(column: $table.rowId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<CapturePhase, int> get phase =>
      $composableBuilder(column: $table.phase, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SignalOrigin, int> get signalOrigin =>
      $composableBuilder(
        column: $table.signalOrigin,
        builder: (column) => column,
      );

  GeneratedColumn<String> get watchSessionId => $composableBuilder(
    column: $table.watchSessionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get coreSessionId => $composableBuilder(
    column: $table.coreSessionId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get acceptedSamples => $composableBuilder(
    column: $table.acceptedSamples,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalSamples => $composableBuilder(
    column: $table.totalSamples,
    builder: (column) => column,
  );

  GeneratedColumn<int> get coverageSeconds => $composableBuilder(
    column: $table.coverageSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get accuracyHigh => $composableBuilder(
    column: $table.accuracyHigh,
    builder: (column) => column,
  );

  GeneratedColumn<int> get accuracyMedium => $composableBuilder(
    column: $table.accuracyMedium,
    builder: (column) => column,
  );

  GeneratedColumn<int> get accuracyLow => $composableBuilder(
    column: $table.accuracyLow,
    builder: (column) => column,
  );

  GeneratedColumn<int> get hsiWindowCount => $composableBuilder(
    column: $table.hsiWindowCount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get hsiFocus =>
      $composableBuilder(column: $table.hsiFocus, builder: (column) => column);

  GeneratedColumn<double> get hsiFocusConfidence => $composableBuilder(
    column: $table.hsiFocusConfidence,
    builder: (column) => column,
  );

  GeneratedColumn<double> get hsiCapacity => $composableBuilder(
    column: $table.hsiCapacity,
    builder: (column) => column,
  );

  GeneratedColumn<double> get hsiCapacityConfidence => $composableBuilder(
    column: $table.hsiCapacityConfidence,
    builder: (column) => column,
  );

  GeneratedColumn<double> get hsiArousal => $composableBuilder(
    column: $table.hsiArousal,
    builder: (column) => column,
  );

  GeneratedColumn<double> get hsiArousalConfidence => $composableBuilder(
    column: $table.hsiArousalConfidence,
    builder: (column) => column,
  );

  GeneratedColumn<double> get hsiStress =>
      $composableBuilder(column: $table.hsiStress, builder: (column) => column);

  GeneratedColumn<double> get hsiStressConfidence => $composableBuilder(
    column: $table.hsiStressConfidence,
    builder: (column) => column,
  );

  GeneratedColumn<double> get quality =>
      $composableBuilder(column: $table.quality, builder: (column) => column);

  GeneratedColumn<String> get diagnosticError => $composableBuilder(
    column: $table.diagnosticError,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$SessionsTableAnnotationComposer get sessionId {
    final $$SessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CaptureSummariesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CaptureSummariesTable,
          CaptureSummary,
          $$CaptureSummariesTableFilterComposer,
          $$CaptureSummariesTableOrderingComposer,
          $$CaptureSummariesTableAnnotationComposer,
          $$CaptureSummariesTableCreateCompanionBuilder,
          $$CaptureSummariesTableUpdateCompanionBuilder,
          (CaptureSummary, $$CaptureSummariesTableReferences),
          CaptureSummary,
          PrefetchHooks Function({bool sessionId})
        > {
  $$CaptureSummariesTableTableManager(
    _$AppDatabase db,
    $CaptureSummariesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CaptureSummariesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CaptureSummariesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CaptureSummariesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> rowId = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<CapturePhase> phase = const Value.absent(),
                Value<SignalOrigin> signalOrigin = const Value.absent(),
                Value<String?> watchSessionId = const Value.absent(),
                Value<String?> coreSessionId = const Value.absent(),
                Value<int> acceptedSamples = const Value.absent(),
                Value<int> totalSamples = const Value.absent(),
                Value<int> coverageSeconds = const Value.absent(),
                Value<int> accuracyHigh = const Value.absent(),
                Value<int> accuracyMedium = const Value.absent(),
                Value<int> accuracyLow = const Value.absent(),
                Value<int> hsiWindowCount = const Value.absent(),
                Value<double?> hsiFocus = const Value.absent(),
                Value<double?> hsiFocusConfidence = const Value.absent(),
                Value<double?> hsiCapacity = const Value.absent(),
                Value<double?> hsiCapacityConfidence = const Value.absent(),
                Value<double?> hsiArousal = const Value.absent(),
                Value<double?> hsiArousalConfidence = const Value.absent(),
                Value<double?> hsiStress = const Value.absent(),
                Value<double?> hsiStressConfidence = const Value.absent(),
                Value<double?> quality = const Value.absent(),
                Value<String?> diagnosticError = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => CaptureSummariesCompanion(
                rowId: rowId,
                sessionId: sessionId,
                phase: phase,
                signalOrigin: signalOrigin,
                watchSessionId: watchSessionId,
                coreSessionId: coreSessionId,
                acceptedSamples: acceptedSamples,
                totalSamples: totalSamples,
                coverageSeconds: coverageSeconds,
                accuracyHigh: accuracyHigh,
                accuracyMedium: accuracyMedium,
                accuracyLow: accuracyLow,
                hsiWindowCount: hsiWindowCount,
                hsiFocus: hsiFocus,
                hsiFocusConfidence: hsiFocusConfidence,
                hsiCapacity: hsiCapacity,
                hsiCapacityConfidence: hsiCapacityConfidence,
                hsiArousal: hsiArousal,
                hsiArousalConfidence: hsiArousalConfidence,
                hsiStress: hsiStress,
                hsiStressConfidence: hsiStressConfidence,
                quality: quality,
                diagnosticError: diagnosticError,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> rowId = const Value.absent(),
                required String sessionId,
                required CapturePhase phase,
                required SignalOrigin signalOrigin,
                Value<String?> watchSessionId = const Value.absent(),
                Value<String?> coreSessionId = const Value.absent(),
                Value<int> acceptedSamples = const Value.absent(),
                Value<int> totalSamples = const Value.absent(),
                Value<int> coverageSeconds = const Value.absent(),
                Value<int> accuracyHigh = const Value.absent(),
                Value<int> accuracyMedium = const Value.absent(),
                Value<int> accuracyLow = const Value.absent(),
                Value<int> hsiWindowCount = const Value.absent(),
                Value<double?> hsiFocus = const Value.absent(),
                Value<double?> hsiFocusConfidence = const Value.absent(),
                Value<double?> hsiCapacity = const Value.absent(),
                Value<double?> hsiCapacityConfidence = const Value.absent(),
                Value<double?> hsiArousal = const Value.absent(),
                Value<double?> hsiArousalConfidence = const Value.absent(),
                Value<double?> hsiStress = const Value.absent(),
                Value<double?> hsiStressConfidence = const Value.absent(),
                Value<double?> quality = const Value.absent(),
                Value<String?> diagnosticError = const Value.absent(),
                required DateTime createdAt,
              }) => CaptureSummariesCompanion.insert(
                rowId: rowId,
                sessionId: sessionId,
                phase: phase,
                signalOrigin: signalOrigin,
                watchSessionId: watchSessionId,
                coreSessionId: coreSessionId,
                acceptedSamples: acceptedSamples,
                totalSamples: totalSamples,
                coverageSeconds: coverageSeconds,
                accuracyHigh: accuracyHigh,
                accuracyMedium: accuracyMedium,
                accuracyLow: accuracyLow,
                hsiWindowCount: hsiWindowCount,
                hsiFocus: hsiFocus,
                hsiFocusConfidence: hsiFocusConfidence,
                hsiCapacity: hsiCapacity,
                hsiCapacityConfidence: hsiCapacityConfidence,
                hsiArousal: hsiArousal,
                hsiArousalConfidence: hsiArousalConfidence,
                hsiStress: hsiStress,
                hsiStressConfidence: hsiStressConfidence,
                quality: quality,
                diagnosticError: diagnosticError,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CaptureSummariesTableReferences(db, table, e),
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
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.sessionId,
                        referencedTable: $$CaptureSummariesTableReferences
                            ._sessionIdTable(db),
                        referencedColumn: $$CaptureSummariesTableReferences
                            ._sessionIdTable(db)
                            .id,
                      ) as T;
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

typedef $$CaptureSummariesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CaptureSummariesTable,
      CaptureSummary,
      $$CaptureSummariesTableFilterComposer,
      $$CaptureSummariesTableOrderingComposer,
      $$CaptureSummariesTableAnnotationComposer,
      $$CaptureSummariesTableCreateCompanionBuilder,
      $$CaptureSummariesTableUpdateCompanionBuilder,
      (CaptureSummary, $$CaptureSummariesTableReferences),
      CaptureSummary,
      PrefetchHooks Function({bool sessionId})
    >;
typedef $$ProfilesTableCreateCompanionBuilder = ProfilesCompanion Function({
  Value<int> id,
  Value<String> nickname,
  Value<bool> setupComplete,
  Value<bool> wearableConsent,
  Value<bool> cloudConsent,
});
typedef $$ProfilesTableUpdateCompanionBuilder = ProfilesCompanion Function({
  Value<int> id,
  Value<String> nickname,
  Value<bool> setupComplete,
  Value<bool> wearableConsent,
  Value<bool> cloudConsent,
});

class $$ProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableFilterComposer({
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

  ColumnFilters<String> get nickname => $composableBuilder(
    column: $table.nickname,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get setupComplete => $composableBuilder(
    column: $table.setupComplete,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get wearableConsent => $composableBuilder(
    column: $table.wearableConsent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get cloudConsent => $composableBuilder(
    column: $table.cloudConsent,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableOrderingComposer({
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

  ColumnOrderings<String> get nickname => $composableBuilder(
    column: $table.nickname,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get setupComplete => $composableBuilder(
    column: $table.setupComplete,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get wearableConsent => $composableBuilder(
    column: $table.wearableConsent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get cloudConsent => $composableBuilder(
    column: $table.cloudConsent,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nickname =>
      $composableBuilder(column: $table.nickname, builder: (column) => column);

  GeneratedColumn<bool> get setupComplete => $composableBuilder(
    column: $table.setupComplete,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get wearableConsent => $composableBuilder(
    column: $table.wearableConsent,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get cloudConsent => $composableBuilder(
    column: $table.cloudConsent,
    builder: (column) => column,
  );
}

class $$ProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProfilesTable,
          Profile,
          $$ProfilesTableFilterComposer,
          $$ProfilesTableOrderingComposer,
          $$ProfilesTableAnnotationComposer,
          $$ProfilesTableCreateCompanionBuilder,
          $$ProfilesTableUpdateCompanionBuilder,
          (Profile, BaseReferences<_$AppDatabase, $ProfilesTable, Profile>),
          Profile,
          PrefetchHooks Function()
        > {
  $$ProfilesTableTableManager(_$AppDatabase db, $ProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> nickname = const Value.absent(),
                Value<bool> setupComplete = const Value.absent(),
                Value<bool> wearableConsent = const Value.absent(),
                Value<bool> cloudConsent = const Value.absent(),
              }) => ProfilesCompanion(
                id: id,
                nickname: nickname,
                setupComplete: setupComplete,
                wearableConsent: wearableConsent,
                cloudConsent: cloudConsent,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> nickname = const Value.absent(),
                Value<bool> setupComplete = const Value.absent(),
                Value<bool> wearableConsent = const Value.absent(),
                Value<bool> cloudConsent = const Value.absent(),
              }) => ProfilesCompanion.insert(
                id: id,
                nickname: nickname,
                setupComplete: setupComplete,
                wearableConsent: wearableConsent,
                cloudConsent: cloudConsent,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProfilesTable,
      Profile,
      $$ProfilesTableFilterComposer,
      $$ProfilesTableOrderingComposer,
      $$ProfilesTableAnnotationComposer,
      $$ProfilesTableCreateCompanionBuilder,
      $$ProfilesTableUpdateCompanionBuilder,
      (Profile, BaseReferences<_$AppDatabase, $ProfilesTable, Profile>),
      Profile,
      PrefetchHooks Function()
    >;
typedef $$PageEventsTableCreateCompanionBuilder = PageEventsCompanion Function({
  Value<int> rowId,
  required String sessionId,
  required String sourceId,
  required int page,
  required DateTime at,
});
typedef $$PageEventsTableUpdateCompanionBuilder = PageEventsCompanion Function({
  Value<int> rowId,
  Value<String> sessionId,
  Value<String> sourceId,
  Value<int> page,
  Value<DateTime> at,
});

final class $$PageEventsTableReferences
    extends BaseReferences<_$AppDatabase, $PageEventsTable, PageEvent> {
  $$PageEventsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SessionsTable _sessionIdTable(_$AppDatabase db) =>
      db.sessions.createAlias('page_events__session_id__sessions__id');

  $$SessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<String>('session_id')!;

    final manager = $$SessionsTableTableManager(
      $_db,
      $_db.sessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $SourcesTable _sourceIdTable(_$AppDatabase db) =>
      db.sources.createAlias('page_events__source_id__sources__id');

  $$SourcesTableProcessedTableManager get sourceId {
    final $_column = $_itemColumn<String>('source_id')!;

    final manager = $$SourcesTableTableManager(
      $_db,
      $_db.sources,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sourceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PageEventsTableFilterComposer
    extends Composer<_$AppDatabase, $PageEventsTable> {
  $$PageEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get rowId => $composableBuilder(
    column: $table.rowId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get page => $composableBuilder(
    column: $table.page,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnFilters(column),
  );

  $$SessionsTableFilterComposer get sessionId {
    final $$SessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableFilterComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SourcesTableFilterComposer get sourceId {
    final $$SourcesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.sources,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SourcesTableFilterComposer(
            $db: $db,
            $table: $db.sources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PageEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $PageEventsTable> {
  $$PageEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get rowId => $composableBuilder(
    column: $table.rowId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get page => $composableBuilder(
    column: $table.page,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnOrderings(column),
  );

  $$SessionsTableOrderingComposer get sessionId {
    final $$SessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableOrderingComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SourcesTableOrderingComposer get sourceId {
    final $$SourcesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.sources,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SourcesTableOrderingComposer(
            $db: $db,
            $table: $db.sources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PageEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PageEventsTable> {
  $$PageEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get rowId =>
      $composableBuilder(column: $table.rowId, builder: (column) => column);

  GeneratedColumn<int> get page =>
      $composableBuilder(column: $table.page, builder: (column) => column);

  GeneratedColumn<DateTime> get at =>
      $composableBuilder(column: $table.at, builder: (column) => column);

  $$SessionsTableAnnotationComposer get sessionId {
    final $$SessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SourcesTableAnnotationComposer get sourceId {
    final $$SourcesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.sources,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SourcesTableAnnotationComposer(
            $db: $db,
            $table: $db.sources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PageEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PageEventsTable,
          PageEvent,
          $$PageEventsTableFilterComposer,
          $$PageEventsTableOrderingComposer,
          $$PageEventsTableAnnotationComposer,
          $$PageEventsTableCreateCompanionBuilder,
          $$PageEventsTableUpdateCompanionBuilder,
          (PageEvent, $$PageEventsTableReferences),
          PageEvent,
          PrefetchHooks Function({bool sessionId, bool sourceId})
        > {
  $$PageEventsTableTableManager(_$AppDatabase db, $PageEventsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PageEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PageEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PageEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> rowId = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<String> sourceId = const Value.absent(),
                Value<int> page = const Value.absent(),
                Value<DateTime> at = const Value.absent(),
              }) => PageEventsCompanion(
                rowId: rowId,
                sessionId: sessionId,
                sourceId: sourceId,
                page: page,
                at: at,
              ),
          createCompanionCallback:
              ({
                Value<int> rowId = const Value.absent(),
                required String sessionId,
                required String sourceId,
                required int page,
                required DateTime at,
              }) => PageEventsCompanion.insert(
                rowId: rowId,
                sessionId: sessionId,
                sourceId: sourceId,
                page: page,
                at: at,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PageEventsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false, sourceId = false}) {
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
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.sessionId,
                        referencedTable: $$PageEventsTableReferences
                            ._sessionIdTable(db),
                        referencedColumn: $$PageEventsTableReferences
                            ._sessionIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (sourceId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.sourceId,
                        referencedTable: $$PageEventsTableReferences
                            ._sourceIdTable(db),
                        referencedColumn: $$PageEventsTableReferences
                            ._sourceIdTable(db)
                            .id,
                      ) as T;
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

typedef $$PageEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PageEventsTable,
      PageEvent,
      $$PageEventsTableFilterComposer,
      $$PageEventsTableOrderingComposer,
      $$PageEventsTableAnnotationComposer,
      $$PageEventsTableCreateCompanionBuilder,
      $$PageEventsTableUpdateCompanionBuilder,
      (PageEvent, $$PageEventsTableReferences),
      PageEvent,
      PrefetchHooks Function({bool sessionId, bool sourceId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SubjectsTableTableManager get subjects =>
      $$SubjectsTableTableManager(_db, _db.subjects);
  $$SourcesTableTableManager get sources =>
      $$SourcesTableTableManager(_db, _db.sources);
  $$SessionsTableTableManager get sessions =>
      $$SessionsTableTableManager(_db, _db.sessions);
  $$HsiWindowsTableTableManager get hsiWindows =>
      $$HsiWindowsTableTableManager(_db, _db.hsiWindows);
  $$CaptureSummariesTableTableManager get captureSummaries =>
      $$CaptureSummariesTableTableManager(_db, _db.captureSummaries);
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db, _db.profiles);
  $$PageEventsTableTableManager get pageEvents =>
      $$PageEventsTableTableManager(_db, _db.pageEvents);
}
