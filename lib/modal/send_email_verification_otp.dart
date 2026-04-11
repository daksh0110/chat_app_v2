class SendEmailVerificationOtp {
  final String newVerificationToken;

  SendEmailVerificationOtp({required this.newVerificationToken});

  factory SendEmailVerificationOtp.fromJson(Map<String, dynamic> json) {
    return SendEmailVerificationOtp(
      newVerificationToken: json["verification_token"],
    );
  }
}
