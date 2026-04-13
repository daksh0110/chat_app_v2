import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/core/app_routes.dart';
import 'package:my_app/core/network/api_client.dart';
import 'package:my_app/data/services/user_api_service.dart';
import 'package:my_app/modal/screens/signup/register_user_argument.dart';
import 'package:my_app/providers/auth_notifier_provider.dart';
import 'package:my_app/providers/google_provider.dart';
import 'package:my_app/widgets/comman/social_icon_button.dart';

class GoogleAuthLogin extends ConsumerWidget {
  const GoogleAuthLogin({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final googleSignIn = ref.read(googleProvider);

    void onGoogleButton() async {
      if (googleSignIn.supportsAuthenticate()) {
        try {
          await googleSignIn.initialize();
          final user = await googleSignIn.authenticate();
          final auth = user.authentication;
          final ApiClient apiClient = ApiClient();
          final response = await UserApiService(
            apiClient,
          ).googleAuth(auth.idToken);
          final data = response.data;

          if (data?.newUser == false && data?.accessToken != null) {
            await ref
                .read(authProvider.notifier)
                .login(data?.accessToken ?? "");
            return;
          }

          if (data?.newUser == true && data?.accessToken == null) {
            print("reached here");
            Navigator.pushNamed(
              context,
              AppRoutes.googlePasswordSetup,
              arguments: RegisterUserArgument(
                name: data?.name,
                email: data?.email,
                id: data?.id,
                token: auth.idToken,
              ),
            );
          }
        } catch (e) {
          print(e);
        }
      }
    }

    return SocialIconButton(
      assetPath: "assets/screens/onboarding_screen/google.svg",
      onTap: onGoogleButton,
    );
  }
}
