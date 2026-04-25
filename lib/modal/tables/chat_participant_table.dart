import 'package:drift/drift.dart';

class ChatParticipants extends Table {
  TextColumn get chatId => text()();
  TextColumn get userId => text()();
  TextColumn get name => text()();
  TextColumn get profilePic => text().nullable()();

  @override
  Set<Column> get primaryKey => {chatId, userId};
}
