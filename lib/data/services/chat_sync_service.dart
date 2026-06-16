import 'dart:io';

import 'package:drift/drift.dart';
import 'package:http/http.dart' as http;
import 'package:my_app/core/database.dart';
import 'package:my_app/core/network/api_client.dart';
import 'package:my_app/data/services/chat_api_service.dart';
import 'package:my_app/data/services/upload_service.dart';
import 'package:my_app/data/services/user_api_service.dart';
import 'package:my_app/modal/screens/createGroup/create_group_response.dart';
import 'package:my_app/modal/upload_responses/upload_attachment.dart';
import 'package:path_provider/path_provider.dart';

class ChatSyncService {
  final AppDatabase db;
  final ApiClient apiClient;

  ChatSyncService({required this.db, required this.apiClient});

  Future<void> cacheUserIfMissing(String userId) async {
    try {
      final existing = await db.managers.usersTable
          .filter((f) => f.id.equals(userId))
          .getSingleOrNull();

      if (existing != null) {
        final hasLocalMedia = await db.managers.mediaTable
            .filter((f) => f.actorId.equals(userId))
            .getSingleOrNull();
        if (hasLocalMedia?.location != null &&
            File(hasLocalMedia!.location!).existsSync()) {
          return;
        }
      }

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

      if (data.media != null) {
        await saveActorMedia(actorId: userId, media: data.media!);
      }
    } catch (_) {}
  }

  Future<String?> saveActorMedia({
    required String actorId,
    required UploadAttachment media,
  }) async {
    try {
      if (media.key.isEmpty) return null;

      final existing = await db.managers.mediaTable
          .filter((f) => f.actorId.equals(actorId))
          .getSingleOrNull();

      if (existing?.location != null) {
        final file = File(existing!.location!);
        if (file.existsSync()) return existing.location;
      }

      final uploadService = UploadService(apiClient);
      var downloadUrl = media.url;

      if (downloadUrl == null || downloadUrl.isEmpty) {
        final res = await uploadService.getDownloadUrl(media.key);
        if (!res.success || res.data == null) return null;
        downloadUrl = res.data;
      }

      final localPath = await _downloadMediaToLocal(
        downloadUrl: downloadUrl!,
        actorId: actorId,
        media: media,
      );

      if (existing == null) {
        await db
            .into(db.mediaTable)
            .insert(
              MediaTableCompanion.insert(
                createdAt: DateTime.now().millisecondsSinceEpoch,
                actorId: Value(actorId),
                Type: Value(media.type),
                contentType: Value(media.contentType),
                location: Value(localPath),
                name: Value(media.name),
                key: Value(media.key),
                url: Value(downloadUrl),
              ),
            );
      } else {
        await (db.update(
          db.mediaTable,
        )..where((tbl) => tbl.id.equals(existing.id))).write(
          MediaTableCompanion(
            Type: Value(media.type),
            contentType: Value(media.contentType),
            location: Value(localPath),
            name: Value(media.name),
            key: Value(media.key),
            url: Value(downloadUrl),
            actorId: Value(actorId),
          ),
        );
      }

      return localPath;
    } catch (_) {
      return null;
    }
  }

  Future<String> _downloadMediaToLocal({
    required String downloadUrl,
    required String actorId,
    required UploadAttachment media,
  }) async {
    var response = await http.get(Uri.parse(downloadUrl));

    if (response.statusCode != 200) {
      final uploadService = UploadService(apiClient);
      final res = await uploadService.getDownloadUrl(media.key);
      if (!res.success || res.data == null) {
        throw Exception('Failed to download media');
      }
      response = await http.get(Uri.parse(res.data!));
      if (response.statusCode != 200) {
        throw Exception('Failed to download media after retry');
      }
    }

    return _writeBytesToProfileDir(response.bodyBytes, actorId, media);
  }

  Future<String> _writeBytesToProfileDir(
    List<int> bytes,
    String actorId,
    UploadAttachment media,
  ) async {
    final appDir = await getApplicationDocumentsDirectory();
    final profileDir = Directory('${appDir.path}/profile_photos');
    if (!await profileDir.exists()) {
      await profileDir.create(recursive: true);
    }

    final extension = _extensionFromName(
      media.name.isNotEmpty ? media.name : 'profile.jpg',
    );
    final filename = '${actorId}_${media.key.replaceAll('/', '_')}$extension';
    final file = File('${profileDir.path}/$filename');
    await file.writeAsBytes(bytes);
    return file.path;
  }

  String _extensionFromName(String name) {
    final dot = name.lastIndexOf('.');
    if (dot == -1) return '.jpg';
    return name.substring(dot);
  }

  Future<void> syncChatMedia(GroupData chatData) async {
    if (chatData.media != null) {
      await saveActorMedia(actorId: chatData.chatId, media: chatData.media!);
    }

    for (final participant in chatData.participants) {
      if (participant.media != null && participant.userId.isNotEmpty) {
        await saveActorMedia(
          actorId: participant.userId,
          media: participant.media!,
        );
      }
    }
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

      final mediaLocation = data.media != null
          ? await saveActorMedia(actorId: chatId, media: data.media!)
          : null;

      await (db.update(
        db.chatListTable,
      )..where((tbl) => tbl.chatId.equals(chatId))).write(
        ChatListTableCompanion(
          name: Value(data.name),
          profilePicUrl: Value(mediaLocation ?? data.profilePicUrl),
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

    if (payload.data != null) {
      await syncChatMedia(payload.data!);
    }
  }

  Future<void> syncCreatedGroupEventPayload({
    required CreateGroupResponse rawPayload,
    required String currentUserId,
  }) async {
    await _syncGroupPayload(payload: rawPayload, currentUserId: currentUserId);

    if (rawPayload.data != null) {
      await syncChatMedia(rawPayload.data!);
    }
  }

  Future<void> _syncGroupPayload({
    required CreateGroupResponse payload,
    required String currentUserId,
  }) async {
    if (!payload.success || payload.data == null) return;

    final group = payload.data!;

    final existingChat = await (db.select(
      db.chatListTable,
    )..where((tbl) => tbl.chatId.equals(group.chatId))).getSingleOrNull();

    if (existingChat != null) {
      await (db.update(
        db.chatListTable,
      )..where((tbl) => tbl.chatId.equals(group.chatId))).write(
        ChatListTableCompanion(
          name: Value(group.name),
          profilePicUrl: Value(group.profilePictureUrl),
          description: Value(group.description),
        ),
      );

      if (group.participants.isNotEmpty) {
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
            mode: InsertMode.insertOrIgnore,
          );
        });
      }
      return;
    }

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
        mode: InsertMode.insertOrIgnore,
      );
    });
  }
}
