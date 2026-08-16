import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_app/core/util/getDatelabel.dart';
import 'package:my_app/core/util/status_map.dart';
import 'package:my_app/modal/screens/message/message_screen_data.dart';
import 'package:my_app/modal/screens/message/send_message_request.dart';
import 'package:my_app/modal/screens/search/message_screen_arguments.dart';
import 'package:my_app/providers/chat_list_provider.dart';
import 'package:my_app/providers/chat_message_provider.dart';
import 'package:my_app/providers/database_provider.dart';
import 'package:my_app/providers/message_provider.dart';
import 'package:my_app/providers/message_screen_provider.dart';
import 'package:my_app/providers/message_typing_provider.dart';
import 'package:my_app/providers/socket_provider.dart';
import 'package:my_app/providers/tables/user_preference_table_provider.dart';
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
        setState(() => _isOnline = data["online"]);
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
          if (userId == receiverId) {
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
    ref.read(messageProvider.notifier).sendTypingEvent(chatId);
  }

  void onStopTyping() {
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

    if (!mounted || data == null) return;

    setState(() {
      chatId = data?.chatId ?? "";
      receiverId = data?.receiverId ?? receiverId;
      name = data?.name ?? name;
      profilePicUrl = data?.profilePic ?? profilePicUrl;
      isGroup = data?.type == "GROUP" ? true : false;
    });

    _chatListController.setActiveChatId(chatId);

    if (chatId.isNotEmpty) {
      ref.read(messageProvider.notifier).markChatMessagesRead(chatId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final typingMap = ref.watch(messageTypingProvider);
    final currentUser = ref.watch(userPreferenceTableProvider).value;
    final isTyping = typingMap[chatId] == true;

    final onlineCount = currentUser != null
        ? _onlineGroupMembers.where((id) => id != currentUser).length
        : _onlineGroupMembers.length;
    final totalMembers = _groupParticipantIds.length;

    final subtitle = isGroup
        ? (onlineCount > 0 ? "$onlineCount online" : "$totalMembers members")
        : null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: Header(
        id: chatId.isNotEmpty ? chatId : receiverId,
        name: name,
        isOnline: _isOnline,
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

                  return messagesAsync.when(
                    data: (messages) {
                      if (currentUser == null) {
                        throw Exception("Current user is not Set");
                      }

                      return ListView.builder(
                        controller: _scrollController,
                        reverse: true,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        itemCount: messages.length + (isTyping ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (isTyping && index == 0) {
                            return TypingIndicator();
                          }

                          final msgIndex = isTyping ? index - 1 : index;
                          final item = messages[messages.length - 1 - msgIndex];
                          final msg = item.message;
                          final sender = item.participant;
                          final currentLabel = getDateLabel(msg.createdAt);

                          String? previousLabel;
                          bool isGrouped = false;
                          if (msgIndex < messages.length - 1) {
                            final prevMsg =
                                messages[messages.length - 1 - (msgIndex + 1)];
                            previousLabel = getDateLabel(
                              prevMsg.message.createdAt,
                            );
                            isGrouped =
                                prevMsg.message.senderId == msg.senderId &&
                                (msg.createdAt - prevMsg.message.createdAt)
                                        .abs() <
                                    5 * 60 * 1000;
                          }

                          final showBanner = currentLabel != previousLabel;

                          if (showBanner) isGrouped = false;

                          return Column(
                            children: [
                              if (showBanner) DateBanner(label: currentLabel),

                              MessageItem(
                                attachments: item.attachments,
                                message: msg.message,
                                isSender: msg.senderId == currentUser,
                                status: msg.senderId == currentUser
                                    ? statusMap(item.overallStatus)
                                    : statusMap("sending"),
                                timestamp: msg.createdAt,
                                senderName: sender.userId == currentUser
                                    ? "You"
                                    : name,
                                isGroupChat: isGroup,
                                isGrouped: isGrouped,
                              ),
                            ],
                          );
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

            ChatInputBox(
              onSend: _handleSend,
              onTyping: onTyping,
              onStopTyping: onStopTyping,
            ),
          ],
        ),
      ),
    );
  }
}
