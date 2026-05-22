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
      minTextLength: 4,
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
  static const VerificationMeta _profilePictureUrlMeta = const VerificationMeta(
    'profilePictureUrl',
  );
  @override
  late final GeneratedColumn<String> profilePictureUrl =
      GeneratedColumn<String>(
        'profile_picture_url',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _bioMeta = const VerificationMeta('bio');
  @override
  late final GeneratedColumn<String> bio = GeneratedColumn<String>(
    'bio',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    email,
    accessToken,
    profilePictureUrl,
    bio,
  ];
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
    if (data.containsKey('profile_picture_url')) {
      context.handle(
        _profilePictureUrlMeta,
        profilePictureUrl.isAcceptableOrUnknown(
          data['profile_picture_url']!,
          _profilePictureUrlMeta,
        ),
      );
    }
    if (data.containsKey('bio')) {
      context.handle(
        _bioMeta,
        bio.isAcceptableOrUnknown(data['bio']!, _bioMeta),
      );
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
      profilePictureUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_picture_url'],
      ),
      bio: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bio'],
      ),
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
  final String? profilePictureUrl;
  final String? bio;
  const UserInfoSetting({
    required this.id,
    required this.name,
    required this.email,
    required this.accessToken,
    this.profilePictureUrl,
    this.bio,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['email'] = Variable<String>(email);
    map['access_token'] = Variable<String>(accessToken);
    if (!nullToAbsent || profilePictureUrl != null) {
      map['profile_picture_url'] = Variable<String>(profilePictureUrl);
    }
    if (!nullToAbsent || bio != null) {
      map['bio'] = Variable<String>(bio);
    }
    return map;
  }

  UserInfoSettingsCompanion toCompanion(bool nullToAbsent) {
    return UserInfoSettingsCompanion(
      id: Value(id),
      name: Value(name),
      email: Value(email),
      accessToken: Value(accessToken),
      profilePictureUrl: profilePictureUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(profilePictureUrl),
      bio: bio == null && nullToAbsent ? const Value.absent() : Value(bio),
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
      profilePictureUrl: serializer.fromJson<String?>(
        json['profilePictureUrl'],
      ),
      bio: serializer.fromJson<String?>(json['bio']),
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
      'profilePictureUrl': serializer.toJson<String?>(profilePictureUrl),
      'bio': serializer.toJson<String?>(bio),
    };
  }

  UserInfoSetting copyWith({
    String? id,
    String? name,
    String? email,
    String? accessToken,
    Value<String?> profilePictureUrl = const Value.absent(),
    Value<String?> bio = const Value.absent(),
  }) => UserInfoSetting(
    id: id ?? this.id,
    name: name ?? this.name,
    email: email ?? this.email,
    accessToken: accessToken ?? this.accessToken,
    profilePictureUrl: profilePictureUrl.present
        ? profilePictureUrl.value
        : this.profilePictureUrl,
    bio: bio.present ? bio.value : this.bio,
  );
  UserInfoSetting copyWithCompanion(UserInfoSettingsCompanion data) {
    return UserInfoSetting(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      email: data.email.present ? data.email.value : this.email,
      accessToken: data.accessToken.present
          ? data.accessToken.value
          : this.accessToken,
      profilePictureUrl: data.profilePictureUrl.present
          ? data.profilePictureUrl.value
          : this.profilePictureUrl,
      bio: data.bio.present ? data.bio.value : this.bio,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserInfoSetting(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('email: $email, ')
          ..write('accessToken: $accessToken, ')
          ..write('profilePictureUrl: $profilePictureUrl, ')
          ..write('bio: $bio')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, email, accessToken, profilePictureUrl, bio);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserInfoSetting &&
          other.id == this.id &&
          other.name == this.name &&
          other.email == this.email &&
          other.accessToken == this.accessToken &&
          other.profilePictureUrl == this.profilePictureUrl &&
          other.bio == this.bio);
}

class UserInfoSettingsCompanion extends UpdateCompanion<UserInfoSetting> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> email;
  final Value<String> accessToken;
  final Value<String?> profilePictureUrl;
  final Value<String?> bio;
  final Value<int> rowid;
  const UserInfoSettingsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.email = const Value.absent(),
    this.accessToken = const Value.absent(),
    this.profilePictureUrl = const Value.absent(),
    this.bio = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserInfoSettingsCompanion.insert({
    required String id,
    required String name,
    required String email,
    required String accessToken,
    this.profilePictureUrl = const Value.absent(),
    this.bio = const Value.absent(),
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
    Expression<String>? profilePictureUrl,
    Expression<String>? bio,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (accessToken != null) 'access_token': accessToken,
      if (profilePictureUrl != null) 'profile_picture_url': profilePictureUrl,
      if (bio != null) 'bio': bio,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserInfoSettingsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? email,
    Value<String>? accessToken,
    Value<String?>? profilePictureUrl,
    Value<String?>? bio,
    Value<int>? rowid,
  }) {
    return UserInfoSettingsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      accessToken: accessToken ?? this.accessToken,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      bio: bio ?? this.bio,
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
    if (profilePictureUrl.present) {
      map['profile_picture_url'] = Variable<String>(profilePictureUrl.value);
    }
    if (bio.present) {
      map['bio'] = Variable<String>(bio.value);
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
          ..write('profilePictureUrl: $profilePictureUrl, ')
          ..write('bio: $bio, ')
          ..write('rowid: $rowid')
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
  late final GeneratedColumn<String> chatId = GeneratedColumn<String>(
    'chat_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
    'server_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
    serverId,
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
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
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
        DriftSqlType.string,
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
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_id'],
      ),
    );
  }

  @override
  $MessagesTable createAlias(String alias) {
    return $MessagesTable(attachedDatabase, alias);
  }
}

class Message extends DataClass implements Insertable<Message> {
  final String id;
  final String chatId;
  final String senderId;
  final String message;
  final String messageStatus;
  final int createdAt;
  final bool isRead;
  final String? serverId;
  const Message({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.message,
    required this.messageStatus,
    required this.createdAt,
    required this.isRead,
    this.serverId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['chat_id'] = Variable<String>(chatId);
    map['sender_id'] = Variable<String>(senderId);
    map['message'] = Variable<String>(message);
    map['message_status'] = Variable<String>(messageStatus);
    map['created_at'] = Variable<int>(createdAt);
    map['is_read'] = Variable<bool>(isRead);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<String>(serverId);
    }
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
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
    );
  }

  factory Message.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Message(
      id: serializer.fromJson<String>(json['id']),
      chatId: serializer.fromJson<String>(json['chatId']),
      senderId: serializer.fromJson<String>(json['senderId']),
      message: serializer.fromJson<String>(json['message']),
      messageStatus: serializer.fromJson<String>(json['messageStatus']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      isRead: serializer.fromJson<bool>(json['isRead']),
      serverId: serializer.fromJson<String?>(json['serverId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'chatId': serializer.toJson<String>(chatId),
      'senderId': serializer.toJson<String>(senderId),
      'message': serializer.toJson<String>(message),
      'messageStatus': serializer.toJson<String>(messageStatus),
      'createdAt': serializer.toJson<int>(createdAt),
      'isRead': serializer.toJson<bool>(isRead),
      'serverId': serializer.toJson<String?>(serverId),
    };
  }

  Message copyWith({
    String? id,
    String? chatId,
    String? senderId,
    String? message,
    String? messageStatus,
    int? createdAt,
    bool? isRead,
    Value<String?> serverId = const Value.absent(),
  }) => Message(
    id: id ?? this.id,
    chatId: chatId ?? this.chatId,
    senderId: senderId ?? this.senderId,
    message: message ?? this.message,
    messageStatus: messageStatus ?? this.messageStatus,
    createdAt: createdAt ?? this.createdAt,
    isRead: isRead ?? this.isRead,
    serverId: serverId.present ? serverId.value : this.serverId,
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
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
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
          ..write('isRead: $isRead, ')
          ..write('serverId: $serverId')
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
    serverId,
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
          other.isRead == this.isRead &&
          other.serverId == this.serverId);
}

class MessagesCompanion extends UpdateCompanion<Message> {
  final Value<String> id;
  final Value<String> chatId;
  final Value<String> senderId;
  final Value<String> message;
  final Value<String> messageStatus;
  final Value<int> createdAt;
  final Value<bool> isRead;
  final Value<String?> serverId;
  final Value<int> rowid;
  const MessagesCompanion({
    this.id = const Value.absent(),
    this.chatId = const Value.absent(),
    this.senderId = const Value.absent(),
    this.message = const Value.absent(),
    this.messageStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.isRead = const Value.absent(),
    this.serverId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MessagesCompanion.insert({
    required String id,
    required String chatId,
    required String senderId,
    required String message,
    this.messageStatus = const Value.absent(),
    required int createdAt,
    this.isRead = const Value.absent(),
    this.serverId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       chatId = Value(chatId),
       senderId = Value(senderId),
       message = Value(message),
       createdAt = Value(createdAt);
  static Insertable<Message> custom({
    Expression<String>? id,
    Expression<String>? chatId,
    Expression<String>? senderId,
    Expression<String>? message,
    Expression<String>? messageStatus,
    Expression<int>? createdAt,
    Expression<bool>? isRead,
    Expression<String>? serverId,
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
      if (serverId != null) 'server_id': serverId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MessagesCompanion copyWith({
    Value<String>? id,
    Value<String>? chatId,
    Value<String>? senderId,
    Value<String>? message,
    Value<String>? messageStatus,
    Value<int>? createdAt,
    Value<bool>? isRead,
    Value<String?>? serverId,
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
      serverId: serverId ?? this.serverId,
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
      map['chat_id'] = Variable<String>(chatId.value);
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
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
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
          ..write('serverId: $serverId, ')
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
  static const VerificationMeta _chatIdMeta = const VerificationMeta('chatId');
  @override
  late final GeneratedColumn<String> chatId = GeneratedColumn<String>(
    'chat_id',
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
  static const VerificationMeta _profilePicUrlMeta = const VerificationMeta(
    'profilePicUrl',
  );
  @override
  late final GeneratedColumn<String> profilePicUrl = GeneratedColumn<String>(
    'profile_pic_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    chatId,
    name,
    lastMessage,
    lastMessageTime,
    unReadCount,
    profilePicUrl,
    isDeleted,
    description,
    type,
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
    if (data.containsKey('chat_id')) {
      context.handle(
        _chatIdMeta,
        chatId.isAcceptableOrUnknown(data['chat_id']!, _chatIdMeta),
      );
    } else if (isInserting) {
      context.missing(_chatIdMeta);
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
    if (data.containsKey('profile_pic_url')) {
      context.handle(
        _profilePicUrlMeta,
        profilePicUrl.isAcceptableOrUnknown(
          data['profile_pic_url']!,
          _profilePicUrlMeta,
        ),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
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
      chatId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chat_id'],
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
      profilePicUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_pic_url'],
      ),
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
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
  final String chatId;
  final String name;
  final String? lastMessage;
  final int? lastMessageTime;
  final int unReadCount;
  final String? profilePicUrl;
  final bool isDeleted;
  final String? description;
  final String type;
  const ChatListTableData({
    required this.id,
    required this.chatId,
    required this.name,
    this.lastMessage,
    this.lastMessageTime,
    required this.unReadCount,
    this.profilePicUrl,
    required this.isDeleted,
    this.description,
    required this.type,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['chat_id'] = Variable<String>(chatId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || lastMessage != null) {
      map['last_message'] = Variable<String>(lastMessage);
    }
    if (!nullToAbsent || lastMessageTime != null) {
      map['last_message_time'] = Variable<int>(lastMessageTime);
    }
    map['un_read_count'] = Variable<int>(unReadCount);
    if (!nullToAbsent || profilePicUrl != null) {
      map['profile_pic_url'] = Variable<String>(profilePicUrl);
    }
    map['is_deleted'] = Variable<bool>(isDeleted);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['type'] = Variable<String>(type);
    return map;
  }

  ChatListTableCompanion toCompanion(bool nullToAbsent) {
    return ChatListTableCompanion(
      id: Value(id),
      chatId: Value(chatId),
      name: Value(name),
      lastMessage: lastMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(lastMessage),
      lastMessageTime: lastMessageTime == null && nullToAbsent
          ? const Value.absent()
          : Value(lastMessageTime),
      unReadCount: Value(unReadCount),
      profilePicUrl: profilePicUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(profilePicUrl),
      isDeleted: Value(isDeleted),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      type: Value(type),
    );
  }

  factory ChatListTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChatListTableData(
      id: serializer.fromJson<int>(json['id']),
      chatId: serializer.fromJson<String>(json['chatId']),
      name: serializer.fromJson<String>(json['name']),
      lastMessage: serializer.fromJson<String?>(json['lastMessage']),
      lastMessageTime: serializer.fromJson<int?>(json['lastMessageTime']),
      unReadCount: serializer.fromJson<int>(json['unReadCount']),
      profilePicUrl: serializer.fromJson<String?>(json['profilePicUrl']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      description: serializer.fromJson<String?>(json['description']),
      type: serializer.fromJson<String>(json['type']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'chatId': serializer.toJson<String>(chatId),
      'name': serializer.toJson<String>(name),
      'lastMessage': serializer.toJson<String?>(lastMessage),
      'lastMessageTime': serializer.toJson<int?>(lastMessageTime),
      'unReadCount': serializer.toJson<int>(unReadCount),
      'profilePicUrl': serializer.toJson<String?>(profilePicUrl),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'description': serializer.toJson<String?>(description),
      'type': serializer.toJson<String>(type),
    };
  }

  ChatListTableData copyWith({
    int? id,
    String? chatId,
    String? name,
    Value<String?> lastMessage = const Value.absent(),
    Value<int?> lastMessageTime = const Value.absent(),
    int? unReadCount,
    Value<String?> profilePicUrl = const Value.absent(),
    bool? isDeleted,
    Value<String?> description = const Value.absent(),
    String? type,
  }) => ChatListTableData(
    id: id ?? this.id,
    chatId: chatId ?? this.chatId,
    name: name ?? this.name,
    lastMessage: lastMessage.present ? lastMessage.value : this.lastMessage,
    lastMessageTime: lastMessageTime.present
        ? lastMessageTime.value
        : this.lastMessageTime,
    unReadCount: unReadCount ?? this.unReadCount,
    profilePicUrl: profilePicUrl.present
        ? profilePicUrl.value
        : this.profilePicUrl,
    isDeleted: isDeleted ?? this.isDeleted,
    description: description.present ? description.value : this.description,
    type: type ?? this.type,
  );
  ChatListTableData copyWithCompanion(ChatListTableCompanion data) {
    return ChatListTableData(
      id: data.id.present ? data.id.value : this.id,
      chatId: data.chatId.present ? data.chatId.value : this.chatId,
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
      profilePicUrl: data.profilePicUrl.present
          ? data.profilePicUrl.value
          : this.profilePicUrl,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      description: data.description.present
          ? data.description.value
          : this.description,
      type: data.type.present ? data.type.value : this.type,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChatListTableData(')
          ..write('id: $id, ')
          ..write('chatId: $chatId, ')
          ..write('name: $name, ')
          ..write('lastMessage: $lastMessage, ')
          ..write('lastMessageTime: $lastMessageTime, ')
          ..write('unReadCount: $unReadCount, ')
          ..write('profilePicUrl: $profilePicUrl, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('description: $description, ')
          ..write('type: $type')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    chatId,
    name,
    lastMessage,
    lastMessageTime,
    unReadCount,
    profilePicUrl,
    isDeleted,
    description,
    type,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChatListTableData &&
          other.id == this.id &&
          other.chatId == this.chatId &&
          other.name == this.name &&
          other.lastMessage == this.lastMessage &&
          other.lastMessageTime == this.lastMessageTime &&
          other.unReadCount == this.unReadCount &&
          other.profilePicUrl == this.profilePicUrl &&
          other.isDeleted == this.isDeleted &&
          other.description == this.description &&
          other.type == this.type);
}

class ChatListTableCompanion extends UpdateCompanion<ChatListTableData> {
  final Value<int> id;
  final Value<String> chatId;
  final Value<String> name;
  final Value<String?> lastMessage;
  final Value<int?> lastMessageTime;
  final Value<int> unReadCount;
  final Value<String?> profilePicUrl;
  final Value<bool> isDeleted;
  final Value<String?> description;
  final Value<String> type;
  const ChatListTableCompanion({
    this.id = const Value.absent(),
    this.chatId = const Value.absent(),
    this.name = const Value.absent(),
    this.lastMessage = const Value.absent(),
    this.lastMessageTime = const Value.absent(),
    this.unReadCount = const Value.absent(),
    this.profilePicUrl = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.description = const Value.absent(),
    this.type = const Value.absent(),
  });
  ChatListTableCompanion.insert({
    this.id = const Value.absent(),
    required String chatId,
    required String name,
    this.lastMessage = const Value.absent(),
    this.lastMessageTime = const Value.absent(),
    this.unReadCount = const Value.absent(),
    this.profilePicUrl = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.description = const Value.absent(),
    required String type,
  }) : chatId = Value(chatId),
       name = Value(name),
       type = Value(type);
  static Insertable<ChatListTableData> custom({
    Expression<int>? id,
    Expression<String>? chatId,
    Expression<String>? name,
    Expression<String>? lastMessage,
    Expression<int>? lastMessageTime,
    Expression<int>? unReadCount,
    Expression<String>? profilePicUrl,
    Expression<bool>? isDeleted,
    Expression<String>? description,
    Expression<String>? type,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (chatId != null) 'chat_id': chatId,
      if (name != null) 'name': name,
      if (lastMessage != null) 'last_message': lastMessage,
      if (lastMessageTime != null) 'last_message_time': lastMessageTime,
      if (unReadCount != null) 'un_read_count': unReadCount,
      if (profilePicUrl != null) 'profile_pic_url': profilePicUrl,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (description != null) 'description': description,
      if (type != null) 'type': type,
    });
  }

  ChatListTableCompanion copyWith({
    Value<int>? id,
    Value<String>? chatId,
    Value<String>? name,
    Value<String?>? lastMessage,
    Value<int?>? lastMessageTime,
    Value<int>? unReadCount,
    Value<String?>? profilePicUrl,
    Value<bool>? isDeleted,
    Value<String?>? description,
    Value<String>? type,
  }) {
    return ChatListTableCompanion(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      name: name ?? this.name,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unReadCount: unReadCount ?? this.unReadCount,
      profilePicUrl: profilePicUrl ?? this.profilePicUrl,
      isDeleted: isDeleted ?? this.isDeleted,
      description: description ?? this.description,
      type: type ?? this.type,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (chatId.present) {
      map['chat_id'] = Variable<String>(chatId.value);
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
    if (profilePicUrl.present) {
      map['profile_pic_url'] = Variable<String>(profilePicUrl.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChatListTableCompanion(')
          ..write('id: $id, ')
          ..write('chatId: $chatId, ')
          ..write('name: $name, ')
          ..write('lastMessage: $lastMessage, ')
          ..write('lastMessageTime: $lastMessageTime, ')
          ..write('unReadCount: $unReadCount, ')
          ..write('profilePicUrl: $profilePicUrl, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('description: $description, ')
          ..write('type: $type')
          ..write(')'))
        .toString();
  }
}

class $UsersTableTable extends UsersTable
    with TableInfo<$UsersTableTable, UsersTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _profilePictureUrlMeta = const VerificationMeta(
    'profilePictureUrl',
  );
  @override
  late final GeneratedColumn<String> profilePictureUrl =
      GeneratedColumn<String>(
        'profile_picture_url',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _bioMeta = const VerificationMeta('bio');
  @override
  late final GeneratedColumn<String> bio = GeneratedColumn<String>(
    'bio',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    email,
    profilePictureUrl,
    bio,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<UsersTableData> instance, {
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
    if (data.containsKey('profile_picture_url')) {
      context.handle(
        _profilePictureUrlMeta,
        profilePictureUrl.isAcceptableOrUnknown(
          data['profile_picture_url']!,
          _profilePictureUrlMeta,
        ),
      );
    }
    if (data.containsKey('bio')) {
      context.handle(
        _bioMeta,
        bio.isAcceptableOrUnknown(data['bio']!, _bioMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UsersTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UsersTableData(
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
      profilePictureUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_picture_url'],
      ),
      bio: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bio'],
      ),
    );
  }

  @override
  $UsersTableTable createAlias(String alias) {
    return $UsersTableTable(attachedDatabase, alias);
  }
}

class UsersTableData extends DataClass implements Insertable<UsersTableData> {
  final String id;
  final String name;
  final String email;
  final String? profilePictureUrl;
  final String? bio;
  const UsersTableData({
    required this.id,
    required this.name,
    required this.email,
    this.profilePictureUrl,
    this.bio,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['email'] = Variable<String>(email);
    if (!nullToAbsent || profilePictureUrl != null) {
      map['profile_picture_url'] = Variable<String>(profilePictureUrl);
    }
    if (!nullToAbsent || bio != null) {
      map['bio'] = Variable<String>(bio);
    }
    return map;
  }

  UsersTableCompanion toCompanion(bool nullToAbsent) {
    return UsersTableCompanion(
      id: Value(id),
      name: Value(name),
      email: Value(email),
      profilePictureUrl: profilePictureUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(profilePictureUrl),
      bio: bio == null && nullToAbsent ? const Value.absent() : Value(bio),
    );
  }

  factory UsersTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UsersTableData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      email: serializer.fromJson<String>(json['email']),
      profilePictureUrl: serializer.fromJson<String?>(
        json['profilePictureUrl'],
      ),
      bio: serializer.fromJson<String?>(json['bio']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'email': serializer.toJson<String>(email),
      'profilePictureUrl': serializer.toJson<String?>(profilePictureUrl),
      'bio': serializer.toJson<String?>(bio),
    };
  }

  UsersTableData copyWith({
    String? id,
    String? name,
    String? email,
    Value<String?> profilePictureUrl = const Value.absent(),
    Value<String?> bio = const Value.absent(),
  }) => UsersTableData(
    id: id ?? this.id,
    name: name ?? this.name,
    email: email ?? this.email,
    profilePictureUrl: profilePictureUrl.present
        ? profilePictureUrl.value
        : this.profilePictureUrl,
    bio: bio.present ? bio.value : this.bio,
  );
  UsersTableData copyWithCompanion(UsersTableCompanion data) {
    return UsersTableData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      email: data.email.present ? data.email.value : this.email,
      profilePictureUrl: data.profilePictureUrl.present
          ? data.profilePictureUrl.value
          : this.profilePictureUrl,
      bio: data.bio.present ? data.bio.value : this.bio,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UsersTableData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('email: $email, ')
          ..write('profilePictureUrl: $profilePictureUrl, ')
          ..write('bio: $bio')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, email, profilePictureUrl, bio);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UsersTableData &&
          other.id == this.id &&
          other.name == this.name &&
          other.email == this.email &&
          other.profilePictureUrl == this.profilePictureUrl &&
          other.bio == this.bio);
}

class UsersTableCompanion extends UpdateCompanion<UsersTableData> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> email;
  final Value<String?> profilePictureUrl;
  final Value<String?> bio;
  final Value<int> rowid;
  const UsersTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.email = const Value.absent(),
    this.profilePictureUrl = const Value.absent(),
    this.bio = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UsersTableCompanion.insert({
    required String id,
    required String name,
    required String email,
    this.profilePictureUrl = const Value.absent(),
    this.bio = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       email = Value(email);
  static Insertable<UsersTableData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? email,
    Expression<String>? profilePictureUrl,
    Expression<String>? bio,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (profilePictureUrl != null) 'profile_picture_url': profilePictureUrl,
      if (bio != null) 'bio': bio,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UsersTableCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? email,
    Value<String?>? profilePictureUrl,
    Value<String?>? bio,
    Value<int>? rowid,
  }) {
    return UsersTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      bio: bio ?? this.bio,
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
    if (profilePictureUrl.present) {
      map['profile_picture_url'] = Variable<String>(profilePictureUrl.value);
    }
    if (bio.present) {
      map['bio'] = Variable<String>(bio.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('email: $email, ')
          ..write('profilePictureUrl: $profilePictureUrl, ')
          ..write('bio: $bio, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ChatParticipantsTable extends ChatParticipants
    with TableInfo<$ChatParticipantsTable, ChatParticipant> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChatParticipantsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _chatIdMeta = const VerificationMeta('chatId');
  @override
  late final GeneratedColumn<String> chatId = GeneratedColumn<String>(
    'chat_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _profilePicUrlMeta = const VerificationMeta(
    'profilePicUrl',
  );
  @override
  late final GeneratedColumn<String> profilePicUrl = GeneratedColumn<String>(
    'profile_pic_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant("MEMBER"),
  );
  @override
  List<GeneratedColumn> get $columns => [
    chatId,
    userId,
    name,
    profilePicUrl,
    role,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chat_participants';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChatParticipant> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('chat_id')) {
      context.handle(
        _chatIdMeta,
        chatId.isAcceptableOrUnknown(data['chat_id']!, _chatIdMeta),
      );
    } else if (isInserting) {
      context.missing(_chatIdMeta);
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
    if (data.containsKey('profile_pic_url')) {
      context.handle(
        _profilePicUrlMeta,
        profilePicUrl.isAcceptableOrUnknown(
          data['profile_pic_url']!,
          _profilePicUrlMeta,
        ),
      );
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {chatId, userId};
  @override
  ChatParticipant map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChatParticipant(
      chatId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chat_id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      profilePicUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_pic_url'],
      ),
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
    );
  }

  @override
  $ChatParticipantsTable createAlias(String alias) {
    return $ChatParticipantsTable(attachedDatabase, alias);
  }
}

class ChatParticipant extends DataClass implements Insertable<ChatParticipant> {
  final String chatId;
  final String userId;
  final String name;
  final String? profilePicUrl;
  final String role;
  const ChatParticipant({
    required this.chatId,
    required this.userId,
    required this.name,
    this.profilePicUrl,
    required this.role,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['chat_id'] = Variable<String>(chatId);
    map['user_id'] = Variable<String>(userId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || profilePicUrl != null) {
      map['profile_pic_url'] = Variable<String>(profilePicUrl);
    }
    map['role'] = Variable<String>(role);
    return map;
  }

  ChatParticipantsCompanion toCompanion(bool nullToAbsent) {
    return ChatParticipantsCompanion(
      chatId: Value(chatId),
      userId: Value(userId),
      name: Value(name),
      profilePicUrl: profilePicUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(profilePicUrl),
      role: Value(role),
    );
  }

  factory ChatParticipant.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChatParticipant(
      chatId: serializer.fromJson<String>(json['chatId']),
      userId: serializer.fromJson<String>(json['userId']),
      name: serializer.fromJson<String>(json['name']),
      profilePicUrl: serializer.fromJson<String?>(json['profilePicUrl']),
      role: serializer.fromJson<String>(json['role']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'chatId': serializer.toJson<String>(chatId),
      'userId': serializer.toJson<String>(userId),
      'name': serializer.toJson<String>(name),
      'profilePicUrl': serializer.toJson<String?>(profilePicUrl),
      'role': serializer.toJson<String>(role),
    };
  }

  ChatParticipant copyWith({
    String? chatId,
    String? userId,
    String? name,
    Value<String?> profilePicUrl = const Value.absent(),
    String? role,
  }) => ChatParticipant(
    chatId: chatId ?? this.chatId,
    userId: userId ?? this.userId,
    name: name ?? this.name,
    profilePicUrl: profilePicUrl.present
        ? profilePicUrl.value
        : this.profilePicUrl,
    role: role ?? this.role,
  );
  ChatParticipant copyWithCompanion(ChatParticipantsCompanion data) {
    return ChatParticipant(
      chatId: data.chatId.present ? data.chatId.value : this.chatId,
      userId: data.userId.present ? data.userId.value : this.userId,
      name: data.name.present ? data.name.value : this.name,
      profilePicUrl: data.profilePicUrl.present
          ? data.profilePicUrl.value
          : this.profilePicUrl,
      role: data.role.present ? data.role.value : this.role,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChatParticipant(')
          ..write('chatId: $chatId, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('profilePicUrl: $profilePicUrl, ')
          ..write('role: $role')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(chatId, userId, name, profilePicUrl, role);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChatParticipant &&
          other.chatId == this.chatId &&
          other.userId == this.userId &&
          other.name == this.name &&
          other.profilePicUrl == this.profilePicUrl &&
          other.role == this.role);
}

class ChatParticipantsCompanion extends UpdateCompanion<ChatParticipant> {
  final Value<String> chatId;
  final Value<String> userId;
  final Value<String> name;
  final Value<String?> profilePicUrl;
  final Value<String> role;
  final Value<int> rowid;
  const ChatParticipantsCompanion({
    this.chatId = const Value.absent(),
    this.userId = const Value.absent(),
    this.name = const Value.absent(),
    this.profilePicUrl = const Value.absent(),
    this.role = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChatParticipantsCompanion.insert({
    required String chatId,
    required String userId,
    required String name,
    this.profilePicUrl = const Value.absent(),
    this.role = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : chatId = Value(chatId),
       userId = Value(userId),
       name = Value(name);
  static Insertable<ChatParticipant> custom({
    Expression<String>? chatId,
    Expression<String>? userId,
    Expression<String>? name,
    Expression<String>? profilePicUrl,
    Expression<String>? role,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (chatId != null) 'chat_id': chatId,
      if (userId != null) 'user_id': userId,
      if (name != null) 'name': name,
      if (profilePicUrl != null) 'profile_pic_url': profilePicUrl,
      if (role != null) 'role': role,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChatParticipantsCompanion copyWith({
    Value<String>? chatId,
    Value<String>? userId,
    Value<String>? name,
    Value<String?>? profilePicUrl,
    Value<String>? role,
    Value<int>? rowid,
  }) {
    return ChatParticipantsCompanion(
      chatId: chatId ?? this.chatId,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      profilePicUrl: profilePicUrl ?? this.profilePicUrl,
      role: role ?? this.role,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (chatId.present) {
      map['chat_id'] = Variable<String>(chatId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (profilePicUrl.present) {
      map['profile_pic_url'] = Variable<String>(profilePicUrl.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChatParticipantsCompanion(')
          ..write('chatId: $chatId, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('profilePicUrl: $profilePicUrl, ')
          ..write('role: $role, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MessageStatusTableTable extends MessageStatusTable
    with TableInfo<$MessageStatusTableTable, MessageStatusTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MessageStatusTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _messageIdMeta = const VerificationMeta(
    'messageId',
  );
  @override
  late final GeneratedColumn<String> messageId = GeneratedColumn<String>(
    'message_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
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
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deliveredAtMeta = const VerificationMeta(
    'deliveredAt',
  );
  @override
  late final GeneratedColumn<int> deliveredAt = GeneratedColumn<int>(
    'delivered_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _readAtMeta = const VerificationMeta('readAt');
  @override
  late final GeneratedColumn<int> readAt = GeneratedColumn<int>(
    'read_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    messageId,
    userId,
    status,
    createdAt,
    updatedAt,
    deliveredAt,
    readAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'message_status_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<MessageStatusTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('message_id')) {
      context.handle(
        _messageIdMeta,
        messageId.isAcceptableOrUnknown(data['message_id']!, _messageIdMeta),
      );
    } else if (isInserting) {
      context.missing(_messageIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
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
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('delivered_at')) {
      context.handle(
        _deliveredAtMeta,
        deliveredAt.isAcceptableOrUnknown(
          data['delivered_at']!,
          _deliveredAtMeta,
        ),
      );
    }
    if (data.containsKey('read_at')) {
      context.handle(
        _readAtMeta,
        readAt.isAcceptableOrUnknown(data['read_at']!, _readAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {messageId, userId};
  @override
  MessageStatusTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MessageStatusTableData(
      messageId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message_id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deliveredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}delivered_at'],
      ),
      readAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}read_at'],
      ),
    );
  }

  @override
  $MessageStatusTableTable createAlias(String alias) {
    return $MessageStatusTableTable(attachedDatabase, alias);
  }
}

class MessageStatusTableData extends DataClass
    implements Insertable<MessageStatusTableData> {
  final String messageId;
  final String userId;
  final String status;
  final int createdAt;
  final int updatedAt;
  final int? deliveredAt;
  final int? readAt;
  const MessageStatusTableData({
    required this.messageId,
    required this.userId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.deliveredAt,
    this.readAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['message_id'] = Variable<String>(messageId);
    map['user_id'] = Variable<String>(userId);
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deliveredAt != null) {
      map['delivered_at'] = Variable<int>(deliveredAt);
    }
    if (!nullToAbsent || readAt != null) {
      map['read_at'] = Variable<int>(readAt);
    }
    return map;
  }

  MessageStatusTableCompanion toCompanion(bool nullToAbsent) {
    return MessageStatusTableCompanion(
      messageId: Value(messageId),
      userId: Value(userId),
      status: Value(status),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deliveredAt: deliveredAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deliveredAt),
      readAt: readAt == null && nullToAbsent
          ? const Value.absent()
          : Value(readAt),
    );
  }

  factory MessageStatusTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MessageStatusTableData(
      messageId: serializer.fromJson<String>(json['messageId']),
      userId: serializer.fromJson<String>(json['userId']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deliveredAt: serializer.fromJson<int?>(json['deliveredAt']),
      readAt: serializer.fromJson<int?>(json['readAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'messageId': serializer.toJson<String>(messageId),
      'userId': serializer.toJson<String>(userId),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deliveredAt': serializer.toJson<int?>(deliveredAt),
      'readAt': serializer.toJson<int?>(readAt),
    };
  }

  MessageStatusTableData copyWith({
    String? messageId,
    String? userId,
    String? status,
    int? createdAt,
    int? updatedAt,
    Value<int?> deliveredAt = const Value.absent(),
    Value<int?> readAt = const Value.absent(),
  }) => MessageStatusTableData(
    messageId: messageId ?? this.messageId,
    userId: userId ?? this.userId,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deliveredAt: deliveredAt.present ? deliveredAt.value : this.deliveredAt,
    readAt: readAt.present ? readAt.value : this.readAt,
  );
  MessageStatusTableData copyWithCompanion(MessageStatusTableCompanion data) {
    return MessageStatusTableData(
      messageId: data.messageId.present ? data.messageId.value : this.messageId,
      userId: data.userId.present ? data.userId.value : this.userId,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deliveredAt: data.deliveredAt.present
          ? data.deliveredAt.value
          : this.deliveredAt,
      readAt: data.readAt.present ? data.readAt.value : this.readAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MessageStatusTableData(')
          ..write('messageId: $messageId, ')
          ..write('userId: $userId, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deliveredAt: $deliveredAt, ')
          ..write('readAt: $readAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    messageId,
    userId,
    status,
    createdAt,
    updatedAt,
    deliveredAt,
    readAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MessageStatusTableData &&
          other.messageId == this.messageId &&
          other.userId == this.userId &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deliveredAt == this.deliveredAt &&
          other.readAt == this.readAt);
}

class MessageStatusTableCompanion
    extends UpdateCompanion<MessageStatusTableData> {
  final Value<String> messageId;
  final Value<String> userId;
  final Value<String> status;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deliveredAt;
  final Value<int?> readAt;
  final Value<int> rowid;
  const MessageStatusTableCompanion({
    this.messageId = const Value.absent(),
    this.userId = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deliveredAt = const Value.absent(),
    this.readAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MessageStatusTableCompanion.insert({
    required String messageId,
    required String userId,
    this.status = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.deliveredAt = const Value.absent(),
    this.readAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : messageId = Value(messageId),
       userId = Value(userId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<MessageStatusTableData> custom({
    Expression<String>? messageId,
    Expression<String>? userId,
    Expression<String>? status,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deliveredAt,
    Expression<int>? readAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (messageId != null) 'message_id': messageId,
      if (userId != null) 'user_id': userId,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deliveredAt != null) 'delivered_at': deliveredAt,
      if (readAt != null) 'read_at': readAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MessageStatusTableCompanion copyWith({
    Value<String>? messageId,
    Value<String>? userId,
    Value<String>? status,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deliveredAt,
    Value<int?>? readAt,
    Value<int>? rowid,
  }) {
    return MessageStatusTableCompanion(
      messageId: messageId ?? this.messageId,
      userId: userId ?? this.userId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      readAt: readAt ?? this.readAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (messageId.present) {
      map['message_id'] = Variable<String>(messageId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deliveredAt.present) {
      map['delivered_at'] = Variable<int>(deliveredAt.value);
    }
    if (readAt.present) {
      map['read_at'] = Variable<int>(readAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MessageStatusTableCompanion(')
          ..write('messageId: $messageId, ')
          ..write('userId: $userId, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deliveredAt: $deliveredAt, ')
          ..write('readAt: $readAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MediaTableTable extends MediaTable
    with TableInfo<$MediaTableTable, MediaTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MediaTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _locationMeta = const VerificationMeta(
    'location',
  );
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
    'location',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _contentTypeMeta = const VerificationMeta(
    'contentType',
  );
  @override
  late final GeneratedColumn<String> contentType = GeneratedColumn<String>(
    'content_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _actorIdMeta = const VerificationMeta(
    'actorId',
  );
  @override
  late final GeneratedColumn<String> actorId = GeneratedColumn<String>(
    'actor_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _TypeMeta = const VerificationMeta('Type');
  @override
  late final GeneratedColumn<String> Type = GeneratedColumn<String>(
    'type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    location,
    contentType,
    actorId,
    Type,
    name,
    key,
    url,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'media_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<MediaTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('location')) {
      context.handle(
        _locationMeta,
        location.isAcceptableOrUnknown(data['location']!, _locationMeta),
      );
    }
    if (data.containsKey('content_type')) {
      context.handle(
        _contentTypeMeta,
        contentType.isAcceptableOrUnknown(
          data['content_type']!,
          _contentTypeMeta,
        ),
      );
    }
    if (data.containsKey('actor_id')) {
      context.handle(
        _actorIdMeta,
        actorId.isAcceptableOrUnknown(data['actor_id']!, _actorIdMeta),
      );
    }
    if (data.containsKey('type')) {
      context.handle(
        _TypeMeta,
        Type.isAcceptableOrUnknown(data['type']!, _TypeMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
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
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MediaTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MediaTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      location: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location'],
      ),
      contentType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_type'],
      ),
      actorId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}actor_id'],
      ),
      Type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      ),
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      ),
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $MediaTableTable createAlias(String alias) {
    return $MediaTableTable(attachedDatabase, alias);
  }
}

class MediaTableData extends DataClass implements Insertable<MediaTableData> {
  final int id;
  final String? location;
  final String? contentType;
  final String? actorId;
  final String? Type;
  final String? name;
  final String? key;
  final String? url;
  final int createdAt;
  const MediaTableData({
    required this.id,
    this.location,
    this.contentType,
    this.actorId,
    this.Type,
    this.name,
    this.key,
    this.url,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || location != null) {
      map['location'] = Variable<String>(location);
    }
    if (!nullToAbsent || contentType != null) {
      map['content_type'] = Variable<String>(contentType);
    }
    if (!nullToAbsent || actorId != null) {
      map['actor_id'] = Variable<String>(actorId);
    }
    if (!nullToAbsent || Type != null) {
      map['type'] = Variable<String>(Type);
    }
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    if (!nullToAbsent || key != null) {
      map['key'] = Variable<String>(key);
    }
    if (!nullToAbsent || url != null) {
      map['url'] = Variable<String>(url);
    }
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  MediaTableCompanion toCompanion(bool nullToAbsent) {
    return MediaTableCompanion(
      id: Value(id),
      location: location == null && nullToAbsent
          ? const Value.absent()
          : Value(location),
      contentType: contentType == null && nullToAbsent
          ? const Value.absent()
          : Value(contentType),
      actorId: actorId == null && nullToAbsent
          ? const Value.absent()
          : Value(actorId),
      Type: Type == null && nullToAbsent ? const Value.absent() : Value(Type),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      key: key == null && nullToAbsent ? const Value.absent() : Value(key),
      url: url == null && nullToAbsent ? const Value.absent() : Value(url),
      createdAt: Value(createdAt),
    );
  }

  factory MediaTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MediaTableData(
      id: serializer.fromJson<int>(json['id']),
      location: serializer.fromJson<String?>(json['location']),
      contentType: serializer.fromJson<String?>(json['contentType']),
      actorId: serializer.fromJson<String?>(json['actorId']),
      Type: serializer.fromJson<String?>(json['Type']),
      name: serializer.fromJson<String?>(json['name']),
      key: serializer.fromJson<String?>(json['key']),
      url: serializer.fromJson<String?>(json['url']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'location': serializer.toJson<String?>(location),
      'contentType': serializer.toJson<String?>(contentType),
      'actorId': serializer.toJson<String?>(actorId),
      'Type': serializer.toJson<String?>(Type),
      'name': serializer.toJson<String?>(name),
      'key': serializer.toJson<String?>(key),
      'url': serializer.toJson<String?>(url),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  MediaTableData copyWith({
    int? id,
    Value<String?> location = const Value.absent(),
    Value<String?> contentType = const Value.absent(),
    Value<String?> actorId = const Value.absent(),
    Value<String?> Type = const Value.absent(),
    Value<String?> name = const Value.absent(),
    Value<String?> key = const Value.absent(),
    Value<String?> url = const Value.absent(),
    int? createdAt,
  }) => MediaTableData(
    id: id ?? this.id,
    location: location.present ? location.value : this.location,
    contentType: contentType.present ? contentType.value : this.contentType,
    actorId: actorId.present ? actorId.value : this.actorId,
    Type: Type.present ? Type.value : this.Type,
    name: name.present ? name.value : this.name,
    key: key.present ? key.value : this.key,
    url: url.present ? url.value : this.url,
    createdAt: createdAt ?? this.createdAt,
  );
  MediaTableData copyWithCompanion(MediaTableCompanion data) {
    return MediaTableData(
      id: data.id.present ? data.id.value : this.id,
      location: data.location.present ? data.location.value : this.location,
      contentType: data.contentType.present
          ? data.contentType.value
          : this.contentType,
      actorId: data.actorId.present ? data.actorId.value : this.actorId,
      Type: data.Type.present ? data.Type.value : this.Type,
      name: data.name.present ? data.name.value : this.name,
      key: data.key.present ? data.key.value : this.key,
      url: data.url.present ? data.url.value : this.url,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MediaTableData(')
          ..write('id: $id, ')
          ..write('location: $location, ')
          ..write('contentType: $contentType, ')
          ..write('actorId: $actorId, ')
          ..write('Type: $Type, ')
          ..write('name: $name, ')
          ..write('key: $key, ')
          ..write('url: $url, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    location,
    contentType,
    actorId,
    Type,
    name,
    key,
    url,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MediaTableData &&
          other.id == this.id &&
          other.location == this.location &&
          other.contentType == this.contentType &&
          other.actorId == this.actorId &&
          other.Type == this.Type &&
          other.name == this.name &&
          other.key == this.key &&
          other.url == this.url &&
          other.createdAt == this.createdAt);
}

class MediaTableCompanion extends UpdateCompanion<MediaTableData> {
  final Value<int> id;
  final Value<String?> location;
  final Value<String?> contentType;
  final Value<String?> actorId;
  final Value<String?> Type;
  final Value<String?> name;
  final Value<String?> key;
  final Value<String?> url;
  final Value<int> createdAt;
  const MediaTableCompanion({
    this.id = const Value.absent(),
    this.location = const Value.absent(),
    this.contentType = const Value.absent(),
    this.actorId = const Value.absent(),
    this.Type = const Value.absent(),
    this.name = const Value.absent(),
    this.key = const Value.absent(),
    this.url = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  MediaTableCompanion.insert({
    this.id = const Value.absent(),
    this.location = const Value.absent(),
    this.contentType = const Value.absent(),
    this.actorId = const Value.absent(),
    this.Type = const Value.absent(),
    this.name = const Value.absent(),
    this.key = const Value.absent(),
    this.url = const Value.absent(),
    required int createdAt,
  }) : createdAt = Value(createdAt);
  static Insertable<MediaTableData> custom({
    Expression<int>? id,
    Expression<String>? location,
    Expression<String>? contentType,
    Expression<String>? actorId,
    Expression<String>? Type,
    Expression<String>? name,
    Expression<String>? key,
    Expression<String>? url,
    Expression<int>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (location != null) 'location': location,
      if (contentType != null) 'content_type': contentType,
      if (actorId != null) 'actor_id': actorId,
      if (Type != null) 'type': Type,
      if (name != null) 'name': name,
      if (key != null) 'key': key,
      if (url != null) 'url': url,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  MediaTableCompanion copyWith({
    Value<int>? id,
    Value<String?>? location,
    Value<String?>? contentType,
    Value<String?>? actorId,
    Value<String?>? Type,
    Value<String?>? name,
    Value<String?>? key,
    Value<String?>? url,
    Value<int>? createdAt,
  }) {
    return MediaTableCompanion(
      id: id ?? this.id,
      location: location ?? this.location,
      contentType: contentType ?? this.contentType,
      actorId: actorId ?? this.actorId,
      Type: Type ?? this.Type,
      name: name ?? this.name,
      key: key ?? this.key,
      url: url ?? this.url,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (contentType.present) {
      map['content_type'] = Variable<String>(contentType.value);
    }
    if (actorId.present) {
      map['actor_id'] = Variable<String>(actorId.value);
    }
    if (Type.present) {
      map['type'] = Variable<String>(Type.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MediaTableCompanion(')
          ..write('id: $id, ')
          ..write('location: $location, ')
          ..write('contentType: $contentType, ')
          ..write('actorId: $actorId, ')
          ..write('Type: $Type, ')
          ..write('name: $name, ')
          ..write('key: $key, ')
          ..write('url: $url, ')
          ..write('createdAt: $createdAt')
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
  late final $MessagesTable messages = $MessagesTable(this);
  late final $ChatListTableTable chatListTable = $ChatListTableTable(this);
  late final $UsersTableTable usersTable = $UsersTableTable(this);
  late final $ChatParticipantsTable chatParticipants = $ChatParticipantsTable(
    this,
  );
  late final $MessageStatusTableTable messageStatusTable =
      $MessageStatusTableTable(this);
  late final $MediaTableTable mediaTable = $MediaTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    userInfoSettings,
    messages,
    chatListTable,
    usersTable,
    chatParticipants,
    messageStatusTable,
    mediaTable,
  ];
}

typedef $$UserInfoSettingsTableCreateCompanionBuilder =
    UserInfoSettingsCompanion Function({
      required String id,
      required String name,
      required String email,
      required String accessToken,
      Value<String?> profilePictureUrl,
      Value<String?> bio,
      Value<int> rowid,
    });
typedef $$UserInfoSettingsTableUpdateCompanionBuilder =
    UserInfoSettingsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> email,
      Value<String> accessToken,
      Value<String?> profilePictureUrl,
      Value<String?> bio,
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

  ColumnFilters<String> get profilePictureUrl => $composableBuilder(
    column: $table.profilePictureUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bio => $composableBuilder(
    column: $table.bio,
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

  ColumnOrderings<String> get profilePictureUrl => $composableBuilder(
    column: $table.profilePictureUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bio => $composableBuilder(
    column: $table.bio,
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

  GeneratedColumn<String> get profilePictureUrl => $composableBuilder(
    column: $table.profilePictureUrl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get bio =>
      $composableBuilder(column: $table.bio, builder: (column) => column);
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
                Value<String?> profilePictureUrl = const Value.absent(),
                Value<String?> bio = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserInfoSettingsCompanion(
                id: id,
                name: name,
                email: email,
                accessToken: accessToken,
                profilePictureUrl: profilePictureUrl,
                bio: bio,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String email,
                required String accessToken,
                Value<String?> profilePictureUrl = const Value.absent(),
                Value<String?> bio = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserInfoSettingsCompanion.insert(
                id: id,
                name: name,
                email: email,
                accessToken: accessToken,
                profilePictureUrl: profilePictureUrl,
                bio: bio,
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
typedef $$MessagesTableCreateCompanionBuilder =
    MessagesCompanion Function({
      required String id,
      required String chatId,
      required String senderId,
      required String message,
      Value<String> messageStatus,
      required int createdAt,
      Value<bool> isRead,
      Value<String?> serverId,
      Value<int> rowid,
    });
typedef $$MessagesTableUpdateCompanionBuilder =
    MessagesCompanion Function({
      Value<String> id,
      Value<String> chatId,
      Value<String> senderId,
      Value<String> message,
      Value<String> messageStatus,
      Value<int> createdAt,
      Value<bool> isRead,
      Value<String?> serverId,
      Value<int> rowid,
    });

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

  ColumnFilters<String> get chatId => $composableBuilder(
    column: $table.chatId,
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

  ColumnFilters<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );
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

  ColumnOrderings<String> get chatId => $composableBuilder(
    column: $table.chatId,
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

  ColumnOrderings<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );
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

  GeneratedColumn<String> get chatId =>
      $composableBuilder(column: $table.chatId, builder: (column) => column);

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

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);
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
          (Message, BaseReferences<_$AppDatabase, $MessagesTable, Message>),
          Message,
          PrefetchHooks Function()
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
                Value<String> chatId = const Value.absent(),
                Value<String> senderId = const Value.absent(),
                Value<String> message = const Value.absent(),
                Value<String> messageStatus = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<bool> isRead = const Value.absent(),
                Value<String?> serverId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MessagesCompanion(
                id: id,
                chatId: chatId,
                senderId: senderId,
                message: message,
                messageStatus: messageStatus,
                createdAt: createdAt,
                isRead: isRead,
                serverId: serverId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String chatId,
                required String senderId,
                required String message,
                Value<String> messageStatus = const Value.absent(),
                required int createdAt,
                Value<bool> isRead = const Value.absent(),
                Value<String?> serverId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MessagesCompanion.insert(
                id: id,
                chatId: chatId,
                senderId: senderId,
                message: message,
                messageStatus: messageStatus,
                createdAt: createdAt,
                isRead: isRead,
                serverId: serverId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
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
      (Message, BaseReferences<_$AppDatabase, $MessagesTable, Message>),
      Message,
      PrefetchHooks Function()
    >;
typedef $$ChatListTableTableCreateCompanionBuilder =
    ChatListTableCompanion Function({
      Value<int> id,
      required String chatId,
      required String name,
      Value<String?> lastMessage,
      Value<int?> lastMessageTime,
      Value<int> unReadCount,
      Value<String?> profilePicUrl,
      Value<bool> isDeleted,
      Value<String?> description,
      required String type,
    });
typedef $$ChatListTableTableUpdateCompanionBuilder =
    ChatListTableCompanion Function({
      Value<int> id,
      Value<String> chatId,
      Value<String> name,
      Value<String?> lastMessage,
      Value<int?> lastMessageTime,
      Value<int> unReadCount,
      Value<String?> profilePicUrl,
      Value<bool> isDeleted,
      Value<String?> description,
      Value<String> type,
    });

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

  ColumnFilters<String> get chatId => $composableBuilder(
    column: $table.chatId,
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

  ColumnFilters<String> get profilePicUrl => $composableBuilder(
    column: $table.profilePicUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );
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

  ColumnOrderings<String> get chatId => $composableBuilder(
    column: $table.chatId,
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

  ColumnOrderings<String> get profilePicUrl => $composableBuilder(
    column: $table.profilePicUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
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

  GeneratedColumn<String> get chatId =>
      $composableBuilder(column: $table.chatId, builder: (column) => column);

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

  GeneratedColumn<String> get profilePicUrl => $composableBuilder(
    column: $table.profilePicUrl,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);
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
          (
            ChatListTableData,
            BaseReferences<
              _$AppDatabase,
              $ChatListTableTable,
              ChatListTableData
            >,
          ),
          ChatListTableData,
          PrefetchHooks Function()
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
                Value<String> chatId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> lastMessage = const Value.absent(),
                Value<int?> lastMessageTime = const Value.absent(),
                Value<int> unReadCount = const Value.absent(),
                Value<String?> profilePicUrl = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String> type = const Value.absent(),
              }) => ChatListTableCompanion(
                id: id,
                chatId: chatId,
                name: name,
                lastMessage: lastMessage,
                lastMessageTime: lastMessageTime,
                unReadCount: unReadCount,
                profilePicUrl: profilePicUrl,
                isDeleted: isDeleted,
                description: description,
                type: type,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String chatId,
                required String name,
                Value<String?> lastMessage = const Value.absent(),
                Value<int?> lastMessageTime = const Value.absent(),
                Value<int> unReadCount = const Value.absent(),
                Value<String?> profilePicUrl = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<String?> description = const Value.absent(),
                required String type,
              }) => ChatListTableCompanion.insert(
                id: id,
                chatId: chatId,
                name: name,
                lastMessage: lastMessage,
                lastMessageTime: lastMessageTime,
                unReadCount: unReadCount,
                profilePicUrl: profilePicUrl,
                isDeleted: isDeleted,
                description: description,
                type: type,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
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
      (
        ChatListTableData,
        BaseReferences<_$AppDatabase, $ChatListTableTable, ChatListTableData>,
      ),
      ChatListTableData,
      PrefetchHooks Function()
    >;
typedef $$UsersTableTableCreateCompanionBuilder =
    UsersTableCompanion Function({
      required String id,
      required String name,
      required String email,
      Value<String?> profilePictureUrl,
      Value<String?> bio,
      Value<int> rowid,
    });
typedef $$UsersTableTableUpdateCompanionBuilder =
    UsersTableCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> email,
      Value<String?> profilePictureUrl,
      Value<String?> bio,
      Value<int> rowid,
    });

class $$UsersTableTableFilterComposer
    extends Composer<_$AppDatabase, $UsersTableTable> {
  $$UsersTableTableFilterComposer({
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

  ColumnFilters<String> get profilePictureUrl => $composableBuilder(
    column: $table.profilePictureUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bio => $composableBuilder(
    column: $table.bio,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UsersTableTableOrderingComposer
    extends Composer<_$AppDatabase, $UsersTableTable> {
  $$UsersTableTableOrderingComposer({
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

  ColumnOrderings<String> get profilePictureUrl => $composableBuilder(
    column: $table.profilePictureUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bio => $composableBuilder(
    column: $table.bio,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UsersTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsersTableTable> {
  $$UsersTableTableAnnotationComposer({
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

  GeneratedColumn<String> get profilePictureUrl => $composableBuilder(
    column: $table.profilePictureUrl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get bio =>
      $composableBuilder(column: $table.bio, builder: (column) => column);
}

class $$UsersTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UsersTableTable,
          UsersTableData,
          $$UsersTableTableFilterComposer,
          $$UsersTableTableOrderingComposer,
          $$UsersTableTableAnnotationComposer,
          $$UsersTableTableCreateCompanionBuilder,
          $$UsersTableTableUpdateCompanionBuilder,
          (
            UsersTableData,
            BaseReferences<_$AppDatabase, $UsersTableTable, UsersTableData>,
          ),
          UsersTableData,
          PrefetchHooks Function()
        > {
  $$UsersTableTableTableManager(_$AppDatabase db, $UsersTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsersTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsersTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> email = const Value.absent(),
                Value<String?> profilePictureUrl = const Value.absent(),
                Value<String?> bio = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UsersTableCompanion(
                id: id,
                name: name,
                email: email,
                profilePictureUrl: profilePictureUrl,
                bio: bio,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String email,
                Value<String?> profilePictureUrl = const Value.absent(),
                Value<String?> bio = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UsersTableCompanion.insert(
                id: id,
                name: name,
                email: email,
                profilePictureUrl: profilePictureUrl,
                bio: bio,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UsersTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UsersTableTable,
      UsersTableData,
      $$UsersTableTableFilterComposer,
      $$UsersTableTableOrderingComposer,
      $$UsersTableTableAnnotationComposer,
      $$UsersTableTableCreateCompanionBuilder,
      $$UsersTableTableUpdateCompanionBuilder,
      (
        UsersTableData,
        BaseReferences<_$AppDatabase, $UsersTableTable, UsersTableData>,
      ),
      UsersTableData,
      PrefetchHooks Function()
    >;
typedef $$ChatParticipantsTableCreateCompanionBuilder =
    ChatParticipantsCompanion Function({
      required String chatId,
      required String userId,
      required String name,
      Value<String?> profilePicUrl,
      Value<String> role,
      Value<int> rowid,
    });
typedef $$ChatParticipantsTableUpdateCompanionBuilder =
    ChatParticipantsCompanion Function({
      Value<String> chatId,
      Value<String> userId,
      Value<String> name,
      Value<String?> profilePicUrl,
      Value<String> role,
      Value<int> rowid,
    });

class $$ChatParticipantsTableFilterComposer
    extends Composer<_$AppDatabase, $ChatParticipantsTable> {
  $$ChatParticipantsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get chatId => $composableBuilder(
    column: $table.chatId,
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

  ColumnFilters<String> get profilePicUrl => $composableBuilder(
    column: $table.profilePicUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ChatParticipantsTableOrderingComposer
    extends Composer<_$AppDatabase, $ChatParticipantsTable> {
  $$ChatParticipantsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get chatId => $composableBuilder(
    column: $table.chatId,
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

  ColumnOrderings<String> get profilePicUrl => $composableBuilder(
    column: $table.profilePicUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ChatParticipantsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChatParticipantsTable> {
  $$ChatParticipantsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get chatId =>
      $composableBuilder(column: $table.chatId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get profilePicUrl => $composableBuilder(
    column: $table.profilePicUrl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);
}

class $$ChatParticipantsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ChatParticipantsTable,
          ChatParticipant,
          $$ChatParticipantsTableFilterComposer,
          $$ChatParticipantsTableOrderingComposer,
          $$ChatParticipantsTableAnnotationComposer,
          $$ChatParticipantsTableCreateCompanionBuilder,
          $$ChatParticipantsTableUpdateCompanionBuilder,
          (
            ChatParticipant,
            BaseReferences<
              _$AppDatabase,
              $ChatParticipantsTable,
              ChatParticipant
            >,
          ),
          ChatParticipant,
          PrefetchHooks Function()
        > {
  $$ChatParticipantsTableTableManager(
    _$AppDatabase db,
    $ChatParticipantsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChatParticipantsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChatParticipantsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChatParticipantsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> chatId = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> profilePicUrl = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChatParticipantsCompanion(
                chatId: chatId,
                userId: userId,
                name: name,
                profilePicUrl: profilePicUrl,
                role: role,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String chatId,
                required String userId,
                required String name,
                Value<String?> profilePicUrl = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChatParticipantsCompanion.insert(
                chatId: chatId,
                userId: userId,
                name: name,
                profilePicUrl: profilePicUrl,
                role: role,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ChatParticipantsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ChatParticipantsTable,
      ChatParticipant,
      $$ChatParticipantsTableFilterComposer,
      $$ChatParticipantsTableOrderingComposer,
      $$ChatParticipantsTableAnnotationComposer,
      $$ChatParticipantsTableCreateCompanionBuilder,
      $$ChatParticipantsTableUpdateCompanionBuilder,
      (
        ChatParticipant,
        BaseReferences<_$AppDatabase, $ChatParticipantsTable, ChatParticipant>,
      ),
      ChatParticipant,
      PrefetchHooks Function()
    >;
typedef $$MessageStatusTableTableCreateCompanionBuilder =
    MessageStatusTableCompanion Function({
      required String messageId,
      required String userId,
      Value<String> status,
      required int createdAt,
      required int updatedAt,
      Value<int?> deliveredAt,
      Value<int?> readAt,
      Value<int> rowid,
    });
typedef $$MessageStatusTableTableUpdateCompanionBuilder =
    MessageStatusTableCompanion Function({
      Value<String> messageId,
      Value<String> userId,
      Value<String> status,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int?> deliveredAt,
      Value<int?> readAt,
      Value<int> rowid,
    });

class $$MessageStatusTableTableFilterComposer
    extends Composer<_$AppDatabase, $MessageStatusTableTable> {
  $$MessageStatusTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get messageId => $composableBuilder(
    column: $table.messageId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deliveredAt => $composableBuilder(
    column: $table.deliveredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get readAt => $composableBuilder(
    column: $table.readAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MessageStatusTableTableOrderingComposer
    extends Composer<_$AppDatabase, $MessageStatusTableTable> {
  $$MessageStatusTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get messageId => $composableBuilder(
    column: $table.messageId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deliveredAt => $composableBuilder(
    column: $table.deliveredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get readAt => $composableBuilder(
    column: $table.readAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MessageStatusTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $MessageStatusTableTable> {
  $$MessageStatusTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get messageId =>
      $composableBuilder(column: $table.messageId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deliveredAt => $composableBuilder(
    column: $table.deliveredAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get readAt =>
      $composableBuilder(column: $table.readAt, builder: (column) => column);
}

class $$MessageStatusTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MessageStatusTableTable,
          MessageStatusTableData,
          $$MessageStatusTableTableFilterComposer,
          $$MessageStatusTableTableOrderingComposer,
          $$MessageStatusTableTableAnnotationComposer,
          $$MessageStatusTableTableCreateCompanionBuilder,
          $$MessageStatusTableTableUpdateCompanionBuilder,
          (
            MessageStatusTableData,
            BaseReferences<
              _$AppDatabase,
              $MessageStatusTableTable,
              MessageStatusTableData
            >,
          ),
          MessageStatusTableData,
          PrefetchHooks Function()
        > {
  $$MessageStatusTableTableTableManager(
    _$AppDatabase db,
    $MessageStatusTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MessageStatusTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MessageStatusTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MessageStatusTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> messageId = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deliveredAt = const Value.absent(),
                Value<int?> readAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MessageStatusTableCompanion(
                messageId: messageId,
                userId: userId,
                status: status,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deliveredAt: deliveredAt,
                readAt: readAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String messageId,
                required String userId,
                Value<String> status = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int?> deliveredAt = const Value.absent(),
                Value<int?> readAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MessageStatusTableCompanion.insert(
                messageId: messageId,
                userId: userId,
                status: status,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deliveredAt: deliveredAt,
                readAt: readAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MessageStatusTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MessageStatusTableTable,
      MessageStatusTableData,
      $$MessageStatusTableTableFilterComposer,
      $$MessageStatusTableTableOrderingComposer,
      $$MessageStatusTableTableAnnotationComposer,
      $$MessageStatusTableTableCreateCompanionBuilder,
      $$MessageStatusTableTableUpdateCompanionBuilder,
      (
        MessageStatusTableData,
        BaseReferences<
          _$AppDatabase,
          $MessageStatusTableTable,
          MessageStatusTableData
        >,
      ),
      MessageStatusTableData,
      PrefetchHooks Function()
    >;
typedef $$MediaTableTableCreateCompanionBuilder =
    MediaTableCompanion Function({
      Value<int> id,
      Value<String?> location,
      Value<String?> contentType,
      Value<String?> actorId,
      Value<String?> Type,
      Value<String?> name,
      Value<String?> key,
      Value<String?> url,
      required int createdAt,
    });
typedef $$MediaTableTableUpdateCompanionBuilder =
    MediaTableCompanion Function({
      Value<int> id,
      Value<String?> location,
      Value<String?> contentType,
      Value<String?> actorId,
      Value<String?> Type,
      Value<String?> name,
      Value<String?> key,
      Value<String?> url,
      Value<int> createdAt,
    });

class $$MediaTableTableFilterComposer
    extends Composer<_$AppDatabase, $MediaTableTable> {
  $$MediaTableTableFilterComposer({
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

  ColumnFilters<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentType => $composableBuilder(
    column: $table.contentType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get actorId => $composableBuilder(
    column: $table.actorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get Type => $composableBuilder(
    column: $table.Type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MediaTableTableOrderingComposer
    extends Composer<_$AppDatabase, $MediaTableTable> {
  $$MediaTableTableOrderingComposer({
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

  ColumnOrderings<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentType => $composableBuilder(
    column: $table.contentType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get actorId => $composableBuilder(
    column: $table.actorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get Type => $composableBuilder(
    column: $table.Type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MediaTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $MediaTableTable> {
  $$MediaTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<String> get contentType => $composableBuilder(
    column: $table.contentType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get actorId =>
      $composableBuilder(column: $table.actorId, builder: (column) => column);

  GeneratedColumn<String> get Type =>
      $composableBuilder(column: $table.Type, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$MediaTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MediaTableTable,
          MediaTableData,
          $$MediaTableTableFilterComposer,
          $$MediaTableTableOrderingComposer,
          $$MediaTableTableAnnotationComposer,
          $$MediaTableTableCreateCompanionBuilder,
          $$MediaTableTableUpdateCompanionBuilder,
          (
            MediaTableData,
            BaseReferences<_$AppDatabase, $MediaTableTable, MediaTableData>,
          ),
          MediaTableData,
          PrefetchHooks Function()
        > {
  $$MediaTableTableTableManager(_$AppDatabase db, $MediaTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MediaTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MediaTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MediaTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> location = const Value.absent(),
                Value<String?> contentType = const Value.absent(),
                Value<String?> actorId = const Value.absent(),
                Value<String?> Type = const Value.absent(),
                Value<String?> name = const Value.absent(),
                Value<String?> key = const Value.absent(),
                Value<String?> url = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
              }) => MediaTableCompanion(
                id: id,
                location: location,
                contentType: contentType,
                actorId: actorId,
                Type: Type,
                name: name,
                key: key,
                url: url,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> location = const Value.absent(),
                Value<String?> contentType = const Value.absent(),
                Value<String?> actorId = const Value.absent(),
                Value<String?> Type = const Value.absent(),
                Value<String?> name = const Value.absent(),
                Value<String?> key = const Value.absent(),
                Value<String?> url = const Value.absent(),
                required int createdAt,
              }) => MediaTableCompanion.insert(
                id: id,
                location: location,
                contentType: contentType,
                actorId: actorId,
                Type: Type,
                name: name,
                key: key,
                url: url,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MediaTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MediaTableTable,
      MediaTableData,
      $$MediaTableTableFilterComposer,
      $$MediaTableTableOrderingComposer,
      $$MediaTableTableAnnotationComposer,
      $$MediaTableTableCreateCompanionBuilder,
      $$MediaTableTableUpdateCompanionBuilder,
      (
        MediaTableData,
        BaseReferences<_$AppDatabase, $MediaTableTable, MediaTableData>,
      ),
      MediaTableData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UserInfoSettingsTableTableManager get userInfoSettings =>
      $$UserInfoSettingsTableTableManager(_db, _db.userInfoSettings);
  $$MessagesTableTableManager get messages =>
      $$MessagesTableTableManager(_db, _db.messages);
  $$ChatListTableTableTableManager get chatListTable =>
      $$ChatListTableTableTableManager(_db, _db.chatListTable);
  $$UsersTableTableTableManager get usersTable =>
      $$UsersTableTableTableManager(_db, _db.usersTable);
  $$ChatParticipantsTableTableManager get chatParticipants =>
      $$ChatParticipantsTableTableManager(_db, _db.chatParticipants);
  $$MessageStatusTableTableTableManager get messageStatusTable =>
      $$MessageStatusTableTableTableManager(_db, _db.messageStatusTable);
  $$MediaTableTableTableManager get mediaTable =>
      $$MediaTableTableTableManager(_db, _db.mediaTable);
}
