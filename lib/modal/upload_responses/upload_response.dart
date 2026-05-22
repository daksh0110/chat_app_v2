class UploadResponse {
  final String url;
  final String entityType;
  final String assetType;
  final String? entityId;

  UploadResponse({
    required this.url,
    required this.entityType,
    required this.assetType,
    this.entityId,
  });

  factory UploadResponse.fromJson(Map<String, dynamic> json) {
    return UploadResponse(
      url: json['url'] as String,
      entityType: json['entity_type'] as String,
      assetType: json['asset_type'] as String,
      entityId: json['entity_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'entity_type': entityType,
      'asset_type': assetType,
      if (entityId != null) 'entity_id': entityId,
    };
  }
}
