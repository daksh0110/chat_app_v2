import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/core/database.dart';
import 'package:my_app/modal/chat_event_model.dart';
import 'package:my_app/modal/tables/chat_events_table.dart';
import 'package:my_app/providers/database_provider.dart';
import 'package:uuid/uuid.dart';

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

  Future<void> insertBannerEvent({
    required String chatId,
    required String text,
    String? id,
    ChatEventAlignment alignment = ChatEventAlignment.center,
    DateTime? createdAt,
  }) async {
    final db = ref.read(databaseProvider);
    final time = createdAt ?? DateTime.now();

    // Deduplication check: if id is not explicitly specified, check if an identical
    // banner event was already inserted recently for this chat (within last 5 seconds)
    if (id == null) {
      final recentDuplicate = await (db.select(db.chatEventsTable)
            ..where((tbl) =>
                tbl.chatId.equals(chatId) &
                tbl.type.equalsValue(ChatEventType.banner) &
                tbl.contentId.equals(text))
            ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)])
            ..limit(1))
          .getSingleOrNull();

      if (recentDuplicate != null) {
        final diff = time.difference(recentDuplicate.createdAt).abs();
        if (diff.inSeconds < 5) {
          return;
        }
      }
    }

    final eventId = id ?? const Uuid().v4();

    await db
        .into(db.chatEventsTable)
        .insertOnConflictUpdate(
          ChatEventsTableCompanion(
            id: Value(eventId),
            chatId: Value(chatId),
            type: const Value(ChatEventType.banner),
            contentId: Value(text),
            alignment: Value(alignment),
            createdAt: Value(time),
          ),
        );
  }

  Future<void> insertFriendAddedEvent({
    required String chatId,
    required String friendName,
    DateTime? createdAt,
  }) async {
    final text = friendName.isNotEmpty
        ? "You and $friendName are now friends"
        : "You are now friends";
    await insertBannerEvent(
      chatId: chatId,
      text: text,
      createdAt: createdAt,
    );
  }

  Future<void> insertUserBlockedEvent({
    required String chatId,
    DateTime? createdAt,
  }) async {
    await insertBannerEvent(
      chatId: chatId,
      text: "You blocked this contact",
      createdAt: createdAt,
    );
  }

  Future<void> insertUserUnblockedEvent({
    required String chatId,
    DateTime? createdAt,
  }) async {
    await insertBannerEvent(
      chatId: chatId,
      text: "You unblocked this contact",
      createdAt: createdAt,
    );
  }

  Future<void> insertGroupMemberAddedEvent({
    required String chatId,
    required String actorName,
    required String memberName,
    bool isSelf = false,
    bool isActorSelf = false,
    String? eventId,
    int? sequence,
    DateTime? createdAt,
  }) async {
    String text;
    if (isSelf) {
      text = actorName.isNotEmpty
          ? "$actorName added you"
          : "You were added to the group";
    } else if (isActorSelf) {
      text = "You added $memberName";
    } else {
      text = "$actorName added $memberName";
    }
    final deterministicId = eventId ??
        (sequence != null ? "event_added_${chatId}_$sequence" : null);
    await insertBannerEvent(
      chatId: chatId,
      id: deterministicId,
      text: text,
      createdAt: createdAt,
    );
  }

  Future<void> insertGroupMemberRemovedEvent({
    required String chatId,
    required String actorName,
    required String memberName,
    bool isSelf = false,
    bool isActorSelf = false,
    String? eventId,
    int? sequence,
    DateTime? createdAt,
  }) async {
    String text;
    if (isSelf) {
      text = actorName.isNotEmpty
          ? "$actorName removed you"
          : "You were removed from the group";
    } else if (isActorSelf) {
      text = "You removed $memberName";
    } else {
      text = "$actorName removed $memberName";
    }
    final deterministicId = eventId ??
        (sequence != null ? "event_removed_${chatId}_$sequence" : null);
    await insertBannerEvent(
      chatId: chatId,
      id: deterministicId,
      text: text,
      createdAt: createdAt,
    );
  }

  Future<void> insertGroupMemberLeftEvent({
    required String chatId,
    required String memberName,
    bool isSelf = false,
    String? eventId,
    int? sequence,
    DateTime? createdAt,
  }) async {
    final text = isSelf ? "You left the group" : "$memberName left the group";
    final deterministicId = eventId ??
        (sequence != null ? "event_left_${chatId}_$sequence" : null);
    await insertBannerEvent(
      chatId: chatId,
      id: deterministicId,
      text: text,
      createdAt: createdAt,
    );
  }

  Future<void> insertGroupMemberRoleUpdatedEvent({
    required String chatId,
    required String actorName,
    required String memberName,
    required String role,
    bool isSelf = false,
    bool isActorSelf = false,
    String? eventId,
    int? sequence,
    DateTime? createdAt,
  }) async {
    String text;
    if (role == "ADMIN") {
      if (isSelf) {
        text = "You are now an admin";
      } else if (isActorSelf) {
        text = "You made $memberName an admin";
      } else {
        text = "$actorName made $memberName an admin";
      }
    } else {
      if (isSelf) {
        text = "You are no longer an admin";
      } else if (isActorSelf) {
        text = "You dismissed $memberName as admin";
      } else {
        text = "$actorName dismissed $memberName as admin";
      }
    }
    final deterministicId = eventId ??
        (sequence != null ? "event_role_${chatId}_$sequence" : null);
    await insertBannerEvent(
      chatId: chatId,
      id: deterministicId,
      text: text,
      createdAt: createdAt,
    );
  }

  Future<void> updateChatId(String oldChatId, String newChatId) async {
    final db = ref.read(databaseProvider);
    await (db.update(db.chatEventsTable)
          ..where((table) => table.chatId.equals(oldChatId)))
        .write(ChatEventsTableCompanion(chatId: Value(newChatId)));
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

  Stream<List<ChatEventsTableData>> watchBannerEvents(
    String chatId, {
    String? fallbackChatId,
  }) {
    final db = ref.read(databaseProvider);

    final query = db.select(db.chatEventsTable)
      ..where((table) {
        final chatFilter = fallbackChatId != null && fallbackChatId.isNotEmpty
            ? table.chatId.equals(chatId) | table.chatId.equals(fallbackChatId)
            : table.chatId.equals(chatId);
        return chatFilter & table.type.equalsValue(ChatEventType.banner);
      })
      ..orderBy([(table) => OrderingTerm.asc(table.createdAt)]);

    return query.watch();
  }

  Future<List<ChatEventsTableData>> getBannerEvents(String chatId) async {
    final db = ref.read(databaseProvider);
    return (db.select(db.chatEventsTable)
          ..where(
            (table) =>
                table.chatId.equals(chatId) &
                table.type.equalsValue(ChatEventType.banner),
          )
          ..orderBy([(table) => OrderingTerm.asc(table.createdAt)]))
        .get();
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
