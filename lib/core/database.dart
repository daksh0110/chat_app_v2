import 'dart:io';
import 'package:my_app/modal/tables/chat_list_table.dart';
import 'package:my_app/modal/tables/chat_participant_table.dart';
import 'package:my_app/modal/tables/friends_table.dart';
import 'package:my_app/modal/tables/groups_table.dart';
import 'package:my_app/modal/tables/media_modal.dart';
import 'package:my_app/modal/tables/message_status_table.dart';
import 'package:my_app/modal/tables/messages_table.dart';
import 'package:my_app/modal/tables/recent_searches_table.dart';
import 'package:my_app/modal/tables/user_preferences_table.dart';
import 'package:my_app/modal/tables/users_table.dart';
import 'package:path/path.dart' as p;
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [
    Messages,
    ChatListTable,
    UsersTable,
    ChatParticipants,
    MessageStatusTable,
    MediaTable,
    RecentSearchesTable,
    UserPreferencesTable,
    GroupListTable,
    FriendsTable,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 8;

  // --- Queries ---
  // Stream<List<UsersTableData>> getAllUsers() {
  //   return select(usersTable).watch();
  // }

  // --- Recent Searches ---

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },

    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 7) {
        await m.createTable(friendsTable);
      }
      if (from < 8) {
        await m.addColumn(friendsTable, friendsTable.isRead);
      }
    },
  );

  Future<void> clearAllData() async {
    await transaction(() async {
      await batch((batch) {
        batch.deleteAll(messages);
        batch.deleteAll(chatListTable);
        batch.deleteAll(usersTable);
        batch.deleteAll(chatParticipants);
        batch.deleteAll(messageStatusTable);
        batch.deleteAll(mediaTable);
        batch.deleteAll(recentSearchesTable);
        batch.deleteAll(userPreferencesTable);
        batch.deleteAll(groupListTable);
        batch.deleteAll(friendsTable);
      });
    });
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'app.sqlite'));
    return NativeDatabase(file);
  });
}
