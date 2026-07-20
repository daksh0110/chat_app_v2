import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/modal/screens/message/message_screen_data.dart';
import 'package:my_app/providers/database_provider.dart';
import 'package:my_app/providers/tables/chat_list_table_provider.dart';
import 'package:my_app/providers/tables/user_preference_table_provider.dart';
import 'package:drift/drift.dart';

final messageScreenProvider = NotifierProvider<MessageScreenProvider, void>(
  MessageScreenProvider.new,
);
final messageScreenFromChatProvider =
    FutureProvider.family<MessageScreenData?, String>((ref, chatId) {
      return ref
          .read(messageScreenProvider.notifier)
          .fetchChatDetailsFromChatId(chatId);
    });

final messageScreenFromReceiverProvider =
    FutureProvider.family<MessageScreenData?, String>((ref, receiverId) {
      return ref
          .read(messageScreenProvider.notifier)
          .fetchChatDetailsFromReceiverId(receiverId);
    });

class MessageScreenProvider extends Notifier {
  @override
  build() {}

  Future<MessageScreenData?> fetchChatDetailsFromChatId(String chatId) async {
    final chatDetails = await ref
        .read(chatListTableProvider.notifier)
        .fetchChatDetailsFromChatId(chatId);

    return chatDetails != null ? MessageScreenData.fromChat(chatDetails) : null;
  }

  Future<MessageScreenData?> fetchChatDetailsFromReceiverId(
    String receiverId,
  ) async {
    final db = ref.read(databaseProvider);
    final currentUser = ref.watch(userPreferenceTableProvider).value;

    if (currentUser == null) {
      return null;
    }

    final participants =
        await (db.select(db.chatParticipants)..where(
              (tbl) =>
                  tbl.userId.equals(currentUser) |
                  tbl.userId.equals(receiverId),
            ))
            .get();

    final Map<String, List<String>> chats = {};

    for (final participant in participants) {
      chats.putIfAbsent(participant.chatId, () => []);
      chats[participant.chatId]!.add(participant.userId);
    }

    for (final entry in chats.entries) {
      final users = entry.value;

      if (!users.contains(currentUser) || !users.contains(receiverId)) {
        continue;
      }

      final chat = await (db.select(
        db.chatListTable,
      )..where((tbl) => tbl.chatId.equals(entry.key))).getSingleOrNull();

      if (chat != null && chat.type == "DIRECT") {
        return fetchChatDetailsFromChatId(chat.chatId);
      }
    }

    return null;
  }
}
