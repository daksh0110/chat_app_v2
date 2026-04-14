import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/core/util/getDatelabel.dart';
import 'package:my_app/core/util/status_map.dart';
import 'package:my_app/modal/screens/search/message_screen_arguments.dart';
import 'package:my_app/providers/chat_list_provider.dart';
import 'package:my_app/providers/chat_message_provider.dart';
import 'package:my_app/providers/message_provider.dart';
import 'package:my_app/providers/message_typing_provider.dart';
import 'package:my_app/providers/settings_user_notifier_provider.dart';
import 'package:my_app/providers/socket_provider.dart';
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
  late String receiverId;
  late String name;
  String? _lastActiveUserId;
  bool _isOnline = false;
  late final ChatListController _chatListController;
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _chatListController = ref.read(chatListControllerProvider);
    final args =
        ModalRoute.of(context)!.settings.arguments as MessageScreenArguments;

    receiverId = args.id;
    name = args.name;

    if (_lastActiveUserId != receiverId) {
      _lastActiveUserId = receiverId;
      _chatListController.setActiveChatUserId(receiverId);
    }

    final socketService = ref.watch(socketProvider);

    socketService.getUserStatus((data) {
      if (data["userId"] == receiverId && mounted) {
        setState(() => _isOnline = data["online"]);
      }
    });

    socketService.listenUserOnline((data) {
      if (data["userId"] == receiverId && mounted) {
        setState(() => _isOnline = true);
      }
    });

    socketService.listenUserOffline((data) {
      if (data["userId"] == receiverId && mounted) {
        setState(() => _isOnline = false);
      }
    });

    socketService.onConnect(() {
      socketService.checkUserStatus(receiverId);
    });

    socketService.checkUserStatus(receiverId);

    Future.microtask(() {
      ref.read(messageProvider.notifier).markChatMessagesRead(receiverId);
    });
  }

  @override
  void dispose() {
    _chatListController.setActiveChatUserId(null);
    _scrollController.dispose();
    super.dispose();
  }

  void _handleSend(String text) async {
    ref
        .read(messageProvider.notifier)
        .sendMessagea(
          message: text,
          receiverId: receiverId,
          receiverName: name,
        );
  }

  void onTyping() {
    ref.read(messageProvider.notifier).sendTypingEvent(receiverId);
  }

  void onStopTyping() {
    ref.read(messageProvider.notifier).sendStopTypingEvent(receiverId);
  }

  @override
  Widget build(BuildContext context) {
    final typingMap = ref.watch(messageTypingProvider);
    final args =
        ModalRoute.of(context)!.settings.arguments as MessageScreenArguments;
    final String name = args.name;
    final currentUser = ref.watch(settingsUserProvider);
    final chatIdAsync = ref.watch(chatIdProvider(receiverId));
    final chatId = chatIdAsync.asData?.value;
    final isTyping = (chatId != null && typingMap[chatId] == true);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: Header(
        id: receiverId,
        name: name,
        isOnline: _isOnline,
        profilePic: args.profilePic,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: chatIdAsync.when(
                data: (chatId) {
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

                          final msg = messages[messages.length - 1 - msgIndex];

                          final currentLabel = getDateLabel(msg.createdAt);

                          String? previousLabel;
                          if (msgIndex < messages.length - 1) {
                            final prevMsg =
                                messages[messages.length - 1 - (msgIndex + 1)];
                            previousLabel = getDateLabel(prevMsg.createdAt);
                          }
                          final showBanner = currentLabel != previousLabel;

                          return Column(
                            children: [
                              if (showBanner) DateBanner(label: currentLabel),

                              MessageItem(
                                message: msg.message,
                                isSender: msg.senderId == currentUser.id,
                                status: msg.senderId == currentUser.id
                                    ? statusMap(msg.messageStatus)
                                    : statusMap("sending"),
                                timestamp: msg.createdAt,
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
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text(e.toString())),
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
