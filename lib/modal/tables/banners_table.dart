import 'package:drift/drift.dart';

class Banners extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get chatId => integer()();

  TextColumn get type => text()();

  IntColumn get actorId => integer()();

  IntColumn get targetUserId => integer().nullable()();

  DateTimeColumn get createdAt => dateTime()();
}
