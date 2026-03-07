import 'package:drift/drift.dart';

class ChatListTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get userId => text()();
  TextColumn get name => text()();
  TextColumn get lastMessage => text().nullable()();
  IntColumn get lastMessageTime => integer().nullable()();
  IntColumn get unReadCount => integer().withDefault(const Constant(0))();
}
