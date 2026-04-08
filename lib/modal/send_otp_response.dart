class SendOtpResponse {
  final String resetToken;

  SendOtpResponse({required this.resetToken});

  factory SendOtpResponse.fromJson(Map<String, dynamic> json) {
    return SendOtpResponse(resetToken: json["reset_token"]);
  }
}
