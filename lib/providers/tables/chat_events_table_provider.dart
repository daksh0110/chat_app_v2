import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/core/database.dart';
import 'package:my_app/modal/chat_event_model.dart';
import 'package:my_app/providers/database_provider.dart';

final chatEventsTableProvider = NotifierProvider<ChatEventsTableProvider, void>(
  ChatEventsTableProvider.new,
);

class ChatEventsTableProvider extends Notifier<void> {
  @override
  void build() {}

  Future<void> createOrUpdateChatEvent(ChatEventModel event) async {
    final db = ref.read(databaseProvider);

    await db
        .into(db.chatEventsTable)
        .insertOnConflictUpdate(
          ChatEventsTableCompanion(
            id: Value(event.id),
            chatId: Value(event.chatId),
            type: Value(event.type),
            contentId: Value(event.contentId),
            alignment: Value(event.alignment),
            createdAt: Value(event.createdAt),
          ),
        );
  }

  Future<List<ChatEventModel>> getChatEvents(String chatId) async {
    final db = ref.read(databaseProvider);
    final rows =
        await (db.select(db.chatEventsTable)
              ..where((table) => table.chatId.equals(chatId))
              ..orderBy([(table) => OrderingTerm.asc(table.createdAt)]))
            .get();

    return rows.map(_toModel).toList();
  }

  Stream<List<ChatEventModel>> watchChatEvents(String chatId) {
    final db = ref.read(databaseProvider);

    return (db.select(db.chatEventsTable)
          ..where((table) => table.chatId.equals(chatId))
          ..orderBy([(table) => OrderingTerm.asc(table.createdAt)]))
        .watch()
        .map((rows) => rows.map(_toModel).toList());
  }

  Future<void> deleteChatEvent(String eventId) async {
    final db = ref.read(databaseProvider);
    await (db.delete(
      db.chatEventsTable,
    )..where((table) => table.id.equals(eventId))).go();
  }

  ChatEventModel _toModel(ChatEventsTableData row) {
    return ChatEventModel(
      id: row.id,
      chatId: row.chatId,
      type: row.type,
      contentId: row.contentId,
      alignment: row.alignment,
      createdAt: row.createdAt,
    );
  }
}
