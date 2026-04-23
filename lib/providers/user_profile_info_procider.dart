import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/core/network/api_client.dart';
import 'package:my_app/data/services/user_api_service.dart';
import 'package:my_app/modal/screens/search/search_item.dart';
import 'package:my_app/providers/database_provider.dart';

final userProfileProvider = FutureProvider.family<SearchItem, String>((
  ref,
  userId,
) async {
  final db = ref.read(databaseProvider);

  final userInfo = await db.managers.usersTable
      .filter((f) => f.id(userId))
      .getSingleOrNull();

  if (userInfo == null) {
    final ApiClient apiClient = ApiClient();
    final response = await UserApiService(apiClient).getUserById(userId);
    if (!response.success) {}
    final user = response.data!;

    return SearchItem(
      id: user.id,
      name: user.name,
      bio: user.bio ?? "",
      email: user.email ?? "",
      profilePicUrl: user.profilePicUrl,
    );
  }

  return SearchItem(
    id: userInfo.id,
    name: userInfo.name,
    bio: userInfo.bio,
    email: userInfo.email,
    profilePicUrl: userInfo.profilePictureUrl,
  );
});
