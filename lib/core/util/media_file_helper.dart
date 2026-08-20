import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:my_app/modal/upload_responses/upload_attachment.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

/// Global helper for saving media files into a permanent, organized directory
/// inside the app's documents folder.
///
/// Folder structure:
/// ```
/// <appDocDir>/
///   chat_media/
///     images/
///     videos/
///     audio/
///     files/
/// ```
///
/// Usage:
/// ```dart
/// // When picking a file
/// final permanentPath = await MediaFileHelper.copyPickedFileToAppDir(xFile);
///
/// // When downloading received media
/// final permanentPath = await MediaFileHelper.downloadMediaToAppDir(
///   url: downloadUrl,
///   media: uploadAttachment,
/// );
/// ```
class MediaFileHelper {
  MediaFileHelper._();

  // ─── Internal helpers ────────────────────────────────────────────────────

  /// Returns the type-specific sub-directory under `<appDocDir>/chat_media/`.
  /// Creates the directory if it doesn't exist.
  static Future<Directory> _subDir(String mediaType) async {
    final appDir = await getApplicationDocumentsDirectory();
    final subFolderName = _subFolderForType(mediaType);
    final dir = Directory('${appDir.path}/chat_media/$subFolderName');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Maps a media type string to a sub-folder name.
  static String _subFolderForType(String type) {
    switch (type.toUpperCase()) {
      case 'IMAGE':
        return 'images';
      case 'VIDEO':
        return 'videos';
      case 'AUDIO':
        return 'audio';
      default:
        return 'files';
    }
  }

  /// Infers the media type from a MIME string.
  static String _mediaTypeFromMime(String mime) {
    if (mime.startsWith('image/')) return 'IMAGE';
    if (mime.startsWith('video/')) return 'VIDEO';
    if (mime.startsWith('audio/')) return 'AUDIO';
    return 'FILE';
  }

  /// Extracts the file extension from a file name, defaulting to empty string.
  static String _extensionFromName(String name) {
    final dot = name.lastIndexOf('.');
    return dot == -1 ? '' : name.substring(dot);
  }

  // ─── Public API ──────────────────────────────────────────────────────────

  /// Copies a picked [XFile] from its (possibly temporary) cache path into
  /// the permanent app documents directory.
  ///
  /// Returns the permanent file path that should be stored in the database.
  ///
  /// [file] — The XFile returned by ImagePicker / FilePicker.
  static Future<String> copyPickedFileToAppDir(XFile file) async {
    final mime = lookupMimeType(file.path) ?? 'application/octet-stream';
    final mediaType = _mediaTypeFromMime(mime);
    final dir = await _subDir(mediaType);

    final ext = _extensionFromName(file.name.isNotEmpty ? file.name : file.path);
    final uniqueName = '${const Uuid().v4()}$ext';
    final dest = File('${dir.path}/$uniqueName');

    await File(file.path).copy(dest.path);

    return dest.path;
  }

  /// Downloads media from [url] and saves it into the permanent app directory.
  ///
  /// Returns the permanent file path that should be stored in the database.
  ///
  /// [url]   — The resolved download URL.
  /// [media] — The [UploadAttachment] metadata (used for type and name).
  ///
  /// Throws an [Exception] if the download fails (non-200 response).
  static Future<String> downloadMediaToAppDir({
    required String url,
    required UploadAttachment media,
  }) async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) {
      throw Exception(
        'MediaFileHelper: failed to download media (HTTP ${response.statusCode})',
      );
    }

    final mediaType = media.type.isNotEmpty
        ? media.type
        : _mediaTypeFromMime(media.contentType);

    final dir = await _subDir(mediaType);

    final ext = _extensionFromName(
      media.name.isNotEmpty ? media.name : 'file',
    );

    // Use the S3 key (sanitised) so the same file is never duplicated.
    final safeKey = media.key.replaceAll(RegExp(r'[/\\:*?"<>|]'), '_');
    final filename = safeKey.isNotEmpty ? '$safeKey$ext' : '${const Uuid().v4()}$ext';

    final file = File('${dir.path}/$filename');

    // Skip writing if the file already exists (idempotent).
    if (!await file.exists()) {
      await file.writeAsBytes(response.bodyBytes);
    }

    return file.path;
  }
}
