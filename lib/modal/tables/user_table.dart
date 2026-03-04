import 'package:drift/drift.dart';

class UserInfoSettings extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text().withLength(min: 6, max: 32)();
  TextColumn get email => text()();
  TextColumn get accessToken => text()();

  @override
  Set<Column> get primaryKey => {id};
}
