import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final flutterSecureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final secureStorageProvider =
    AsyncNotifierProvider<SecureStorageNotifier, String?>(
      SecureStorageNotifier.new,
    );

class SecureStorageNotifier extends AsyncNotifier<String?> {
  late final FlutterSecureStorage _storage;

  @override
  Future<String?> build() async {
    _storage = ref.read(flutterSecureStorageProvider);

    return await _storage.read(key: 'accessToken');
  }

  Future<void> setToken(String token) async {
    state = const AsyncLoading();

    await _storage.write(key: 'accessToken', value: token);

    state = AsyncData(token);
  }

  Future<void> clearToken() async {
    state = const AsyncLoading();

    await _storage.delete(key: 'accessToken');

    state = const AsyncData(null);
  }
}
