class LoginUser {
  final String email;
  final String password;

  LoginUser({required this.email, required this.password});

  Map<String, dynamic> toJson() => {"email": email, "password": password};
}
