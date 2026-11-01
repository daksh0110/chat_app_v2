import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/modal/message_reaction_modal.dart';
import 'package:my_app/providers/database_provider.dart';
import 'package:my_app/providers/tables/user_preference_table_provider.dart';

/// Streams a map of messageId to `List<ReactionGroup>` for all messages in a chat.
final chatReactionsProvider = StreamProvider.family<
    Map<String, List<ReactionGroup>>, String>((ref, chatId) {
  final db = ref.watch(databaseProvider);
  final currentUserId = ref.watch(userPreferenceTableProvider).value;

  final query = db.select(db.messageReactionsTable)
    ..where((tbl) => tbl.chatId.equals(chatId))
    ..orderBy([(tbl) => OrderingTerm.asc(tbl.createdAt)]);

  return query.watch().map((rows) {
    final Map<String, Map<String, List<ReactionUser>>> messageEmojiMap = {};

    for (final row in rows) {
      messageEmojiMap
          .putIfAbsent(row.messageId, () => {})
          .putIfAbsent(row.emoji, () => [])
          .add(ReactionUser(userId: row.userId, name: row.userName ?? ''));
    }

    final Map<String, List<ReactionGroup>> result = {};
    for (final entry in messageEmojiMap.entries) {
      final messageId = entry.key;
      final emojiMap = entry.value;
      result[messageId] = emojiMap.entries.map((e) {
        final hasReacted =
            currentUserId != null && e.value.any((u) => u.userId == currentUserId);
        return ReactionGroup(
          emoji: e.key,
          count: e.value.length,
          users: e.value,
          hasReactedByMe: hasReacted,
        );
      }).toList();
    }

    return result;
  });
});

