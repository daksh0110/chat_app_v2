import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/core/network/api_client.dart';
import 'package:my_app/data/services/user_api_service.dart';
import 'package:my_app/modal/upload_responses/upload_attachment.dart';
import 'package:my_app/modal/user.modal.dart';
import 'package:my_app/providers/database_provider.dart';

import 'package:my_app/providers/socket_provider.dart';
import 'package:my_app/providers/tables/user_preference_table_provider.dart';
import 'package:my_app/providers/tables/users_table_provider.dart';
import 'package:my_app/providers/token_provider.dart';

enum AuthState { authenticated, unauthenticated }

final authProvider = AsyncNotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

class AuthNotifier extends AsyncNotifier<AuthState> {
  @override
  @override
  Future<AuthState> build() async {
    final token = await ref.watch(tokenProvider.future);

    if (token != null && token.isNotEmpty) {
      return AuthState.authenticated;
    }

    return AuthState.unauthenticated;
  }

  Future<void> login(String token) async {
    await ref.read(tokenProvider.notifier).setToken(token);

    final profile = await UserApiService(
      ApiClient(),
    ).getMyProfile(token: token);

    if (profile.data == null) {
      throw Exception("Failed to fetch user profile.");
    }

    final userTableProvider = ref.read(usersTableProvider.notifier);
    await userTableProvider.updateUserProfile(
      UserModel(
        id: profile.data!.id,
        name: profile.data!.name,
        email: profile.data!.email,
        bio: profile.data?.bio ?? "",
      ),
      profile.data!.media != null
          ? UploadAttachment(
              key: profile.data!.media!.key,
              contentType: profile.data!.media!.contentType,
              type: profile.data!.media!.type,
              actorId: profile.data!.id,
              name: profile.data!.media!.name,
            )
          : null,
    );

    await ref
        .read(userPreferenceTableProvider.notifier)
        .setCurrentUser(profile.data!.id, token);

    ref.read(socketProvider).connect(token);

    state = const AsyncData(AuthState.authenticated);
  }

  Future<void> logout() async {
    final db = ref.read(databaseProvider);

    await db.clearAllData();
    await ref.read(tokenProvider.notifier).clear();
    ref.read(socketProvider).disconnect();

    state = const AsyncData(AuthState.unauthenticated);
  }
}
