class SucessfullAuthentication {
  final String accessToken;

  SucessfullAuthentication({required this.accessToken});

  factory SucessfullAuthentication.fromJson(Map<String, dynamic> json) {
    return SucessfullAuthentication(accessToken: json["accessToken"]);
  }
}
