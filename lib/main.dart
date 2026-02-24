import 'package:flutter/material.dart';
import 'package:my_app/core/app_routes.dart';
import 'package:my_app/providers/auth_notifier_provider.dart';
import 'package:my_app/screens/main_screen.dart';
import 'package:my_app/screens/log_in.dart';
import 'package:my_app/screens/message.dart';
import 'package:my_app/screens/onboarding_screen.dart';
import 'package:my_app/screens/search.dart';
import 'package:my_app/screens/settings/settings_main.dart';
import 'package:my_app/screens/sign_up.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/widgets/socket_initilizer.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            return SocketInitializer(child: MainScreen());
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
