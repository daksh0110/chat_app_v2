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
      final createdAt = DateTime.now().millisecondsSinceEpoch;
      final existingChat = await database.managers.chatListTable
          .filter((f) => f.userId(senderId))
          .getSingleOrNull();

      int chatId;

      final unreadIncrement = shouldAutoRead ? 0 : 1;
      if (existingChat == null) {
        final response = await UserApiService(apiClient).getUserById(senderId);
        final user = response.data!;

        final newId = await database.managers.chatListTable.create(
          (o) => o(
            userId: senderId,
            name: user.name,
            lastMessage: Value(data["message"]),
            lastMessageTime: Value(createdAt),
            unReadCount: Value(unreadIncrement),
          ),
        );

        chatId = newId;
      } else {
        await database.managers.chatListTable
            .filter((f) => f.id(existingChat.id))
            .update(
              (o) => o(
                lastMessage: Value(data["message"]),
                lastMessageTime: Value(createdAt),
                unReadCount: Value(existingChat.unReadCount + unreadIncrement),
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
          createdAt: createdAt,
          isRead: Value(shouldAutoRead),
          messageStatus: Value(shouldAutoRead ? "read" : "delivered"),
        ),
        mode: InsertMode.insertOrIgnore,
      );

      ref.read(socketProvider).sendMessage("message_delivered", {
        "message_id": data["id"],
        "sender_id": senderId,
      });

      if (shouldAutoRead) {
        ref.read(socketProvider).sendMessage("message_read", {
          "message_id": data["id"],
          "sender_id": senderId,
        });
      }
    });
  }

  Future<void> sendMessagea({
    required String message,
    required String receiverId,
    required String receiverName,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    ref.read(socketProvider).sendMessage("send_message", {
      "message": message,
      "receiver_id": receiverId,
      "temp_id": now,
    });
    final database = ref.read(databaseProvider);
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

  Future<void> messageSent() async {
    final db = ref.read(databaseProvider);
    ref.read(socketProvider).listen("message_sent", (dynamic data) async {
      final String tempId = data["temp_id"].toString();
      final String messageId = data["message_id"].toString();
      final message = await db.managers.messages
          .filter((f) => f.id(tempId))
          .getSingleOrNull();

      if (message == null) return;

      await db.managers.messages
          .filter((f) => f.id(tempId))
          .update(
            (o) => o(id: Value(messageId), messageStatus: const Value("sent")),
          );
    });
  }

  Future<void> messageDelivered() async {
    final db = ref.read(databaseProvider);

    ref.read(socketProvider).listen("message_delivered", (data) async {
      final messageId = data["message_id"].toString();

      Future<void> _markDelivered([int attempt = 0]) async {
        final message = await db.managers.messages
            .filter((f) => f.id(messageId))
            .getSingleOrNull();
        if (message == null) {
          if (attempt < 3) {
            await Future.delayed(const Duration(milliseconds: 200));
            await _markDelivered(attempt + 1);
          }
          return;
        }
        if (message.messageStatus == "read") return;

        await db.managers.messages
            .filter((f) => f.id(messageId))
            .update((o) => o(messageStatus: const Value("delivered")));
      }

      await _markDelivered();
    });
  }

  Future<void> markRead() async {
    final db = ref.read(databaseProvider);

    ref.read(socketProvider).listen("message_read", (data) async {
      final messageId = data["message_id"].toString();

      Future<void> _markRead([int attempt = 0]) async {
        final message = await db.managers.messages
            .filter((f) => f.id(messageId))
            .getSingleOrNull();

        if (message == null) {
          print("Message not found (attempt $attempt)");

          if (attempt < 5) {
            await Future.delayed(const Duration(milliseconds: 200));
            await _markRead(attempt + 1);
          }

          return;
        }

        if (message.messageStatus == "read") {
          print("Already read");
          return;
        }

        await db.managers.messages
            .filter((f) => f.id(messageId))
            .update((o) => o(messageStatus: const Value("read")));
      }

      await _markRead();
    });
  }

  Future<void> markChatMessagesRead(String senderId) async {
    final db = ref.read(databaseProvider);
    final currentUser = ref.read(settingsUserProvider);

    if (currentUser == null) return;

    final unreadMessages = await db.managers.messages
        .filter((f) => f.senderId(senderId) & f.isRead(false))
        .get();

    for (final msg in unreadMessages) {
      await db.managers.messages
          .filter((f) => f.id(msg.id))
          .update(
            (o) => o(
              isRead: const Value(true),
              messageStatus: const Value("read"),
            ),
          );

      ref.read(socketProvider).sendMessage("message_read", {
        "message_id": msg.id,
        "sender_id": senderId,
      });
    }

    // Reset unread count for this chat so list shows 0 when user is on screen
    final chat = await db.managers.chatListTable
        .filter((f) => f.userId(senderId))
        .getSingleOrNull();
    if (chat != null) {
      await db.managers.chatListTable
          .filter((f) => f.id(chat.id))
          .update((o) => o(unReadCount: const Value(0)));
    }
  }

  Future<void> resetMessagesCount() async {}
}
