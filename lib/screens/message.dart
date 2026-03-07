import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/modal/screens/message/message_modal.dart';
import 'package:my_app/modal/screens/search/message_screen_arguments.dart';
import 'package:my_app/providers/database_provider.dart';
import 'package:my_app/providers/socket_provider.dart';
import 'package:my_app/services/socker_service.dart';
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
  final List<MessageModel> _messages = [];
  final ScrollController _scrollController = ScrollController();
  late SocketService socket;
  late String receiverId;
  late String name;
  @override
  void initState() {
    super.initState();
    socket = ref.read(socketProvider);
    socket.listen("receive_message", (dynamic data) {
      print(data);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)!.settings.arguments as MessageScreenArguments;

    receiverId = args.id;
    name = args.name;
  }

  void _handleSend(String text) async {
    socket.sendMessage("send_message", {
      "message": text,
      "receiver_id": receiverId,
    });

    final database = ref.read(databaseProvider);
    final now = DateTime.now().millisecondsSinceEpoch;

    final existingChat = await database.managers.chatListTable
        .filter((f) => f.userId(receiverId))
        .getSingleOrNull();

    int chatId;

    if (existingChat == null) {
      final newId = await database.managers.chatListTable.create(
        (o) => o(
          userId: receiverId,
          name: name,
          lastMessage: Value(text),
          lastMessageTime: Value(now),
        ),
      );

      chatId = newId;
    } else {
      await database.managers.chatListTable
          .filter((f) => f.id(existingChat.id))
          .update(
            (o) => o(lastMessage: Value(text), lastMessageTime: Value(now)),
          );

      chatId = existingChat.id;
    }

    await database.managers.messages.create(
      (o) => o(
        id: now.toString(),
        chatId: chatId,
        message: text,
        receiverId: receiverId,
        senderId: "me",
        createdAt: now,
      ),
    );

    final newMessage = MessageModel(
      id: now.toString(),
      text: text,
      isMe: true,
      createdAt: DateTime.now(),
    );

    setState(() {
      _messages.add(newMessage);
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as MessageScreenArguments;
    final String name = args.name;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: Header(id: receiverId, name: name),
      bottomNavigationBar: ChatInputBox(onSend: _handleSend),
      body: ListView.separated(
        controller: _scrollController,
        reverse: true,
        padding: const EdgeInsets.symmetric(vertical: 10),
        itemCount: _messages.length,
        separatorBuilder: (_, __) => const SizedBox(height: 4),
        itemBuilder: (context, index) {
          final msg = _messages[_messages.length - 1 - index];

          return MessageItem(message: msg.text, isSender: msg.isMe);
        },
      ),
    );
  }
}
