class PresignedUrlResponse {
  final String url;
  final String? key;
  final String? contentType;

  PresignedUrlResponse({required this.url, this.key, this.contentType});

  factory PresignedUrlResponse.fromJson(Map<String, dynamic> json) {
    return PresignedUrlResponse(
      url: json['url'] as String,
      key: json['key'] as String?,
      contentType: json['content_type'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'url': url, 'key': key, 'content_type': contentType};
  }
}
