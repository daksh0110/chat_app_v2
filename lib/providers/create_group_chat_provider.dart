import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:my_app/core/network/api_client.dart';
import 'package:my_app/core/util/get_file_type.dart';
import 'package:my_app/data/services/upload_service.dart';
import 'package:my_app/modal/chat_list_modal.dart';
import 'package:my_app/modal/group_creation_modal.dart';
import 'package:my_app/modal/upload_responses/upload_attachment.dart';
import 'package:my_app/providers/socket_provider.dart';
import 'package:my_app/providers/tables/chat_list_table_provider.dart';
import 'package:my_app/providers/tables/groups_table_provider.dart';
import 'package:my_app/providers/tables/media_table_provider.dart';

final createGroupChatProvider = NotifierProvider<CreateGroupChatProvider, void>(
  CreateGroupChatProvider.new,
);

class CreateGroupChatProvider extends Notifier {
  @override
  build() {}

  Future<UploadAttachment?> uploadImage(XFile pickedImage) async {
    try {
      final mime =
          lookupMimeType(pickedImage.path) ?? "application/octet-stream";

      final presignedUrl = await UploadService(ApiClient()).getPresignedUrl(
        assetType: "chat",
        entityType: "avatar",
        contentType: mime,
      );
      if (!presignedUrl.success || presignedUrl.data == null) {
        throw Exception("unable to generate presignedUrl");
      }
      final response = presignedUrl.data!;
      final result = await UploadService(
        ApiClient(),
      ).uploadToSignedUrl(await pickedImage.readAsBytes(), response.url, mime);

      if (result == 200) {
        return UploadAttachment(
          contentType: mime,
          key: response.key ?? "",
          type: getMediaType(mime),
          name: pickedImage.name,
          location: pickedImage.path,
        );
      }
      return null;
    } catch (e) {
      debugPrint(
        "failed to upload Image while creating group: ${e.toString()}",
      );
      return null;
    }
  }

  Future<void> createGroup(GroupCreationModal group) async {
    final socket = ref.read(socketProvider);

    final response = await socket.createGroup(group.toJson());

    if (response.success != true) {
      throw Exception(response.message);
    }

    final chatId = response.data?.chatId;
    if (chatId == null) {
      throw Exception("Chat ID not received");
    }

    if (group.media != null) {
      await ref
          .read(mediaTableProvider.notifier)
          .addOrUpdateMediaDocument(group.media!, chatId);
    }

    final groupDoc = await ref
        .read(groupsTableProvider.notifier)
        .fetchAndUpdateGroup(chatId);
    if (groupDoc != null) {
      await ref
          .read(chatListTableProvider.notifier)
          .createOrUpdateChatList(
            ChatListModal(
              id: groupDoc.id,
              chatId: chatId,
              lastMessage: "group created",
              lastMessageTime: DateTime.now().millisecondsSinceEpoch.toString(),
              bio: groupDoc.bio,
              name: groupDoc.name,
              type: "GROUP",
            ),
          );
    }
  }
}
