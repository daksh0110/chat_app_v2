import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:my_app/providers/socket_provider.dart';

enum AuthState { authenticated, unauthenticated }

final authProvider = AsyncNotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

class AuthNotifier extends AsyncNotifier<AuthState> {
  final _storage = const FlutterSecureStorage();

  @override
  Future<AuthState> build() async {
    final token = await _storage.read(key: "accessToken");

    if (token != null && token.isNotEmpty) {
      return AuthState.authenticated;
    }

    return AuthState.unauthenticated;
  }

  Future<void> login(String token) async {
    await _storage.write(key: "accessToken", value: token);

    ref.read(socketProvider).connect(token);

    state = const AsyncData(AuthState.authenticated);
  }

  Future<void> logout() async {
    await _storage.delete(key: "accessToken");

    ref.read(socketProvider).disconnect();

    state = const AsyncData(AuthState.unauthenticated);
  }
}
