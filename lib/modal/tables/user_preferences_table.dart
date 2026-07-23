import 'package:drift/drift.dart';

class UserPreferencesTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get userId => text().unique()();
  TextColumn get accessToken => text().nullable()();
}
