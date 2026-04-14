import 'package:drift/drift.dart';

class UserInfoSettings extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 4, max: 32)();
  TextColumn get email => text()();
  TextColumn get accessToken => text()();
  TextColumn get profilePictureUrl => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
