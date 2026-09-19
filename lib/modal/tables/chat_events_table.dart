import 'package:drift/drift.dart';

enum ChatEventType { message, banner }

enum ChatEventAlignment { left, center, right }

class ChatEventsTable extends Table {
  TextColumn get id => text()();

  TextColumn get chatId => text()();

  TextColumn get type => textEnum<ChatEventType>()();

  TextColumn get contentId => text()();

  TextColumn get alignment => textEnum<ChatEventAlignment>()();

  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
