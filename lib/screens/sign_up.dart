import 'package:flutter/material.dart';
import 'package:my_app/colors/defaullt_color_sheet.dart';
import 'package:my_app/widgets/comman/divider_text.dart';
import 'package:my_app/widgets/comman/primary_button.dart';
import 'package:my_app/widgets/comman/primary_text.dart';
import 'package:my_app/widgets/comman/primary_text_field.dart';
import 'package:my_app/widgets/comman/social_icon_button.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool get isFormFilled =>
      nameController.text.isNotEmpty &&
      emailController.text.isNotEmpty &&
      passwordController.text.isNotEmpty &&
      confirmPasswordController.text.isNotEmpty;

  @override
  void initState() {
    super.initState();
    nameController.addListener(_onTextChange);
    emailController.addListener(_onTextChange);
    passwordController.addListener(_onTextChange);
    confirmPasswordController.addListener(_onTextChange);
  }

  void _onTextChange() => setState(() {});

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = !isFormFilled;

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
          child: Column(
            children: [
              const SizedBox(height: 60),

              const PrimaryText(
                "Sign up with Email",
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),

              const SizedBox(height: 16),

              const PrimaryText(
                "Get chatting with friends and family today by signing up for our chat app!",
                textAlign: TextAlign.center,
                color: DefaultColorSheet.grey500,
              ),

              const SizedBox(height: 30),

              SocialIconButton(
                assetPath: "assets/screens/onboarding_screen/google.svg",
                onTap: () {},
              ),

              const SizedBox(height: 30),
              const DividerText(text: "OR"),
              const SizedBox(height: 30),

              /// 🔥 SCROLLABLE AREA
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: IntrinsicHeight(
                          child: Column(
                            children: [
                              Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    PrimaryTextField(
                                      label: "Your name",
                                      controller: nameController,
                                      validator: (value) => value!.isEmpty
                                          ? "Name is required"
                                          : null,
                                    ),

                                    const SizedBox(height: 24),

                                    PrimaryTextField(
                                      label: "Email",
                                      controller: emailController,
                                      keyboardType: TextInputType.emailAddress,
                                      validator: (value) {
                                        if (value!.isEmpty) {
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
                                        if (value!.isEmpty) {
                                          return "Password is required";
                                        }
                                        if (value.length < 6) {
                                          return "Minimum 6 characters";
                                        }
                                        return null;
                                      },
                                    ),

                                    const SizedBox(height: 24),

                                    PrimaryTextField(
                                      label: "Confirm Password",
                                      controller: confirmPasswordController,
                                      obscureText: true,
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return "Confirm your password";
                                        }
                                        if (value != passwordController.text) {
                                          return "Passwords do not match";
                                        }
                                        return null;
                                      },
                                    ),
                                  ],
                                ),
                              ),

                              const Spacer(),

                              PrimaryButton(
                                text: "Create Account",
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
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
