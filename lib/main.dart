import 'package:flutter/material.dart';
import 'package:my_app/core/app_routes.dart';
import 'package:my_app/core/util/route_observer.dart';
import 'package:my_app/data/services/notification_service.dart';
import 'package:my_app/providers/auth_notifier_provider.dart';
import 'package:my_app/providers/friend_requests_provider.dart';
import 'package:my_app/providers/message_provider.dart';

import 'package:my_app/providers/server_connection_provider.dart';
import 'package:my_app/providers/socket_provider.dart';
import 'package:my_app/providers/token_provider.dart';
import 'package:my_app/screens/main_screen.dart';
import 'package:my_app/screens/onboarding_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:my_app/services/socket/friend_request_socket.dart';
import 'package:my_app/services/socket/misc_socket.dart';
import 'firebase_options.dart';
import 'package:my_app/widgets/comman/overlay_banner.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Future.microtask(() {
      ref.read(serverConnectedProvider.notifier).verifyServerConnection();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final socket = ref.read(socketProvider);
      if (socket.isConnected) {
        final notifier = ref.read(messageProvider.notifier);
        notifier.sendChatSyncEvent();
        notifier.sendQueueMessages();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authProvider, (previous, next) async {
      next.whenData((state) async {
        if (state == AuthState.authenticated) {
          await Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform,
          );

          FirebaseMessaging.onBackgroundMessage(
            firebaseMessagingBackgroundHandler,
          );

          await NotificationService.initialize();
          final token = await ref.read(tokenProvider.future);

          if (token == null) return;
          ref.read(socketProvider).onConnect(() async {
            final notifier = ref.read(messageProvider.notifier);
            await notifier.receiveMessage();
            await notifier.messageDelivered();
            await notifier.markRead();
            notifier.sendChatSyncEvent();
            notifier.receiveTypingEvent();
            notifier.receiveStopTypingEvent();
            notifier.sendQueueMessages();
            notifier.groupChatCreatedListener();
            await ref
                .read(miscellaneousNotifierProvider.notifier)
                .listenUserUpdateDetails();
            ref.read(friendRequestSocketProvider.notifier).listen();
            // notifier.groupsCountSync();

            await NotificationService.handleInitialMessage();
          });
          ref.read(socketProvider).connect(token);
          await seedFriendRequestsFromRest(ref);
        }
      });
    });

    final authState = ref.watch(authProvider);

    return MaterialApp(
      navigatorKey: navigatorKey,
      navigatorObservers: [routeObserver],
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: "Caros"),
      builder: (context, child) {
        return Stack(children: [child!, const OverLayBanner()]);
      },
      home: authState.when(
        loading: () =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),

        error: (err, stack) =>
            const Scaffold(body: Center(child: Text("Something went wrong"))),

        data: (state) {
          if (state == AuthState.authenticated) {
            return MainScreen();
          } else {
            return const OnboardingScreen();
          }
        },
      ),

      routes: AppRoutes.routes,
    );
  }
}
