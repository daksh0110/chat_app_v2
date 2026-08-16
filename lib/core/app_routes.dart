import 'package:flutter/widgets.dart';
import 'package:my_app/screens/change_password.dart';
import 'package:my_app/screens/create_group_chat.dart';
import 'package:my_app/screens/google_password_setup.dart';
import 'package:my_app/screens/log_in.dart';
import 'package:my_app/screens/main_screen.dart';
import 'package:my_app/screens/message.dart';
import 'package:my_app/screens/new_chat_screen.dart';
import 'package:my_app/screens/onboarding_screen.dart';
import 'package:my_app/screens/profile_setup.dart';
import 'package:my_app/screens/search.dart';
import 'package:my_app/screens/settings/account/accounts_main.dart';
import 'package:my_app/screens/settings/profile/profile_edit.dart';
import 'package:my_app/screens/settings/settings_main.dart';
import 'package:my_app/screens/sign_up.dart';
import 'package:my_app/screens/user_profile.dart';
import 'package:my_app/screens/verify_email.dart';

class AppRoutes {
  static const String home = '/home';
  static const String onboarding = '/onboarding';
  static const String logIn = "/login";
  static const String signUp = "/signup";
  static const String googlePasswordSetup = "/google-password-setup";
  static const String search = "/search";
  static const String message = "/message";
  static const String settingsMain = "/settings";
  static const String profileEdit = "/settings/profile-edit";
  static const String accountsMain = "/settings/account";
  static const String changePassword = "/change-password";
  static const String verifyEmail = "/verify-email";
  static const String profileSetup = "/profile-setup";
  static const String userProfile = "/user-profile";
  static const String createGroupChat = "/create-group";
  static const String newChat = "/new-chat";

  static Map<String, WidgetBuilder> get routes => {
    home: (context) => MainScreen(),
    onboarding: (context) => const OnboardingScreen(),
    logIn: (context) => const LogIn(),
    signUp: (context) => const SignUp(),
    googlePasswordSetup: (context) => const GooglePasswordSetup(),
    search: (context) => const Search(),
    message: (context) => const MessageScreen(),
    settingsMain: (context) => const SettingsMain(),
    changePassword: (context) => const ChangePassword(),
    verifyEmail: (context) => const VerifyEmailScreen(),
    profileSetup: (context) => const ProfileSetupScreen(),
    userProfile: (context) => UserProfile(),
    createGroupChat: (context) => CreateGroupChat(),
    newChat: (context) => const NewChatScreen(),
    profileEdit: (context) => const ProfileEdit(),
    accountsMain: (context) => const AccountsPage(),
  };
}
