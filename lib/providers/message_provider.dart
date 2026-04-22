import 'dart:collection';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/core/database.dart';
import 'package:my_app/core/network/api_client.dart';
import 'package:my_app/data/services/user_api_service.dart';
import 'package:my_app/providers/chat_list_provider.dart';
import 'package:my_app/providers/database_provider.dart';
import 'package:my_app/providers/message_typing_provider.dart';
import 'package:my_app/providers/settings_user_notifier_provider.dart';
import 'package:my_app/providers/socket_provider.dart';
import 'package:uuid/uuid.dart';

int _parseTimestamp(dynamic ts) {
  if (ts == null) return DateTime.now().millisecondsSinceEpoch;
  if (ts is int) return ts;
  if (ts is String) {
    return DateTime.tryParse(ts)?.millisecondsSinceEpoch ??
        int.tryParse(ts) ??
        DateTime.now().millisecondsSinceEpoch;
  }
  if (ts is double) return ts.toInt();
  return DateTime.now().millisecondsSinceEpoch;
}

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
      final chatId = data["chat_id"];
      if (chatId != null) {
        ref.read(messageTypingProvider.notifier).clearTyping(chatId);
      }
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

    final createdAt = _parseTimestamp(data["created_at"]);
    final existing = await database.managers.messages
        .filter((f) => f.serverId(messageId))
        .getSingleOrNull();

    if (existing != null) return;
    await database.managers.messages.create(
      (o) => o(
        id: messageId,
        serverId: Value(messageId),
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
              profilePic: Value(user.profilePicUrl ?? ""),
            ),
          );
      await database
          .into(database.usersTable)
          .insertOnConflictUpdate(
            UsersTableCompanion(
              id: Value(user.id),
              name: Value(user.name),
              email: Value(user.email ?? ""),
              bio: Value(user.bio ?? ""),
              profilePictureUrl: Value(user.profilePicUrl ?? ""),
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
      "chat_id": chatId,
    });

    if (shouldAutoRead) {
      ref.read(socketProvider).sendMessage("message_read", {
        "message_id": messageId,
        "chat_id": chatId,
      });
    }
  }

  Future<void> sendMessagea({
    required String message,
    required String receiverId,
    required String receiverName,
  }) async {
    int now = DateTime.now().millisecondsSinceEpoch;
    final tempId = const Uuid().v4();

    final database = ref.read(databaseProvider);
    final user = ref.read(settingsUserProvider);
    if (user == null) return;

    final localChatId = "local_$receiverId";

    final existingChat = await database.managers.chatListTable
        .filter((f) => f.userId.equals(receiverId))
        .getSingleOrNull();
    if (existingChat != null && existingChat.lastMessageTime != null) {
      if (now <= existingChat.lastMessageTime!) {
        now = existingChat.lastMessageTime! + 1;
      }
    }

    final currentChatId = existingChat?.chatId ?? localChatId;

    if (existingChat == null) {
      final response = await UserApiService(
        ApiClient(),
      ).getUserById(receiverId);
      final user = response.data!;
      await database.managers.chatListTable.create(
        (o) => o(
          chatId: localChatId,
          userId: receiverId,
          name: receiverName,
          lastMessage: const Value(null),
          lastMessageTime: const Value(null),
          unReadCount: const Value(0),
          profilePic: Value(user.profilePicUrl ?? ""),
        ),
      );

      await database
          .into(database.usersTable)
          .insertOnConflictUpdate(
            UsersTableCompanion(
              id: Value(user.id),
              name: Value(user.name),
              email: Value(user.email ?? ""),
              bio: Value(user.bio ?? ""),
              profilePictureUrl: Value(user.profilePicUrl ?? ""),
            ),
          );
    }

    await database.managers.messages.create(
      (o) => o(
        id: tempId,
        chatId: currentChatId,
        message: message,
        senderId: user.id,
        createdAt: now,
        isRead: const Value(true),
        messageStatus: const Value("sending"),
      ),
    );
    final isRealChat = !currentChatId.startsWith("local_");
    ref.read(socketProvider).sendMessageWithAck(
      "send_message",
      {
        "message": message,
        "receiver_id": receiverId,
        "temp_id": tempId,
        if (isRealChat) "chat_id": currentChatId,
      },
      (response) async {
        final realChatId = response["chat_id"];
        final messageId = response["message_id"];
        final serverCreatedAt = _parseTimestamp(response["created_at"]);

        if (currentChatId.startsWith("local_")) {
          await database.managers.messages
              .filter((f) => f.id(tempId))
              .update((o) => o(chatId: Value(realChatId)));
        }

        final chat = await database.managers.chatListTable
            .filter((f) => f.userId(receiverId))
            .getSingleOrNull();

        if (chat == null) {
          final response = await UserApiService(
            ApiClient(),
          ).getUserById(receiverId);
          await database.managers.chatListTable.create(
            (o) => o(
              chatId: realChatId,
              userId: receiverId,
              name: receiverName,
              lastMessage: Value(message),
              lastMessageTime: Value(serverCreatedAt),
              profilePic: Value(response.data?.profilePicUrl ?? ""),
            ),
          );
        } else {
          await database.managers.chatListTable
              .filter((f) => f.id(chat.id))
              .update(
                (o) => o(
                  chatId: Value(realChatId),
                  lastMessage: Value(message),
                  lastMessageTime: Value(serverCreatedAt),
                ),
              );
        }
        await database.managers.messages
            .filter((f) => f.id(tempId))
            .update(
              (o) => o(
                serverId: Value(messageId),
                chatId: Value(realChatId),
                createdAt: Value(serverCreatedAt),
                messageStatus: const Value("sent"),
              ),
            );
      },
    );
  }

  Future<void> messageDelivered() async {
    final db = ref.read(databaseProvider);

    ref.read(socketProvider).listen("message_delivered", (data) async {
      final messageId = data["message_id"].toString();

      Future<void> _markDelivered([int attempt = 0]) async {
        final message = await db.managers.messages
            .filter((f) => f.serverId(messageId))
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
            .filter((f) => f.serverId(messageId))
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
            .filter((f) => f.serverId(messageId))
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
            .filter((f) => f.serverId(messageId))
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
        "message_id": msg.serverId ?? msg.id,
        "chat_id": msg.chatId,
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

  Future<void> sendQueueMessages() async {
    final db = ref.read(databaseProvider);
    final socketService = ref.read(socketProvider);

    if (!socketService.isConnected) return;

    final messages = await db.managers.messages
        .filter((f) => f.messageStatus.equals("sending"))
        .get();

    for (final msg in messages) {
      final receiverId = msg.chatId.replaceFirst("local_", "");

      socketService.sendMessageWithAck(
        "send_message",
        {"message": msg.message, "receiver_id": receiverId, "temp_id": msg.id},
        (response) async {
          final messageId = response["message_id"];
          final chatId = response["chat_id"];
          final createdAt = _parseTimestamp(response["created_at"]);

          await db.managers.messages
              .filter((f) => f.id(msg.id))
              .update(
                (o) => o(
                  serverId: Value(messageId),
                  chatId: Value(chatId),
                  createdAt: Value(createdAt),
                  messageStatus: const Value("sent"),
                ),
              );
        },
      );
    }
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

  void sendTypingEvent(String receiverId) async {
    final db = ref.read(databaseProvider);
    final existingChat = await db.managers.chatListTable
        .filter((f) => f.userId.equals(receiverId))
        .getSingleOrNull();

    final chatId = existingChat?.chatId;

    if (chatId != null && !chatId.startsWith("local_")) {
      ref.read(socketProvider).sendMessage("is_typing", {"chat_id": chatId});
    }
  }

  void receiveTypingEvent() {
    ref.read(socketProvider).listen("user_typing", (dynamic data) {
      final chatId = data["chat_id"];
      if (chatId != null) {
        ref.read(messageTypingProvider.notifier).receiveUserTyping(chatId);
      }
    });
  }

  void sendStopTypingEvent(String receiverId) async {
    final db = ref.read(databaseProvider);
    final existingChat = await db.managers.chatListTable
        .filter((f) => f.userId.equals(receiverId))
        .getSingleOrNull();

    final chatId = existingChat?.chatId;

    if (chatId != null && !chatId.startsWith("local_")) {
      ref.read(socketProvider).sendMessage("stop_typing", {"chat_id": chatId});
    }
  }

  void receiveStopTypingEvent() {
    ref.read(socketProvider).listen("user_stop_typing", (dynamic data) {
      final chatId = data["chat_id"];
      if (chatId != null) {
        ref.read(messageTypingProvider.notifier).clearTyping(chatId);
      }
    });
  }
}
