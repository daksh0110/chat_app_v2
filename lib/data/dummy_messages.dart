import 'package:my_app/modal/screens/message/message_modal.dart';

final List<MessageModel> dummyMessages = [
  MessageModel(
    id: "1",
    text: "Hey bro 👋",
    isMe: false,
    createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
  ),
  MessageModel(
    id: "2",
    text: "Hello! What's up?",
    isMe: true,
    createdAt: DateTime.now().subtract(const Duration(minutes: 9)),
  ),
  MessageModel(
    id: "3",
    text: "Working on Flutter chat UI 😄",
    isMe: false,
    createdAt: DateTime.now().subtract(const Duration(minutes: 8)),
  ),
  MessageModel(
    id: "4",
    text: "Nice! Looks cool already 🔥",
    isMe: true,
    createdAt: DateTime.now().subtract(const Duration(minutes: 7)),
  ),
  MessageModel(
    id: "5",
    text: "Still need to add backend though",
    isMe: false,
    createdAt: DateTime.now().subtract(const Duration(minutes: 6)),
  ),
];
