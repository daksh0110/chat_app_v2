import 'package:drift/drift.dart';

class ChatParticipants extends Table {
  TextColumn get chatId => text()();
  TextColumn get userId => text()();
  TextColumn get name => text()();
  TextColumn get profilePicUrl => text().nullable()();
  TextColumn get role => text().withDefault(const Constant("MEMBER"))();

  @override
  Set<Column> get primaryKey => {chatId, userId};
}
