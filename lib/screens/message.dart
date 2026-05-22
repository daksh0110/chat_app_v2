import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_app/core/util/getDatelabel.dart';
import 'package:my_app/core/util/status_map.dart';
import 'package:my_app/modal/screens/search/message_screen_arguments.dart';
import 'package:my_app/providers/chat_list_provider.dart';
import 'package:my_app/providers/chat_message_provider.dart';
import 'package:my_app/providers/database_provider.dart';
import 'package:my_app/providers/message_provider.dart';
import 'package:my_app/providers/message_typing_provider.dart';
import 'package:my_app/providers/settings_user_notifier_provider.dart';
import 'package:my_app/providers/socket_provider.dart';
import 'package:my_app/widgets/screens/message/chat_input_box.dart';
import 'package:my_app/widgets/screens/message/date_banner.dart';
import 'package:my_app/widgets/screens/message/header.dart';
import 'package:my_app/widgets/screens/message/message_item.dart';
import 'package:my_app/widgets/screens/message/typing_indicator.dart';
import 'package:drift/drift.dart' hide Column;

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
  String? _lastActiveUserId;
  bool _isOnline = false;
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
    final isGroup = args.isGroupChat == "GROUP";

    if (_lastActiveUserId != chatId) {
      _lastActiveUserId = chatId;
      _chatListController.setActiveChatId(chatId);
    }

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
      if (receiverId.isEmpty) {
        _resolveReceiverId(chatId).then((id) {
          if (id != null && mounted) {
            setState(() {
              receiverId = id;
            });

            socketService.checkUserStatus(receiverId);
          }
        });
      } else {
        socketService.checkUserStatus(receiverId);
      }
    }

    if (chatId.isEmpty && receiverId.isNotEmpty) {
      _resolveChatId();
    } else {
      Future.microtask(() {
        ref.read(messageProvider.notifier).markChatMessagesRead(chatId);
      });
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
          message: text,
          receiverId: receiverId,
          receiverName: name,
          chatId: chatId,
          attachments: attachments,
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
        );
  }

  void onTyping() {
    ref.read(messageProvider.notifier).sendTypingEvent(chatId);
  }

  void onStopTyping() {
    ref.read(messageProvider.notifier).sendStopTypingEvent(chatId);
  }

  Future<String?> _resolveReceiverId(String chatId) async {
    final db = ref.read(databaseProvider);
    final currentUser = ref.read(settingsUserProvider);
    if (currentUser == null) return null;

    final participants = await db.managers.chatParticipants
        .filter((f) => f.chatId.equals(chatId))
        .get();

    try {
      return participants.firstWhere((p) => p.userId != currentUser.id).userId;
    } catch (_) {
      return null;
    }
  }

  Future<void> _resolveChatId() async {
    final db = ref.read(databaseProvider);
    final currentUser = ref.read(settingsUserProvider);
    if (currentUser == null || receiverId.isEmpty) return;

    final participantRows = await db.managers.chatParticipants
        .filter((f) => f.userId.equals(receiverId))
        .get();

    for (final p in participantRows) {
      final chat = await db.managers.chatListTable
          .filter((f) => f.chatId.equals(p.chatId) & f.type.equals("DIRECT"))
          .getSingleOrNull();

      if (chat != null && mounted) {
        setState(() {
          chatId = chat.chatId;
        });

        if (_lastActiveUserId != chatId) {
          _lastActiveUserId = chatId;
          _chatListController.setActiveChatId(chatId);
        }

        Future.microtask(() {
          ref.read(messageProvider.notifier).markChatMessagesRead(chatId);
        });
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final typingMap = ref.watch(messageTypingProvider);
    final args =
        ModalRoute.of(context)!.settings.arguments as MessageScreenArguments;
    final String name = args.name;
    final String isGroupChat = args.isGroupChat;
    final isGroup = isGroupChat == "GROUP";
    final currentUser = ref.watch(settingsUserProvider);
    final isTyping = typingMap[chatId] == true;

    final onlineCount = currentUser != null
        ? _onlineGroupMembers.where((id) => id != currentUser.id).length
        : _onlineGroupMembers.length;
    final totalMembers = _groupParticipantIds.length;

    final subtitle = isGroup
        ? (onlineCount > 0 ? "$onlineCount online" : "$totalMembers members")
        : null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: Header(
        id: isGroupChat == "GROUP" ? chatId : receiverId,
        name: name,
        isOnline: _isOnline,
        profilePicUrl: args.profilePicUrl,
        isGroupChat: isGroupChat == "GROUP",
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
                        return const Center(child: CircularProgressIndicator());
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
                          if (msgIndex < messages.length - 1) {
                            final prevMsg =
                                messages[messages.length - 1 - (msgIndex + 1)];
                            previousLabel = getDateLabel(
                              prevMsg.message.createdAt,
                            );
                          }

                          final showBanner = currentLabel != previousLabel;

                          return Column(
                            children: [
                              if (showBanner) DateBanner(label: currentLabel),

                              MessageItem(
                                attachments: item.attachments,
                                message: msg.message,
                                isSender: msg.senderId == currentUser.id,
                                status: msg.senderId == currentUser.id
                                    ? statusMap(item.overallStatus)
                                    : statusMap("sending"),
                                timestamp: msg.createdAt,
                                senderName: sender.userId == currentUser.id
                                    ? "You"
                                    : sender.name,
                                isGroupChat: isGroupChat == "GROUP",
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
