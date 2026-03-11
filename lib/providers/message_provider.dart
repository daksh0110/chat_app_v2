import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/core/network/api_client.dart';
import 'package:my_app/data/services/user_api_service.dart';
import 'package:my_app/providers/chat_list_provider.dart';
import 'package:my_app/providers/database_provider.dart';
import 'package:my_app/providers/settings_user_notifier_provider.dart';
import 'package:my_app/providers/socket_provider.dart';

final messageProvider = NotifierProvider(MessageNotifer.new);

class MessageNotifer extends Notifier {
  @override
  build() {
    return null;
  }

  Future<void> receiveMessage() async {
    ref.read(socketProvider).listen("receive_message", (dynamic data) async {
      final database = ref.read(databaseProvider);
      final apiClient = ApiClient();

      final String senderId = data["sender_id"];
      final String receiverId = data["receiver_id"];
      final currentUser = ref.read(settingsUserProvider);
      final activeChatUserId = ref
          .read(chatListControllerProvider)
          .activeChatUserId;

      if (currentUser != null && senderId == currentUser.id) {
        return;
      }

      final isIncomingForMe =
          currentUser != null && receiverId == currentUser.id;
      if (!isIncomingForMe) {
        return;
      }

      final shouldAutoRead = activeChatUserId == senderId;

      final existingChat = await database.managers.chatListTable
          .filter((f) => f.userId(senderId))
          .getSingleOrNull();

      int chatId;

      if (existingChat == null) {
        final response = await UserApiService(apiClient).getUserById(senderId);
        final user = response.data!;

        final newId = await database.managers.chatListTable.create(
          (o) => o(
            userId: senderId,
            name: user.name,
            lastMessage: Value(data["message"]),
            lastMessageTime: Value(data["created_at"]),
            unReadCount: const Value(1),
          ),
        );

        chatId = newId;
      } else {
        await database.managers.chatListTable
            .filter((f) => f.id(existingChat.id))
            .update(
              (o) => o(
                lastMessage: Value(data["message"]),
                lastMessageTime: Value(data["created_at"]),
                unReadCount: Value(existingChat.unReadCount + 1),
              ),
            );

        chatId = existingChat.id;
      }

      await database.managers.messages.create(
        (o) => o(
          id: data["id"],
          chatId: chatId,
          message: data["message"],
          receiverId: receiverId,
          senderId: senderId,
          createdAt: data["created_at"],
          isRead: const Value(false),
        ),
        mode: InsertMode.insertOrIgnore,
      );

      if (shouldAutoRead) {
        await ref.read(chatListControllerProvider).markChatAsRead(senderId);
      }
    });
  }

  Future<void> sendMessagea({
    required String message,
    required String receiverId,
    required String receiverName,
  }) async {
    ref.read(socketProvider).sendMessage("send_message", {
      "message": message,
      "receiver_id": receiverId,
    });
    final database = ref.read(databaseProvider);
    final now = DateTime.now().millisecondsSinceEpoch;
    final user = ref.watch(settingsUserProvider);
    if (user == null) return;
    final existingChat = await database.managers.chatListTable
        .filter((f) => f.userId(receiverId))
        .getSingleOrNull();

    int chatId;

    if (existingChat == null) {
      final newId = await database.managers.chatListTable.create(
        (o) => o(
          userId: receiverId,
          name: receiverName,
          lastMessage: Value(message),
          lastMessageTime: Value(now),
        ),
      );

      chatId = newId;
    } else {
      await database.managers.chatListTable
          .filter((f) => f.id(existingChat.id))
          .update(
            (o) => o(lastMessage: Value(message), lastMessageTime: Value(now)),
          );

      chatId = existingChat.id;
    }

    await database.managers.messages.create(
      (o) => o(
        id: now.toString(),
        chatId: chatId,
        message: message,
        receiverId: receiverId,
        senderId: user.id,
        createdAt: now,
        isRead: const Value(true),
      ),
    );
  }

  Future<void> changeMessageStatus() async {}

  Future<void> resetMessagesCount() async {}
}
