import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/core/database.dart';
import 'package:my_app/modal/screens/message/message_body_request.dart';
import 'package:my_app/modal/tables/chat_events_table.dart';
import 'package:my_app/modal/user_profile_modal.dart';
import 'package:my_app/providers/database_provider.dart';
import 'package:my_app/providers/tables/chat_list_table_provider.dart';
import 'package:my_app/providers/tables/user_preference_table_provider.dart';

final messagesTableProvider = NotifierProvider<MessagesTableProvider, void>(
  MessagesTableProvider.new,
);

class MessagesTableProvider extends Notifier {
  @override
  build() {}

  Future<void> createTempMessage(MessageBodyRequest messageBody) async {
    final db = ref.read(databaseProvider);
    final now = DateTime.now().millisecondsSinceEpoch;
    await db
        .into(db.messages)
        .insert(
          MessagesCompanion(
            chatId: Value(messageBody.chatId ?? ""),
            createdAt: Value(now),
            id: Value(messageBody.tempId ?? ""),
            isRead: Value(messageBody.isRead),
            message: Value(messageBody.message ?? ""),
            senderId: Value(messageBody.senderId ?? ""),
            replyToId: Value(messageBody.replyToId),
            replyToSenderName: Value(messageBody.replyToSenderName),
            replyToMessage: Value(messageBody.replyToMessage),
          ),
        );
  }

  Future<void> updateTempMessage(
    MessageBodyRequest messageBody,
    String newId,
  ) async {
    final db = ref.read(databaseProvider);

    final existingTempMessage =
        await (db.select(db.messages)
              ..where((tbl) => tbl.id.equals(messageBody.tempId ?? "")))
            .getSingleOrNull();
    if (existingTempMessage != null) {
      await (db.update(
        db.messages,
      )..where((tbl) => tbl.id.equals(messageBody.tempId ?? ""))).write(
        MessagesCompanion(
          id: Value(newId),
          serverId: Value(newId),
          chatId: Value(messageBody.chatId ?? existingTempMessage.chatId),
        ),
      );
    }
  }

  Future<void> createOrUpdateMessage(MessageBodyRequest messageRequest) async {
    final db = ref.read(databaseProvider);
    try {
      await db
          .into(db.messages)
          .insertOnConflictUpdate(
            MessagesCompanion(
              chatId: Value(messageRequest.chatId ?? ""),
              id: Value(messageRequest.messageId ?? ""),
              createdAt: Value(messageRequest.createdAt),
              isRead: Value(messageRequest.isRead),
              message: Value(messageRequest.message ?? ""),
              senderId: Value(messageRequest.senderId ?? ""),
              serverCreatedAt: Value(messageRequest.serverCreatedAt),
              replyToId: Value(messageRequest.replyToId),
              replyToSenderName: Value(messageRequest.replyToSenderName),
              replyToMessage: Value(messageRequest.replyToMessage),
            ),
          );

      final msgId = messageRequest.messageId ?? messageRequest.tempId;
      if (msgId != null && msgId.isNotEmpty) {
        final timestamp =
            messageRequest.serverCreatedAt ?? messageRequest.createdAt;
        final eventTime = DateTime.fromMillisecondsSinceEpoch(timestamp);

        await db
            .into(db.chatEventsTable)
            .insertOnConflictUpdate(
              ChatEventsTableCompanion(
                id: Value(msgId),
                chatId: Value(messageRequest.chatId ?? ""),
                type: const Value(ChatEventType.message),
                contentId: Value(msgId),
                alignment: const Value(ChatEventAlignment.left),
                createdAt: Value(eventTime),
              ),
            );
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<({List<MediaShared> media, int count})> fetchMessagesImages({
    required String chatId,
    int limit = 4,
  }) async {
    final db = ref.read(databaseProvider);

    final rows =
        await (db.select(db.messages)
              ..where((tbl) => tbl.chatId.equals(chatId))
              ..orderBy([
                (tbl) => OrderingTerm(
                  expression: tbl.createdAt,
                  mode: OrderingMode.desc,
                ),
              ]))
            .join([
              leftOuterJoin(
                db.mediaTable,
                db.mediaTable.actorId.equalsExp(db.messages.id) |
                    db.mediaTable.actorId.equalsExp(db.messages.serverId),
              ),
              leftOuterJoin(
                db.usersTable,
                db.usersTable.userId.equalsExp(db.messages.senderId),
              ),
            ])
            .get();

    final media = rows
        .map((row) {
          final mediaRow = row.readTableOrNull(db.mediaTable);
          final user = row.readTableOrNull(db.usersTable);
          if (mediaRow == null) return null;

          return MediaShared(
            key: mediaRow.key ?? "",
            contentType: mediaRow.contentType ?? "",
            type: mediaRow.Type ?? "",
            name: mediaRow.name ?? "",
            location: mediaRow.location,
            actorId: mediaRow.actorId,
            userId: user?.userId ?? "",
            userName: user?.name ?? "",
          );
        })
        .whereType<MediaShared>()
        .toList();

    return (media: media.take(limit).toList(), count: media.length);
  }

  Future<int> unreadCount(String chatId) async {
    final db = ref.read(databaseProvider);
    final currentUser = ref.read(userPreferenceTableProvider).value;
    final messages =
        await (db.select(db.messages)..where(
              (tbl) =>
                  tbl.chatId.equals(chatId) &
                  tbl.isRead.equals(false) &
                  (currentUser != null
                      ? tbl.senderId.isNotValue(currentUser)
                      : const Constant(true)),
            ))
            .get();

    return messages.length;
  }

  /// Mark message deleted for everyone (tombstone)
  Future<void> markMessageAsDeleted(String messageId, String chatId) async {
    final db = ref.read(databaseProvider);

    await db.transaction(() async {
      await (db.update(db.messages)..where(
            (tbl) => tbl.id.equals(messageId) | tbl.serverId.equals(messageId),
          ))
          .write(
            const MessagesCompanion(
              message: Value('This message was deleted'),
              isDeleted: Value(true),
              replyToId: Value(null),
              replyToSenderName: Value(null),
              replyToMessage: Value(null),
            ),
          );

      // Remove attachments & reactions associated with the deleted message
      await (db.delete(
        db.mediaTable,
      )..where((tbl) => tbl.actorId.equals(messageId))).go();

      await (db.delete(
        db.messageReactionsTable,
      )..where((tbl) => tbl.messageId.equals(messageId))).go();

      await updateChatLastMessageAfterDeletion(chatId);
    });
  }

  /// Delete message permanently for me (removes row from SQLite)
  Future<void> deleteMessagePermanently(String messageId, String chatId) async {
    final db = ref.read(databaseProvider);

    await db.transaction(() async {
      await (db.delete(db.messages)..where(
            (tbl) => tbl.id.equals(messageId) | tbl.serverId.equals(messageId),
          ))
          .go();

      await (db.delete(db.chatEventsTable)..where(
            (tbl) => tbl.id.equals(messageId) | tbl.contentId.equals(messageId),
          ))
          .go();

      await (db.delete(
        db.mediaTable,
      )..where((tbl) => tbl.actorId.equals(messageId))).go();

      await (db.delete(
        db.messageStatusTable,
      )..where((tbl) => tbl.messageId.equals(messageId))).go();

      await (db.delete(
        db.messageReactionsTable,
      )..where((tbl) => tbl.messageId.equals(messageId))).go();

      await updateChatLastMessageAfterDeletion(chatId);
    });
  }

  /// Updates the chat list card preview with the newest remaining message
  Future<void> updateChatLastMessageAfterDeletion(String chatId) async {
    final db = ref.read(databaseProvider);

    final newestMessage =
        await (db.select(db.messages)
              ..where((tbl) => tbl.chatId.equals(chatId))
              ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)])
              ..limit(1))
            .getSingleOrNull();

    if (newestMessage != null) {
      final preview = newestMessage.isDeleted
          ? 'This message was deleted'
          : (newestMessage.message.isNotEmpty
                ? newestMessage.message
                : 'Media');
      await (db.update(
        db.chatListTable,
      )..where((tbl) => tbl.chatId.equals(chatId))).write(
        ChatListTableCompanion(
          lastMessage: Value(preview),
          lastMessageTime: Value(newestMessage.createdAt),
        ),
      );
    } else {
      await (db.update(db.chatListTable)
            ..where((tbl) => tbl.chatId.equals(chatId)))
          .write(const ChatListTableCompanion(lastMessage: Value('')));
    }
  }

  Future<void> editMessageContent(String messageId, String newText) async {
    final db = ref.read(databaseProvider);
    await (db.update(db.messages)..where(
          (tbl) => tbl.id.equals(messageId) | tbl.serverId.equals(messageId),
        ))
        .write(
          MessagesCompanion(
            message: Value(newText),
            isEdited: const Value(true),
          ),
        );

    final msg =
        await (db.select(db.messages)..where(
              (tbl) =>
                  tbl.id.equals(messageId) | tbl.serverId.equals(messageId),
            ))
            .getSingleOrNull();
    if (msg != null) {
      await ref
          .read(chatListTableProvider.notifier)
          .updateLastMessage(chatId: msg.chatId, lastMessage: newText);
    }
  }

  Future<void> togglePinMessage(String messageId, bool isPinned) async {
    final db = ref.read(databaseProvider);
    final now = DateTime.now().millisecondsSinceEpoch;
    await (db.update(db.messages)..where(
          (tbl) => tbl.id.equals(messageId) | tbl.serverId.equals(messageId),
        ))
        .write(
          MessagesCompanion(
            isPinned: Value(isPinned),
            pinnedAt: Value(isPinned ? now : null),
          ),
        );
  }
}

final pinnedMessagesProvider = StreamProvider.family<List<Message>, String>((
  ref,
  chatId,
) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.messages)
        ..where(
          (tbl) =>
              tbl.chatId.equals(chatId) &
              tbl.isPinned.equals(true) &
              tbl.isDeleted.equals(false),
        )
        ..orderBy([(tbl) => OrderingTerm.desc(tbl.pinnedAt)]))
      .watch();
});
