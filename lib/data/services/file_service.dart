import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:my_app/core/util/media_file_helper.dart';
import 'package:my_app/modal/upload_responses/upload_attachment.dart';
import 'package:path_provider/path_provider.dart';

class FileService {
  Future<String> downloadAndSave({
    required String downloadUrl,
    required String actorId,
    required UploadAttachment media,
  }) async {
    var response = await http.get(Uri.parse(downloadUrl));

    if (response.statusCode != 200) {
      throw Exception('Failed to download media');
    }

    return _writeBytesToProfileDir(response.bodyBytes, actorId, media);
  }

  /// Downloads a **chat media attachment** and saves it into the permanent
  /// `chat_media/<type>/` directory via [MediaFileHelper].
  ///
  /// Use this instead of [downloadAndSave] for message attachments so the
  /// file lands in the correct, organized app-documents folder.
  Future<String> downloadChatMedia({
    required String downloadUrl,
    required UploadAttachment media,
  }) async {
    return MediaFileHelper.downloadMediaToAppDir(
      url: downloadUrl,
      media: media,
    );
  }

  Future<String> _writeBytesToProfileDir(
    List<int> bytes,
    String actorId,
    UploadAttachment media,
  ) async {
    final appDir = await getApplicationDocumentsDirectory();

    final profileDir = Directory('${appDir.path}/profile_photos');

    if (!await profileDir.exists()) {
      await profileDir.create(recursive: true);
    }

    final extension = _extensionFromName(
      media.name.isNotEmpty ? media.name : 'profile.jpg',
    );

    final filename = '${actorId}_${media.key.replaceAll('/', '_')}$extension';

    final file = File('${profileDir.path}/$filename');

    await file.writeAsBytes(bytes);

    return file.path;
  }

  String _extensionFromName(String name) {
    final dot = name.lastIndexOf('.');
    return dot == -1 ? '.jpg' : name.substring(dot);
  }
}
