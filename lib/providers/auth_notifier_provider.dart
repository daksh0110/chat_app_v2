import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

enum AuthState { authenticated, unauthenticated }

final authProvider = AsyncNotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

class AuthNotifier extends AsyncNotifier<AuthState> {
  final _storage = const FlutterSecureStorage();

  @override
  Future<AuthState> build() async {
    final token = await _storage.read(key: "accessToken");
    print(token);
    if (token != null && token.isNotEmpty) {
      return AuthState.authenticated;
    }

    return AuthState.unauthenticated;
  }

  Future<void> login(String token) async {
    print(token);
    await _storage.write(key: "accessToken", value: token);
    state = const AsyncData(AuthState.authenticated);
    print("STATE AFTER LOGIN: $state");
  }

  Future<void> logout() async {
    await _storage.delete(key: "accessToken");
    state = const AsyncData(AuthState.unauthenticated);
  }
}
