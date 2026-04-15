class GoogleAuthResponse {
  final String? name;
  final String? email;
  final String? accessToken;
  final bool? newUser;
  final String? id;

  GoogleAuthResponse({
    this.name,
    this.email,
    this.accessToken,
    this.newUser,
    this.id,
  });

  factory GoogleAuthResponse.fromJson(Map<String, dynamic> json) {
    return GoogleAuthResponse(
      name: json['name'],
      email: json['email'],
      accessToken: json['accessToken'],
      newUser: json['newUser'] ?? false,
      id: json['id'],
    );
  }
}
