// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $UserInfoSettingsTable extends UserInfoSettings
    with TableInfo<$UserInfoSettingsTable, UserInfoSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserInfoSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 6,
      maxTextLength: 32,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accessTokenMeta = const VerificationMeta(
    'accessToken',
  );
  @override
  late final GeneratedColumn<String> accessToken = GeneratedColumn<String>(
    'access_token',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, email, accessToken];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_info_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserInfoSetting> instance, {
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
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('access_token')) {
      context.handle(
        _accessTokenMeta,
        accessToken.isAcceptableOrUnknown(
          data['access_token']!,
          _accessTokenMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_accessTokenMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserInfoSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserInfoSetting(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      )!,
      accessToken: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}access_token'],
      )!,
    );
  }

  @override
  $UserInfoSettingsTable createAlias(String alias) {
    return $UserInfoSettingsTable(attachedDatabase, alias);
  }
}

class UserInfoSetting extends DataClass implements Insertable<UserInfoSetting> {
  final int id;
  final String name;
  final String email;
  final String accessToken;
  const UserInfoSetting({
    required this.id,
    required this.name,
    required this.email,
    required this.accessToken,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['email'] = Variable<String>(email);
    map['access_token'] = Variable<String>(accessToken);
    return map;
  }

  UserInfoSettingsCompanion toCompanion(bool nullToAbsent) {
    return UserInfoSettingsCompanion(
      id: Value(id),
      name: Value(name),
      email: Value(email),
      accessToken: Value(accessToken),
    );
  }

  factory UserInfoSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserInfoSetting(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      email: serializer.fromJson<String>(json['email']),
      accessToken: serializer.fromJson<String>(json['accessToken']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'email': serializer.toJson<String>(email),
      'accessToken': serializer.toJson<String>(accessToken),
    };
  }

  UserInfoSetting copyWith({
    int? id,
    String? name,
    String? email,
    String? accessToken,
  }) => UserInfoSetting(
    id: id ?? this.id,
    name: name ?? this.name,
    email: email ?? this.email,
    accessToken: accessToken ?? this.accessToken,
  );
  UserInfoSetting copyWithCompanion(UserInfoSettingsCompanion data) {
    return UserInfoSetting(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      email: data.email.present ? data.email.value : this.email,
      accessToken: data.accessToken.present
          ? data.accessToken.value
          : this.accessToken,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserInfoSetting(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('email: $email, ')
          ..write('accessToken: $accessToken')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, email, accessToken);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserInfoSetting &&
          other.id == this.id &&
          other.name == this.name &&
          other.email == this.email &&
          other.accessToken == this.accessToken);
}

class UserInfoSettingsCompanion extends UpdateCompanion<UserInfoSetting> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> email;
  final Value<String> accessToken;
  const UserInfoSettingsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.email = const Value.absent(),
    this.accessToken = const Value.absent(),
  });
  UserInfoSettingsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String email,
    required String accessToken,
  }) : name = Value(name),
       email = Value(email),
       accessToken = Value(accessToken);
  static Insertable<UserInfoSetting> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? email,
    Expression<String>? accessToken,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (accessToken != null) 'access_token': accessToken,
    });
  }

  UserInfoSettingsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? email,
    Value<String>? accessToken,
  }) {
    return UserInfoSettingsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      accessToken: accessToken ?? this.accessToken,
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
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (accessToken.present) {
      map['access_token'] = Variable<String>(accessToken.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserInfoSettingsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('email: $email, ')
          ..write('accessToken: $accessToken')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UserInfoSettingsTable userInfoSettings = $UserInfoSettingsTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [userInfoSettings];
}

typedef $$UserInfoSettingsTableCreateCompanionBuilder =
    UserInfoSettingsCompanion Function({
      Value<int> id,
      required String name,
      required String email,
      required String accessToken,
    });
typedef $$UserInfoSettingsTableUpdateCompanionBuilder =
    UserInfoSettingsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> email,
      Value<String> accessToken,
    });

class $$UserInfoSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $UserInfoSettingsTable> {
  $$UserInfoSettingsTableFilterComposer({
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

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accessToken => $composableBuilder(
    column: $table.accessToken,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserInfoSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $UserInfoSettingsTable> {
  $$UserInfoSettingsTableOrderingComposer({
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

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accessToken => $composableBuilder(
    column: $table.accessToken,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserInfoSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserInfoSettingsTable> {
  $$UserInfoSettingsTableAnnotationComposer({
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

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get accessToken => $composableBuilder(
    column: $table.accessToken,
    builder: (column) => column,
  );
}

class $$UserInfoSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserInfoSettingsTable,
          UserInfoSetting,
          $$UserInfoSettingsTableFilterComposer,
          $$UserInfoSettingsTableOrderingComposer,
          $$UserInfoSettingsTableAnnotationComposer,
          $$UserInfoSettingsTableCreateCompanionBuilder,
          $$UserInfoSettingsTableUpdateCompanionBuilder,
          (
            UserInfoSetting,
            BaseReferences<
              _$AppDatabase,
              $UserInfoSettingsTable,
              UserInfoSetting
            >,
          ),
          UserInfoSetting,
          PrefetchHooks Function()
        > {
  $$UserInfoSettingsTableTableManager(
    _$AppDatabase db,
    $UserInfoSettingsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserInfoSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserInfoSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserInfoSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> email = const Value.absent(),
                Value<String> accessToken = const Value.absent(),
              }) => UserInfoSettingsCompanion(
                id: id,
                name: name,
                email: email,
                accessToken: accessToken,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String email,
                required String accessToken,
              }) => UserInfoSettingsCompanion.insert(
                id: id,
                name: name,
                email: email,
                accessToken: accessToken,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserInfoSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserInfoSettingsTable,
      UserInfoSetting,
      $$UserInfoSettingsTableFilterComposer,
      $$UserInfoSettingsTableOrderingComposer,
      $$UserInfoSettingsTableAnnotationComposer,
      $$UserInfoSettingsTableCreateCompanionBuilder,
      $$UserInfoSettingsTableUpdateCompanionBuilder,
      (
        UserInfoSetting,
        BaseReferences<_$AppDatabase, $UserInfoSettingsTable, UserInfoSetting>,
      ),
      UserInfoSetting,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UserInfoSettingsTableTableManager get userInfoSettings =>
      $$UserInfoSettingsTableTableManager(_db, _db.userInfoSettings);
}
