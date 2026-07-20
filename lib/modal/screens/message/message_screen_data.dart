import 'package:my_app/modal/chat_list_modal.dart';

class MessageScreenData {
  final String? chatId;
  final String? name;
  final String? profilePic;
  final String? bio;
  final String? receiverId;
  final String? type;

  MessageScreenData({
    this.chatId,
    this.name,
    this.profilePic,
    this.bio,
    this.receiverId,
    this.type = "DIRECT",
  });

  factory MessageScreenData.fromChat(ChatListModal chat) {
    return MessageScreenData(
      chatId: chat.chatId,
      name: chat.name,
      profilePic: chat.profilePicUrl,
      bio: chat.bio,
      type: chat.type,
      receiverId: chat.receiverId,
    );
  }
}
