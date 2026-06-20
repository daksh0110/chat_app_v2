import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:my_app/core/network/api_client.dart';
import 'package:my_app/core/util/get_file_type.dart';
import 'package:my_app/data/services/upload_service.dart';
import 'package:my_app/modal/upload_responses/upload_attachment.dart';

final AwsNotifierProvider = NotifierProvider(AwsNotifier.new);

class AwsNotifier extends Notifier {
  @override
  build() {
    return null;
  }

  Future<UploadAttachment?> uploadImage(
    XFile? pickedImageFile,
    String? actorId,
  ) async {
    if (pickedImageFile == null) {
      return null;
    }

    try {
      final mime =
          lookupMimeType(pickedImageFile.path) ?? "application/octet-stream";

      final presignedUrl = await UploadService(ApiClient()).getPresignedUrl(
        assetType: "user",
        entityType: "avatar",
        contentType: mime,
        entityId: actorId,
      );

      if (!presignedUrl.success || presignedUrl.data == null) {
        return null;
      }

      final response = presignedUrl.data!;

      final result = await UploadService(ApiClient()).uploadToSignedUrl(
        await pickedImageFile.readAsBytes(),
        response.url,
        mime,
      );

      if (result == 200) {
        return UploadAttachment(
          contentType: mime,
          key: response.key ?? "",
          type: getMediaType(mime),
          name: pickedImageFile.name,
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
