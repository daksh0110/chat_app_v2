import 'package:drift/drift.dart';

class RecentSearchesTable extends Table {
  TextColumn get actorId => text()();
  IntColumn get searchedAt => integer()();
  TextColumn get actorType => text()();

  @override
  Set<Column> get primaryKey => {actorId};
}
