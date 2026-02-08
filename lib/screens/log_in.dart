import 'package:flutter/material.dart';
import 'package:my_app/colors/defaullt_color_sheet.dart';
import 'package:my_app/widgets/comman/divider_text.dart';
import 'package:my_app/widgets/comman/primary_button.dart';
import 'package:my_app/widgets/comman/primary_text.dart';
import 'package:my_app/widgets/comman/primary_text_field.dart';
import 'package:my_app/widgets/comman/social_icon_button.dart';

class LogIn extends StatefulWidget {
  const LogIn({super.key});

  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool get isFormFilled =>
      emailController.text.isNotEmpty && passwordController.text.isNotEmpty;

  @override
  void initState() {
    super.initState();
    emailController.addListener(_onTextChange);
    passwordController.addListener(_onTextChange);
  }

  void _onTextChange() {
    setState(() {});
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = !isFormFilled;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 60),

                const PrimaryText(
                  "Log in to Chatbox",
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                const Padding(
                  padding: EdgeInsets.all(13),
                  child: PrimaryText(
                    "Welcome back! Sign in using your social account or email to continue us",
                    textAlign: TextAlign.center,
                    color: DefaultColorSheet.grey500,
                  ),
                ),

                const SizedBox(height: 30),

                SocialIconButton(
                  assetPath: "assets/screens/onboarding_screen/google.svg",
                  onTap: () {},
                ),

                const SizedBox(height: 30),

                const DividerText(
                  text: "OR",
                  textColor: DefaultColorSheet.grey500,
                ),

                const SizedBox(height: 30),

                Expanded(
                  child: Column(
                    children: [
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            PrimaryTextField(
                              label: "Email",
                              controller: emailController,
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Email is required";
                                }
                                if (!RegExp(
                                  r'^[^@]+@[^@]+\.[^@]+',
                                ).hasMatch(value)) {
                                  return "Enter a valid email";
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 24),

                            PrimaryTextField(
                              label: "Password",
                              controller: passwordController,
                              obscureText: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Password is required";
                                }
                                if (value.length < 6) {
                                  return "Password must be at least 6 characters";
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),

                      PrimaryButton(
                        text: "Log In",
                        onPressed: isDisabled
                            ? () {}
                            : () {
                                Navigator.pushNamed(context, "/");
                              },
                        backgroundColor: isDisabled
                            ? DefaultColorSheet.disbaledButton
                            : DefaultColorSheet.primary,
                        borderColor: isDisabled
                            ? DefaultColorSheet.disbaledButton
                            : DefaultColorSheet.primary,
                        textColor: isDisabled
                            ? DefaultColorSheet.grey500
                            : Colors.white,
                      ),

                      const SizedBox(height: 16),

                      InkWell(
                        onTap: () {},
                        child: const PrimaryText(
                          "Forgot password?",
                          color: DefaultColorSheet.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
