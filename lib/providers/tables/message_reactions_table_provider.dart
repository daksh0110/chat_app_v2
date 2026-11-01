import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/core/database.dart';
import 'package:my_app/modal/message_reaction_modal.dart';
import 'package:my_app/providers/database_provider.dart';

final messageReactionsTableProvider =
    NotifierProvider<MessageReactionsTableProvider, void>(
      MessageReactionsTableProvider.new,
    );

class MessageReactionsTableProvider extends Notifier {
  @override
  build() {}

  /// Add or update a reaction locally
  Future<void> addOrUpdateReaction({
    required String messageId,
    required String chatId,
    required String userId,
    required String emoji,
    String? userName,
    int? createdAt,
  }) async {
    final db = ref.read(databaseProvider);
    final id = "${messageId}_$userId";
    final time = createdAt ?? DateTime.now().millisecondsSinceEpoch;

    await db.into(db.messageReactionsTable).insertOnConflictUpdate(
      MessageReactionsTableCompanion(
        id: Value(id),
        messageId: Value(messageId),
        chatId: Value(chatId),
        userId: Value(userId),
        userName: Value(userName),
        emoji: Value(emoji),
        createdAt: Value(time),
      ),
    );
  }

  /// Remove a user's reaction from a message
  Future<void> removeReaction({
    required String messageId,
    required String userId,
  }) async {
    final db = ref.read(databaseProvider);
    final id = "${messageId}_$userId";
    await (db.delete(db.messageReactionsTable)
          ..where((tbl) => tbl.id.equals(id)))
        .go();
  }

  /// Replace all reactions for a message with the authoritative list from server
  Future<void> syncReactionsForMessage({
    required String messageId,
    required String chatId,
    required List<ReactionGroup> reactionGroups,
  }) async {
    final db = ref.read(databaseProvider);
    final now = DateTime.now().millisecondsSinceEpoch;

    await db.transaction(() async {
      await (db.delete(db.messageReactionsTable)
            ..where((tbl) => tbl.messageId.equals(messageId)))
          .go();

      for (final group in reactionGroups) {
        for (final user in group.users) {
          final id = "${messageId}_${user.userId}";
          await db.into(db.messageReactionsTable).insertOnConflictUpdate(
            MessageReactionsTableCompanion(
              id: Value(id),
              messageId: Value(messageId),
              chatId: Value(chatId),
              userId: Value(user.userId),
              userName: Value(user.name),
              emoji: Value(group.emoji),
              createdAt: Value(now),
            ),
          );
        }
      }
    });
  }

  /// Delete all reactions for a message
  Future<void> deleteReactionsForMessage(String messageId) async {
    final db = ref.read(databaseProvider);
    await (db.delete(db.messageReactionsTable)
          ..where((tbl) => tbl.messageId.equals(messageId)))
        .go();
  }
}

