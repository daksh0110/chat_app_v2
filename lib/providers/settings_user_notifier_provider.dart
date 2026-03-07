import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/core/database.dart';
import 'package:my_app/core/network/api_client.dart';
import 'package:my_app/data/services/user_api_service.dart';
import 'package:my_app/providers/database_provider.dart';

final settingsUserProvider =
    NotifierProvider<SettingsUserNotifier, UserInfoSetting?>(
      SettingsUserNotifier.new,
    );

class SettingsUserNotifier extends Notifier<UserInfoSetting?> {
  @override
  UserInfoSetting? build() {
    _loadFromDb();
    return null;
  }

  Future<void> _loadFromDb() async {
    final database = ref.read(databaseProvider);
    final user = await database.managers.userInfoSettings.getSingleOrNull();
    state = user;
  }

  Future<void> setUser(String token) async {
    final database = ref.read(databaseProvider);

    final apiClient = ApiClient();
    final userInfo = await UserApiService(apiClient).getMyProfile(token: token);
    print(userInfo.data);
    final user = UserInfoSetting(
      id: 1,
      name: userInfo.data!.name,
      email: userInfo.data!.subtitle,
      accessToken: token,
    );

    state = user;

    await database
        .into(database.userInfoSettings)
        .insert(
          UserInfoSettingsCompanion.insert(
            id: const Value(1),
            name: user.name,
            email: user.email,
            accessToken: token,
          ),
          mode: InsertMode.insertOrReplace,
        );
  }

  Future<void> clearUser() async {
    final database = ref.read(databaseProvider);

    state = null;

    await database.delete(database.userInfoSettings).go();
  }
}
