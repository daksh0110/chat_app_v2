import 'package:drift/drift.dart';

class UsersTable extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get email => text()();
  TextColumn get profilePictureUrl => text().nullable()();
  TextColumn get bio => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
