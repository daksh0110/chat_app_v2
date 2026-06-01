import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/core/app_routes.dart';
import 'package:my_app/modal/screens/search/message_screen_arguments.dart';
import 'package:my_app/providers/chat_list_provider.dart';

import '../../firebase_options.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final FlutterLocalNotificationsPlugin _localNotif =
    FlutterLocalNotificationsPlugin();

const _androidChannel = AndroidNotificationChannel(
  'chat_messages',
  'Chat Messages',
  description: 'Incoming chat message notifications',
  importance: Importance.high,
  playSound: true,
);

class NotificationService {
  static Future<void> initialize() async {
    final messaging = FirebaseMessaging.instance;

    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (kDebugMode) {
      print('FCM Permission: ${settings.authorizationStatus}');
    }

    final token = await messaging.getToken();
    if (kDebugMode) {
      print('FCM Token: $token');
    }

    const initSettingsAndroid = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const initSettingsIOS = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: initSettingsAndroid,
      iOS: initSettingsIOS,
    );

    await _localNotif.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (details) {
        _handlePayloadNavigation(details.payload);
      },
    );

    await _localNotif
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_androidChannel);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('Foreground FCM: ${message.notification?.title}');
      }

      final chatId = message.data['chat_id'] as String? ?? '';
      bool shouldShow = true;
      final context = navigatorKey.currentContext;

      if (context != null && chatId.isNotEmpty) {
        try {
          final activeChatId = ProviderScope.containerOf(
            context,
          ).read(chatListControllerProvider).activeChatId;
          if (activeChatId == chatId) {
            shouldShow = false;
          }
        } catch (_) {}
      }

      if (shouldShow) {
        _showLocalNotification(message);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('onMessageOpenedApp: ${message.data}');
      }
      _navigateToChat(message.data);
    });
  }

  static Future<void> handleInitialMessage() async {
    final message = await FirebaseMessaging.instance.getInitialMessage();
    if (message != null) {
      if (kDebugMode) {
        print('getInitialMessage: ${message.data}');
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigateToChat(message.data);
      });
    }
  }

  static Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    final title = notification?.title ?? 'New message';
    final body = notification?.body ?? '';

    // Encode data as pipe-separated payload for the tap callback
    final chatId = message.data['chat_id'] ?? '';
    final senderId = message.data['sender_id'] ?? '';
    final type = message.data['type'] ?? 'DIRECT';
    final payload = '$chatId|$senderId|$type';

    final androidDetails = AndroidNotificationDetails(
      _androidChannel.id,
      _androidChannel.name,
      channelDescription: _androidChannel.description,
      importance: Importance.high,
      priority: Priority.high,
      ticker: body,
    );

    await _localNotif.show(
      id: message.hashCode,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(android: androidDetails),
      payload: payload,
    );
  }

  // ── Parse pipe-encoded payload and navigate ────────────────────────────────
  static void _handlePayloadNavigation(String? payload) {
    if (payload == null || payload.isEmpty) return;
    final parts = payload.split('|');
    if (parts.length < 3) return;

    final chatId = parts[0];
    final senderId = parts[1];
    final type = parts[2];

    _navigateToChat({'chat_id': chatId, 'sender_id': senderId, 'type': type});
  }

  // ── Core navigation helper ─────────────────────────────────────────────────
  // Reads chat_id / sender_id / type from the FCM data map and pushes
  // MessageScreen.  sender_name / profilePicUrl are not in the payload so
  // MessageScreen will resolve them from its local DB.
  static void _navigateToChat(Map<String, dynamic> data) {
    final chatId = data['chat_id'] as String? ?? '';
    final senderId = data['sender_id'] as String? ?? '';
    final type = data['type'] as String? ?? 'DIRECT';

    if (chatId.isEmpty) return;

    final context = navigatorKey.currentContext;
    if (context == null) return;

    // Pop everything back to the root first so we don't stack duplicate chat
    // screens on top of each other.
    Navigator.of(context).popUntil((route) => route.isFirst);

    Navigator.pushNamed(
      context,
      AppRoutes.message,
      arguments: MessageScreenArguments(
        chatId: chatId,
        receiverId: senderId,
        name: '', // MessageScreen resolves name from DB / chat list
        isGroupChat: type,
      ),
    );
  }
}

// ─── Background message handler (top-level, required by firebase_messaging) ──
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (kDebugMode) {
    print('Background FCM: ${message.messageId}');
  }
  // Background messages are automatically shown by the OS using the FCM
  // notification payload; no further action needed here.
}
