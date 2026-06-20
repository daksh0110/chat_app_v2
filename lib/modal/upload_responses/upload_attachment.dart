class UploadAttachment {
  final String key;
  final String contentType;
  final String type;
  final String name;
  final String? url;
  final String? actorId;
  final String? location;

  UploadAttachment({
    required this.key,
    required this.contentType,
    required this.type,
    this.name = "",
    this.url,
    this.actorId = "",
    this.location = "",
  });

  factory UploadAttachment.fromJson(Map<String, dynamic> json) {
    return UploadAttachment(
      key: json['key'] as String,
      contentType: json['content_type'] as String,
      type: json['type'] as String,
      name: json['name'] as String? ?? "",
      url: json['url'] as String?,
      actorId: json["actor_id"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'content_type': contentType,
      'type': type,
      'name': name,
      if (url != null) 'url': url,
    };
  }
}
