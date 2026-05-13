import 'package:drift/drift.dart';

class MessageStatusTable extends Table {
  TextColumn get messageId => text()();
  TextColumn get userId => text()();
  TextColumn get status => text().withDefault(const Constant("sending"))();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  IntColumn get deliveredAt => integer().nullable()();
  IntColumn get readAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {messageId, userId};
}
