import 'package:drift/drift.dart';

class FriendsTable extends Table {
  TextColumn get userId => text()();
  TextColumn get status => text()();

  BoolColumn get isRead => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {userId};
}
