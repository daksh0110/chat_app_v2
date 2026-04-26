import 'dart:async';
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
  int _serverTimeOffset = 0;

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
    final currentUser = ref.read(settingsUserProvider);
    if (currentUser == null) return;

    final senderId = data["sender_id"];
    final messageId = data["message_id"];
    final chatId = data["chat_id"];
    final tempId = data["temp_id"];

    final createdAt = _parseTimestamp(data["created_at"]);
    _serverTimeOffset = createdAt - DateTime.now().millisecondsSinceEpoch;

    if (senderId == currentUser.id) return;

    if (tempId != null) {
      final existingTemp = await database.managers.messages
          .filter((f) => f.id.equals(tempId))
          .getSingleOrNull();

      if (existingTemp != null) return;
    }

    final existing = await database.managers.messages
        .filter((f) => f.serverId.equals(messageId))
        .getSingleOrNull();

    if (existing != null) return;

    final activeChatId = ref.read(chatListControllerProvider).activeChatId;

    final shouldAutoRead = activeChatId == chatId;

    await database.transaction(() async {
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

      final existingChat = await (database.select(
        database.chatListTable,
      )..where((c) => c.chatId.equals(chatId))).getSingleOrNull();
      final ApiClient apiClient = ApiClient();
      final response = await UserApiService(apiClient).getUserById(senderId);
      final user = response.data;
      if (existingChat == null) {
        await database.managers.chatListTable.create(
          (o) => o(
            chatId: chatId,
            name: user?.name ?? "Unknown",
            type: "dm",
            isDeleted: const Value(false),
            lastMessage: Value(data["message"]),
            lastMessageTime: Value(createdAt),
            profilePicUrl: Value(user?.profilePicUrl ?? ""),
            unReadCount: Value(shouldAutoRead ? 0 : 1),
          ),
        );
        await database.batch((batch) {
          batch.insertAll(database.chatParticipants, [
            ChatParticipantsCompanion.insert(
              chatId: chatId,
              userId: currentUser.id,
              name: currentUser.name,
            ),
            ChatParticipantsCompanion.insert(
              chatId: chatId,
              userId: senderId,
              name: user?.name ?? "Unknown",
            ),
          ], mode: InsertMode.insertOrIgnore);
        });
      } else {
        final isNewer =
            existingChat.lastMessageTime == null ||
            createdAt >= existingChat.lastMessageTime!;

        final unread = shouldAutoRead ? 0 : (existingChat.unReadCount) + 1;

        await database.managers.chatListTable
            .filter((f) => f.chatId.equals(chatId))
            .update(
              (o) => o(
                lastMessage: isNewer
                    ? Value(data["message"])
                    : const Value.absent(),
                lastMessageTime: isNewer
                    ? Value(createdAt)
                    : const Value.absent(),
                unReadCount: Value(unread),
                isDeleted: const Value(false),
              ),
            );
      }
    });

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

    unawaited(_cacheUser(senderId));
    unawaited(_UpdateChatItem(senderId, chatId));
  }

  Future<void> sendMessagea({
    required String message,
    required String receiverId,
    required String receiverName,
    String chatId = "",
    void Function(String realChatId)? onChatResolved,
  }) async {
    try {
      final database = ref.read(databaseProvider);
      final user = ref.read(settingsUserProvider);
      if (user == null) return;

      final now = DateTime.now().millisecondsSinceEpoch + _serverTimeOffset;
      final tempId = const Uuid().v4();
      late String currentChatId;

      await database.transaction(() async {
        currentChatId = chatId;

        if (currentChatId.isEmpty || currentChatId.startsWith("local_")) {
          currentChatId = "local_$receiverId";

          final existingChat = await (database.select(
            database.chatListTable,
          )..where((c) => c.chatId.equals(currentChatId))).getSingleOrNull();

          if (existingChat == null) {
            await database.managers.chatListTable.create(
              (o) => o(
                chatId: currentChatId,
                name: receiverName,
                type: "dm",
                isDeleted: const Value(false),
                lastMessage: Value(message),
                lastMessageTime: Value(now),
                profilePicUrl: const Value(null),
                unReadCount: const Value(0),
              ),
            );

            await database.managers.chatParticipants.bulkCreate(
              (o) => [
                o(chatId: currentChatId, userId: user.id, name: user.name),
                o(
                  chatId: currentChatId,
                  userId: receiverId,
                  name: receiverName,
                ),
              ],
            );
          }
        } else {
          await (database.update(
            database.chatListTable,
          )..where((c) => c.chatId.equals(currentChatId))).write(
            ChatListTableCompanion(
              lastMessage: Value(message),
              lastMessageTime: Value(now),
              isDeleted: const Value(false),
            ),
          );
        }

        await database.managers.messages.create(
          (o) => o(
            chatId: currentChatId,
            id: tempId,
            message: message,
            senderId: user.id,
            isRead: const Value(true),
            messageStatus: const Value("sending"),
            createdAt: now,
          ),
        );
      });
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
          final createdAt = _parseTimestamp(response["created_at"]);
          _serverTimeOffset = createdAt - DateTime.now().millisecondsSinceEpoch;

          if (currentChatId.startsWith("local_")) {
            await database.managers.chatParticipants
                .filter((f) => f.chatId.equals(currentChatId))
                .update((o) => o(chatId: Value(realChatId)));
          }
          onChatResolved?.call(realChatId);

          await database.managers.chatListTable
              .filter((f) => f.chatId.equals(currentChatId))
              .update(
                (o) => o(
                  chatId: Value(realChatId),
                  lastMessageTime: Value(createdAt),
                  lastMessage: Value(message),
                  isDeleted: const Value(false),
                ),
              );
          await database.managers.messages
              .filter((f) => f.id.equals(tempId))
              .update(
                (o) => o(
                  serverId: Value(messageId),
                  chatId: Value(realChatId),
                  createdAt: Value(createdAt),
                  messageStatus: const Value("sent"),
                ),
              );
          unawaited(_UpdateChatItem(receiverId, realChatId));
        },

      );
      unawaited(_cacheUser(receiverId));
    } catch (e) {
      // optionally log
    }
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
          return;
        }

        await db.managers.messages
            .filter((f) => f.serverId.equals(messageId))
            .update((o) => o(messageStatus: const Value("read")));
      }

      await _markRead();
    });
  }

  Future<void> markChatMessagesRead(String chatId) async {
    final db = ref.read(databaseProvider);
    final currentUser = ref.read(settingsUserProvider);

    if (currentUser == null) return;

    final unreadMessages = await db.managers.messages
        .filter((f) => f.chatId.equals(chatId) & f.isRead.equals(false))
        .get();

    if (unreadMessages.isEmpty) return;

    await db.managers.messages
        .filter((f) => f.chatId.equals(chatId) & f.isRead.equals(false))
        .update(
          (o) =>
              o(isRead: const Value(true), messageStatus: const Value("read")),
        );

    for (final msg in unreadMessages) {
      ref.read(socketProvider).sendMessage("message_read", {
        "message_id": msg.serverId ?? msg.id,
        "chat_id": msg.chatId,
      });
    }

    await db.managers.chatListTable
        .filter((f) => f.chatId.equals(chatId))
        .update((o) => o(unReadCount: const Value(0)));
  }

  void sendChatSyncEvent() {
    ref.read(socketProvider).sendMessage("chat_sync", null);
  }

  Future<void> sendQueueMessages() async {
    final db = ref.read(databaseProvider);
    final socketService = ref.read(socketProvider);
    final currentUser = ref.read(settingsUserProvider);

    if (currentUser == null) return;
    if (!socketService.isConnected) return;

    final messages = await db.managers.messages
        .filter((f) => f.messageStatus.equals("sending"))
        .get();

    for (final msg in messages) {
      if (msg.serverId != null) continue;

      final participants = await db.managers.chatParticipants
          .filter((f) => f.chatId.equals(msg.chatId))
          .get();

      final receiver = participants.firstWhere(
        (p) => p.userId != currentUser.id,
      );

      final receiverId = receiver.userId;

      final isRealChat = !msg.chatId.startsWith("local_");

      socketService.sendMessageWithAck(
        "send_message",
        {
          "message": msg.message,
          "receiver_id": receiverId,
          "temp_id": msg.id,
          if (isRealChat) "chat_id": msg.chatId,
        },
        (response) async {
          final messageId = response["message_id"];
          final chatId = response["chat_id"];
          final createdAt = _parseTimestamp(response["created_at"]);

          if (msg.chatId.startsWith("local_")) {
            await db.managers.chatParticipants
                .filter((f) => f.chatId.equals(msg.chatId))
                .update((o) => o(chatId: Value(chatId)));
          }

          await db.managers.chatListTable
              .filter((f) => f.chatId.equals(msg.chatId))
              .update(
                (o) => o(
                  chatId: Value(chatId),
                  lastMessage: Value(msg.message),
                  lastMessageTime: Value(createdAt),
                ),
              );

          await db.managers.messages
              .filter((f) => f.id.equals(msg.id))
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

  Future<int> getUnreadCount(String chatId) async {
    final db = ref.read(databaseProvider);

    final result =
        await (db.selectOnly(db.messages)
              ..addColumns([db.messages.id.count()])
              ..where(
                db.messages.chatId.equals(chatId) &
                    db.messages.isRead.equals(false),
              ))
            .getSingle();

    return result.read(db.messages.id.count()) ?? 0;
  }

  void sendTypingEvent(String chatId) {
    if (!chatId.startsWith("local_")) {
      ref.read(socketProvider).sendMessage("is_typing", {"chat_id": chatId});
    }
  }

  bool _typingListenerAdded = false;

  void receiveTypingEvent() {
    if (_typingListenerAdded) return;
    _typingListenerAdded = true;

    ref.read(socketProvider).listen("user_typing", (dynamic data) {
      final chatId = data["chat_id"];
      if (chatId != null) {
        ref.read(messageTypingProvider.notifier).receiveUserTyping(chatId);
      }
    });
  }

  bool _isTyping = false;

  void sendStopTypingEvent(String chatId) {
    if (!_isTyping) return;

    _isTyping = false;

    if (!chatId.startsWith("local_")) {
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

  Future<void> _cacheUser(String userId) async {
    try {
      final database = ref.read(databaseProvider);

      final existing = await database.managers.usersTable
          .filter((f) => f.id.equals(userId))
          .getSingleOrNull();

      if (existing != null) return;

      final response = await UserApiService(ApiClient()).getUserById(userId);
      final data = response.data;

      if (data != null) {
        await database
            .into(database.usersTable)
            .insertOnConflictUpdate(
              UsersTableCompanion(
                id: Value(data.id),
                name: Value(data.name),
                email: Value(data.email ?? ""),
                bio: Value(data.bio ?? ""),
                profilePictureUrl: Value(data.profilePicUrl ?? ""),
              ),
            );
      }
    } catch (_) {}
  }

  Future<void> _UpdateChatItem(String userId, String chatId) async {
    try {
      final database = ref.read(databaseProvider);

      final existing = await database.managers.chatListTable
          .filter((f) => f.chatId.equals(chatId))
          .getSingleOrNull();

      if (existing == null) return;

      if (existing.type != "dm") return;

      final response = await UserApiService(ApiClient()).getUserById(userId);
      final data = response.data;

      if (data != null) {
        await (database.update(
          database.chatListTable,
        )..where((tbl) => tbl.chatId.equals(chatId))).write(
          ChatListTableCompanion(
            name: Value(data.name),
            profilePicUrl: Value(data.profilePicUrl),
          ),
        );
      }
    } catch (_) {}
  }
}
