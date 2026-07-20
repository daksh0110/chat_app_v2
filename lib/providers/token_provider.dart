import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final tokenProvider = AsyncNotifierProvider<TokenNotifier, String?>(
  TokenNotifier.new,
);

class TokenNotifier extends AsyncNotifier<String?> {
  final _storage = const FlutterSecureStorage();

  @override
  Future<String?> build() async {
    return await _storage.read(key: "accessToken");
  }

  Future<void> setToken(String token) async {
    await _storage.write(key: "accessToken", value: token);
    state = AsyncData(token);
  }

  Future<void> clear() async {
    await _storage.delete(key: "accessToken");
    state = const AsyncData(null);
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    state = AsyncData(await _storage.read(key: "accessToken"));
  }
}
