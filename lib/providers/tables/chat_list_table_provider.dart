import 'package:drift/drift.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/core/database.dart';
import 'package:my_app/core/network/api_client.dart';
import 'package:my_app/data/services/chat_api_service.dart';
import 'package:my_app/modal/screens/createGroup/create_group_response.dart';
import 'package:my_app/providers/database_provider.dart';
import 'package:my_app/modal/chat_list_modal.dart';
import 'package:my_app/providers/tables/chat_participants_table.dart';
import 'package:my_app/providers/tables/groups_table_provider.dart';
import 'package:my_app/providers/tables/user_preference_table_provider.dart';
import 'package:my_app/providers/tables/users_table_provider.dart';
import 'package:my_app/modal/user.modal.dart';
import 'package:my_app/providers/token_provider.dart';

final chatListTableProvider = NotifierProvider<ChatListTableProvider, void>(
  ChatListTableProvider.new,
);

class ChatListTableProvider extends Notifier {
  @override
  build() {}

  Future<ChatListModal?> fetchChatDetailsFromChatId(String chatId) async {
    final db = ref.read(databaseProvider);
    final currentUser = ref.watch(userPreferenceTableProvider).value;
    if (currentUser == null) {
      throw Exception("Current user ID is null");
    }
    final chatquery = await (db.select(
      db.chatListTable,
    )..where((tbl) => tbl.chatId.equals(chatId))).getSingleOrNull();
    if (chatquery == null) {
      return null;
    }

    if (chatquery.type == "DIRECT") {
      final participant =
          await (db.select(db.chatParticipants)..where(
                (tbl) =>
                    tbl.chatId.equals(chatId) &
                    tbl.userId.isNotValue(currentUser),
              ))
              .getSingleOrNull();

      if (participant == null) {
        throw Exception("No other participant found for chatId: $chatId");
      }

      final otherParticipant = participant.userId;
      final userQuery =
          await (db.select(db.usersTable).join([
                leftOuterJoin(
                  db.mediaTable,
                  db.mediaTable.actorId.equalsExp(db.usersTable.userId),
                ),
              ])..where(db.usersTable.userId.equals(otherParticipant)))
              .getSingleOrNull();

      if (userQuery == null) {
        throw Exception("User not found for userId: $otherParticipant");
      }
      final user = userQuery.readTable(db.usersTable);
      final media = userQuery.readTableOrNull(db.mediaTable);

      return ChatListModal(
        bio: user.bio,
        chatId: chatId,
        name: user.name,
        profilePicUrl: media?.location,
        type: "DIRECT",
        id: chatId, // Using chatId as the unique identifier
        lastMessage: chatquery.lastMessage ?? "",
        lastMessageTime: chatquery.lastMessageTime?.toString() ?? "",
        unReadCount: chatquery.unReadCount,
      );
    } else {
      final groupQuery = await (db.select(db.chatListTable).join([
        leftOuterJoin(
          db.groupListTable,
          db.groupListTable.chatId.equalsExp(db.chatListTable.chatId),
        ),
        leftOuterJoin(
          db.mediaTable,
          db.mediaTable.actorId.equalsExp(db.groupListTable.chatId),
        ),
      ])..where(db.chatListTable.chatId.equals(chatId))).getSingleOrNull();
      if (groupQuery == null) {
        throw Exception("Group not found for chatId: $chatId");
      }
      final group = groupQuery.readTableOrNull(db.groupListTable);
      final media = groupQuery.readTableOrNull(db.mediaTable);

      return ChatListModal(
        bio: group?.bio,
        chatId: chatId,
        name: group?.name ?? "Unknown Group",
        profilePicUrl: media?.location,
        type: "GROUP",
        id: chatId,
        lastMessage: chatquery.lastMessage ?? "",
        lastMessageTime: chatquery.lastMessageTime?.toString() ?? "",
        unReadCount: chatquery.unReadCount,
      );
    }
  }

  Future<void> updateChat(ChatListModal chat) async {
    final db = ref.read(databaseProvider);

    await (db.update(
      db.chatListTable,
    )..where((tbl) => tbl.chatId.equals(chat.chatId))).write(
      ChatListTableCompanion(
        lastMessage: Value(chat.lastMessage),
        lastMessageTime: Value(
          chat.lastMessageTime.isNotEmpty
              ? int.tryParse(chat.lastMessageTime)
              : null,
        ),
        unReadCount: Value(chat.unReadCount),
      ),
    );
  }

  Future<void> createChat(ChatListModal chat) async {
    final db = ref.read(databaseProvider);
    debugPrint(chat.chatId);
    final currentUser = ref.watch(userPreferenceTableProvider).value;
    if (currentUser == null) {
      throw Exception("Current user ID is null");
    }
    String finalType;
    if (chat.type == "") {
      final token = ref.read(tokenProvider).value;
      debugPrint("reached creatChat token: $token");
      final ApiClient apiClient = ApiClient();
      final response = await ChatApiService(
        apiClient,
      ).getChat(token: token ?? "", chatId: chat.chatId);
      finalType = response.data!.data!.type;
    } else {
      finalType = chat.type;
    }

    if (finalType == "DIRECT") {
      UserModel? existingUser = await ref
          .read(usersTableProvider.notifier)
          .getUserById(chat.receiverId ?? "");

      existingUser ??= await ref
          .read(usersTableProvider.notifier)
          .fetchAndUpdateUserProfile(chat.receiverId ?? "");
      await ref
          .read(chatParticipantsTableProvider.notifier)
          .bulkInsertParticipants([
            Participant(
              chatId: chat.chatId,
              userId: currentUser,
              role: "MEMBER",
            ),
            Participant(
              chatId: chat.chatId,
              userId: chat.receiverId ?? "",
              role: "MEMBER",
            ),
          ]);

      await db
          .into(db.chatListTable)
          .insert(
            ChatListTableCompanion(
              chatId: Value(chat.chatId),
              lastMessage: Value(chat.lastMessage),
              lastMessageTime: Value(
                chat.lastMessageTime.isNotEmpty
                    ? int.tryParse(chat.lastMessageTime)
                    : null,
              ),
              unReadCount: Value(chat.unReadCount),
              type: Value(finalType),
            ),
          );
    } else {
      await ref
          .read(groupsTableProvider.notifier)
          .fetchAndUpdateGroup(chat.chatId);
      await db
          .into(db.chatListTable)
          .insert(
            ChatListTableCompanion(
              chatId: Value(chat.chatId),
              lastMessage: Value(chat.lastMessage),
              lastMessageTime: Value(
                chat.lastMessageTime.isNotEmpty
                    ? int.tryParse(chat.lastMessageTime)
                    : null,
              ),
              unReadCount: Value(chat.unReadCount),
              type: Value(chat.type),
            ),
          );
    }
  }

  Future<void> createOrUpdateChatList(
    ChatListModal chat, {
    bool isIncomingMessage = false,
    bool shouldAutoRead = false,
  }) async {
    try {
      final db = ref.read(databaseProvider);
      final existingChat = await (db.select(
        db.chatListTable,
      )..where((tbl) => tbl.chatId.equals(chat.chatId))).getSingleOrNull();

      if (existingChat != null) {
        if (isIncomingMessage) {
          final newTime = chat.lastMessageTime.isNotEmpty
              ? int.tryParse(chat.lastMessageTime)
              : null;
          final isNewer =
              existingChat.lastMessageTime == null ||
              (newTime != null && newTime >= existingChat.lastMessageTime!);
          final unread = shouldAutoRead ? 0 : (existingChat.unReadCount) + 1;

          await (db.update(
            db.chatListTable,
          )..where((tbl) => tbl.chatId.equals(chat.chatId))).write(
            ChatListTableCompanion(
              lastMessage: isNewer
                  ? Value(chat.lastMessage)
                  : const Value.absent(),
              lastMessageTime: isNewer ? Value(newTime) : const Value.absent(),
              unReadCount: Value(unread),
              isDeleted: const Value(false),
            ),
          );
        } else {
          await updateChat(chat);
        }
      } else {
        final newChat = ChatListModal(
          id: chat.id,
          chatId: chat.chatId,
          lastMessage: chat.lastMessage,
          lastMessageTime: chat.lastMessageTime,
          receiverId: chat.receiverId,
          name: chat.name,
          profilePicUrl: chat.profilePicUrl,
          unReadCount: 1,
          type: chat.type,
          bio: chat.bio,
        );
        await createChat(newChat);
      }
    } catch (e) {
      debugPrint("error at createorUpdateChatList: ${e.toString()}");
    }
  }

  Future<void> updateChatId(String oldChatId, String currentChatId) async {
    final db = ref.read(databaseProvider);

    await (db.update(
      db.chatListTable,
    )..where((tbl) => tbl.chatId.equals(oldChatId))).write(
      ChatListTableCompanion(
        chatId: Value(currentChatId),
        isDeleted: const Value(false),
      ),
    );
  }
}
