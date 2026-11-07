class ChatNotificationSettings {
  final bool isMuted;
  final int? mutedUntil;
  final String notificationSound; // Local setting

  const ChatNotificationSettings({
    this.isMuted = false,
    this.mutedUntil,
    this.notificationSound = 'default',
  });

  bool get isEffectivelyMuted {
    if (!isMuted) return false;
    if (mutedUntil == null) return true;
    return DateTime.now().millisecondsSinceEpoch < mutedUntil!;
  }

  factory ChatNotificationSettings.fromJson(Map<String, dynamic> json) {
    return ChatNotificationSettings(
      isMuted: json['isMuted'] ?? json['is_muted'] ?? false,
      mutedUntil: json['mutedUntil'] is int
          ? json['mutedUntil']
          : json['muted_until'] != null
              ? DateTime.tryParse(json['muted_until'].toString())
                  ?.millisecondsSinceEpoch
              : null,
      notificationSound: (json['notificationSound'] ??
              json['notification_sound'] ??
              'default')
          .toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isMuted': isMuted,
      'mutedUntil': mutedUntil,
      'notificationSound': notificationSound,
    };
  }

  Map<String, dynamic> toBackendJson() {
    return {
      'is_muted': isMuted,
      'muted_until': mutedUntil != null
          ? DateTime.fromMillisecondsSinceEpoch(mutedUntil!).toIso8601String()
          : null,
    };
  }

  ChatNotificationSettings copyWith({
    bool? isMuted,
    int? mutedUntil,
    bool clearMutedUntil = false,
    String? notificationSound,
  }) {
    return ChatNotificationSettings(
      isMuted: isMuted ?? this.isMuted,
      mutedUntil: clearMutedUntil ? null : (mutedUntil ?? this.mutedUntil),
      notificationSound: notificationSound ?? this.notificationSound,
    );
  }
}

class ChatAppearanceSettings {
  final String? wallpaper; // Local setting (color, preset, or image path)

  const ChatAppearanceSettings({
    this.wallpaper,
  });

  factory ChatAppearanceSettings.fromJson(Map<String, dynamic> json) {
    return ChatAppearanceSettings(
      wallpaper: json['wallpaper']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'wallpaper': wallpaper,
    };
  }

  ChatAppearanceSettings copyWith({
    String? wallpaper,
    bool clearWallpaper = false,
  }) {
    return ChatAppearanceSettings(
      wallpaper: clearWallpaper ? null : (wallpaper ?? this.wallpaper),
    );
  }
}

class ChatManagementSettings {
  final bool isPinned;
  final int? pinnedAt;
  final bool isArchived;
  final int? archivedAt;

  const ChatManagementSettings({
    this.isPinned = false,
    this.pinnedAt,
    this.isArchived = false,
    this.archivedAt,
  });

  factory ChatManagementSettings.fromJson(Map<String, dynamic> json) {
    return ChatManagementSettings(
      isPinned: json['isPinned'] ?? json['is_pinned'] ?? false,
      pinnedAt: json['pinnedAt'] is int
          ? json['pinnedAt']
          : json['pinned_at'] != null
              ? DateTime.tryParse(json['pinned_at'].toString())
                  ?.millisecondsSinceEpoch
              : null,
      isArchived: json['isArchived'] ?? json['is_archived'] ?? false,
      archivedAt: json['archivedAt'] is int
          ? json['archivedAt']
          : json['archived_at'] != null
              ? DateTime.tryParse(json['archived_at'].toString())
                  ?.millisecondsSinceEpoch
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isPinned': isPinned,
      'pinnedAt': pinnedAt,
      'isArchived': isArchived,
      'archivedAt': archivedAt,
    };
  }

  Map<String, dynamic> toBackendJson() {
    return {
      'is_pinned': isPinned,
      'is_archived': isArchived,
    };
  }

  ChatManagementSettings copyWith({
    bool? isPinned,
    int? pinnedAt,
    bool? isArchived,
    int? archivedAt,
  }) {
    return ChatManagementSettings(
      isPinned: isPinned ?? this.isPinned,
      pinnedAt: pinnedAt ?? this.pinnedAt,
      isArchived: isArchived ?? this.isArchived,
      archivedAt: archivedAt ?? this.archivedAt,
    );
  }
}

class ChatPrivacySettings {
  final int disappearingDuration; // in seconds (0 = off)

  const ChatPrivacySettings({
    this.disappearingDuration = 0,
  });

  factory ChatPrivacySettings.fromJson(Map<String, dynamic> json) {
    return ChatPrivacySettings(
      disappearingDuration: json['disappearingDuration'] ??
          json['disappearing_messages_duration'] ??
          json['duration'] ??
          0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'disappearingDuration': disappearingDuration,
    };
  }

  Map<String, dynamic> toBackendJson() {
    return {
      'duration': disappearingDuration,
    };
  }

  ChatPrivacySettings copyWith({
    int? disappearingDuration,
  }) {
    return ChatPrivacySettings(
      disappearingDuration: disappearingDuration ?? this.disappearingDuration,
    );
  }
}

class ChatStorageSettings {
  final String mediaAutoDownload; // 'default' | 'always' | 'wifi_only' | 'never' (Local)

  const ChatStorageSettings({
    this.mediaAutoDownload = 'default',
  });

  factory ChatStorageSettings.fromJson(Map<String, dynamic> json) {
    return ChatStorageSettings(
      mediaAutoDownload: (json['mediaAutoDownload'] ??
              json['media_auto_download'] ??
              'default')
          .toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mediaAutoDownload': mediaAutoDownload,
    };
  }

  ChatStorageSettings copyWith({
    String? mediaAutoDownload,
  }) {
    return ChatStorageSettings(
      mediaAutoDownload: mediaAutoDownload ?? this.mediaAutoDownload,
    );
  }
}

class ChatSettingsModal {
  final String chatId;
  final ChatNotificationSettings notifications;
  final ChatAppearanceSettings appearance;
  final ChatManagementSettings management;
  final ChatPrivacySettings privacy;
  final ChatStorageSettings storage;

  const ChatSettingsModal({
    required this.chatId,
    this.notifications = const ChatNotificationSettings(),
    this.appearance = const ChatAppearanceSettings(),
    this.management = const ChatManagementSettings(),
    this.privacy = const ChatPrivacySettings(),
    this.storage = const ChatStorageSettings(),
  });

  // Conveniences
  bool get isMuted => notifications.isMuted;
  int? get mutedUntil => notifications.mutedUntil;
  bool get isEffectivelyMuted => notifications.isEffectivelyMuted;
  String get notificationSound => notifications.notificationSound;
  String? get wallpaper => appearance.wallpaper;
  bool get isPinned => management.isPinned;
  int? get pinnedAt => management.pinnedAt;
  bool get isArchived => management.isArchived;
  int? get archivedAt => management.archivedAt;
  int get disappearingDuration => privacy.disappearingDuration;
  String get mediaAutoDownload => storage.mediaAutoDownload;

  factory ChatSettingsModal.fromJson(Map<String, dynamic> json) {
    final chatId = (json['chatId'] ?? json['chat_id'] ?? '').toString();

    // Support nested or flat JSON
    final notifJson = json['notifications'] is Map
        ? Map<String, dynamic>.from(json['notifications'])
        : json;
    final appearJson = json['appearance'] is Map
        ? Map<String, dynamic>.from(json['appearance'])
        : json;
    final mgmtJson = json['chat_management'] is Map
        ? Map<String, dynamic>.from(json['chat_management'])
        : (json['management'] is Map
            ? Map<String, dynamic>.from(json['management'])
            : json);
    final privJson = json['disappearing_messages'] is Map
        ? Map<String, dynamic>.from(json['disappearing_messages'])
        : (json['privacy'] is Map
            ? Map<String, dynamic>.from(json['privacy'])
            : json);
    final storeJson = json['storage'] is Map
        ? Map<String, dynamic>.from(json['storage'])
        : json;

    return ChatSettingsModal(
      chatId: chatId,
      notifications: ChatNotificationSettings.fromJson(notifJson),
      appearance: ChatAppearanceSettings.fromJson(appearJson),
      management: ChatManagementSettings.fromJson(mgmtJson),
      privacy: ChatPrivacySettings.fromJson(privJson),
      storage: ChatStorageSettings.fromJson(storeJson),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chatId': chatId,
      'notifications': notifications.toJson(),
      'appearance': appearance.toJson(),
      'management': management.toJson(),
      'privacy': privacy.toJson(),
      'storage': storage.toJson(),
    };
  }

  Map<String, dynamic> toBackendJson() {
    return {
      'notifications': notifications.toBackendJson(),
      'chat_management': management.toBackendJson(),
      'disappearing_messages': privacy.toBackendJson(),
    };
  }

  ChatSettingsModal copyWith({
    String? chatId,
    ChatNotificationSettings? notifications,
    ChatAppearanceSettings? appearance,
    ChatManagementSettings? management,
    ChatPrivacySettings? privacy,
    ChatStorageSettings? storage,
  }) {
    return ChatSettingsModal(
      chatId: chatId ?? this.chatId,
      notifications: notifications ?? this.notifications,
      appearance: appearance ?? this.appearance,
      management: management ?? this.management,
      privacy: privacy ?? this.privacy,
      storage: storage ?? this.storage,
    );
  }
}
