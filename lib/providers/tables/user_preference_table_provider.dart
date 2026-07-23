import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/core/database.dart';
import 'package:my_app/modal/user.modal.dart';
import 'package:my_app/providers/database_provider.dart';
import 'package:my_app/providers/tables/users_table_provider.dart';

final userPreferenceTableProvider =
    AsyncNotifierProvider<UserPreferenceTableProvider, String?>(
      UserPreferenceTableProvider.new,
    );

final currentUserIdProvider = FutureProvider<String?>((ref) async {
  return ref.read(userPreferenceTableProvider.notifier).getCurrentUserId();
});

final userProvider = StreamProvider<UserModel?>((ref) {
  return ref.read(userPreferenceTableProvider.notifier).getUser();
});

class UserPreferenceTableProvider extends AsyncNotifier<String?> {
  @override
  Future<String?> build() async {
    return getCurrentUserId();
  }

  Stream<UserModel?> getUser() {
    final db = ref.read(databaseProvider);
    final query = db.select(db.userPreferencesTable).join([
      leftOuterJoin(
        db.mediaTable,
        db.mediaTable.actorId.equalsExp(db.userPreferencesTable.userId),
      ),
      leftOuterJoin(
        db.usersTable,
        db.usersTable.userId.equalsExp(db.userPreferencesTable.userId),
      ),
    ]);

    return query.watch().map((rows) {
      if (rows.isEmpty) return null;

      final row = rows.first;

      final media = row.readTableOrNull(db.mediaTable);
      final user = row.readTable(db.usersTable);

      return UserModel(
        id: user.userId,
        name: user.name,
        email: user.email,
        bio: user.bio,
        profilePic: media?.location,
      );
    });
  }

  Future<void> setCurrentUser(String userId, String accessToken) async {
    final database = ref.read(databaseProvider);

    final userTableProvider = ref.read(usersTableProvider.notifier);
    final user = await userTableProvider.getUserById(userId);
    if (user == null) return;

    await database
        .into(database.userPreferencesTable)
        .insertOnConflictUpdate(
          UserPreferencesTableCompanion(
            userId: Value(userId),
            accessToken: Value(accessToken),
          ),
        );
    state = AsyncData(userId);
    return;
  }

  Future<String?> getCurrentUserId() async {
    final database = ref.read(databaseProvider);
    final user = await database
        .select(database.userPreferencesTable)
        .getSingleOrNull();
    if (user != null) {
      return user.userId;
    }

    return null;
  }

  Future<void> clearUser() async {
    final database = ref.read(databaseProvider);
    await database.delete(database.userPreferencesTable).go();
  }
}
