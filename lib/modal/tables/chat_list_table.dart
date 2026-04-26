import 'package:drift/drift.dart';

class ChatListTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get chatId => text().unique()();
  TextColumn get name => text()();
  TextColumn get lastMessage => text().nullable()();
  IntColumn get lastMessageTime => integer().nullable()();
  IntColumn get unReadCount => integer().withDefault(const Constant(0))();
  TextColumn get profilePicUrl => text().nullable()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  TextColumn get type => text()();
}
