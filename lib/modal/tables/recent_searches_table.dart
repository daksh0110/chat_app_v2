import 'package:drift/drift.dart';

class RecentSearchesTable extends Table {
  TextColumn get userId => text()();
  TextColumn get name => text()();
  TextColumn get email => text().withDefault(const Constant(''))();
  TextColumn get profilePicUrl => text().nullable()();
  IntColumn get searchedAt => integer()();

  @override
  Set<Column> get primaryKey => {userId};
}
