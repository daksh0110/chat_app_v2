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

  @override
  Set<Column> get primaryKey => {id};
}
