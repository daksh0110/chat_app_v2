import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:my_app/modal/screens/createGroup/create_group_response.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SocketService {
  IO.Socket? socket;
  final List<void Function()> _onConnectCallbacks = [];
  final Set<String> _registeredEvents = {};

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
      _registeredEvents.clear();

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
    _onConnectCallbacks.add(callback);

    if (socket?.connected == true) {
      callback();
    }
  }

  void listenOnce(String event, Function(dynamic) callback) {
    if (socket == null) return;
    if (_registeredEvents.contains(event)) return;
    _registeredEvents.add(event);
    socket!.on(event, callback);
  }

  void emitEvent(String event, dynamic data) {
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

  void checkGroupStatus(String chatId) {
    if (socket == null || !socket!.connected) return;
    socket!.emit("check_group_status", {"chatId": chatId});
  }

  void getGroupStatus(void Function(dynamic data) callback) {
    if (socket == null) return;
    socket!.on("group_status", callback);
  }

  Future<CreateGroupResponse> createGroup(Map<String, dynamic> data) {
    final completer = Completer<CreateGroupResponse>();

    if (socket == null || !socket!.connected) {
      completer.completeError(Exception("Socket is not connected"));
      return completer.future;
    }

    socket!.emitWithAck(
      "create-group",
      data,
      ack: (response) {
        try {
          final parsed = CreateGroupResponse.fromJson(
            Map<String, dynamic>.from(response),
          );
          completer.complete(parsed);
        } catch (e) {
          completer.completeError(e);
        }
      },
    );

    return completer.future;
  }

  void listenGroupCreated(void Function(dynamic data) callback) {
    if (socket == null) return;
    socket!.on("group-created", callback);
  }

  void listenUserOnline(void Function(dynamic data) callback) {
    if (socket == null) return;
    socket!.on("user_online", callback);
  }

  void listenUserOffline(void Function(dynamic data) callback) {
    if (socket == null) return;
    socket!.on("user_offline", callback);
  }

  void listenUserUpdateDetails(void Function(dynamic data) onUserUpdated) {
    if (socket == null) return;

    socket!.on("user-info-updated", (data) {
      onUserUpdated(data);
    });
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
