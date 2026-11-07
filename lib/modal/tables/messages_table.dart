import 'package:drift/drift.dart';

class Messages extends Table {
  TextColumn get id => text()();
  TextColumn get chatId => text()();
  TextColumn get senderId => text()();
  TextColumn get message => text()();
  IntColumn get createdAt => integer()();
  IntColumn get serverCreatedAt => integer().nullable()();
  BoolColumn get isRead => boolean().withDefault(const Constant(false))();
  TextColumn get serverId => text().nullable()();
  TextColumn get replyToId => text().nullable()();
  TextColumn get replyToSenderName => text().nullable()();
  TextColumn get replyToMessage => text().nullable()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isEdited => boolean().withDefault(const Constant(false))();
  BoolColumn get isPinned => boolean().withDefault(const Constant(false))();
  IntColumn get pinnedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
