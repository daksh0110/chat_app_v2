import 'dart:async';
import 'dart:collection';

import 'package:drift/drift.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_app/core/database.dart';
import 'package:my_app/core/network/api_client.dart';
import 'package:my_app/core/util/get_file_type.dart';
import 'package:my_app/data/services/chat_api_service.dart';
import 'package:my_app/data/services/chat_sync_service.dart';
import 'package:my_app/data/services/upload_service.dart';
import 'package:my_app/data/services/user_api_service.dart';
import 'package:my_app/modal/screens/createGroup/create_group_response.dart';
import 'package:my_app/modal/screens/message/message_delivered_response.dart';
import 'package:my_app/modal/screens/message/message_read_response.dart';
import 'package:my_app/modal/screens/message/message_status.dart';
import 'package:my_app/modal/screens/message/send_message_ack.dart';
import 'package:my_app/modal/upload_responses/presigned_url_response.dart';
import 'package:my_app/modal/upload_responses/upload_attachment.dart';
import 'package:my_app/providers/chat_list_provider.dart';
import 'package:my_app/providers/database_provider.dart';
import 'package:my_app/providers/message_typing_provider.dart';
import 'package:my_app/providers/settings_user_notifier_provider.dart';
import 'package:my_app/providers/socket_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:mime/mime.dart';

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

  final _statusQueue = Queue<Future<void> Function()>();
  bool _isProcessingStatus = false;

  Future<void> _processStatusQueue() async {
    if (_isProcessingStatus) return;
    _isProcessingStatus = true;

    while (_statusQueue.isNotEmpty) {
      final action = _statusQueue.removeFirst();
      try {
        await action();
      } catch (e) {
        debugPrint("Error in status queue: $e");
      }
    }

    _isProcessingStatus = false;
  }

  int _statusRank(String status) {
    switch (status) {
      case "sending":
        return 0;
      case "sent":
        return 1;
      case "delivered":
        return 2;
      case "read":
        return 3;
      default:
        return -1;
    }
  }

  void _acknowledgeEvent(dynamic data) {
    if (data is Map && data.containsKey('sequence')) {
      final sequence = data['sequence'];
      if (sequence != null) {
        ref.read(socketProvider).sendMessage('chat_event_ack', {
          'sequence': sequence,
        });
      }
    }
  }

  Future<void> receiveMessage() async {
    ref.read(socketProvider).listen("receive_message", (dynamic data) {
      _acknowledgeEvent(data);
      final chatId = data["chat_id"];
      if (chatId != null) {
        ref.read(messageTypingProvider.notifier).clearTyping(chatId);
      }
      final payload = SendMessageAck.fromJson(data);

      _messageQueue.add(payload);
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
    final chatSyncService = ChatSyncService(
      db: database,
      apiClient: ApiClient(),
    );
    if (currentUser == null) return;
    final senderId = data.senderId;
    final messageId = data.messageId;
    final chatId = data.chatId;
    final tempId = data.tempId;

    final createdAt = _parseTimestamp(data.createdAt);
    _serverTimeOffset = createdAt - DateTime.now().millisecondsSinceEpoch;

    if (senderId == currentUser.id) return;

    if (tempId.isNotEmpty) {
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
          id: tempId.isNotEmpty ? tempId : const Uuid().v4(),
          serverId: Value(messageId),
          chatId: chatId,
          message: data.message,
          senderId: senderId,
          createdAt: createdAt,
          isRead: Value(shouldAutoRead),
          messageStatus: Value(shouldAutoRead ? "read" : "delivered"),
        ),
        mode: InsertMode.insertOrIgnore,
      );

      await database.managers.messageStatusTable.bulkCreate(
        (o) => data.messageStatuses
            .map<Insertable<MessageStatusTableData>>(
              (status) => o(
                messageId: messageId,
                userId: status.userId,
                status: Value(status.status),
                createdAt: _parseTimestamp(status.createdAt),
                updatedAt: _parseTimestamp(status.updatedAt),
                deliveredAt: Value(
                  status.deliveredAt != null
                      ? _parseTimestamp(status.deliveredAt)
                      : null,
                ),
                readAt: Value(
                  status.readAt != null ? _parseTimestamp(status.readAt) : null,
                ),
              ),
            )
            .toList(),
        mode: InsertMode.insertOrIgnore,
      );

      if (data.attachments.isNotEmpty) {
        await database.managers.mediaTable.bulkCreate(
          (o) => data.attachments.map<Insertable<MediaTableData>>((attachment) => o(
            createdAt: createdAt,
            actorId: Value(messageId),
            key: Value(attachment.key),
            url: Value(attachment.url),
            Type: Value(attachment.type),
            contentType: Value(attachment.contentType),
            name: Value(attachment.name),
            location: const Value(null),
          )).toList(),
          mode: InsertMode.insertOrIgnore,
        );
      }

      final existingChat = await (database.select(
        database.chatListTable,
      )..where((c) => c.chatId.equals(chatId))).getSingleOrNull();
      if (existingChat == null) {
        final token = currentUser.accessToken;
        final ApiClient apiClient = ApiClient();
        final response = await ChatApiService(
          apiClient,
        ).getChat(token: token, chatId: chatId);

        final user = response.data?.data;
        debugPrint("Fetched chat details for new message: ${user}");
        await database.managers.chatListTable.create(
          (o) => o(
            chatId: chatId,
            name: user?.name ?? "Unknown",
            type: user?.type ?? "DIRECT",
            isDeleted: const Value(false),
            lastMessage: Value(data.message),
            lastMessageTime: Value(createdAt),
            profilePicUrl: Value(user?.profilePictureUrl ?? ""),
            unReadCount: Value(shouldAutoRead ? 0 : 1),
          ),
        );
        final participants = user?.participants;
        await database.managers.chatParticipants.bulkCreate(
          (o) =>
              participants
                  ?.map(
                    (p) => o(
                      chatId: chatId,
                      userId: p.userId,
                      name: p.name,
                      role: Value(p.role),
                      profilePicUrl: Value(p.profilePictureUrl),
                    ),
                  )
                  .toList() ??
              [],
          mode: InsertMode.insertOrIgnore,
        );
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
                    ? Value(data.message)
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

    unawaited(chatSyncService.cacheUserIfMissing(senderId));
    unawaited(
      chatSyncService.updateDmChatItem(userId: senderId, chatId: chatId),
    );
  }

  Future<void> sendMessage({
    String message = "",
    required String receiverId,
    required String receiverName,
    List<XFile> attachments = const [],
    String chatId = "",
    void Function(String realChatId)? onChatResolved,
  }) async {
    try {
      final database = ref.read(databaseProvider);
      final user = ref.read(settingsUserProvider);
      final List<UploadAttachment> uploadedAttachments = [];

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
                type: "DIRECT",
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

          mode: InsertMode.insertOrIgnore,
        );
        for (final attachment in attachments) {
          final mime =
              lookupMimeType(attachment.path) ?? "application/octet-stream";
          await database.managers.mediaTable.create(
            (o) => o(
              createdAt: now,
              actorId: Value(tempId),
              Type: Value(getMediaType(mime)),
              contentType: Value(mime),
              location: Value(attachment.path),
              name: Value(attachment.name),
            ),
          );
        }

        final participants = await database.managers.chatParticipants
            .filter((f) => f.chatId.equals(currentChatId))
            .get();

        await database.managers.messageStatusTable.bulkCreate(
          (o) => participants.map((p) {
            final isMe = p.userId == user.id;

            return o(
              messageId: tempId,
              userId: p.userId,

              status: Value(isMe ? "sent" : "sending"),

              createdAt: now,
              updatedAt: now,

              deliveredAt: Value(isMe ? now : null),

              readAt: Value(isMe ? now : null),
            );
          }).toList(),
        );
      });
      final isRealChat = !currentChatId.startsWith("local_");
      if (attachments.isNotEmpty) {
        final futures = attachments.map((attachment) async {
          final mime =
              lookupMimeType(attachment.path) ?? "application/octet-stream";

          final presignedUrl = await UploadService(ApiClient()).getPresignedUrl(
            assetType: "chat",
            entityType: "attachments",
            contentType: mime,
            entityId: chatId,
          );

          if (!presignedUrl.success) {
            return null;
          }

          final response = presignedUrl.data!;
          final result = await UploadService(ApiClient()).uploadToSignedUrl(
            await attachment.readAsBytes(),
            response.url,
            mime,
          );

          if (result == 200) {
            return UploadAttachment(
              contentType: mime,
              key: response.key ?? "",
              type: getMediaType(mime),
              name: attachment.name,
            );
          }

          return null;
        }).toList();

        final uploaded = await Future.wait(futures);

        uploadedAttachments.addAll(uploaded.whereType<UploadAttachment>());
      }
      ref.read(socketProvider).sendMessageWithAck(
        "send_message",
        {
          "message": message,
          "receiver_id": receiverId,
          "temp_id": tempId,
          "attachments": uploadedAttachments.map((e) => e.toJson()).toList(),
          if (isRealChat) "chat_id": currentChatId,
        },
        (response) async {
          final payload = SendMessageAck.fromJson(response);
          final realChatId = payload.chatId;
          final messageId = payload.messageId;
          final createdAt = _parseTimestamp(payload.createdAt);
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
                  id: Value(messageId),
                ),
              );
          await database.managers.mediaTable
              .filter((f) => f.actorId.equals(tempId))
              .update((o) => o(actorId: Value(messageId)));

          final ackAttachments = payload.attachments;
          if (ackAttachments.isNotEmpty) {
            final localMedias = await database.managers.mediaTable
                .filter((f) => f.actorId.equals(messageId))
                .get();
            for (int i = 0; i < localMedias.length; i++) {
              if (i < ackAttachments.length) {
                final att = ackAttachments[i];
                await database.managers.mediaTable
                    .filter((f) => f.id.equals(localMedias[i].id))
                    .update((o) => o(
                      key: Value(att.key),
                      url: Value(att.url),
                    ));
              }
            }
          }
          await database.managers.messageStatusTable
              .filter((f) => f.messageId.equals(tempId))
              .delete();

          await database.managers.messageStatusTable.bulkCreate(
            (o) => payload.messageStatuses.map((status) {
              return o(
                messageId: messageId,
                userId: status.userId,
                status: Value(status.status),
                createdAt: _parseTimestamp(status.createdAt),
                updatedAt: _parseTimestamp(status.updatedAt),
                deliveredAt: Value(
                  status.deliveredAt != null
                      ? _parseTimestamp(status.deliveredAt)
                      : null,
                ),
                readAt: Value(
                  status.readAt != null ? _parseTimestamp(status.readAt) : null,
                ),
              );
            }).toList(),
            mode: InsertMode.insertOrReplace,
          );
          final chatSyncService = ChatSyncService(
            db: database,
            apiClient: ApiClient(),
          );
          unawaited(
            chatSyncService.updateDmChatItem(
              userId: receiverId,
              chatId: realChatId,
            ),
          );
        },
      );
      final chatSyncService = ChatSyncService(
        db: database,
        apiClient: ApiClient(),
      );
      unawaited(chatSyncService.cacheUserIfMissing(receiverId));
    } catch (e) {
      debugPrint("Error sending message: $e");
    }
  }

  Future<void> messageDelivered() async {
    final db = ref.read(databaseProvider);

    ref.read(socketProvider).listen("message_delivered", (data) async {
      _acknowledgeEvent(data);
      _statusQueue.add(() async {
        await _retry(() async {
          final payload = MessageDeliveredResponse.fromJson(data);

          final status = payload.messageStatus;

          final existingRow = await db.managers.messageStatusTable
              .filter(
                (f) =>
                    f.messageId.equals(status.messageId) &
                    f.userId.equals(status.userId),
              )
              .getSingleOrNull();

          if (existingRow == null) {
            throw Exception("Status row not found yet, retrying...");
          }

          if (_statusRank(status.status) <= _statusRank(existingRow.status)) {
            return;
          }

          await db.managers.messageStatusTable
              .filter(
                (f) =>
                    f.messageId.equals(status.messageId) &
                    f.userId.equals(status.userId),
              )
              .update(
                (o) => o(
                  status: Value(status.status),
                  deliveredAt: Value(_parseTimestamp(status.deliveredAt)),
                  updatedAt: Value(_parseTimestamp(status.updatedAt)),
                ),
              );
        });
      });
      _processStatusQueue();
    });
  }

  Future<void> markRead() async {
    final db = ref.read(databaseProvider);

    ref.read(socketProvider).listen("message_read", (data) async {
      _acknowledgeEvent(data);
      _statusQueue.add(() async {
        await _retry(() async {
          final payload = MessageReadResponse.fromJson(data);

          final status = payload.messageStatus;

          final existingRow = await db.managers.messageStatusTable
              .filter(
                (f) =>
                    f.messageId.equals(status.messageId) &
                    f.userId.equals(status.userId),
              )
              .getSingleOrNull();

          if (existingRow == null) {
            throw Exception("Status row not found yet, retrying...");
          }

          if (_statusRank(status.status) <= _statusRank(existingRow.status)) {
            return;
          }

          await db.managers.messageStatusTable
              .filter(
                (f) =>
                    f.messageId.equals(status.messageId) &
                    f.userId.equals(status.userId),
              )
              .update(
                (o) => o(
                  status: Value(status.status),
                  readAt: Value(_parseTimestamp(status.readAt)),
                  updatedAt: Value(_parseTimestamp(status.updatedAt)),
                ),
              );
        });
      });
      _processStatusQueue();
    });
  }

  Future<void> markChatMessagesRead(String chatId) async {
    final db = ref.read(databaseProvider);

    final currentUser = ref.read(settingsUserProvider);

    if (currentUser == null) return;

    final now = DateTime.now().millisecondsSinceEpoch;

    final unreadStatuses = await db.managers.messageStatusTable
        .filter((f) => f.userId.equals(currentUser.id) & f.status.not("read"))
        .get();

    if (unreadStatuses.isEmpty) return;

    await db.managers.messageStatusTable
        .filter((f) => f.userId.equals(currentUser.id) & f.status.not("read"))
        .update(
          (o) => o(
            status: const Value("read"),
            readAt: Value(now),
            updatedAt: Value(now),
          ),
        );

    for (final status in unreadStatuses) {
      ref.read(socketProvider).sendMessage("message_read", {
        "message_id": status.messageId,
        "chat_id": chatId,
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
                  id: Value(messageId),
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

  Future<void> groupChatCreatedListener() async {
    try {
      ref.read(socketProvider).listen("group-created", (dynamic data) async {
        _acknowledgeEvent(data);
        final db = ref.read(databaseProvider);
        final currentUser = ref.read(settingsUserProvider);
        if (currentUser == null || currentUser.accessToken.isEmpty) return;

        if (data is Map) {
          final payload = CreateGroupResponse.fromJson(
            Map<String, dynamic>.from(data),
          );

          if (payload.data?.chatId.isEmpty ?? true) return;
          {
            await ChatSyncService(
              db: db,
              apiClient: ApiClient(),
            ).syncCreatedGroupEventPayload(
              rawPayload: payload,
              currentUserId: currentUser.id,
            );
            return;
          }
        }
      });
    } catch (_) {}
  }

  Future<void> _retry(
    Future<void> Function() action, {
    int maxRetries = 3,
    Duration delay = const Duration(milliseconds: 500),
  }) async {
    int attempt = 0;

    while (true) {
      try {
        await action();
        return;
      } catch (e) {
        attempt++;

        if (attempt >= maxRetries) {
          rethrow;
        }

        await Future.delayed(delay * attempt);
      }
    }
  }
}
