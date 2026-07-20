import 'dart:async';
import 'dart:collection';
import 'dart:developer';

import 'package:drift/drift.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/core/network/api_client.dart';
import 'package:my_app/core/util/get_file_type.dart';
import 'package:my_app/core/util/parse_time.dart';
import 'package:my_app/core/util/status_rank.dart';
import 'package:my_app/data/services/upload_service.dart';
import 'package:my_app/modal/chat_list_modal.dart';
import 'package:my_app/modal/screens/createGroup/create_group_response.dart';
import 'package:my_app/modal/screens/message/message_body_request.dart';
import 'package:my_app/modal/screens/message/message_delivered_response.dart';
import 'package:my_app/modal/screens/message/message_read_response.dart';
import 'package:my_app/modal/screens/message/message_status.dart';
import 'package:my_app/modal/screens/message/send_message_ack.dart';
import 'package:my_app/modal/screens/message/send_message_request.dart';
import 'package:my_app/modal/upload_responses/upload_attachment.dart';
import 'package:my_app/providers/chat_list_provider.dart';
import 'package:my_app/providers/database_provider.dart';
import 'package:my_app/providers/message_typing_provider.dart';
import 'package:my_app/providers/socket_provider.dart';
import 'package:my_app/providers/tables/chat_list_table_provider.dart';
import 'package:my_app/providers/tables/chat_participants_table.dart';
import 'package:my_app/providers/tables/media_table_provider.dart';
import 'package:my_app/providers/tables/message_status_table_provider.dart';
import 'package:my_app/providers/tables/messages_table_provider.dart';
import 'package:my_app/providers/tables/user_preference_table_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:mime/mime.dart';

final messageProvider = NotifierProvider(MessageNotifer.new);

class MessageNotifer extends Notifier {
  @override
  build() {
    return null;
  }

  final _messageQueue = Queue<dynamic>();
  bool _isProcessing = false;

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

  void _acknowledgeEvent(dynamic data) {
    if (data is Map && data.containsKey('sequence')) {
      final sequence = data['sequence'];
      if (sequence != null) {
        ref.read(socketProvider).emitEvent('chat_event_ack', {
          'sequence': sequence,
        });
      }
    }
  }

  Future<void> receiveMessage() async {
    ref.read(socketProvider).listenOnce("receive_message", (dynamic data) {
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

  Future<void> _handleMessage(SendMessageAck data) async {
    log(data.toString());
    try {
      final database = ref.read(databaseProvider);
      final currentUser = ref.watch(userPreferenceTableProvider).value;

      if (currentUser == null || data.senderId == currentUser) return;
      final senderId = data.senderId;
      final messageId = data.messageId;
      final chatId = data.chatId;

      final createdAt = parseTimestamp(data.createdAt);

      final activeChatId = ref.read(chatListControllerProvider).activeChatId;

      final isResumed =
          WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
      final shouldAutoRead = isResumed && activeChatId == chatId;

      await database.transaction(() async {
        await ref
            .read(messagesTableProvider.notifier)
            .createOrUpdateMessage(
              MessageBodyRequest(
                chatId: chatId,
                createdAt: DateTime.now().millisecondsSinceEpoch,
                isRead: shouldAutoRead,
                message: data.message,
                messageId: messageId,
                senderId: senderId,
                serverCreatedAt: createdAt,
              ),
            );
        final List<MessageStatus> messageStatuses = data.messageStatuses
            .map(
              (e) => MessageStatus(
                messageId: e.messageId,
                userId: e.userId,
                status: e.status,
                createdAt: parseTimestamp(e.createdAt),
                updatedAt: parseTimestamp(e.updatedAt),
              ),
            )
            .toList();
        await ref
            .read(messageStatusTableProvider.notifier)
            .bulkCreateMessageStatus(messageStatuses, messageId);

        if (data.attachments.isNotEmpty) {
          final List<UploadAttachment> medias = data.attachments
              .map(
                (e) => UploadAttachment(
                  key: e.key,
                  contentType: e.contentType,
                  type: e.type,
                  actorId: e.actorId,
                  name: e.name,
                  url: e.url,
                ),
              )
              .toList();

          await ref
              .read(mediaTableProvider.notifier)
              .bulkAddMediaDocuments(medias, messageId);
        }
        final ChatListModal chatData = ChatListModal(
          id: chatId,
          chatId: chatId,
          lastMessage: data.message.isNotEmpty
              ? data.message
              : data.attachments.isNotEmpty
              ? "You recieved media"
              : "",
          lastMessageTime: createdAt.toString(),
          receiverId: data.senderId,
          type: "",
        );
        await ref
            .read(chatListTableProvider.notifier)
            .createOrUpdateChatList(
              chatData,
              isIncomingMessage: true,
              shouldAutoRead: shouldAutoRead,
            );
      });

      ref.read(socketProvider).emitEvent("message_delivered", {
        "message_id": messageId,
        "chat_id": chatId,
      });

      if (shouldAutoRead) {
        ref.read(socketProvider).emitEvent("message_read", {
          "message_id": messageId,
          "chat_id": chatId,
        });
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> sendMessage(SendMessageRequest request) async {
    try {
      log(request.toString());
      final database = ref.read(databaseProvider);
      final currentUserId = ref.watch(userPreferenceTableProvider).value;
      final chatListTableProviderRef = ref.read(chatListTableProvider.notifier);
      final messagesTableProviderRef = ref.read(messagesTableProvider.notifier);
      final mediaTableProviderRef = ref.read(mediaTableProvider.notifier);
      final messageStatusTableProviderRef = ref.read(
        messageStatusTableProvider.notifier,
      );

      final List<UploadAttachment> uploadedAttachments = [];

      final now = DateTime.now().millisecondsSinceEpoch;
      final tempId = const Uuid().v4();
      late String currentChatId;

      await database.transaction(() async {
        currentChatId = request.chatId ?? "";

        if (currentChatId.isEmpty || currentChatId.startsWith("local_")) {
          currentChatId = "local_${request.receiverId}";
        }

        await chatListTableProviderRef.createOrUpdateChatList(
          ChatListModal(
            id: currentChatId,
            chatId: currentChatId,
            name: request.receiverName,
            lastMessage: (request.message.isNotEmpty)
                ? request.message
                : request.attachments.isNotEmpty
                ? "You sent media"
                : "",
            lastMessageTime: now.toString(),
            unReadCount: 0,
            type: request.type ?? "DIRECT",
            receiverId: request.receiverId,
          ),
        );

        await messagesTableProviderRef.createTempMessage(
          MessageBodyRequest(
            chatId: currentChatId,
            isRead: true,
            message: request.message,
            senderId: currentUserId,
            tempId: tempId,
          ),
        );

        if (request.attachments.isNotEmpty) {
          final mediasToInsert = request.attachments.map((attachment) {
            final mime =
                lookupMimeType(attachment.path) ?? "application/octet-stream";
            return UploadAttachment(
              key: "",
              contentType: mime,
              type: getMediaType(mime),
              location: attachment.path,
              name: attachment.name,
              url: "",
            );
          }).toList();

          await mediaTableProviderRef.bulkAddMediaDocuments(
            mediasToInsert,
            tempId,
          );
        }

        await messageStatusTableProviderRef.createLocalParticipantsStatus(
          tempId,
          currentUserId ?? "",
          currentChatId,
          now,
        );
      });
      final isRealChat = !currentChatId.startsWith("local_");
      if (request.attachments.isNotEmpty) {
        final futures = request.attachments.map((attachment) async {
          final mime =
              lookupMimeType(attachment.path) ?? "application/octet-stream";

          final presignedUrl = await UploadService(ApiClient()).getPresignedUrl(
            assetType: "chat",
            entityType: "attachments",
            contentType: mime,
            entityId: request.chatId ?? currentChatId,
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
          "message": request.message,
          "receiver_id": request.receiverId,
          "temp_id": tempId,
          "attachments": uploadedAttachments.map((e) => e.toJson()).toList(),
          if (isRealChat) "chat_id": currentChatId,
        },
        (response) async {
          final payload = SendMessageAck.fromJson(response);
          final realChatId = payload.chatId;
          final messageId = payload.messageId;
          final createdAt = parseTimestamp(payload.createdAt);

          if (currentChatId.startsWith("local_")) {
            await ref
                .read(chatParticipantsTableProvider.notifier)
                .updateParticipantsChatId(currentChatId, realChatId);
          }
          request.onChatResolved?.call(realChatId);

          await ref
              .read(chatListTableProvider.notifier)
              .updateChatId(currentChatId, realChatId);
          await messagesTableProviderRef.updateTempMessage(
            MessageBodyRequest(
              chatId: realChatId,
              tempId: tempId,
              createdAt: createdAt,
            ),
            messageId,
          );

          await mediaTableProviderRef.updateActorId(tempId, messageId);

          await mediaTableProviderRef.updateUploadedMedia(
            messageId,
            payload.attachments,
          );

          final messageStatusProviderRef = ref.read(
            messageStatusTableProvider.notifier,
          );
          await messageStatusProviderRef.deleteMessageStatus(tempId);
          await messageStatusProviderRef.bulkCreateMessageStatus(
            payload.messageStatuses,
            messageId,
          );
        },
      );
    } catch (e) {
      debugPrint("Error sending message: $e");
    }
  }

  Future<void> messageDelivered() async {
    ref.read(socketProvider).listenOnce("message_delivered", (data) async {
      _acknowledgeEvent(data);
      _statusQueue.add(() async {
        await _retry(() async {
          final payload = MessageDeliveredResponse.fromJson(data);

          await ref
              .read(messageStatusTableProvider.notifier)
              .updateMessageStatus(payload, statusRank);
        });
      });
      _processStatusQueue();
    });
  }

  Future<void> markRead() async {
    ref.read(socketProvider).listenOnce("message_read", (data) async {
      _acknowledgeEvent(data);

      _statusQueue.add(() async {
        await _retry(() async {
          final payload = MessageReadResponse.fromJson(data);

          await ref
              .read(messageStatusTableProvider.notifier)
              .updateMessageReadStatus(payload, statusRank);
        });
      });

      _processStatusQueue();
    });
  }

  Future<void> markChatMessagesRead(String chatId) async {
    final db = ref.read(databaseProvider);

    final currentUser = ref.watch(userPreferenceTableProvider).value;
    if (currentUser == null) return;

    final now = DateTime.now().millisecondsSinceEpoch;

    final statusProvider = ref.read(messageStatusTableProvider.notifier);

    final unreadStatuses = await statusProvider.getUnreadStatusesForChat(
      chatId: chatId,
      userId: currentUser,
    );

    if (unreadStatuses.isEmpty) return;

    final messageIds = unreadStatuses.map((e) => e.messageId).toList();

    await statusProvider.bulkUpdateMessageReadStatus(
      messageIds: messageIds,
      userId: currentUser,
      readAt: now,
    );

    final socket = ref.read(socketProvider);

    for (final id in messageIds) {
      socket.emitEvent("message_read", {"message_id": id, "chat_id": chatId});
    }

    await db.managers.chatListTable
        .filter((f) => f.chatId.equals(chatId))
        .update((o) => o(unReadCount: const Value(0)));
  }

  void sendChatSyncEvent() {
    ref.read(socketProvider).emitEvent("chat_sync", null);
  }

  Future<void> sendQueueMessages() async {
    final db = ref.read(databaseProvider);
    final socketService = ref.read(socketProvider);
    final currentUser = ref.watch(userPreferenceTableProvider).value;

    if (currentUser == null) return;
    if (!socketService.isConnected) return;

    final messages = await db.managers.messages
        .filter((f) => f.message.equals("sending"))
        .get();

    for (final msg in messages) {
      if (msg.serverId != null) continue;

      final participants = await db.managers.chatParticipants
          .filter((f) => f.chatId.equals(msg.chatId))
          .get();

      final receiver = participants.firstWhere((p) => p.userId != currentUser);

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
          final createdAt = parseTimestamp(response["created_at"]);

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
      ref.read(socketProvider).emitEvent("is_typing", {"chat_id": chatId});
    }
  }

  bool _typingListenerAdded = false;

  void receiveTypingEvent() {
    if (_typingListenerAdded) return;
    _typingListenerAdded = true;

    ref.read(socketProvider).listenOnce("user_typing", (dynamic data) {
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
      ref.read(socketProvider).emitEvent("stop_typing", {"chat_id": chatId});
    }
  }

  void receiveStopTypingEvent() {
    ref.read(socketProvider).listenOnce("user_stop_typing", (dynamic data) {
      final chatId = data["chat_id"];
      if (chatId != null) {
        ref.read(messageTypingProvider.notifier).clearTyping(chatId);
      }
    });
  }

  Future<void> groupChatCreatedListener() async {
    try {
      ref.read(socketProvider).listenOnce("group-created", (
        dynamic data,
      ) async {
        _acknowledgeEvent(data);
        final currentUser = ref.watch(userPreferenceTableProvider).value;
        debugPrint("current USer Exist: $currentUser");
        if (currentUser == null) return;

        final payload = CreateGroupResponse.fromJson(
          Map<String, dynamic>.from(data),
        );
        log(payload.toString());

        if (payload.data?.chatId.isEmpty ?? true) return;
        ref
            .read(chatListTableProvider.notifier)
            .createOrUpdateChatList(
              ChatListModal(
                id: currentUser,
                chatId: payload.data!.chatId,
                lastMessage: "",
                lastMessageTime: DateTime.now().millisecondsSinceEpoch
                    .toString(),
                bio: payload.data?.bio,
                type: "GROUP",
              ),
            );
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
