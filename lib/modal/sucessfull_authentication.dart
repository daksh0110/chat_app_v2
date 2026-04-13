class SucessfullAuthentication {
  final String email;
  final bool skipOtp;
  final String verificationToken;
  final String message;
  final String? accessToken;

  SucessfullAuthentication({
    required this.email,
    this.skipOtp = false,
    required this.verificationToken,
    required this.message,
    this.accessToken,
  });

  factory SucessfullAuthentication.fromJson(Map<String, dynamic> json) {
    return SucessfullAuthentication(
      email: json["email"],
      skipOtp: json["skip_otp"],
      verificationToken: json["verification_token"],
      message: json["message"] ?? "",
      accessToken: json["accessToken"],
    );
  }
}
