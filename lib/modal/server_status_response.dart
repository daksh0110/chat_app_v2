class ServerStatusResponse {
  final bool success;
  final String message;

  ServerStatusResponse({
    required this.success,
    required this.message,
  });

  factory ServerStatusResponse.fromJson(Map<String, dynamic> json) {
    return ServerStatusResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
    );
  }
}
