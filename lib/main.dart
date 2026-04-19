import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:my_app/core/app_routes.dart';
import 'package:my_app/providers/auth_notifier_provider.dart';
import 'package:my_app/providers/database_provider.dart';
import 'package:my_app/providers/message_provider.dart';
import 'package:my_app/providers/secure_storage_provider.dart';
import 'package:my_app/providers/settings_user_notifier_provider.dart';
import 'package:my_app/providers/socket_provider.dart';
import 'package:my_app/screens/change_password.dart';
import 'package:my_app/screens/main_screen.dart';
import 'package:my_app/screens/log_in.dart';
import 'package:my_app/screens/message.dart';
import 'package:my_app/screens/onboarding_screen.dart';
import 'package:my_app/screens/search.dart';
import 'package:my_app/screens/settings/settings_main.dart';
import 'package:my_app/screens/sign_up.dart';
import 'package:my_app/screens/google_password_setup.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:my_app/screens/profile_setup.dart';
import 'package:my_app/screens/user_profile.dart';
import 'package:my_app/screens/verify_email.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(authProvider, (previous, next) async {
      // ref.read(databaseProvider).managers.chatListTable.delete();
      // ref.read(databaseProvider).managers.messages.delete();
      // ref.read(databaseProvider).managers.userInfoSettings.delete();
      // ref.read(secureStorageProvider.notifier).clearToken();
      next.whenData((state) async {
        if (state == AuthState.authenticated) {
          final storage = const FlutterSecureStorage();
          final token = await storage.read(key: "accessToken") ?? "";
          ref.read(socketProvider).onConnect(() async {
            final notifier = ref.read(messageProvider.notifier);
            await notifier.receiveMessage();
            await notifier.messageDelivered();
            await notifier.markRead();
            notifier.sendChatSyncEvent();
            notifier.receiveTypingEvent();
            notifier.receiveStopTypingEvent();
            notifier.sendQueueMessages();
          });
          await ref.read(settingsUserProvider.notifier).setUser(token);
          ref.read(socketProvider).connect(token);
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
        AppRoutes.googlePasswordSetup: (context) => const GooglePasswordSetup(),
        AppRoutes.search: (context) => const Search(),
        AppRoutes.message: (context) => const MessageScreen(),
        AppRoutes.settingsMain: (context) => const SettingsMain(),
        AppRoutes.changePassword: (context) => const ChangePassword(),
        AppRoutes.verifyEmail: (context) => const VerifyEmailScreen(),
        AppRoutes.profileSetup: (context) => const ProfileSetupScreen(),
        AppRoutes.userProfile: (context) => UserProfile(),
      },
    );
  }
}
