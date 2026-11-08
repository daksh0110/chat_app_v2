import 'package:my_app/core/database.dart';

class SharedMediaItemModel {
  final int id;
  final String messageId;
  final String chatId;
  final String senderId;
  final String senderName;
  final String type;
  final String name;
  final String key;
  final String? location;
  final String? url;
  final String? contentType;
  final DateTime createdAt;

  const SharedMediaItemModel({
    required this.id,
    required this.messageId,
    required this.chatId,
    required this.senderId,
    required this.senderName,
    required this.type,
    required this.name,
    required this.key,
    this.location,
    this.url,
    this.contentType,
    required this.createdAt,
  });

  bool get isImage =>
      type.toUpperCase() == 'IMAGE' ||
      (contentType?.toLowerCase().startsWith('image/') ?? false);

  bool get isVideo =>
      type.toUpperCase() == 'VIDEO' ||
      (contentType?.toLowerCase().startsWith('video/') ?? false);

  bool get isAudio =>
      type.toUpperCase() == 'AUDIO' ||
      (contentType?.toLowerCase().startsWith('audio/') ?? false);

  bool get isFile => !isImage && !isVideo && !isAudio;

  MediaTableData toMediaTableData() {
    return MediaTableData(
      id: id,
      location: location,
      contentType: contentType,
      actorId: messageId,
      Type: type,
      name: name,
      key: key,
      url: url,
      createdAt: createdAt.millisecondsSinceEpoch,
    );
  }
}
