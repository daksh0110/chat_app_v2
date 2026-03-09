import 'package:drift/drift.dart';
import 'chat_list_table.dart';

class Messages extends Table {
  TextColumn get id => text()();
  IntColumn get chatId =>
      integer().references(ChatListTable, #id, onDelete: KeyAction.cascade)();
  TextColumn get senderId => text()();
  TextColumn get receiverId => text()();
  TextColumn get message => text()();
  IntColumn get createdAt => integer()();
  BoolColumn get isRead => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
