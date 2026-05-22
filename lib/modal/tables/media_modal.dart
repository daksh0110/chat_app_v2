import 'package:drift/drift.dart';

class MediaTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get location => text().nullable()();
  TextColumn get contentType => text().nullable()();
  TextColumn get actorId => text().nullable()();
  TextColumn get Type => text().nullable()();
  TextColumn get name => text().nullable()();
  TextColumn get key => text().nullable()();
  TextColumn get url => text().nullable()();
  IntColumn get createdAt => integer()();
}
