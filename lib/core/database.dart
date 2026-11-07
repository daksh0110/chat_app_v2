import 'dart:io';
import 'package:my_app/modal/tables/blocks_table.dart';
import 'package:my_app/modal/tables/chat_events_table.dart';
import 'package:my_app/modal/tables/chat_list_table.dart';
import 'package:my_app/modal/tables/chat_participant_table.dart';
import 'package:my_app/modal/tables/chat_settings_table.dart';
import 'package:my_app/modal/tables/friends_table.dart';
import 'package:my_app/modal/tables/groups_table.dart';
import 'package:my_app/modal/tables/media_modal.dart';
import 'package:my_app/modal/tables/message_status_table.dart';
import 'package:my_app/modal/tables/messages_table.dart';
import 'package:my_app/modal/tables/message_reactions_table.dart';
import 'package:my_app/modal/tables/notifications_table.dart';
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
    BlocksTable,
    NotificationsTable,
    ChatEventsTable,
    MessageReactionsTable,
    ChatSettingsTable,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 18;

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
        try {
          await m.addColumn(friendsTable, friendsTable.isRead);
        } catch (_) {}
      }
      if (from < 9) {
        await m.createTable(blocksTable);
      }
      if (from < 10) {
        await m.createTable(notificationsTable);
      }
      if (from < 11) {
        await m.createTable(chatEventsTable);
      }
      if (from < 12) {
        await _backfillChatEventsForMessages();
      }
      if (from < 13) {
        try {
          await m.addColumn(messages, messages.replyToId);
        } catch (_) {}
        try {
          await m.addColumn(messages, messages.replyToSenderName);
        } catch (_) {}
        try {
          await m.addColumn(messages, messages.replyToMessage);
        } catch (_) {}
      }
      if (from < 14) {
        await m.createTable(messageReactionsTable);
      }
      if (from < 15) {
        try {
          await m.addColumn(messages, messages.isDeleted);
        } catch (_) {}
      }
      if (from < 16) {
        try {
          await m.addColumn(userPreferencesTable, userPreferencesTable.themeMode);
        } catch (_) {}
      }
      if (from < 17) {
        try {
          await m.createTable(chatSettingsTable);
        } catch (_) {}
      }
      if (from < 18) {
        try {
          await m.addColumn(messages, messages.isEdited);
        } catch (_) {}
        try {
          await m.addColumn(messages, messages.isPinned);
        } catch (_) {}
        try {
          await m.addColumn(messages, messages.pinnedAt);
        } catch (_) {}
      }
    },

    beforeOpen: (OpeningDetails details) async {
      await _backfillChatEventsForMessages();
    },
  );

  /// Ensures all existing messages in SQLite have a corresponding row in chatEventsTable
  Future<void> _backfillChatEventsForMessages() async {
    try {
      final existingMessages = await select(messages).get();
      if (existingMessages.isEmpty) return;

      final existingEvents = await (selectOnly(
        chatEventsTable,
      )..addColumns([chatEventsTable.id, chatEventsTable.contentId])).get();

      final existingIds = <String>{};
      for (final row in existingEvents) {
        final id = row.read(chatEventsTable.id);
        final contentId = row.read(chatEventsTable.contentId);
        if (id != null) existingIds.add(id);
        if (contentId != null) existingIds.add(contentId);
      }

      final currentUserPref = await select(
        userPreferencesTable,
      ).getSingleOrNull();
      final currentUserId = currentUserPref?.userId;

      final missing = existingMessages.where(
        (m) =>
            !existingIds.contains(m.id) &&
            (m.serverId == null || !existingIds.contains(m.serverId)),
      );

      if (missing.isEmpty) return;

      await batch((b) {
        for (final msg in missing) {
          final timestamp = msg.serverCreatedAt ?? msg.createdAt;
          final isSender =
              currentUserId != null && msg.senderId == currentUserId;
          b.insert(
            chatEventsTable,
            ChatEventsTableCompanion(
              id: Value(msg.id),
              chatId: Value(msg.chatId),
              type: const Value(ChatEventType.message),
              contentId: Value(msg.serverId ?? msg.id),
              alignment: Value(
                isSender ? ChatEventAlignment.right : ChatEventAlignment.left,
              ),
              createdAt: Value(DateTime.fromMillisecondsSinceEpoch(timestamp)),
            ),
            mode: InsertMode.insertOrIgnore,
          );
        }
      });
    } catch (_) {}
  }

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
        batch.deleteAll(blocksTable);
        batch.deleteAll(notificationsTable);
        batch.deleteAll(chatEventsTable);
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
