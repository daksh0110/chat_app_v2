import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/core/network/api_client.dart';
import 'package:my_app/data/services/miscellenious.service.dart';
import 'package:my_app/modal/server_status_response.dart';

class ServerConnectionState {
  final bool isConnected;
  final String message;

  const ServerConnectionState({
    required this.isConnected,
    required this.message,
  });
}

final serverConnectedProvider =
    NotifierProvider<ServerConnectedNotifier, ServerConnectionState>(
      ServerConnectedNotifier.new,
    );

class ServerConnectedNotifier extends Notifier<ServerConnectionState> {
  @override
  ServerConnectionState build() {
    return const ServerConnectionState(
      isConnected: false,
      message: "Not connected",
    );
  }

  Future<void> verifyServerConnection() async {
    state = const ServerConnectionState(
      isConnected: false,
      message: "Connecting to server...",
    );

    while (true) {
      try {
        final apiClient = ApiClient();

        final ServerStatusResponse statusResponse = await MiscelleniousService(apiClient).verifyServerConnection();

        if (statusResponse.success) {
          state = ServerConnectionState(
            isConnected: true,
            message: statusResponse.message,
          );
          return;
        } else {
          throw Exception("Server response indicated failure");
        }
      } catch (_) {
        state = const ServerConnectionState(
          isConnected: false,
          message: "Connection failed. Retrying...",
        );

        await Future.delayed(const Duration(seconds: 5));
      }
    }
  }
}
