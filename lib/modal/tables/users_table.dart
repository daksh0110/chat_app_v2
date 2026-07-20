import 'package:drift/drift.dart';

class UsersTable extends Table {
  TextColumn get userId => text()();

  TextColumn get chatId => text().nullable().unique()();
  TextColumn get name => text()();
  TextColumn get email => text()();
  TextColumn get bio => text().nullable()();

  @override
  Set<Column> get primaryKey => {userId};
}
