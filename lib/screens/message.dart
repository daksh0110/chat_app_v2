import 'package:flutter/material.dart';
import 'package:my_app/data/dummy_messages.dart';
import 'package:my_app/modal/screens/message/message_modal.dart';
import 'package:my_app/widgets/screens/message/chat_input_box.dart';
import 'package:my_app/widgets/screens/message/header.dart';
import 'package:my_app/widgets/screens/message/message_item.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  State<MessageScreen> createState() {
    return _MessageScreen();
  }
}

class _MessageScreen extends State<MessageScreen> {
  final List<MessageModel> _messages = List.from(dummyMessages);
  final ScrollController _scrollController = ScrollController();

  void _handleSend(String text) {
    final newMessage = MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: Header(),
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
