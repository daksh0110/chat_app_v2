import 'package:drift/drift.dart';

class Messages extends Table {
  TextColumn get id => text()();
  TextColumn get chatId => text()();
  TextColumn get senderId => text()();
  TextColumn get message => text()();
  TextColumn get messageStatus =>
      text().withDefault(const Constant("sending"))();
  IntColumn get createdAt => integer()();
  BoolColumn get isRead => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
