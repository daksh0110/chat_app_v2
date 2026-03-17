import 'dart:collection';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/core/database.dart';
import 'package:my_app/core/network/api_client.dart';
import 'package:my_app/data/services/user_api_service.dart';
import 'package:my_app/providers/chat_list_provider.dart';
import 'package:my_app/providers/database_provider.dart';
import 'package:my_app/providers/settings_user_notifier_provider.dart';
import 'package:my_app/providers/socket_provider.dart';
import 'package:uuid/uuid.dart';

final messageProvider = NotifierProvider(MessageNotifer.new);

class MessageNotifer extends Notifier {
  @override
  build() {
    return null;
  }

  final _messageQueue = Queue<dynamic>();
  bool _isProcessing = false;

  Future<void> receiveMessage() async {
    ref.read(socketProvider).listen("receive_message", (dynamic data) {
      _messageQueue.add(data);
      _processQueue();
    });
  }

  Future<void> _processQueue() async {
    if (_isProcessing) return;

    _isProcessing = true;

    while (_messageQueue.isNotEmpty) {
      final data = _messageQueue.removeFirst();
      await _handleMessage(data);
    }

    _isProcessing = false;
  }

  Future<void> _handleMessage(dynamic data) async {
    final database = ref.read(databaseProvider);
    final apiClient = ApiClient();

    final senderId = data["sender_id"];
    final messageId = data["message_id"] ?? data["id"];
    final chatId = data["chat_id"];
    final tempId = data["temp_id"];

    final currentUser = ref.read(settingsUserProvider);
    if (currentUser == null) return;

    if (tempId != null) {
      final existingTemp = await database.managers.messages
          .filter((f) => f.id(tempId))
          .getSingleOrNull();

      if (existingTemp != null) return;
    }

    if (senderId == currentUser.id) return;

    final activeChatUserId = ref
        .read(chatListControllerProvider)
        .activeChatUserId;

    final shouldAutoRead = activeChatUserId == senderId;

    final createdAt =
        data["created_at"] ?? DateTime.now().millisecondsSinceEpoch;

    await database.managers.messages.create(
      (o) => o(
        id: messageId,
        chatId: chatId,
        message: data["message"],
        senderId: senderId,
        createdAt: createdAt,
        isRead: Value(shouldAutoRead),
        messageStatus: Value(shouldAutoRead ? "read" : "delivered"),
      ),
      mode: InsertMode.insertOrIgnore,
    );

    final existingChat = await database.managers.chatListTable
        .filter((f) => f.chatId(chatId))
        .getSingleOrNull();

    if (existingChat == null) {
      final response = await UserApiService(apiClient).getUserById(senderId);
      final user = response.data!;

      await database
          .into(database.chatListTable)
          .insert(
            ChatListTableCompanion.insert(
              userId: senderId,
              name: user.name,
              chatId: chatId,
              lastMessage: Value(data["message"]),
              lastMessageTime: Value(createdAt),
              unReadCount: Value(shouldAutoRead ? 0 : 1),
            ),
          );
    } else {
      final isNewer =
          existingChat.lastMessageTime == null ||
          createdAt >= existingChat.lastMessageTime!;
      final unReadCount = await getUnreadCount(senderId);
      await database.managers.chatListTable
          .filter((f) => f.id(existingChat.id))
          .update(
            (o) => o(
              lastMessage: isNewer
                  ? Value(data["message"])
                  : Value(existingChat.lastMessage),
              lastMessageTime: isNewer
                  ? Value(createdAt)
                  : Value(existingChat.lastMessageTime),
              unReadCount: Value(unReadCount),
            ),
          );
    }

    ref.read(socketProvider).sendMessage("message_delivered", {
      "message_id": messageId,
      "sender_id": senderId,
    });

    if (shouldAutoRead) {
      ref.read(socketProvider).sendMessage("message_read", {
        "message_id": messageId,
        "sender_id": senderId,
      });
    }
  }

  Future<void> sendMessagea({
    required String message,
    required String receiverId,
    required String receiverName,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final tempId = const Uuid().v4();

    final database = ref.read(databaseProvider);
    final user = ref.read(settingsUserProvider);
    if (user == null) return;

    await database.managers.messages.create(
      (o) => o(
        id: tempId,
        chatId: "",
        message: message,
        senderId: user.id,
        createdAt: now,
        isRead: const Value(true),
        messageStatus: const Value("sending"),
      ),
    );

    ref.read(socketProvider).sendMessageWithAck(
      "send_message",
      {"message": message, "receiver_id": receiverId, "temp_id": tempId},
      (response) async {
        final chatId = response["chat_id"];
        final messageId = response["message_id"];
        final createdAt = response["created_at"];

        final existingChat = await database.managers.chatListTable
            .filter((f) => f.chatId(chatId))
            .getSingleOrNull();

        int localChatId;

        if (existingChat == null) {
          final newId = await database.managers.chatListTable.create(
            (o) => o(
              chatId: chatId,
              userId: receiverId,
              name: receiverName,
              lastMessage: Value(message),
              lastMessageTime: Value(createdAt),
            ),
          );
          localChatId = newId;
        } else {
          localChatId = existingChat.id;

          await database.managers.chatListTable
              .filter((f) => f.id(existingChat.id))
              .update(
                (o) => o(
                  lastMessage: Value(message),
                  lastMessageTime: Value(createdAt),
                ),
              );
        }

        await database.managers.messages
            .filter((f) => f.id(tempId))
            .update(
              (o) => o(
                id: Value(messageId),
                chatId: Value(chatId),
                createdAt: Value(createdAt),
                messageStatus: const Value("sent"),
              ),
            );
      },
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

    final chat = await db.managers.chatListTable
        .filter((f) => f.userId(senderId))
        .getSingleOrNull();
    if (chat != null) {
      await db.managers.chatListTable
          .filter((f) => f.id(chat.id))
          .update((o) => o(unReadCount: const Value(0)));
    }
  }

  void sendChatSyncEvent() {
    ref.read(socketProvider).sendMessage("chat_sync", null);
  }

  Future<int> getUnreadCount(String senderId) async {
    final db = ref.read(databaseProvider);
    final me = ref.read(settingsUserProvider);

    if (me == null) return 0;

    final result =
        await (db.selectOnly(db.messages)
              ..addColumns([db.messages.id.count()])
              ..where(
                db.messages.senderId.equals(senderId) &
                    db.messages.isRead.equals(false),
              ))
            .getSingle();

    return result.read(db.messages.id.count()) ?? 0;
  }
}
