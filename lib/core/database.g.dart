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
        DriftSqlType.string,
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
  final String id;
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
    map['id'] = Variable<String>(id);
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
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      email: serializer.fromJson<String>(json['email']),
      accessToken: serializer.fromJson<String>(json['accessToken']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'email': serializer.toJson<String>(email),
      'accessToken': serializer.toJson<String>(accessToken),
    };
  }

  UserInfoSetting copyWith({
    String? id,
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
  final Value<String> id;
  final Value<String> name;
  final Value<String> email;
  final Value<String> accessToken;
  final Value<int> rowid;
  const UserInfoSettingsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.email = const Value.absent(),
    this.accessToken = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserInfoSettingsCompanion.insert({
    required String id,
    required String name,
    required String email,
    required String accessToken,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       email = Value(email),
       accessToken = Value(accessToken);
  static Insertable<UserInfoSetting> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? email,
    Expression<String>? accessToken,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (accessToken != null) 'access_token': accessToken,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserInfoSettingsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? email,
    Value<String>? accessToken,
    Value<int>? rowid,
  }) {
    return UserInfoSettingsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      accessToken: accessToken ?? this.accessToken,
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
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (accessToken.present) {
      map['access_token'] = Variable<String>(accessToken.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserInfoSettingsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('email: $email, ')
          ..write('accessToken: $accessToken, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ChatListTableTable extends ChatListTable
    with TableInfo<$ChatListTableTable, ChatListTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChatListTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
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
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastMessageMeta = const VerificationMeta(
    'lastMessage',
  );
  @override
  late final GeneratedColumn<String> lastMessage = GeneratedColumn<String>(
    'last_message',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastMessageTimeMeta = const VerificationMeta(
    'lastMessageTime',
  );
  @override
  late final GeneratedColumn<int> lastMessageTime = GeneratedColumn<int>(
    'last_message_time',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _unReadCountMeta = const VerificationMeta(
    'unReadCount',
  );
  @override
  late final GeneratedColumn<int> unReadCount = GeneratedColumn<int>(
    'un_read_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    name,
    lastMessage,
    lastMessageTime,
    unReadCount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chat_list_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChatListTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('last_message')) {
      context.handle(
        _lastMessageMeta,
        lastMessage.isAcceptableOrUnknown(
          data['last_message']!,
          _lastMessageMeta,
        ),
      );
    }
    if (data.containsKey('last_message_time')) {
      context.handle(
        _lastMessageTimeMeta,
        lastMessageTime.isAcceptableOrUnknown(
          data['last_message_time']!,
          _lastMessageTimeMeta,
        ),
      );
    }
    if (data.containsKey('un_read_count')) {
      context.handle(
        _unReadCountMeta,
        unReadCount.isAcceptableOrUnknown(
          data['un_read_count']!,
          _unReadCountMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChatListTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChatListTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      lastMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_message'],
      ),
      lastMessageTime: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_message_time'],
      ),
      unReadCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}un_read_count'],
      )!,
    );
  }

  @override
  $ChatListTableTable createAlias(String alias) {
    return $ChatListTableTable(attachedDatabase, alias);
  }
}

class ChatListTableData extends DataClass
    implements Insertable<ChatListTableData> {
  final int id;
  final String userId;
  final String name;
  final String? lastMessage;
  final int? lastMessageTime;
  final int unReadCount;
  const ChatListTableData({
    required this.id,
    required this.userId,
    required this.name,
    this.lastMessage,
    this.lastMessageTime,
    required this.unReadCount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<String>(userId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || lastMessage != null) {
      map['last_message'] = Variable<String>(lastMessage);
    }
    if (!nullToAbsent || lastMessageTime != null) {
      map['last_message_time'] = Variable<int>(lastMessageTime);
    }
    map['un_read_count'] = Variable<int>(unReadCount);
    return map;
  }

  ChatListTableCompanion toCompanion(bool nullToAbsent) {
    return ChatListTableCompanion(
      id: Value(id),
      userId: Value(userId),
      name: Value(name),
      lastMessage: lastMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(lastMessage),
      lastMessageTime: lastMessageTime == null && nullToAbsent
          ? const Value.absent()
          : Value(lastMessageTime),
      unReadCount: Value(unReadCount),
    );
  }

  factory ChatListTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChatListTableData(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      name: serializer.fromJson<String>(json['name']),
      lastMessage: serializer.fromJson<String?>(json['lastMessage']),
      lastMessageTime: serializer.fromJson<int?>(json['lastMessageTime']),
      unReadCount: serializer.fromJson<int>(json['unReadCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<String>(userId),
      'name': serializer.toJson<String>(name),
      'lastMessage': serializer.toJson<String?>(lastMessage),
      'lastMessageTime': serializer.toJson<int?>(lastMessageTime),
      'unReadCount': serializer.toJson<int>(unReadCount),
    };
  }

  ChatListTableData copyWith({
    int? id,
    String? userId,
    String? name,
    Value<String?> lastMessage = const Value.absent(),
    Value<int?> lastMessageTime = const Value.absent(),
    int? unReadCount,
  }) => ChatListTableData(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    name: name ?? this.name,
    lastMessage: lastMessage.present ? lastMessage.value : this.lastMessage,
    lastMessageTime: lastMessageTime.present
        ? lastMessageTime.value
        : this.lastMessageTime,
    unReadCount: unReadCount ?? this.unReadCount,
  );
  ChatListTableData copyWithCompanion(ChatListTableCompanion data) {
    return ChatListTableData(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      name: data.name.present ? data.name.value : this.name,
      lastMessage: data.lastMessage.present
          ? data.lastMessage.value
          : this.lastMessage,
      lastMessageTime: data.lastMessageTime.present
          ? data.lastMessageTime.value
          : this.lastMessageTime,
      unReadCount: data.unReadCount.present
          ? data.unReadCount.value
          : this.unReadCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChatListTableData(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('lastMessage: $lastMessage, ')
          ..write('lastMessageTime: $lastMessageTime, ')
          ..write('unReadCount: $unReadCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, userId, name, lastMessage, lastMessageTime, unReadCount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChatListTableData &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.name == this.name &&
          other.lastMessage == this.lastMessage &&
          other.lastMessageTime == this.lastMessageTime &&
          other.unReadCount == this.unReadCount);
}

class ChatListTableCompanion extends UpdateCompanion<ChatListTableData> {
  final Value<int> id;
  final Value<String> userId;
  final Value<String> name;
  final Value<String?> lastMessage;
  final Value<int?> lastMessageTime;
  final Value<int> unReadCount;
  const ChatListTableCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.name = const Value.absent(),
    this.lastMessage = const Value.absent(),
    this.lastMessageTime = const Value.absent(),
    this.unReadCount = const Value.absent(),
  });
  ChatListTableCompanion.insert({
    this.id = const Value.absent(),
    required String userId,
    required String name,
    this.lastMessage = const Value.absent(),
    this.lastMessageTime = const Value.absent(),
    this.unReadCount = const Value.absent(),
  }) : userId = Value(userId),
       name = Value(name);
  static Insertable<ChatListTableData> custom({
    Expression<int>? id,
    Expression<String>? userId,
    Expression<String>? name,
    Expression<String>? lastMessage,
    Expression<int>? lastMessageTime,
    Expression<int>? unReadCount,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (name != null) 'name': name,
      if (lastMessage != null) 'last_message': lastMessage,
      if (lastMessageTime != null) 'last_message_time': lastMessageTime,
      if (unReadCount != null) 'un_read_count': unReadCount,
    });
  }

  ChatListTableCompanion copyWith({
    Value<int>? id,
    Value<String>? userId,
    Value<String>? name,
    Value<String?>? lastMessage,
    Value<int?>? lastMessageTime,
    Value<int>? unReadCount,
  }) {
    return ChatListTableCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unReadCount: unReadCount ?? this.unReadCount,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (lastMessage.present) {
      map['last_message'] = Variable<String>(lastMessage.value);
    }
    if (lastMessageTime.present) {
      map['last_message_time'] = Variable<int>(lastMessageTime.value);
    }
    if (unReadCount.present) {
      map['un_read_count'] = Variable<int>(unReadCount.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChatListTableCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('lastMessage: $lastMessage, ')
          ..write('lastMessageTime: $lastMessageTime, ')
          ..write('unReadCount: $unReadCount')
          ..write(')'))
        .toString();
  }
}

class $MessagesTable extends Messages with TableInfo<$MessagesTable, Message> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chatIdMeta = const VerificationMeta('chatId');
  @override
  late final GeneratedColumn<int> chatId = GeneratedColumn<int>(
    'chat_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES chat_list_table (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _senderIdMeta = const VerificationMeta(
    'senderId',
  );
  @override
  late final GeneratedColumn<String> senderId = GeneratedColumn<String>(
    'sender_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _messageMeta = const VerificationMeta(
    'message',
  );
  @override
  late final GeneratedColumn<String> message = GeneratedColumn<String>(
    'message',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _messageStatusMeta = const VerificationMeta(
    'messageStatus',
  );
  @override
  late final GeneratedColumn<String> messageStatus = GeneratedColumn<String>(
    'message_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant("sending"),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isReadMeta = const VerificationMeta('isRead');
  @override
  late final GeneratedColumn<bool> isRead = GeneratedColumn<bool>(
    'is_read',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_read" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    chatId,
    senderId,
    message,
    messageStatus,
    createdAt,
    isRead,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'messages';
  @override
  VerificationContext validateIntegrity(
    Insertable<Message> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('chat_id')) {
      context.handle(
        _chatIdMeta,
        chatId.isAcceptableOrUnknown(data['chat_id']!, _chatIdMeta),
      );
    } else if (isInserting) {
      context.missing(_chatIdMeta);
    }
    if (data.containsKey('sender_id')) {
      context.handle(
        _senderIdMeta,
        senderId.isAcceptableOrUnknown(data['sender_id']!, _senderIdMeta),
      );
    } else if (isInserting) {
      context.missing(_senderIdMeta);
    }
    if (data.containsKey('message')) {
      context.handle(
        _messageMeta,
        message.isAcceptableOrUnknown(data['message']!, _messageMeta),
      );
    } else if (isInserting) {
      context.missing(_messageMeta);
    }
    if (data.containsKey('message_status')) {
      context.handle(
        _messageStatusMeta,
        messageStatus.isAcceptableOrUnknown(
          data['message_status']!,
          _messageStatusMeta,
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
    if (data.containsKey('is_read')) {
      context.handle(
        _isReadMeta,
        isRead.isAcceptableOrUnknown(data['is_read']!, _isReadMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Message map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Message(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      chatId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chat_id'],
      )!,
      senderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sender_id'],
      )!,
      message: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message'],
      )!,
      messageStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message_status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      isRead: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_read'],
      )!,
    );
  }

  @override
  $MessagesTable createAlias(String alias) {
    return $MessagesTable(attachedDatabase, alias);
  }
}

class Message extends DataClass implements Insertable<Message> {
  final String id;
  final int chatId;
  final String senderId;
  final String message;
  final String messageStatus;
  final int createdAt;
  final bool isRead;
  const Message({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.message,
    required this.messageStatus,
    required this.createdAt,
    required this.isRead,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['chat_id'] = Variable<int>(chatId);
    map['sender_id'] = Variable<String>(senderId);
    map['message'] = Variable<String>(message);
    map['message_status'] = Variable<String>(messageStatus);
    map['created_at'] = Variable<int>(createdAt);
    map['is_read'] = Variable<bool>(isRead);
    return map;
  }

  MessagesCompanion toCompanion(bool nullToAbsent) {
    return MessagesCompanion(
      id: Value(id),
      chatId: Value(chatId),
      senderId: Value(senderId),
      message: Value(message),
      messageStatus: Value(messageStatus),
      createdAt: Value(createdAt),
      isRead: Value(isRead),
    );
  }

  factory Message.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Message(
      id: serializer.fromJson<String>(json['id']),
      chatId: serializer.fromJson<int>(json['chatId']),
      senderId: serializer.fromJson<String>(json['senderId']),
      message: serializer.fromJson<String>(json['message']),
      messageStatus: serializer.fromJson<String>(json['messageStatus']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      isRead: serializer.fromJson<bool>(json['isRead']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'chatId': serializer.toJson<int>(chatId),
      'senderId': serializer.toJson<String>(senderId),
      'message': serializer.toJson<String>(message),
      'messageStatus': serializer.toJson<String>(messageStatus),
      'createdAt': serializer.toJson<int>(createdAt),
      'isRead': serializer.toJson<bool>(isRead),
    };
  }

  Message copyWith({
    String? id,
    int? chatId,
    String? senderId,
    String? message,
    String? messageStatus,
    int? createdAt,
    bool? isRead,
  }) => Message(
    id: id ?? this.id,
    chatId: chatId ?? this.chatId,
    senderId: senderId ?? this.senderId,
    message: message ?? this.message,
    messageStatus: messageStatus ?? this.messageStatus,
    createdAt: createdAt ?? this.createdAt,
    isRead: isRead ?? this.isRead,
  );
  Message copyWithCompanion(MessagesCompanion data) {
    return Message(
      id: data.id.present ? data.id.value : this.id,
      chatId: data.chatId.present ? data.chatId.value : this.chatId,
      senderId: data.senderId.present ? data.senderId.value : this.senderId,
      message: data.message.present ? data.message.value : this.message,
      messageStatus: data.messageStatus.present
          ? data.messageStatus.value
          : this.messageStatus,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      isRead: data.isRead.present ? data.isRead.value : this.isRead,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Message(')
          ..write('id: $id, ')
          ..write('chatId: $chatId, ')
          ..write('senderId: $senderId, ')
          ..write('message: $message, ')
          ..write('messageStatus: $messageStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('isRead: $isRead')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    chatId,
    senderId,
    message,
    messageStatus,
    createdAt,
    isRead,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Message &&
          other.id == this.id &&
          other.chatId == this.chatId &&
          other.senderId == this.senderId &&
          other.message == this.message &&
          other.messageStatus == this.messageStatus &&
          other.createdAt == this.createdAt &&
          other.isRead == this.isRead);
}

class MessagesCompanion extends UpdateCompanion<Message> {
  final Value<String> id;
  final Value<int> chatId;
  final Value<String> senderId;
  final Value<String> message;
  final Value<String> messageStatus;
  final Value<int> createdAt;
  final Value<bool> isRead;
  final Value<int> rowid;
  const MessagesCompanion({
    this.id = const Value.absent(),
    this.chatId = const Value.absent(),
    this.senderId = const Value.absent(),
    this.message = const Value.absent(),
    this.messageStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.isRead = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MessagesCompanion.insert({
    required String id,
    required int chatId,
    required String senderId,
    required String message,
    this.messageStatus = const Value.absent(),
    required int createdAt,
    this.isRead = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       chatId = Value(chatId),
       senderId = Value(senderId),
       message = Value(message),
       createdAt = Value(createdAt);
  static Insertable<Message> custom({
    Expression<String>? id,
    Expression<int>? chatId,
    Expression<String>? senderId,
    Expression<String>? message,
    Expression<String>? messageStatus,
    Expression<int>? createdAt,
    Expression<bool>? isRead,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (chatId != null) 'chat_id': chatId,
      if (senderId != null) 'sender_id': senderId,
      if (message != null) 'message': message,
      if (messageStatus != null) 'message_status': messageStatus,
      if (createdAt != null) 'created_at': createdAt,
      if (isRead != null) 'is_read': isRead,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MessagesCompanion copyWith({
    Value<String>? id,
    Value<int>? chatId,
    Value<String>? senderId,
    Value<String>? message,
    Value<String>? messageStatus,
    Value<int>? createdAt,
    Value<bool>? isRead,
    Value<int>? rowid,
  }) {
    return MessagesCompanion(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      message: message ?? this.message,
      messageStatus: messageStatus ?? this.messageStatus,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (chatId.present) {
      map['chat_id'] = Variable<int>(chatId.value);
    }
    if (senderId.present) {
      map['sender_id'] = Variable<String>(senderId.value);
    }
    if (message.present) {
      map['message'] = Variable<String>(message.value);
    }
    if (messageStatus.present) {
      map['message_status'] = Variable<String>(messageStatus.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (isRead.present) {
      map['is_read'] = Variable<bool>(isRead.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MessagesCompanion(')
          ..write('id: $id, ')
          ..write('chatId: $chatId, ')
          ..write('senderId: $senderId, ')
          ..write('message: $message, ')
          ..write('messageStatus: $messageStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('isRead: $isRead, ')
          ..write('rowid: $rowid')
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
  late final $ChatListTableTable chatListTable = $ChatListTableTable(this);
  late final $MessagesTable messages = $MessagesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    userInfoSettings,
    chatListTable,
    messages,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'chat_list_table',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('messages', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$UserInfoSettingsTableCreateCompanionBuilder =
    UserInfoSettingsCompanion Function({
      required String id,
      required String name,
      required String email,
      required String accessToken,
      Value<int> rowid,
    });
typedef $$UserInfoSettingsTableUpdateCompanionBuilder =
    UserInfoSettingsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> email,
      Value<String> accessToken,
      Value<int> rowid,
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
  ColumnFilters<String> get id => $composableBuilder(
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
  ColumnOrderings<String> get id => $composableBuilder(
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
  GeneratedColumn<String> get id =>
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
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> email = const Value.absent(),
                Value<String> accessToken = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserInfoSettingsCompanion(
                id: id,
                name: name,
                email: email,
                accessToken: accessToken,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String email,
                required String accessToken,
                Value<int> rowid = const Value.absent(),
              }) => UserInfoSettingsCompanion.insert(
                id: id,
                name: name,
                email: email,
                accessToken: accessToken,
                rowid: rowid,
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
typedef $$ChatListTableTableCreateCompanionBuilder =
    ChatListTableCompanion Function({
      Value<int> id,
      required String userId,
      required String name,
      Value<String?> lastMessage,
      Value<int?> lastMessageTime,
      Value<int> unReadCount,
    });
typedef $$ChatListTableTableUpdateCompanionBuilder =
    ChatListTableCompanion Function({
      Value<int> id,
      Value<String> userId,
      Value<String> name,
      Value<String?> lastMessage,
      Value<int?> lastMessageTime,
      Value<int> unReadCount,
    });

final class $$ChatListTableTableReferences
    extends
        BaseReferences<_$AppDatabase, $ChatListTableTable, ChatListTableData> {
  $$ChatListTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$MessagesTable, List<Message>> _messagesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.messages,
    aliasName: $_aliasNameGenerator(db.chatListTable.id, db.messages.chatId),
  );

  $$MessagesTableProcessedTableManager get messagesRefs {
    final manager = $$MessagesTableTableManager(
      $_db,
      $_db.messages,
    ).filter((f) => f.chatId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_messagesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ChatListTableTableFilterComposer
    extends Composer<_$AppDatabase, $ChatListTableTable> {
  $$ChatListTableTableFilterComposer({
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

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastMessage => $composableBuilder(
    column: $table.lastMessage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastMessageTime => $composableBuilder(
    column: $table.lastMessageTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get unReadCount => $composableBuilder(
    column: $table.unReadCount,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> messagesRefs(
    Expression<bool> Function($$MessagesTableFilterComposer f) f,
  ) {
    final $$MessagesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.messages,
      getReferencedColumn: (t) => t.chatId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MessagesTableFilterComposer(
            $db: $db,
            $table: $db.messages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ChatListTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ChatListTableTable> {
  $$ChatListTableTableOrderingComposer({
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

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastMessage => $composableBuilder(
    column: $table.lastMessage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastMessageTime => $composableBuilder(
    column: $table.lastMessageTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get unReadCount => $composableBuilder(
    column: $table.unReadCount,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ChatListTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChatListTableTable> {
  $$ChatListTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get lastMessage => $composableBuilder(
    column: $table.lastMessage,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastMessageTime => $composableBuilder(
    column: $table.lastMessageTime,
    builder: (column) => column,
  );

  GeneratedColumn<int> get unReadCount => $composableBuilder(
    column: $table.unReadCount,
    builder: (column) => column,
  );

  Expression<T> messagesRefs<T extends Object>(
    Expression<T> Function($$MessagesTableAnnotationComposer a) f,
  ) {
    final $$MessagesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.messages,
      getReferencedColumn: (t) => t.chatId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MessagesTableAnnotationComposer(
            $db: $db,
            $table: $db.messages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ChatListTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ChatListTableTable,
          ChatListTableData,
          $$ChatListTableTableFilterComposer,
          $$ChatListTableTableOrderingComposer,
          $$ChatListTableTableAnnotationComposer,
          $$ChatListTableTableCreateCompanionBuilder,
          $$ChatListTableTableUpdateCompanionBuilder,
          (ChatListTableData, $$ChatListTableTableReferences),
          ChatListTableData,
          PrefetchHooks Function({bool messagesRefs})
        > {
  $$ChatListTableTableTableManager(_$AppDatabase db, $ChatListTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChatListTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChatListTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChatListTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> lastMessage = const Value.absent(),
                Value<int?> lastMessageTime = const Value.absent(),
                Value<int> unReadCount = const Value.absent(),
              }) => ChatListTableCompanion(
                id: id,
                userId: userId,
                name: name,
                lastMessage: lastMessage,
                lastMessageTime: lastMessageTime,
                unReadCount: unReadCount,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String userId,
                required String name,
                Value<String?> lastMessage = const Value.absent(),
                Value<int?> lastMessageTime = const Value.absent(),
                Value<int> unReadCount = const Value.absent(),
              }) => ChatListTableCompanion.insert(
                id: id,
                userId: userId,
                name: name,
                lastMessage: lastMessage,
                lastMessageTime: lastMessageTime,
                unReadCount: unReadCount,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ChatListTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({messagesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (messagesRefs) db.messages],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (messagesRefs)
                    await $_getPrefetchedData<
                      ChatListTableData,
                      $ChatListTableTable,
                      Message
                    >(
                      currentTable: table,
                      referencedTable: $$ChatListTableTableReferences
                          ._messagesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$ChatListTableTableReferences(
                            db,
                            table,
                            p0,
                          ).messagesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.chatId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ChatListTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ChatListTableTable,
      ChatListTableData,
      $$ChatListTableTableFilterComposer,
      $$ChatListTableTableOrderingComposer,
      $$ChatListTableTableAnnotationComposer,
      $$ChatListTableTableCreateCompanionBuilder,
      $$ChatListTableTableUpdateCompanionBuilder,
      (ChatListTableData, $$ChatListTableTableReferences),
      ChatListTableData,
      PrefetchHooks Function({bool messagesRefs})
    >;
typedef $$MessagesTableCreateCompanionBuilder =
    MessagesCompanion Function({
      required String id,
      required int chatId,
      required String senderId,
      required String message,
      Value<String> messageStatus,
      required int createdAt,
      Value<bool> isRead,
      Value<int> rowid,
    });
typedef $$MessagesTableUpdateCompanionBuilder =
    MessagesCompanion Function({
      Value<String> id,
      Value<int> chatId,
      Value<String> senderId,
      Value<String> message,
      Value<String> messageStatus,
      Value<int> createdAt,
      Value<bool> isRead,
      Value<int> rowid,
    });

final class $$MessagesTableReferences
    extends BaseReferences<_$AppDatabase, $MessagesTable, Message> {
  $$MessagesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ChatListTableTable _chatIdTable(_$AppDatabase db) =>
      db.chatListTable.createAlias(
        $_aliasNameGenerator(db.messages.chatId, db.chatListTable.id),
      );

  $$ChatListTableTableProcessedTableManager get chatId {
    final $_column = $_itemColumn<int>('chat_id')!;

    final manager = $$ChatListTableTableTableManager(
      $_db,
      $_db.chatListTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_chatIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MessagesTableFilterComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableFilterComposer({
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

  ColumnFilters<String> get senderId => $composableBuilder(
    column: $table.senderId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get messageStatus => $composableBuilder(
    column: $table.messageStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isRead => $composableBuilder(
    column: $table.isRead,
    builder: (column) => ColumnFilters(column),
  );

  $$ChatListTableTableFilterComposer get chatId {
    final $$ChatListTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.chatId,
      referencedTable: $db.chatListTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChatListTableTableFilterComposer(
            $db: $db,
            $table: $db.chatListTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MessagesTableOrderingComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableOrderingComposer({
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

  ColumnOrderings<String> get senderId => $composableBuilder(
    column: $table.senderId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get messageStatus => $composableBuilder(
    column: $table.messageStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isRead => $composableBuilder(
    column: $table.isRead,
    builder: (column) => ColumnOrderings(column),
  );

  $$ChatListTableTableOrderingComposer get chatId {
    final $$ChatListTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.chatId,
      referencedTable: $db.chatListTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChatListTableTableOrderingComposer(
            $db: $db,
            $table: $db.chatListTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MessagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get senderId =>
      $composableBuilder(column: $table.senderId, builder: (column) => column);

  GeneratedColumn<String> get message =>
      $composableBuilder(column: $table.message, builder: (column) => column);

  GeneratedColumn<String> get messageStatus => $composableBuilder(
    column: $table.messageStatus,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get isRead =>
      $composableBuilder(column: $table.isRead, builder: (column) => column);

  $$ChatListTableTableAnnotationComposer get chatId {
    final $$ChatListTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.chatId,
      referencedTable: $db.chatListTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChatListTableTableAnnotationComposer(
            $db: $db,
            $table: $db.chatListTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MessagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MessagesTable,
          Message,
          $$MessagesTableFilterComposer,
          $$MessagesTableOrderingComposer,
          $$MessagesTableAnnotationComposer,
          $$MessagesTableCreateCompanionBuilder,
          $$MessagesTableUpdateCompanionBuilder,
          (Message, $$MessagesTableReferences),
          Message,
          PrefetchHooks Function({bool chatId})
        > {
  $$MessagesTableTableManager(_$AppDatabase db, $MessagesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MessagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> chatId = const Value.absent(),
                Value<String> senderId = const Value.absent(),
                Value<String> message = const Value.absent(),
                Value<String> messageStatus = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<bool> isRead = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MessagesCompanion(
                id: id,
                chatId: chatId,
                senderId: senderId,
                message: message,
                messageStatus: messageStatus,
                createdAt: createdAt,
                isRead: isRead,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int chatId,
                required String senderId,
                required String message,
                Value<String> messageStatus = const Value.absent(),
                required int createdAt,
                Value<bool> isRead = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MessagesCompanion.insert(
                id: id,
                chatId: chatId,
                senderId: senderId,
                message: message,
                messageStatus: messageStatus,
                createdAt: createdAt,
                isRead: isRead,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MessagesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({chatId = false}) {
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
                    if (chatId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.chatId,
                                referencedTable: $$MessagesTableReferences
                                    ._chatIdTable(db),
                                referencedColumn: $$MessagesTableReferences
                                    ._chatIdTable(db)
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

typedef $$MessagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MessagesTable,
      Message,
      $$MessagesTableFilterComposer,
      $$MessagesTableOrderingComposer,
      $$MessagesTableAnnotationComposer,
      $$MessagesTableCreateCompanionBuilder,
      $$MessagesTableUpdateCompanionBuilder,
      (Message, $$MessagesTableReferences),
      Message,
      PrefetchHooks Function({bool chatId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UserInfoSettingsTableTableManager get userInfoSettings =>
      $$UserInfoSettingsTableTableManager(_db, _db.userInfoSettings);
  $$ChatListTableTableTableManager get chatListTable =>
      $$ChatListTableTableTableManager(_db, _db.chatListTable);
  $$MessagesTableTableManager get messages =>
      $$MessagesTableTableManager(_db, _db.messages);
}
