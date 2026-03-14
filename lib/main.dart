import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:my_app/core/app_routes.dart';
import 'package:my_app/providers/auth_notifier_provider.dart';
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

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(authProvider, (previous, next) {
      next.whenData((state) async {
        if (state == AuthState.authenticated) {
          final storage = const FlutterSecureStorage();
          final token = await storage.read(key: "accessToken") ?? "";
          await ref.read(settingsUserProvider.notifier).setUser(token);

          ref.read(socketProvider).connect(token);
          ref.read(messageProvider.notifier).receiveMessage();
          ref.read(messageProvider.notifier).messageSent();
          ref.read(messageProvider.notifier).messageDelivered();
          ref.read(messageProvider.notifier).markRead();
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
