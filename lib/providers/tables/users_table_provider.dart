import 'package:drift/drift.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/core/database.dart';
import 'package:my_app/core/network/api_client.dart';
import 'package:my_app/data/services/user_api_service.dart';
import 'package:my_app/modal/upload_responses/upload_attachment.dart';
import 'package:my_app/modal/user.modal.dart';
import 'package:my_app/providers/database_provider.dart';
import 'package:my_app/providers/tables/media_table_provider.dart';
import 'package:my_app/providers/tables/request_user_provider.dart';
import 'package:my_app/providers/tables/user_preference_table_provider.dart';

final usersTableProvider = NotifierProvider<UsersTableProvider, void>(
  UsersTableProvider.new,
);

final allUsersProvider = StreamProvider<List<UserModel>>((ref) {
  return ref.read(usersTableProvider.notifier).watchAllUsers();
});

class UsersTableProvider extends Notifier {
  @override
  build() {}

  Stream<List<UserModel>> watchAllUsers() {
    final db = ref.read(databaseProvider);
    final currentUser = ref.watch(userPreferenceTableProvider).value;

    if (currentUser == null) {
      return Stream.value([]);
    }

    final query = db.select(db.usersTable).join([
      leftOuterJoin(
        db.mediaTable,
        db.mediaTable.actorId.equalsExp(db.usersTable.userId),
      ),
    ])..where(db.usersTable.userId.isNotValue(currentUser));

    return query.watch().map((rows) {
      return rows.map((row) {
        final user = row.readTable(db.usersTable);
        final media = row.readTableOrNull(db.mediaTable);

        return UserModel(
          id: user.userId,
          name: user.name,
          email: user.email,
          bio: user.bio,
          profilePic: media?.location,
        );
      }).toList();
    });
  }

  Future<UserModel?> updateUserProfile(
    UserModel userData,
    UploadAttachment? media,
  ) async {
    final db = ref.read(databaseProvider);

    await db
        .into(db.usersTable)
        .insertOnConflictUpdate(
          UsersTableCompanion(
            bio: Value(userData.bio),
            email: Value(userData.email),
            name: Value(userData.name),
            userId: Value(userData.id),
          ),
        );

    if (media != null) {
      await ref
          .read(mediaTableProvider.notifier)
          .addOrUpdateMediaDocument(media, userData.id);
    }

    return getUserById(userData.id);
  }

  Future<bool> doesUserExistInDb(String userId) async {
    final db = ref.read(databaseProvider);

    final user = await (db.select(
      db.usersTable,
    )..where((tbl) => tbl.userId.equals(userId))).getSingleOrNull();

    return user != null;
  }

  Future<UserModel?> getUserById(String userId) async {
    final db = ref.read(databaseProvider);
    final mediaRef = ref.read(mediaTableProvider.notifier);

    final media = await mediaRef.getMediaByActorId(userId);

    final query = db.select(db.usersTable).join([
      leftOuterJoin(
        db.friendsTable,
        db.friendsTable.userId.equalsExp(db.usersTable.userId),
      ),
    ])..where(db.usersTable.userId.equals(userId));

    final result = await query.getSingleOrNull();

    if (result == null) {
      return null;
    }

    final user = result.readTable(db.usersTable);
    final friend = result.readTableOrNull(db.friendsTable);
    return UserModel(
      id: user.userId,
      name: user.name,
      email: user.email,
      bio: user.bio,
      profilePic: media?.location,
      relationshipStatus: friend?.status,
    );
  }

  Future<void> updateUserBio(String userId, String newBio) async {
    final db = ref.read(databaseProvider);
    await (db.update(db.usersTable)..where((tbl) => tbl.userId.equals(userId)))
        .write(UsersTableCompanion(bio: Value(newBio)));
  }

  Future<UserModel?> fetchAndUpdateUserProfile(String userId) async {
    final profile = await UserApiService(ApiClient()).getUserById(userId);

    if (!profile.success || profile.data == null) {
      throw Exception(profile.message);
    }
    final data = profile.data!;
    await ref
        .read(requestUserProvider.notifier)
        .insertOrUpdateRequest(data.id, data.relationshipStatus ?? "NONE");

    return await updateUserProfile(
      UserModel(
        id: data.id,
        name: data.name,
        email: data.email ?? "",
        bio: data.bio ?? "",
      ),
      data.media != null
          ? UploadAttachment(
              key: data.media!.key,
              contentType: data.media!.contentType,
              type: data.media!.type,
              actorId: data.id,
              name: data.media!.name,
            )
          : null,
    );
  }
}
