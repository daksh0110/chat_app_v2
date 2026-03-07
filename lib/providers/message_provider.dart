import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/core/network/api_client.dart';
import 'package:my_app/data/services/user_api_service.dart';
import 'package:my_app/providers/database_provider.dart';
import 'package:my_app/providers/socket_provider.dart';

final messageProvider = NotifierProvider(MessageNotifer.new);

class MessageNotifer extends Notifier {
  @override
  build() {
    return null;
  }

  Future<void> receiveMessage() async {
    ref.read(socketProvider).listen("receive_message", (dynamic data) async {
      final database = ref.read(databaseProvider);
      final apiClient = ApiClient();

      final senderId = data["sender_id"];

      final existingChat = await database.managers.chatListTable
          .filter((f) => f.userId(senderId))
          .getSingleOrNull();

      int chatId;

      if (existingChat == null) {
        final response = await UserApiService(apiClient).getUserById(senderId);
        final user = response.data!;

        final newId = await database.managers.chatListTable.create(
          (o) => o(
            userId: senderId,
            name: user.name,
            lastMessage: Value(data["message"]),
            lastMessageTime: Value(data["created_at"]),
            unReadCount: const Value(1),
          ),
        );

        chatId = newId;
      } else {
        await database.managers.chatListTable
            .filter((f) => f.id(existingChat.id))
            .update(
              (o) => o(
                lastMessage: Value(data["message"]),
                lastMessageTime: Value(data["created_at"]),
                unReadCount: Value(existingChat.unReadCount + 1),
              ),
            );

        chatId = existingChat.id;
      }

      await database.managers.messages.create(
        (o) => o(
          id: data["id"],
          chatId: chatId,
          message: data["message"],
          receiverId: data["receiver_id"],
          senderId: data["sender_id"],
          createdAt: data["created_at"],
        ),
        mode: InsertMode.insertOrIgnore,
      );
    });
  }
}
