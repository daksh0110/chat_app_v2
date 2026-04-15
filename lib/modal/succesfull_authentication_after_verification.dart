class SuccesfullAuthenticationAfterVerification {
  final String accessToken;

  SuccesfullAuthenticationAfterVerification({required this.accessToken});

  factory SuccesfullAuthenticationAfterVerification.fromJson(
    Map<String, dynamic> json,
  ) {
    return SuccesfullAuthenticationAfterVerification(
      accessToken: json["accessToken"],
    );
  }
}
