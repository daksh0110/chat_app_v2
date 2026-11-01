import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/core/network/api_client.dart';
import 'package:my_app/data/services/miscellenious.service.dart';
import 'package:my_app/modal/server_status_response.dart';
import 'package:my_app/providers/socket_provider.dart';

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
  bool _listenerAttached = false;

  @override
  ServerConnectionState build() {
    if (!_listenerAttached) {
      _listenerAttached = true;
      Future.microtask(() => _attachSocketListener());
    }
    return const ServerConnectionState(
      isConnected: false,
      message: "Connecting to server...",
    );
  }

  void _attachSocketListener() {
    final socket = ref.read(socketProvider);
    socket.onConnectionChange((isConnected, message) {
      state = ServerConnectionState(
        isConnected: isConnected,
        message: message,
      );
    });
  }

  void setConnectionState(bool isConnected, String message) {
    state = ServerConnectionState(
      isConnected: isConnected,
      message: message,
    );
  }

  Future<void> verifyServerConnection() async {
    final socket = ref.read(socketProvider);
    if (socket.isConnected) {
      state = const ServerConnectionState(
        isConnected: true,
        message: "Connected to server",
      );
      return;
    }

    try {
      final apiClient = ApiClient();
      final ServerStatusResponse statusResponse =
          await MiscelleniousService(apiClient).verifyServerConnection();

      if (statusResponse.success) {
        if (socket.isConnected) {
          state = ServerConnectionState(
            isConnected: true,
            message: statusResponse.message,
          );
        } else {
          state = const ServerConnectionState(
            isConnected: false,
            message: "Connecting to real-time chat...",
          );
        }
      } else {
        state = const ServerConnectionState(
          isConnected: false,
          message: "Server is unavailable. Retrying...",
        );
      }
    } catch (_) {
      state = const ServerConnectionState(
        isConnected: false,
        message: "Server not connected. Retrying...",
      );
    }
  }
}
