import 'dart:io';
import 'package:my_app/modal/tables/chat_list_table.dart';
import 'package:my_app/modal/tables/chat_participant_table.dart';
import 'package:my_app/modal/tables/messages_table.dart';
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
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async {
        await m.createAll();
      },
      onUpgrade: (m, from, to) async {
        if (from < 2) {
          // Simplest migration for dev: delete and recreate all tables
          for (final table in allTables) {
            await m.deleteTable(table.actualTableName);
            await m.createTable(table);
          }
        }
      },
    );
  }
}


LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'app.sqlite'));
    return NativeDatabase(file);
  });
}
