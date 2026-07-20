import 'package:drift/drift.dart';

class GroupListTable extends Table {
  TextColumn get chatId => text()();
  TextColumn get name => text()();
  TextColumn get bio => text().nullable()();

  @override
  Set<Column> get primaryKey => {chatId};
}
