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
import 'package:my_app/providers/tables/user_preference_table_provider.dart';
import 'package:my_app/providers/user_relationship_provider.dart';
import 'package:my_app/widgets/screens/message/chat_input_box.dart';
import 'package:my_app/widgets/screens/message/date_banner.dart';
import 'package:my_app/widgets/screens/message/header.dart';
import 'package:my_app/widgets/screens/message/message_item.dart';
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
    _chatListController.setActiveChatId(null);
    _scrollController.dispose();
    super.dispose();
  }

  void _handleSend(String text, List<XFile> attachments) async {
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
  }

  @override
  Widget build(BuildContext context) {
    final typingMap = ref.watch(messageTypingProvider);
    final currentUser = ref.watch(userPreferenceTableProvider).value;

    final isBlocked = !isGroup && receiverId.isNotEmpty
        ? ref.watch(userRelationshipProvider(receiverId)).value ==
              RelationshipStatus.blocked
        : false;

    final isParticipant =
        !isGroup || (ref.watch(isGroupParticipantProvider(chatId)).value ?? true);

    final isTyping = !isBlocked && typingMap[chatId] == true;

    final onlineCount = currentUser != null
        ? _onlineGroupMembers.where((id) => id != currentUser).length
        : _onlineGroupMembers.length;
    final totalMembers = _groupParticipantIds.length;

    final subtitle = isGroup
        ? (onlineCount > 0 ? "$onlineCount online" : "$totalMembers members")
        : (!isBlocked && _isOnline ? "Online" : null);

    return Scaffold(
      backgroundColor: const Color(0xFFECE5DD),
      appBar: Header(
        id: chatId.isNotEmpty ? chatId : receiverId,
        name: name,
        isOnline: !isBlocked && _isOnline,
        profilePicUrl: profilePicUrl,
        isGroupChat: isGroup,
        subtitle: subtitle,
      ),
      body: SafeArea(
        child: Column(
          children: [
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
                            DateBannerTimelineEvent(:final label) => DateBanner(
                              label: label,
                            ),
                            MessageTimelineEvent(:final model) => MessageItem(
                              data: model.copyWith(
                                reactions: reactionsMap[model.id] ?? const [],
                              ),
                              onReply: (item) {
                                setState(() {
                                  _replyingTo = ReplyMessageInfo(
                                    messageId: item.id,
                                    senderId: item.isSender
                                        ? (currentUser ?? "")
                                        : receiverId,
                                    senderName: item.isSender
                                        ? "You"
                                        : item.senderName,
                                    message: item.message.isNotEmpty
                                        ? item.message
                                        : (item.attachments.isNotEmpty
                                            ? "Attachment"
                                            : ""),
                                  );
                                });
                              },
                              onReact: (messageId, emoji) {
                                ref
                                    .read(messageProvider.notifier)
                                    .toggleReaction(
                                      messageId: messageId,
                                      chatId: chatId,
                                      emoji: emoji,
                                    );
                              },
                            ),
                            BannerTimelineEvent(:final text) => DateBanner(
                              label: text,
                            ),
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
                            .read(userRelationshipProvider(receiverId).notifier)
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
              ),
          ],
        ),
      ),
    );
  }
}
