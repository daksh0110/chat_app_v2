import 'package:drift/drift.dart';

class ChatListTable extends Table {
  TextColumn get chatId => text()();
  TextColumn get lastMessage => text().nullable()();
  IntColumn get lastMessageTime => integer().nullable()();
  IntColumn get unReadCount => integer().withDefault(const Constant(0))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  TextColumn get type => text()();

  Set<Column> get primaryKey => {chatId};
}
