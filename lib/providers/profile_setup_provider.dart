import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:my_app/core/network/api_client.dart';
import 'package:my_app/core/util/get_file_type.dart';
import 'package:my_app/data/services/upload_service.dart';
import 'package:my_app/data/services/user_api_service.dart';
import 'package:my_app/modal/upload_responses/upload_attachment.dart';
import 'package:my_app/modal/user.modal.dart';
import 'package:my_app/providers/media_download_provider.dart';
import 'package:my_app/providers/tables/media_table_provider.dart';
import 'package:my_app/providers/tables/user_preference_table_provider.dart';
import 'package:my_app/providers/tables/users_table_provider.dart';

final profileScreenProvider = NotifierProvider<ProfileSetupProvider, void>(
  ProfileSetupProvider.new,
);

class ProfileSetupProvider extends Notifier {
  @override
  build() {}

  Future<UserModel?> fetchUserProfileDetails() async {
    final currentUser = ref.watch(userPreferenceTableProvider).value;
    final userTableRef = ref.read(usersTableProvider.notifier);
    final user = await userTableRef.getUserById(currentUser ?? '');

    if (user == null) {
      throw Exception("User not found");
    }

    return UserModel(
      id: currentUser ?? '',
      bio: user.bio,
      name: user.name,
      email: user.email,
      profilePic: user.profilePic,
    );
  }

  Future<UploadAttachment?> uploadImage(XFile? pickedImageFile) async {
    if (pickedImageFile == null) return null;

    final currentUser = ref.watch(userPreferenceTableProvider).value;

    final mime =
        lookupMimeType(pickedImageFile.path) ?? "application/octet-stream";

    final presignedUrl = await UploadService(ApiClient()).getPresignedUrl(
      assetType: "user",
      entityType: "avatar",
      contentType: mime,
      entityId: currentUser,
    );

    if (!presignedUrl.success || presignedUrl.data == null) {
      throw Exception("Failed to get upload URL");
    }

    final response = presignedUrl.data!;

    final result = await UploadService(ApiClient()).uploadToSignedUrl(
      await pickedImageFile.readAsBytes(),
      response.url,
      mime,
    );

    if (result != 200) {
      throw Exception("Upload failed");
    }

    return UploadAttachment(
      contentType: mime,
      key: response.key ?? "",
      type: getMediaType(mime),
      name: pickedImageFile.name,
    );
  }

  Future<void> updateProfile({
    required String bio,
    XFile? pickedImageFile,
    String? profilePicUrl,
  }) async {
    final currentUser = ref.watch(userPreferenceTableProvider).value;

    if (currentUser == null) {
      throw Exception("User not found");
    }

    final storage = const FlutterSecureStorage();
    final token = await storage.read(key: 'accessToken');
    final apiClient = ApiClient();

    UploadAttachment? media;
    String? localPath;

    if (pickedImageFile == null && profilePicUrl == null) {
      final result = await UserApiService(apiClient).updateProfile(
        token: token ?? "",
        bio: bio.trim().isEmpty ? null : bio.trim(),
        media: null,
      );

      if (!result.success) {
        throw Exception(result.message);
      }

      return;
    }

    if (pickedImageFile != null) {
      media = await uploadImage(pickedImageFile);

      if (media == null) {
        throw Exception("Failed to upload image");
      }

      localPath = pickedImageFile.path;
    } else {
      final localFile = await ref
          .read(mediaDownloadProvider.notifier)
          .saveImageUrlLocally(profilePicUrl!);

      localPath = localFile.path;

      media = await uploadImage(localFile);

      if (media == null) {
        throw Exception("Failed to upload Google profile image");
      }
    }

    await ref
        .read(mediaTableProvider.notifier)
        .addOrUpdateMediaDocument(
          UploadAttachment(
            key: media.key,
            contentType: media.contentType,
            type: media.type,
            actorId: currentUser,
            location: localPath,
            name: media.name,
          ),
          currentUser,
        );

    final result = await UserApiService(apiClient).updateProfile(
      token: token ?? "",
      bio: bio.trim().isEmpty ? null : bio.trim(),
      media: media,
    );

    if (!result.success) {
      throw Exception(result.message);
    }

    await ref
        .read(usersTableProvider.notifier)
        .updateUserBio(currentUser, bio.trim());
  }
}
