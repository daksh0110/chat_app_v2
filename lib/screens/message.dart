import 'dart:io';
import 'package:my_app/colors/defaullt_color_sheet.dart';
import 'package:my_app/providers/tables/chat_settings_table_provider.dart';
import 'package:my_app/providers/tables/chat_participants_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_app/modal/screens/message/message_screen_data.dart';
import 'package:my_app/modal/screens/message/reply_message_info.dart';
import 'package:my_app/modal/screens/message/send_message_request.dart';
import 'package:my_app/modal/screens/search/message_screen_arguments.dart';
import 'package:my_app/providers/chat_list_provider.dart';
import 'package:my_app/providers/chat_message_provider.dart';
import 'package:my_app/providers/chat_reactions_provider.dart';
import 'package:my_app/providers/database_provider.dart';
import 'package:my_app/providers/message_provider.dart';
import 'package:my_app/providers/message_screen_provider.dart';
import 'package:my_app/providers/message_typing_provider.dart';
import 'package:my_app/providers/socket_provider.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_app/modal/screens/message/message_item_model.dart';
import 'package:my_app/providers/tables/messages_table_provider.dart';
import 'package:my_app/providers/tables/request_user_provider.dart';
import 'package:my_app/providers/tables/user_preference_table_provider.dart';
import 'package:my_app/providers/user_relationship_provider.dart';
import 'package:my_app/widgets/comman/primary_text.dart';
import 'package:my_app/widgets/screens/message/chat_input_box.dart';
import 'package:my_app/widgets/screens/message/date_banner.dart';
import 'package:my_app/widgets/screens/message/delete_message_dialog.dart';
import 'package:my_app/widgets/screens/message/editing_message_info.dart';
import 'package:my_app/widgets/screens/message/forward_message_dialog.dart';
import 'package:my_app/widgets/screens/message/friendship_banner.dart';
import 'package:my_app/widgets/screens/message/header.dart';
import 'package:my_app/widgets/screens/message/message_info_sheet.dart';
import 'package:my_app/widgets/screens/message/message_item.dart';
import 'package:my_app/widgets/screens/message/pinned_message_banner.dart';
import 'package:my_app/widgets/screens/message/typing_indicator.dart';

class MessageScreen extends ConsumerStatefulWidget {
  const MessageScreen({super.key});

  @override
  ConsumerState<MessageScreen> createState() {
    return _MessageScreen();
  }
}

class _MessageScreen extends ConsumerState<MessageScreen> {
  final ScrollController _scrollController = ScrollController();
  late String chatId;
  late String receiverId;
  late String name;
  String? profilePicUrl;
  String? _lastActiveUserId;
  bool _isOnline = false;
  late bool isGroup = false;
  late final ChatListController _chatListController;
  final Set<String> _onlineGroupMembers = {};
  List<String> _groupParticipantIds = [];
  ReplyMessageInfo? _replyingTo;
  final Set<String> _selectedMessageIds = {};
  final Map<String, MessageItemModel> _selectedMessagesMap = {};
  EditingMessageInfo? _editingMessage;
  @override
  void initState() {
    super.initState();

    _chatListController = ref.read(chatListControllerProvider);
  }

  Future<void> _loadGroupParticipants() async {
    final db = ref.read(databaseProvider);
    final participants = await db.managers.chatParticipants
        .filter((f) => f.chatId.equals(chatId))
        .get();
    if (mounted) {
      setState(() {
        _groupParticipantIds = participants.map((p) => p.userId).toList();
      });
    }
  }

  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_initialized) return;
    _initialized = true;

    final args =
        ModalRoute.of(context)!.settings.arguments as MessageScreenArguments;

    chatId = args.chatId;
    receiverId = args.receiverId;
    name = args.name;
    profilePicUrl = args.profilePicUrl;
    isGroup = args.isGroupChat == "GROUP";

    _loadChatData().then((_) {
      if (mounted) {
        _initialiseSockets();
      }
    });
  }

  void _initialiseSockets() {
    final socketService = ref.watch(socketProvider);

    socketService.getUserStatus((data) {
      if (data["userId"] == receiverId && mounted) {
        final isBlocked =
            ref.read(userRelationshipProvider(receiverId)).value ==
            RelationshipStatus.blocked;
        setState(() => _isOnline = !isBlocked && data["online"] == true);
      }
    });

    socketService.getGroupStatus((data) {
      if (data["chatId"] == chatId && mounted) {
        setState(() {
          _onlineGroupMembers.clear();
          _onlineGroupMembers.addAll(List<String>.from(data["onlineMembers"]));
        });
      }
    });

    socketService.listenUserOnline((data) {
      final userId = data["userId"];
      if (mounted) {
        if (isGroup) {
          if (_groupParticipantIds.contains(userId)) {
            setState(() {
              _onlineGroupMembers.add(userId);
            });
          }
        } else {
          final isBlocked =
              ref.read(userRelationshipProvider(receiverId)).value ==
              RelationshipStatus.blocked;
          if (userId == receiverId && !isBlocked) {
            setState(() => _isOnline = true);
          }
        }
      }
    });

    socketService.listenUserOffline((data) {
      final userId = data["userId"];
      if (mounted) {
        if (isGroup) {
          setState(() {
            _onlineGroupMembers.remove(userId);
          });
        } else {
          if (userId == receiverId) {
            setState(() => _isOnline = false);
          }
        }
      }
    });

    if (isGroup) {
      _loadGroupParticipants().then((_) {
        socketService.checkGroupStatus(chatId);
      });
    } else {
      socketService.checkUserStatus(receiverId);
    }
  }

  @override
  void dispose() {
    if (chatId.isNotEmpty) {
      _chatListController.markChatAsRead(chatId);
    }
    _chatListController.setActiveChatId(null);
    _scrollController.dispose();
    super.dispose();
  }

  void _handleSend(String text, List<XFile> attachments) async {
    if (!isGroup) {
      if (receiverId.isNotEmpty) {
        final status = ref.read(userRelationshipProvider(receiverId)).value;
        if (status != RelationshipStatus.friends) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("You can only message friends")),
          );
          return;
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Recipient not resolved yet")),
        );
        return;
      }
    }

    final replyTo = _replyingTo;
    if (_replyingTo != null) {
      setState(() {
        _replyingTo = null;
      });
    }

    ref
        .read(messageProvider.notifier)
        .sendMessage(
          SendMessageRequest(
            receiverId: receiverId,
            receiverName: name,
            attachments: attachments,
            chatId: chatId,
            message: text,
            type: isGroup ? "GROUP" : "DIRECT",
            replyTo: replyTo,
            onChatResolved: (realId) {
              if (mounted) {
                setState(() {
                  chatId = realId;
                });
                if (_lastActiveUserId != realId) {
                  _lastActiveUserId = realId;
                  _chatListController.setActiveChatId(realId);
                }
              }
            },
          ),
        );
  }

  void onTyping() {
    final isBlocked = !isGroup && receiverId.isNotEmpty
        ? ref.read(userRelationshipProvider(receiverId)).value ==
            RelationshipStatus.blocked
        : false;
    if (isBlocked) return;
    ref.read(messageProvider.notifier).sendTypingEvent(chatId);
  }

  void onStopTyping() {
    final isBlocked = !isGroup && receiverId.isNotEmpty
        ? ref.read(userRelationshipProvider(receiverId)).value ==
            RelationshipStatus.blocked
        : false;
    if (isBlocked) return;
    ref.read(messageProvider.notifier).sendStopTypingEvent(chatId);
  }

  void _toggleSelection(MessageItemModel message) {
    setState(() {
      if (_selectedMessageIds.contains(message.id)) {
        _selectedMessageIds.remove(message.id);
        _selectedMessagesMap.remove(message.id);
      } else {
        _selectedMessageIds.add(message.id);
        _selectedMessagesMap[message.id] = message;
      }
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedMessageIds.clear();
      _selectedMessagesMap.clear();
    });
  }

  void _handleReply(MessageItemModel item) {
    final currentUser = ref.read(userPreferenceTableProvider).value;
    setState(() {
      _replyingTo = ReplyMessageInfo(
        messageId: item.id,
        senderId: item.isSender ? (currentUser ?? "") : receiverId,
        senderName: item.isSender ? "You" : item.senderName,
        message: item.message.isNotEmpty
            ? item.message
            : (item.attachments.isNotEmpty ? "Attachment" : ""),
      );
    });
  }

  void _copySelectedMessages() {
    final texts = _selectedMessagesMap.values
        .where((m) => !m.isDeleted && m.message.isNotEmpty)
        .map((m) => m.message)
        .toList();

    if (texts.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: texts.join('\n')));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            texts.length == 1
                ? 'Message copied'
                : '${texts.length} messages copied',
          ),
          duration: const Duration(seconds: 1),
        ),
      );
    }
    _clearSelection();
  }

  void _togglePin(MessageItemModel message) {
    final newPinnedState = !message.isPinned;
    ref.read(messageProvider.notifier).togglePinMessage(
      messageId: message.id,
      chatId: chatId,
      isPinned: newPinnedState,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          newPinnedState ? 'Message pinned' : 'Message unpinned',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
    if (_selectedMessageIds.isNotEmpty) {
      _clearSelection();
    }
  }

  Future<void> _deleteSelectedMessages(List<MessageItemModel> messages) async {
    final isCurrentUserGroupAdmin =
        isGroup && (ref.read(isGroupAdminProvider(chatId)).value ?? false);

    final canDeleteForEveryone = messages.every(
      (m) => m.isSender || isCurrentUserGroupAdmin,
    );

    final deleteType = await showDeleteMessageDialog(
      context,
      canDeleteForEveryone: canDeleteForEveryone,
    );

    if (deleteType == null) return;

    final deleteForEveryone = deleteType == DeleteMessageType.everyone;

    for (final item in messages) {
      ref.read(messageProvider.notifier).deleteMessage(
        messageId: item.id,
        chatId: chatId,
        deleteForEveryone: deleteForEveryone,
      );
    }

    _clearSelection();
  }

  Future<void> _forwardMessages(List<MessageItemModel> messages) async {
    if (messages.isEmpty) return;

    final targetChats = await ForwardMessageDialog.show(
      context,
      messages: messages,
    );

    if (targetChats == null || targetChats.isEmpty) return;

    for (final target in targetChats) {
      for (final msg in messages) {
        final files = msg.attachments
            .where((a) => a.url != null && a.url!.isNotEmpty)
            .map((a) => XFile(a.url!))
            .toList();

        ref.read(messageProvider.notifier).sendMessage(
          SendMessageRequest(
            receiverId: target.receiverId ?? target.chatId,
            receiverName: target.name ?? "Chat",
            chatId: target.chatId,
            message: msg.message,
            attachments: files,
            type: target.type == "GROUP" ? "GROUP" : "DIRECT",
          ),
        );
      }
    }

    _clearSelection();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Forwarded to ${targetChats.length} ${targetChats.length == 1 ? "chat" : "chats"}',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showMessageInfo(MessageItemModel item) {
    MessageInfoSheet.show(
      context,
      message: item,
      chatId: chatId,
      isGroup: isGroup,
    );
  }

  PreferredSizeWidget _buildSelectionAppBar() {
    final count = _selectedMessageIds.length;
    final selectedList = _selectedMessagesMap.values.toList();
    final singleMessage = count == 1 ? selectedList.first : null;
    final canEditSingle = singleMessage != null &&
        singleMessage.isSender &&
        !singleMessage.isDeleted &&
        singleMessage.message.isNotEmpty;
    final isSinglePinned = singleMessage?.isPinned ?? false;

    return AppBar(
      backgroundColor: DefaultColorSheet.surfaceBg(context),
      elevation: 1,
      leading: IconButton(
        icon: const Icon(LucideIcons.x),
        color: DefaultColorSheet.iconColor(context),
        onPressed: _clearSelection,
      ),
      titleSpacing: 0,
      title: PrimaryText(
        '$count',
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: DefaultColorSheet.textPrimary(context),
      ),
      actions: [
        if (singleMessage != null && !singleMessage.isDeleted)
          IconButton(
            icon: const Icon(LucideIcons.reply, size: 20),
            color: DefaultColorSheet.iconColor(context),
            tooltip: 'Reply',
            onPressed: () {
              final item = singleMessage;
              _clearSelection();
              _handleReply(item);
            },
          ),
        if (singleMessage != null &&
            singleMessage.isSender &&
            !singleMessage.isDeleted)
          IconButton(
            icon: const Icon(LucideIcons.info, size: 20),
            color: DefaultColorSheet.iconColor(context),
            tooltip: 'Info',
            onPressed: () {
              final item = singleMessage;
              _clearSelection();
              _showMessageInfo(item);
            },
          ),
        if (canEditSingle)
          IconButton(
            icon: const Icon(LucideIcons.pencil, size: 20),
            color: DefaultColorSheet.iconColor(context),
            tooltip: 'Edit',
            onPressed: () {
              final item = singleMessage;
              _clearSelection();
              setState(() {
                _editingMessage = EditingMessageInfo(
                  messageId: item.id,
                  text: item.message,
                );
              });
            },
          ),
        if (singleMessage != null && !singleMessage.isDeleted)
          IconButton(
            icon: Icon(
              isSinglePinned ? LucideIcons.pinOff : LucideIcons.pin,
              size: 20,
            ),
            color: isSinglePinned
                ? Colors.amber.shade700
                : DefaultColorSheet.iconColor(context),
            tooltip: isSinglePinned ? 'Unpin' : 'Pin',
            onPressed: () {
              final item = singleMessage;
              _clearSelection();
              _togglePin(item);
            },
          ),
        IconButton(
          icon: const Icon(LucideIcons.copy, size: 20),
          color: DefaultColorSheet.iconColor(context),
          tooltip: 'Copy',
          onPressed: _copySelectedMessages,
        ),
        IconButton(
          icon: const Icon(LucideIcons.forward, size: 20),
          color: DefaultColorSheet.iconColor(context),
          tooltip: 'Forward',
          onPressed: () => _forwardMessages(selectedList),
        ),
        IconButton(
          icon: const Icon(LucideIcons.trash2, size: 20),
          color: Colors.redAccent,
          tooltip: 'Delete',
          onPressed: () => _deleteSelectedMessages(selectedList),
        ),
      ],
    );
  }

  Future<void> _loadChatData() async {
    MessageScreenData? data;

    if (chatId.isNotEmpty) {
      data = await ref
          .read(messageScreenProvider.notifier)
          .fetchChatDetailsFromChatId(chatId);
    } else if (receiverId.isNotEmpty) {
      data = await ref
          .read(messageScreenProvider.notifier)
          .fetchChatDetailsFromReceiverId(receiverId);
    }

    final chatData = data;
    if (!mounted || chatData == null) return;

    final newChatId = chatData.chatId;
    final newReceiverId = chatData.receiverId;
    final newName = chatData.name;
    final newProfilePic = chatData.profilePic;
    final newIsGroup = chatData.type == "GROUP";

    setState(() {
      if (newChatId != null && newChatId.isNotEmpty) {
        chatId = newChatId;
      }
      receiverId = newReceiverId ?? receiverId;
      name = newName ?? name;
      profilePicUrl = newProfilePic ?? profilePicUrl;
      isGroup = newIsGroup;
    });

    if (newChatId != null &&
        newChatId.isNotEmpty &&
        _lastActiveUserId != newChatId) {
      _lastActiveUserId = newChatId;
      _chatListController.setActiveChatId(newChatId);
      ref.read(messageProvider.notifier).markChatMessagesRead(newChatId);
    }

    if (!isGroup &&
        receiverId.isNotEmpty &&
        chatId.isNotEmpty &&
        !chatId.startsWith("local_")) {
      final currentStatus = await ref
          .read(requestUserProvider.notifier)
          .getRelationshipStatus(receiverId);
      if (currentStatus != RelationshipStatus.friends &&
          currentStatus != RelationshipStatus.blocked) {
        await ref
            .read(requestUserProvider.notifier)
            .insertOrUpdateRequest(receiverId, 'FRIENDS');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final typingMap = ref.watch(messageTypingProvider);
    final currentUser = ref.watch(userPreferenceTableProvider).value;

    final relationshipStatus = !isGroup
        ? (receiverId.isNotEmpty
            ? ref.watch(userRelationshipProvider(receiverId)).value ??
                RelationshipStatus.none
            : RelationshipStatus.none)
        : RelationshipStatus.friends;

    final isBlocked = relationshipStatus == RelationshipStatus.blocked;

    final isParticipant =
        !isGroup || (ref.watch(isGroupParticipantProvider(chatId)).value ?? true);

    final isCurrentUserGroupAdmin =
        isGroup && (ref.watch(isGroupAdminProvider(chatId)).value ?? false);

    final isTyping = !isBlocked && typingMap[chatId] == true;

    final onlineCount = currentUser != null
        ? _onlineGroupMembers.where((id) => id != currentUser).length
        : _onlineGroupMembers.length;
    final totalMembers = _groupParticipantIds.length;

    final subtitle = isGroup
        ? (onlineCount > 0 ? "$onlineCount online" : "$totalMembers members")
        : (!isBlocked && _isOnline ? "Online" : null);

    final chatSettings = ref
        .watch(chatSettingsStreamProvider(chatId.isNotEmpty ? chatId : receiverId))
        .value;
    final customWallpaper = chatSettings?.wallpaper;

    final defaultBg = DefaultColorSheet.chatBg(context);
    BoxDecoration? bgDecoration;
    Color? scaffoldBg;

    if (customWallpaper != null && customWallpaper.isNotEmpty) {
      if (customWallpaper.startsWith('0x') || customWallpaper.startsWith('0X')) {
        scaffoldBg = Color(int.tryParse(customWallpaper) ?? 0xFFECE5DD);
      } else if (File(customWallpaper).existsSync()) {
        bgDecoration = BoxDecoration(
          image: DecorationImage(
            image: FileImage(File(customWallpaper)),
            fit: BoxFit.cover,
          ),
        );
      }
    }
    scaffoldBg ??= defaultBg;

    return PopScope(
      canPop: _selectedMessageIds.isEmpty,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          _clearSelection();
        }
      },
      child: Scaffold(
        backgroundColor: scaffoldBg,
        appBar: _selectedMessageIds.isNotEmpty
            ? _buildSelectionAppBar()
            : Header(
                id: chatId.isNotEmpty ? chatId : receiverId,
                name: name,
                isOnline: !isBlocked && _isOnline,
                profilePicUrl: profilePicUrl,
                isGroupChat: isGroup,
                subtitle: subtitle,
              ),
        body: Container(
          decoration: bgDecoration,
          child: SafeArea(
            child: Column(
              children: [
                if (chatId.isNotEmpty)
                  Consumer(
                    builder: (context, ref, _) {
                      final pinnedAsync =
                          ref.watch(pinnedMessagesProvider(chatId));
                      return pinnedAsync.when(
                        data: (pinnedRows) {
                          if (pinnedRows.isEmpty) return const SizedBox.shrink();
                          final currentUser =
                              ref.watch(userPreferenceTableProvider).value;
                          final models = pinnedRows.map((m) {
                            final isMe = m.senderId == currentUser;
                            return MessageItemModel(
                              id: m.id,
                              message: m.message,
                              isSender: isMe,
                              timestamp: m.createdAt,
                              senderName: isMe ? 'You' : name,
                              isPinned: m.isPinned,
                              pinnedAt: m.pinnedAt,
                              isEdited: m.isEdited,
                              reactions: const [],
                              attachments: const [],
                              isDeleted: m.isDeleted,
                            );
                          }).toList();

                          return PinnedMessageBanner(
                            pinnedMessages: models,
                            onTap: (pinnedMsg) {
                              // Optional: scroll to message
                            },
                            onUnpin: (pinnedMsg) {
                              _togglePin(pinnedMsg);
                            },
                          );
                        },
                        loading: () => const SizedBox.shrink(),
                        error: (_, _) => const SizedBox.shrink(),
                      );
                    },
                  ),
                Expanded(
                  child: Consumer(
                    builder: (context, ref, _) {
                      final messagesAsync = ref.watch(
                        chatMessagesProvider((
                          chatId: chatId,
                          receiverId: receiverId,
                        )),
                      );
                      final reactionsMap =
                          ref.watch(chatReactionsProvider(chatId)).value ??
                          const {};

                      return messagesAsync.when(
                        data: (events) {
                          return ListView.builder(
                            controller: _scrollController,
                            reverse: true,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            itemCount: events.length + (isTyping ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (isTyping && index == 0) {
                                return TypingIndicator();
                              }

                              final eventIndex = isTyping ? index - 1 : index;
                              final event = events[eventIndex];

                              return switch (event) {
                                DateBannerTimelineEvent(:final label) =>
                                  DateBanner(label: label),
                                MessageTimelineEvent(:final model) => MessageItem(
                                    data: model.copyWith(
                                      reactions:
                                          reactionsMap[model.id] ?? const [],
                                    ),
                                    isGroupAdmin: isCurrentUserGroupAdmin,
                                    isSelected:
                                        _selectedMessageIds.contains(model.id),
                                    isSelecting: _selectedMessageIds.isNotEmpty,
                                    onSelectionTap: () =>
                                        _toggleSelection(model),
                                    onSelect: (item) => _toggleSelection(item),
                                    onInfo: (item) => _showMessageInfo(item),
                                    onReply: (item) => _handleReply(item),
                                    onEdit: (item) {
                                      setState(() {
                                        _editingMessage = EditingMessageInfo(
                                          messageId: item.id,
                                          text: item.message,
                                        );
                                      });
                                    },
                                    onPin: (item) => _togglePin(item),
                                    onForward: (item) =>
                                        _forwardMessages([item]),
                                    onReact: (messageId, emoji) {
                                      ref
                                          .read(messageProvider.notifier)
                                          .toggleReaction(
                                            messageId: messageId,
                                            chatId: chatId,
                                            emoji: emoji,
                                          );
                                    },
                                    onDelete: (item, deleteForEveryone) {
                                      ref
                                          .read(messageProvider.notifier)
                                          .deleteMessage(
                                            messageId: item.id,
                                            chatId: chatId,
                                            deleteForEveryone:
                                                deleteForEveryone,
                                          );
                                    },
                                  ),
                                BannerTimelineEvent(:final text) =>
                                  DateBanner(label: text),
                              };
                            },
                          );
                        },
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (e, _) => Center(child: Text(e.toString())),
                      );
                    },
                  ),
                ),
                if (isBlocked)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 16,
                    ),
                    color: Colors.grey.shade900,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "You blocked this contact. ",
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        GestureDetector(
                          onTap: () {
                            ref
                                .read(
                                    userRelationshipProvider(receiverId).notifier)
                                .unblockUser();
                          },
                          child: const Text(
                            "Unblock",
                            style: TextStyle(
                              color: Colors.blueAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else if (isGroup && !isParticipant)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 20,
                    ),
                    color: Colors.grey.shade900,
                    child: const Text(
                      "You can't send messages to this group because you're no longer a member.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  )
                else if (!isGroup &&
                    receiverId.isNotEmpty &&
                    relationshipStatus != RelationshipStatus.friends &&
                    !isBlocked)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: FriendshipBanner(
                      receiverId: receiverId,
                      name: name,
                      status: relationshipStatus,
                    ),
                  )
                else
                  ChatInputBox(
                    onSend: _handleSend,
                    onTyping: onTyping,
                    onStopTyping: onStopTyping,
                    replyingTo: _replyingTo,
                    onCancelReply: () {
                      setState(() {
                        _replyingTo = null;
                      });
                    },
                    editingMessage: _editingMessage,
                    onEdit: (messageId, newText) {
                      ref.read(messageProvider.notifier).editMessage(
                            messageId: messageId,
                            chatId: chatId,
                            newText: newText,
                          );
                      setState(() => _editingMessage = null);
                    },
                    onCancelEdit: () {
                      setState(() => _editingMessage = null);
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}
