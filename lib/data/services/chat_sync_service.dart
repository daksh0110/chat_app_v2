import 'package:drift/drift.dart';
import 'package:my_app/core/database.dart';
import 'package:my_app/core/network/api_client.dart';
import 'package:my_app/data/services/chat_api_service.dart';
import 'package:my_app/modal/screens/createGroup/create_group_response.dart';
import 'package:my_app/data/services/user_api_service.dart';

class ChatSyncService {
  final AppDatabase db;
  final ApiClient apiClient;

  ChatSyncService({required this.db, required this.apiClient});

  Future<void> cacheUserIfMissing(String userId) async {
    try {
      final existing = await db.managers.usersTable
          .filter((f) => f.id.equals(userId))
          .getSingleOrNull();

      if (existing != null) return;

      final response = await UserApiService(apiClient).getUserById(userId);
      final data = response.data;

      if (data == null) return;

      await db
          .into(db.usersTable)
          .insertOnConflictUpdate(
            UsersTableCompanion(
              id: Value(data.id),
              name: Value(data.name),
              email: Value(data.email ?? ""),
              bio: Value(data.bio ?? ""),
              profilePictureUrl: Value(data.profilePicUrl ?? ""),
            ),
          );
    } catch (_) {}
  }

  Future<void> updateDmChatItem({
    required String userId,
    required String chatId,
  }) async {
    try {
      final existing = await db.managers.chatListTable
          .filter((f) => f.chatId.equals(chatId))
          .getSingleOrNull();

      if (existing == null || existing.type != "DIRECT") return;

      final response = await UserApiService(apiClient).getUserById(userId);
      final data = response.data;
      if (data == null) return;

      await (db.update(
        db.chatListTable,
      )..where((tbl) => tbl.chatId.equals(chatId))).write(
        ChatListTableCompanion(
          name: Value(data.name),
          profilePicUrl: Value(data.profilePicUrl),
        ),
      );
    } catch (_) {}
  }

  Future<void> syncCreatedGroupById({
    required String incomingChatId,
    required String accessToken,
    required String currentUserId,
  }) async {
    final existing = await db.managers.chatListTable
        .filter((f) => f.chatId.equals(incomingChatId))
        .getSingleOrNull();
    if (existing != null) return;

    final response = await ChatApiService(
      apiClient,
    ).getChat(token: accessToken, chatId: incomingChatId);
    final payload = response.data;
    if (payload == null) return;

    if (payload.data?.chatId != incomingChatId) return;

    await _syncGroupPayload(payload: payload, currentUserId: currentUserId);
  }

  Future<void> syncCreatedGroupEventPayload({
    required CreateGroupResponse rawPayload,
    required String currentUserId,
  }) async {
    await _syncGroupPayload(payload: rawPayload, currentUserId: currentUserId);
  }

  Future<void> _syncGroupPayload({
    required CreateGroupResponse payload,
    required String currentUserId,
  }) async {
    if (!payload.success || payload.data == null) return;
    final group = payload.data!;
    await db.managers.chatListTable.create(
      (o) => o(
        chatId: group.chatId,
        name: group.name,
        type: "GROUP",
        isDeleted: const Value(false),
        lastMessage: const Value(null),
        lastMessageTime: Value(DateTime.now().millisecondsSinceEpoch),
        profilePicUrl: Value(group.profilePictureUrl),
        description: Value(group.description),
        unReadCount: const Value(0),
      ),
      mode: InsertMode.insertOrReplace,
    );

    if (group.participants.isEmpty) return;

    await db.batch((batch) {
      batch.insertAll(
        db.chatParticipants,
        group.participants
            .where((p) => p.chatId.isNotEmpty || group.chatId.isNotEmpty)
            .map((p) {
              final resolvedUserId = p.userId.isEmpty
                  ? currentUserId
                  : p.userId;
              return ChatParticipantsCompanion.insert(
                chatId: group.chatId,
                userId: resolvedUserId,
                name: p.name,
                role: Value(p.role),
                profilePicUrl: Value(p.profilePictureUrl),
              );
            })
            .toList(),
        mode: InsertMode.insertOrReplace,
      );
    });
  }
}
