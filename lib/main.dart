import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:my_app/core/app_routes.dart';
import 'package:my_app/providers/auth_notifier_provider.dart';
import 'package:my_app/providers/database_provider.dart';
import 'package:my_app/providers/message_provider.dart';
import 'package:my_app/providers/settings_user_notifier_provider.dart';
import 'package:my_app/providers/socket_provider.dart';
import 'package:my_app/screens/main_screen.dart';
import 'package:my_app/screens/log_in.dart';
import 'package:my_app/screens/message.dart';
import 'package:my_app/screens/onboarding_screen.dart';
import 'package:my_app/screens/search.dart';
import 'package:my_app/screens/settings/settings_main.dart';
import 'package:my_app/screens/sign_up.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(authProvider, (previous, next) async {
      next.whenData((state) async {
        if (state == AuthState.authenticated) {
          final storage = const FlutterSecureStorage();
          final token = await storage.read(key: "accessToken") ?? "";
          await ref.read(settingsUserProvider.notifier).setUser(token);

          ref.read(socketProvider).connect(token);
          final notifier = ref.read(messageProvider.notifier);

          await notifier.receiveMessage();
          await notifier.messageDelivered();
          await notifier.markRead();

          notifier.sendChatSyncEvent();
        }
      });
    });
    final authState = ref.watch(authProvider);

    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: "Caros"),

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

      routes: {
        AppRoutes.home: (context) => MainScreen(),
        AppRoutes.onboarding: (context) => const OnboardingScreen(),
        AppRoutes.logIn: (context) => const LogIn(),
        AppRoutes.signUp: (context) => const SignUp(),
        AppRoutes.search: (context) => const Search(),
        AppRoutes.message: (context) => const MessageScreen(),
        AppRoutes.settingsMain: (context) => const SettingsMain(),
      },
    );
  }
}
