enum NotificationType { friendRequestReceived, friendRequestAccepted }

enum NotificationEntityType { user }

class NotificationModel {
  final String id;
  final String recipientId;
  final String? actorId;
  final NotificationType type;
  final String? entityId;
  final NotificationEntityType? entityType;
  final bool isRead;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.recipientId,
    this.actorId,
    required this.type,
    this.entityId,
    this.entityType,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      recipientId: json['recipientId'] as String,
      actorId: json['actorId'] as String?,
      type: NotificationType.values.firstWhere((e) => e.name == json['type']),
      entityId: json['entityId'] as String?,
      entityType: json['entityType'] != null
          ? NotificationEntityType.values.firstWhere(
              (e) => e.name == json['entityType'],
            )
          : null,
      isRead: json['isRead'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'recipientId': recipientId,
      'actorId': actorId,
      'type': type.name,
      'entityId': entityId,
      'entityType': entityType?.name,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'NotificationModel('
        'id: $id, '
        'recipientId: $recipientId, '
        'actorId: $actorId, '
        'type: ${type.name}, '
        'entityId: $entityId, '
        'entityType: ${entityType?.name}, '
        'isRead: $isRead, '
        'createdAt: $createdAt'
        ')';
  }
}
