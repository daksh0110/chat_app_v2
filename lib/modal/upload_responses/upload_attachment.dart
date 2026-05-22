class UploadAttachment {
  final String key;
  final String contentType;
  final String type;
  final String name;
  final String? url;

  UploadAttachment({
    required this.key,
    required this.contentType,
    required this.type,
    this.name = "",
    this.url,
  });

  factory UploadAttachment.fromJson(Map<String, dynamic> json) {
    return UploadAttachment(
      key: json['key'] as String,
      contentType: json['content_type'] as String,
      type: json['type'] as String,
      name: json['name'] as String? ?? "",
      url: json['url'] as String?,
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
