import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  late IO.Socket socket;

  void connect(String token) {
    socket = IO.io(
      'http://192.168.29.193:5000',
      IO.OptionBuilder().setTransports(['websocket']).setAuth({
        "token": token,
      }).build(),
    );

    socket.connect();

    socket.onConnect((_) {
      print('✅ Connected: ${socket.id}');
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
