import 'dart:io';
import 'package:my_app/modal/tables/chat_list_table.dart';
import 'package:my_app/modal/tables/chat_participant_table.dart';
import 'package:my_app/modal/tables/media_modal.dart';
import 'package:my_app/modal/tables/message_status_table.dart';
import 'package:my_app/data/daos/recent_searches_dao.dart';
import 'package:my_app/modal/tables/messages_table.dart';
import 'package:my_app/modal/tables/recent_searches_table.dart';
import 'package:my_app/modal/tables/user_table.dart';
import 'package:my_app/modal/tables/users_table.dart';
import 'package:path/path.dart' as p;
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [
    UserInfoSettings,
    Messages,
    ChatListTable,
    UsersTable,
    ChatParticipants,
    MessageStatusTable,
    MediaTable,
    RecentSearchesTable,
  ],
  daos: [RecentSearchesDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async {
        await m.createAll();
      },
      onUpgrade: (m, from, to) async {
        if (from < 5) {
          // Simplest migration for dev: delete and recreate all tables
          for (final table in allTables) {
            await m.createTable(table);
          }
        }
      },
    );
  }

  // --- Queries ---
  Stream<List<UsersTableData>> getAllUsers() {
    return select(usersTable).watch();
  }

  // --- Recent Searches ---

}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'app.sqlite'));
    return NativeDatabase(file);
  });
}
