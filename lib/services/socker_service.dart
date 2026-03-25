import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SocketService {
  IO.Socket? socket;
  final List<void Function()> _onConnectCallbacks = [];

  bool get isInitialized => socket != null;
  bool get isConnected => socket?.connected ?? false;

  void connect(String token) {
    socket = IO.io(
      dotenv.env['BASE_URL'],
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({"token": token})
          .enableReconnection()
          .setReconnectionAttempts(999999)
          .setReconnectionDelay(2000)
          .build(),
    );

    socket!.connect();

    socket!.onConnect((_) {
      print('✅ Connected');

      for (final cb in _onConnectCallbacks) {
        cb();
      }
    });

    socket!.onDisconnect((_) {
      print('❌ Disconnected');
    });

    socket!.onConnectError((data) {
      print('⚠️ Connect Error: $data');
    });
  }

  void disconnect() {
    socket?.disconnect();
  }

  void onConnect(void Function() callback) {
    if (socket?.connected == true) {
      callback();
    } else {
      _onConnectCallbacks.add(callback);
    }
  }

  void sendMessage(String event, dynamic data) {
    if (socket == null || !socket!.connected) return;
    socket!.emit(event, data);
  }

  void sendMessageWithAck(String event, dynamic data, Function(dynamic) onAck) {
    if (socket == null || !socket!.connected) return;
    socket!.emitWithAck(event, data, ack: onAck);
  }

  void listen(String event, Function(dynamic) callback) {
    if (socket == null) return;
    socket!.on(event, callback);
  }

  void checkUserStatus(String receiverId) {
    if (socket == null || !socket!.connected) return;
    socket!.emit("check_user_status", {"userId": receiverId});
  }

  void getUserStatus(void Function(dynamic data) callback) {
    if (socket == null) return;
    socket!.on("user_status", callback);
  }

  void listenUserOnline(void Function(dynamic data) callback) {
    if (socket == null) return;
    socket!.on("user_online", callback);
  }

  void listenUserOffline(void Function(dynamic data) callback) {
    if (socket == null) return;
    socket!.on("user_offline", callback);
  }

  void off(String event, [Function(dynamic)? callback]) {
    if (socket == null) return;
    if (callback != null) {
      socket!.off(event, callback);
    } else {
      socket!.off(event);
    }
  }

  void dispose() {
    socket?.dispose();
  }
}
