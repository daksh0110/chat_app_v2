import 'package:drift/drift.dart';

class ChatTimelineEvents extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get chatId => text()();
  TextColumn get type => text()();
  TextColumn get contentId => text()();
  TextColumn get senderId => text()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
}
