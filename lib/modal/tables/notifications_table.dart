import 'package:drift/drift.dart';

class NotificationsTable extends Table {
  TextColumn get id => text()();

  TextColumn get recipientId => text()();

  TextColumn get actorId => text().nullable()();

  TextColumn get type => text()();

  TextColumn get entityId => text().nullable()();

  TextColumn get entityType => text().nullable()();

  BoolColumn get isRead => boolean().withDefault(const Constant(false))();

  DateTimeColumn get readAt => dateTime().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
