import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_app/core/network/api_client.dart';
import 'package:my_app/data/services/user_api_service.dart';
import 'package:my_app/modal/upload_responses/upload_attachment.dart';
import 'package:my_app/modal/user.modal.dart';
import 'package:my_app/providers/notifiers/aws_notifier.dart';
import 'package:my_app/providers/secure_storage_provider.dart';
import 'package:my_app/providers/socket_provider.dart';
import 'package:my_app/providers/tables/users_table_provider.dart';

final profileEditProvider = AsyncNotifierProvider<ProfileEditProvider, void>(
  ProfileEditProvider.new,
);

class ProfileEditProvider extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> updateProfile({
    required String userId,
    required String name,
    required String email,
    required String? bio,
    required XFile? image,
    required bool profileChanged,
  }) async {
    state = const AsyncLoading();

    try {
      UploadAttachment? media;

      if (profileChanged) {
        media = await ref
            .read(AwsNotifierProvider.notifier)
            .uploadImage(image, userId);

        if (media == null) {
          throw Exception("Failed to upload image");
        }
      }

      final token = await ref
          .read(flutterSecureStorageProvider)
          .read(key: "accessToken");

      if (token == null || token.isEmpty) {
        throw Exception("Access token not found");
      }

      final result = await UserApiService(ApiClient()).updateProfile(
        token: token,
        bio: bio?.trim().isNotEmpty == true ? bio!.trim() : null,
        media: media,
      );

      if (!result.success) {
        throw Exception(result.message);
      }

      await ref
          .read(usersTableProvider.notifier)
          .updateUserProfile(
            UserModel(id: userId, name: name, email: email, bio: bio),
            media,
          );

      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> sendUpdateUserEvent(String userId) async {
    final data = {"user_id": userId};
    ref.read(socketProvider).emitEvent("user-info-updated", data);
  }
}
