import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/core/util/status_map.dart';
import 'package:my_app/modal/screens/search/message_screen_arguments.dart';
import 'package:my_app/providers/chat_list_provider.dart';
import 'package:my_app/providers/chat_message_provider.dart';
import 'package:my_app/providers/message_provider.dart';
import 'package:my_app/providers/settings_user_notifier_provider.dart';
import 'package:my_app/providers/socket_provider.dart';
import 'package:my_app/widgets/screens/message/chat_input_box.dart';
import 'package:my_app/widgets/screens/message/header.dart';
import 'package:my_app/widgets/screens/message/message_item.dart';

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
    _chatListController = ref.read(chatListControllerProvider);
    final socketService = ref.read(socketProvider);

    socketService.getUserStatus((data) {
      if (data["userId"] == receiverId) {
        setState(() {
          _isOnline = data["online"];
        });
      }
    });

    socketService.listenUserOnline((data) {
      if (data["userId"] == receiverId) {
        setState(() {
          _isOnline = true;
        });
      }
    });

    socketService.listenUserOffline((data) {
      if (data["userId"] == receiverId) {
        setState(() {
          _isOnline = false;
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)!.settings.arguments as MessageScreenArguments;

    receiverId = args.id;
    name = args.name;

    if (_lastActiveUserId != receiverId) {
      _lastActiveUserId = receiverId;
      _chatListController.setActiveChatUserId(receiverId);
    }

    Future.microtask(() {
      ref.read(messageProvider.notifier).markChatMessagesRead(receiverId);
    });
    final socketService = ref.read(socketProvider);
    socketService.checkUserStatus(receiverId);
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

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as MessageScreenArguments;
    final String name = args.name;
    final currentUser = ref.watch(settingsUserProvider);
    final chatIdAsync = ref.watch(chatIdProvider(receiverId));
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: Header(id: receiverId, name: name, isOnline: _isOnline),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: ChatInputBox(onSend: _handleSend),
      ),
      body: SafeArea(
        child: chatIdAsync.when(
          data: (chatId) {
            final messagesAsync = ref.watch(
              chatMessagesProvider((chatId: chatId, receiverId: receiverId)),
            );

            return messagesAsync.when(
              data: (messages) {
                if (currentUser == null) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (messages.isNotEmpty) {
                  Future.microtask(() {
                    ref
                        .read(messageProvider.notifier)
                        .markChatMessagesRead(receiverId);
                  });
                }

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[messages.length - 1 - index];
                    return MessageItem(
                      message: msg.message,
                      isSender: msg.senderId == currentUser.id,
                      status: msg.senderId == currentUser.id
                          ? statusMap(msg.messageStatus)
                          : statusMap("sending"),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text(e.toString())),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text(e.toString())),
        ),
      ),
    );
  }
}
