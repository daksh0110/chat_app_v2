class GoogleAuthResponse {
  final String? name;
  final String? email;
  final String? accessToken;
  final bool? newUser;

  GoogleAuthResponse({this.name, this.email, this.accessToken, this.newUser});

  factory GoogleAuthResponse.fromJson(Map<String, dynamic> json) {
    return GoogleAuthResponse(
      name: json['name'],
      email: json['email'],
      accessToken: json['accessToken'],
      newUser: json['newUser'] ?? false,
    );
  }
}
