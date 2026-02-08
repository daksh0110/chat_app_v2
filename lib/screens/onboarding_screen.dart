import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_app/colors/defaullt_color_sheet.dart';
import 'package:my_app/core/app_routes.dart';
import 'package:my_app/widgets/comman/divider_text.dart';
import 'package:my_app/widgets/comman/primary_text.dart';
import 'package:my_app/widgets/comman/secondary_button.dart';
import 'package:my_app/widgets/comman/social_icon_button.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Background image
            Image.asset(
              "assets/screens/onboarding_screen/Onboarding.jpg",
              fit: BoxFit.cover,
            ),

            // Foreground content (acts like normal layout)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    PrimaryText(
                      "Atlas",
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                    const SizedBox(height: 12),
                    PrimaryText(
                      "Connect friends",
                      fontSize: 68,
                      overflow: TextOverflow.visible,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                    PrimaryText(
                      "easily & quickly",
                      fontSize: 68,
                      overflow: TextOverflow.visible,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 16),
                    PrimaryText(
                      "Our chat app is the perfect way to stay connected with friends and family.",
                      color: DefaultColorSheet.grey400,
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                    const SizedBox(height: 38),
                    SocialIconButton(
                      assetPath: "assets/screens/onboarding_screen/google.svg",
                      onTap: () {
                        print("Google login");
                      },
                    ),
                    const SizedBox(height: 30),
                    DividerText(text: "OR"),
                    const SizedBox(height: 30),
                    SecondaryButton(
                      text: "Sign up with mail",
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.signUp);
                      },
                    ),
                    const SizedBox(height: 46),
                    InkWell(
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.logIn);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          PrimaryText(
                            "Existing account?",
                            color: DefaultColorSheet.grey400,
                            fontWeight: FontWeight.w500,
                          ),
                          PrimaryText(
                            " Log in",
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
