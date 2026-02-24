import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  late IO.Socket socket;

  void connect() {
    socket = IO.io(
      'http://10.0.2.2:5000',
      IO.OptionBuilder()
          .setTransports(['websocket'])
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
