import 'dart:async';

import 'package:my_app/modal/screens/createGroup/create_group_response.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SocketService {
  IO.Socket? socket;
  final List<void Function()> _onConnectCallbacks = [];
  final Set<String> _registeredEvents = {};
  final List<void Function(bool isConnected, String message)>
      _onConnectionChangeCallbacks = [];

  void onConnectionChange(
    void Function(bool isConnected, String message) callback,
  ) {
    _onConnectionChangeCallbacks.add(callback);
    if (socket != null) {
      callback(
        socket!.connected,
        socket!.connected ? "Connected to server" : "Server not connected",
      );
    }
  }

  void _notifyConnectionChange(bool connected, String message) {
    for (final cb in _onConnectionChangeCallbacks) {
      cb(connected, message);
    }
  }

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
      _notifyConnectionChange(true, "Connected to server");

      for (final cb in _onConnectCallbacks) {
        cb();
      }
    });

    socket!.onDisconnect((_) {
      print('❌ Disconnected');
      _notifyConnectionChange(false, "Server not connected. Reconnecting...");
    });

    socket!.onConnectError((data) {
      print('⚠️ Connect Error: $data');
      _notifyConnectionChange(false, "Connection error. Reconnecting...");
    });

    socket!.io.on('reconnect', (_) {
      _notifyConnectionChange(true, "Reconnected to server");
    });

    socket!.io.on('reconnecting', (_) {
      _notifyConnectionChange(false, "Reconnecting to server...");
    });
  }

  void disconnect() {
    socket?.disconnect();
    _notifyConnectionChange(false, "Disconnected");
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

  Future<dynamic> addGroupMember(String chatId, String userId) {
    final completer = Completer<dynamic>();
    if (socket == null) {
      completer.completeError('Socket not connected');
      return completer.future;
    }

    socket!.emitWithAck(
      "add-group-member",
      {"chatId": chatId, "userId": userId},
      ack: (response) {
        if (response is Map && response['success'] == true) {
          completer.complete(response);
        } else {
          completer.completeError(
            Exception(
              response is Map
                  ? (response['message'] ?? 'Failed to add member')
                  : 'Failed to add member',
            ),
          );
        }
      },
    );
    return completer.future;
  }

  Future<dynamic> removeGroupMember(String chatId, String userId) {
    final completer = Completer<dynamic>();
    if (socket == null) {
      completer.completeError('Socket not connected');
      return completer.future;
    }

    socket!.emitWithAck(
      "remove-group-member",
      {"chatId": chatId, "userId": userId},
      ack: (response) {
        if (response is Map && response['success'] == true) {
          completer.complete(response);
        } else {
          completer.completeError(
            Exception(
              response is Map
                  ? (response['message'] ?? 'Failed to remove member')
                  : 'Failed to remove member',
            ),
          );
        }
      },
    );
    return completer.future;
  }

  Future<dynamic> leaveGroup(String chatId) {
    final completer = Completer<dynamic>();
    if (socket == null) {
      completer.completeError('Socket not connected');
      return completer.future;
    }

    socket!.emitWithAck(
      "leave-group",
      {"chatId": chatId},
      ack: (response) {
        if (response is Map && response['success'] == true) {
          completer.complete(response);
        } else {
          completer.completeError(
            Exception(
              response is Map
                  ? (response['message'] ?? 'Failed to leave group')
                  : 'Failed to leave group',
            ),
          );
        }
      },
    );
    return completer.future;
  }

  Future<dynamic> changeGroupMemberRole(
    String chatId,
    String userId,
    String role,
  ) {
    final completer = Completer<dynamic>();
    if (socket == null) {
      completer.completeError('Socket not connected');
      return completer.future;
    }

    socket!.emitWithAck(
      "change-group-member-role",
      {"chatId": chatId, "userId": userId, "role": role},
      ack: (response) {
        if (response is Map && response['success'] == true) {
          completer.complete(response);
        } else {
          completer.completeError(
            Exception(
              response is Map
                  ? (response['message'] ?? 'Failed to update role')
                  : 'Failed to update role',
            ),
          );
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
