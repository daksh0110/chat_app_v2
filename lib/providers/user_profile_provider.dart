import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/modal/group_profile_modal.dart';
import 'package:my_app/modal/user_profile_modal.dart';
import 'package:my_app/providers/database_provider.dart';
import 'package:drift/drift.dart';
import 'package:my_app/providers/tables/media_table_provider.dart';
import 'package:my_app/providers/tables/messages_table_provider.dart';
import 'package:my_app/providers/tables/user_preference_table_provider.dart';
import 'package:my_app/providers/tables/users_table_provider.dart';

final userProfileProvider = NotifierProvider<UserProfileProvider, void>(
  UserProfileProvider.new,
);

final groupProfile = FutureProvider.autoDispose.family<GroupProfile?, String>((
  ref,
  chatId,
) {
  return ref
      .read(userProfileProvider.notifier)
      .fetchGroupProfileDetails(chatId);
});

final userProfile = FutureProvider.autoDispose
    .family<UserProfileModal?, String>((ref, chatId) {
      return ref
          .read(userProfileProvider.notifier)
          .fetchUserProfileDetails(chatId);
    });

class UserProfileProvider extends Notifier {
  @override
  build() {}

  Future<GroupProfile?> fetchGroupProfileDetails(String chatId) async {
    final db = ref.read(databaseProvider);

    final groupResult =
        await (db.select(db.chatListTable).join([
              leftOuterJoin(
                db.groupListTable,
                db.groupListTable.chatId.equalsExp(db.chatListTable.chatId),
              ),
              leftOuterJoin(
                db.mediaTable,
                db.mediaTable.actorId.equalsExp(db.chatListTable.chatId),
              ),
            ])..where(
              db.chatListTable.chatId.equals(chatId) &
                  db.chatListTable.type.equals("GROUP"),
            ))
            .getSingleOrNull();

    if (groupResult == null) {
      throw Exception("Group not found");
    }

    final chat = groupResult.readTable(db.chatListTable);
    final group = groupResult.readTableOrNull(db.groupListTable);
    final groupMedia = groupResult.readTableOrNull(db.mediaTable);

    final memberResults = await (db.select(db.chatParticipants).join([
      leftOuterJoin(
        db.usersTable,
        db.usersTable.userId.equalsExp(db.chatParticipants.userId),
      ),
      leftOuterJoin(
        db.mediaTable,
        db.mediaTable.actorId.equalsExp(db.usersTable.userId),
      ),
    ])..where(db.chatParticipants.chatId.equals(chatId))).get();

    final mediaShared = await ref
        .read(messagesTableProvider.notifier)
        .fetchMessagesImages(chatId: chatId, limit: 7);

    final members = memberResults.map((row) {
      final participant = row.readTable(db.chatParticipants);
      final user = row.readTable(db.usersTable);
      final media = row.readTableOrNull(db.mediaTable);

      return GroupMember(
        userId: user.userId,
        name: user.name,
        profilePicUrl: media?.location,
        role: participant.role,
      );
    }).toList();

    return GroupProfile(
      chatId: chat.chatId,
      name: group?.name ?? "",
      description: group?.bio ?? "",
      profilePicUrl: groupMedia?.location,
      members: members,
      mediaShared: mediaShared.media,
    );
  }

  Future<UserProfileModal?> fetchUserProfileDetails(String chatId) async {
    if (chatId.isEmpty) {
      throw Exception("ChatId is not Provided");
    }
    final db = ref.read(databaseProvider);
    final currentUser = await ref
        .read(userPreferenceTableProvider.notifier)
        .getCurrentUserId();

    final chat =
        await (db.select(db.chatListTable)..where(
              (tbl) => tbl.chatId.equals(chatId) & tbl.type.equals("DIRECT"),
            ))
            .getSingleOrNull();

    String userId = chatId;

    if (chat != null) {
      final participant =
          await (db.select(db.chatParticipants)..where(
                (tbl) =>
                    tbl.chatId.equals(chatId) &
                    tbl.userId.isNotValue(currentUser ?? ""),
              ))
              .getSingleOrNull();

      if (participant == null) return null;

      userId = participant.userId;
    }

    final usersTable = ref.read(usersTableProvider.notifier);
    // var user = await usersTable.getUserById(userId);

    // if (user == null) {
    //   final userExistsInDb = await usersTable.doesUserExistInDb(userId);

    //   if (userExistsInDb) {
    //     user = await usersTable.getUserById(userId);
    //   } else {
    //     user = await usersTable.fetchAndUpdateUserProfile(userId);
    //   }
    // }

    final user = await usersTable.fetchAndUpdateUserProfile(userId);

    if (user == null) return null;
    debugPrint("Fetching new user, : $user");
    final media = await ref
        .read(mediaTableProvider.notifier)
        .getMediaByActorId(userId);
    final mediaShared = await ref
        .read(messagesTableProvider.notifier)
        .fetchMessagesImages(chatId: chatId, limit: 7);
    return UserProfileModal(
      id: user.id,
      chatId: chat != null ? chatId : null,
      name: user.name,
      email: user.email,
      bio: user.bio,
      profilePic: media?.location ?? user.profilePic,
      mediaShared: mediaShared.media,
      totalMediaCount: mediaShared.count,
      relationshipStatus: user.relationshipStatus,
    );
  }
}
