import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  late IO.Socket socket;

  void connect(String token) {
    socket = IO.io(
      'http://192.168.1.11:5000',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({"token": token})
          .disableAutoConnect()
          .build(),
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

  void listen(String event, Function(dynamic) callback) {
    socket.on(event, callback);
  }

  void dispose() {
    socket.dispose();
  }
}
