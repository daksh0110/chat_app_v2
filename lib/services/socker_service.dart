import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SocketService {
  late IO.Socket socket;
  final List<void Function()> _onConnectCallbacks = [];
  void connect(String token) {
    socket = IO.io(
      '${dotenv.env['BASE_URL']}',
      IO.OptionBuilder().setTransports(['websocket']).setAuth({
        "token": token,
      }).build(),
    );

    socket.connect();

    socket.onConnect((_) {
      for (final cb in _onConnectCallbacks) {
        cb();
      }
    });

    socket.onDisconnect((_) {
      print('❌ Disconnected');
    });

    socket.onConnectError((data) {
      print('⚠️ Connect Error: $data');
    });
  }

  void disconnect() {
    socket.disconnect();
  }

  void onConnect(void Function() callback) {
    _onConnectCallbacks.add(callback);
  }

  void sendMessage(String event, dynamic data) {
    socket.emit(event, data);
  }

  void sendMessageWithAck(String event, dynamic data, Function(dynamic) onAck) {
    socket.emitWithAck(event, data, ack: onAck);
  }

  void listen(String event, Function(dynamic) callback) {
    socket.on(event, callback);
  }

  void checkUserStatus(String receiverId) {
    socket.emit("check_user_status", {"userId": receiverId});
  }

  void getUserStatus(void Function(dynamic data) callback) {
    socket.off("user_status");
    socket.on("user_status", callback);
  }

  void listenUserOnline(void Function(dynamic data) callback) {
    socket.off("user_online");
    socket.on("user_online", callback);
  }

  void listenUserOffline(void Function(dynamic data) callback) {
    socket.off("user_offline");
    socket.on("user_offline", callback);
  }

  void dispose() {
    socket.dispose();
  }
}
