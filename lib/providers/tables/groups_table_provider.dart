import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/core/database.dart';
import 'package:my_app/core/network/api_client.dart';
import 'package:my_app/data/services/chat_api_service.dart';
import 'package:my_app/modal/group_modal.dart';
import 'package:my_app/modal/screens/createGroup/create_group_response.dart';
import 'package:my_app/modal/upload_responses/upload_attachment.dart';
import 'package:my_app/providers/database_provider.dart';
import 'package:my_app/providers/tables/chat_participants_table.dart';
import 'package:my_app/providers/tables/media_table_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:my_app/providers/tables/users_table_provider.dart';
import 'package:my_app/modal/user.modal.dart';

final groupsTableProvider = NotifierProvider<GroupsTableProvider, void>(
  () => GroupsTableProvider(),
);

class GroupsTableProvider extends Notifier {
  @override
  build() {}

  Future<GroupModal?> findGroupById(String groupId) async {
    final db = ref.read(databaseProvider);
    final groupQuery = await (db.select(db.groupListTable).join([
      leftOuterJoin(
        db.mediaTable,
        db.mediaTable.actorId.equalsExp(db.groupListTable.chatId),
      ),
    ])..where(db.groupListTable.chatId.equals(groupId))).getSingleOrNull();

    if (groupQuery == null) {
      return null;
    }
    final group = groupQuery.readTable(db.groupListTable);
    final media = groupQuery.readTableOrNull(db.mediaTable);

    return GroupModal(
      id: group.chatId,
      name: group.name,
      bio: group.bio,
      profilePic: media?.location,
    );
  }

  Future<GroupModal?> createOrUpdateGroup(GroupModal group) async {
    final db = ref.read(databaseProvider);

    await db
        .into(db.groupListTable)
        .insertOnConflictUpdate(
          GroupListTableCompanion(
            chatId: Value(group.id),
            name: Value(group.name ?? ''),
            bio: Value(group.bio),
          ),
        );

    if (group.media != null) {
      await ref
          .read(mediaTableProvider.notifier)
          .addOrUpdateMediaDocument(group.media!, group.id);
    }

    return findGroupById(group.id);
  }

  Future<GroupModal?> fetchAndUpdateGroup(String groupId) async {
    final groupApiService = ChatApiService(ApiClient());
    final token = await FlutterSecureStorage().read(key: "accessToken");
    final groupResponse = await groupApiService.getChat(
      token: token ?? "",
      chatId: groupId,
    );

    if (groupResponse.data?.data == null) {
      throw Exception("Failed to fetch group data from API.");
    }

    final groupData = groupResponse.data?.data;

    if (groupData != null && groupData.participants.isNotEmpty) {
      final participants = <Participant>[];
      for (final participant in groupData.participants) {
        await ref
            .read(usersTableProvider.notifier)
            .updateUserProfile(
              UserModel(
                id: participant.userId,
                name: participant.name,
                email: participant.email ?? "",
                bio: participant.bio,
              ),
              participant.media,
            );

        participants.add(
          Participant(
            chatId: groupId,
            userId: participant.userId,
            role: participant.role,
          ),
        );
      }

      await ref
          .read(chatParticipantsTableProvider.notifier)
          .bulkInsertParticipants(participants);
    }

    final groupModal = GroupModal(
      id: groupData?.chatId ?? "",
      name: groupData?.name,
      bio: groupData?.bio,
      media: groupData?.media != null
          ? UploadAttachment(
              contentType: groupData!.media!.contentType,
              key: groupData.media!.key,
              actorId: groupData.chatId,
              name: groupData.media!.name,
              type: groupData.media!.type,
            )
          : null,
    );

    return createOrUpdateGroup(groupModal);
  }
}
