import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:my_app/core/util/get_file_type.dart';
import 'package:my_app/modal/upload_responses/upload_attachment.dart';

String formatMessagePreview({
  required String message,
  List<UploadAttachment>? attachments,
  List<XFile>? localAttachments,
}) {
  if (message.isNotEmpty) {
    if ((attachments != null && attachments.isNotEmpty) ||
        (localAttachments != null && localAttachments.isNotEmpty)) {
      final type = attachments?.isNotEmpty == true
          ? attachments!.first.type
          : (localAttachments?.isNotEmpty == true
              ? getMediaType(lookupMimeType(localAttachments!.first.path) ?? "")
              : "");
      final prefix = switch (type.toUpperCase()) {
        "IMAGE" => "📷 ",
        "VIDEO" => "🎥 ",
        "AUDIO" => "🎵 ",
        _ => "📄 ",
      };
      return "$prefix$message";
    }
    return message;
  }

  if (attachments != null && attachments.isNotEmpty) {
    final type = attachments.first.type.toUpperCase();
    return switch (type) {
      "IMAGE" => "📷 Photo",
      "VIDEO" => "🎥 Video",
      "AUDIO" => "🎵 Audio",
      _ => "📄 Document",
    };
  }

  if (localAttachments != null && localAttachments.isNotEmpty) {
    final mime = lookupMimeType(localAttachments.first.path) ?? "";
    final type = getMediaType(mime).toUpperCase();
    return switch (type) {
      "IMAGE" => "📷 Photo",
      "VIDEO" => "🎥 Video",
      "AUDIO" => "🎵 Audio",
      _ => "📄 Document",
    };
  }

  return "";
}

