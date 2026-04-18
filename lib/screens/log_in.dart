import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/colors/defaullt_color_sheet.dart';
import 'package:my_app/core/app_routes.dart';
import 'package:my_app/core/network/api_client.dart';
import 'package:my_app/data/services/user_api_service.dart';
import 'package:my_app/modal/screens/login/login_user.dart';
import 'package:my_app/modal/screens/verifyEmail/verify_screen_arguments.dart';
import 'package:my_app/providers/auth_notifier_provider.dart';
import 'package:my_app/widgets/comman/divider_text.dart';
import 'package:my_app/widgets/comman/google_auth_login.dart';
import 'package:my_app/widgets/comman/primary_button.dart';
import 'package:my_app/widgets/comman/primary_text.dart';
import 'package:my_app/widgets/comman/primary_text_field.dart';
import 'package:my_app/widgets/comman/toast_notification.dart';
import 'package:toastification/toastification.dart';

class LogIn extends ConsumerStatefulWidget {
  const LogIn({super.key});

  @override
  ConsumerState<LogIn> createState() => _LogInState();
}

class _LogInState extends ConsumerState<LogIn> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool loading = false;
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

  void _onLogin() async {
    final String email = emailController.text;
    final String password = passwordController.text;
    final ApiClient apiClient = ApiClient();
    try {
      setState(() {
        loading = true;
      });
      final result = await UserApiService(
        apiClient,
      ).loginUser(LoginUser(email: email, password: password).toJson());
      if (result.success) {
        if (result.data?.skipOtp == true) {
          if (!mounted) return;
          toastification.show(
            context: context,
            title: PrimaryText(
              result.message,
              color: Colors.white,
              fontSize: 18,
            ),
            type: ToastificationType.success,
            autoCloseDuration: Duration(seconds: 5),
            style: ToastificationStyle.fillColored,
          );
          final data = result.data;
          await ref.read(authProvider.notifier).login(data?.accessToken ?? "");
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
        } else {
          Navigator.of(context).pushNamed(
            AppRoutes.verifyEmail,
            arguments: VerifyScreenArguments(
              email: result.data?.email ?? "",
              verificationToken: result.data?.verificationToken ?? "",
            ),
          );
        }

        return;
      }
    } catch (e, stackTrace) {
      debugPrint("Login error: $e");
      debugPrintStack(stackTrace: stackTrace);
      if (!mounted) return;
      ToastHelper.show(
        context: context,
        message: "Something went wrong. Please try again.",
        type: ToastificationType.error,
      );
    } finally {
      setState(() {
        loading = false;
      });
    }
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
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SizedBox(
            width: double.infinity,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
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

                  GoogleAuthLogin(),

                  const SizedBox(height: 30),

                  const DividerText(
                    text: "OR",
                    textColor: DefaultColorSheet.grey500,
                  ),

                  const SizedBox(height: 30),
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

                  const SizedBox(height: 40),
                  PrimaryButton(
                    text: "Log In",
                    onPressed: isDisabled ? () {} : _onLogin,
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
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.changePassword);
                    },
                    child: const PrimaryText(
                      "Forgot password?",
                      color: DefaultColorSheet.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
