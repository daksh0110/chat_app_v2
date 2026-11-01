import 'package:drift/drift.dart';

class MessageReactionsTable extends Table {
  TextColumn get id => text()();
  TextColumn get messageId => text()();
  TextColumn get chatId => text()();
  TextColumn get userId => text()();
  TextColumn get userName => text().nullable()();
  TextColumn get emoji => text()();
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

