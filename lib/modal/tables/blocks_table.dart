import 'package:drift/drift.dart';

class BlocksTable extends Table {
  TextColumn get userId => text()();
  DateTimeColumn get createdAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {userId};
}
