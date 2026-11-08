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
      final user = row.readTableOrNull(db.usersTable);

      if (user == null) return null;

      final pic = (media?.location != null && media!.location!.isNotEmpty)
          ? media.location
          : media?.url;

      return UserModel(
        id: user.userId,
        name: user.name,
        email: user.email,
        bio: user.bio,
        profilePic: pic,
      );
    });
  }

  Stream<String> watchThemeMode() {
    final db = ref.read(databaseProvider);
    return db
        .select(db.userPreferencesTable)
        .watchSingleOrNull()
        .map((pref) => pref?.themeMode ?? 'system');
  }

  Future<void> updateThemeMode(String mode) async {
    final db = ref.read(databaseProvider);
    final existing =
        await db.select(db.userPreferencesTable).getSingleOrNull();
    if (existing != null) {
      await (db.update(db.userPreferencesTable)
            ..where((t) => t.id.equals(existing.id)))
          .write(UserPreferencesTableCompanion(themeMode: Value(mode)));
    } else {
      await db.into(db.userPreferencesTable).insert(
            UserPreferencesTableCompanion(
              userId: const Value('default'),
              themeMode: Value(mode),
            ),
          );
    }
  }

  Future<void> setCurrentUser(String userId, String accessToken) async {
    final database = ref.read(databaseProvider);

    final userTableProvider = ref.read(usersTableProvider.notifier);
    final user = await userTableProvider.getUserById(userId);
    if (user == null) return;

    final existingPref =
        await database.select(database.userPreferencesTable).getSingleOrNull();

    await database
        .into(database.userPreferencesTable)
        .insertOnConflictUpdate(
          UserPreferencesTableCompanion(
            userId: Value(userId),
            accessToken: Value(accessToken),
            themeMode: existingPref?.themeMode != null
                ? Value(existingPref!.themeMode)
                : const Value('system'),
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
