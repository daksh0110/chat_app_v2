import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/colors/defaullt_color_sheet.dart';
import 'package:my_app/core/app_routes.dart';
import 'package:my_app/core/network/api_client.dart';
import 'package:my_app/data/services/user_api_service.dart';
import 'package:my_app/modal/screens/signup/register_user.dart';
import 'package:my_app/modal/screens/signup/register_user_argument.dart';
import 'package:my_app/modal/screens/verifyEmail/verify_screen_arguments.dart';
import 'package:my_app/providers/auth_notifier_provider.dart';
import 'package:my_app/widgets/comman/divider_text.dart';
import 'package:my_app/widgets/comman/google_auth_login.dart';
import 'package:my_app/widgets/comman/primary_button.dart';
import 'package:my_app/widgets/comman/primary_text.dart';
import 'package:my_app/widgets/comman/primary_text_field.dart';
import 'package:my_app/widgets/comman/toast_notification.dart';
import 'package:toastification/toastification.dart';

class SignUp extends ConsumerStatefulWidget {
  const SignUp({super.key});

  @override
  ConsumerState<SignUp> createState() => _SignUpState();
}

class _SignUpState extends ConsumerState<SignUp> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool get isFormFilled =>
      nameController.text.isNotEmpty &&
      emailController.text.isNotEmpty &&
      passwordController.text.isNotEmpty &&
      confirmPasswordController.text.isNotEmpty &&
      passwordController.text == confirmPasswordController.text;
  RegisterUserArgument? args;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (args == null) {
      args =
          ModalRoute.of(context)?.settings.arguments as RegisterUserArgument?;

      if (args != null) {
        nameController.text = args!.name ?? "";
        emailController.text = args!.email ?? "";
      }
    }
  }

  @override
  void initState() {
    super.initState();
    nameController.addListener(_onTextChange);
    emailController.addListener(_onTextChange);
    passwordController.addListener(_onTextChange);
    confirmPasswordController.addListener(_onTextChange);
  }

  void _onTextChange() => setState(() {});

  void onSubmit() async {
    final name = nameController.text;
    final email = emailController.text;
    final password = passwordController.text;
    final ApiClient apiClient = ApiClient();
    final result = await UserApiService(apiClient).createUser(
      RegisterUser(name: name, email: email, password: password).toJson(),
    );
    if (result.success) {
      ToastHelper.show(
        context: context,
        message: result.data?.message ?? result.message,
      );
      if (!mounted) return;
      Navigator.of(context).pushNamed(
        AppRoutes.verifyEmail,
        arguments: VerifyScreenArguments(
          email: result.data?.email ?? "",
          verificationToken: result.data?.verificationToken ?? "",
        ),
      );
      // await ref.watch(authProvider.notifier).login(data?.accessToken ?? "");
    } else {
      ToastHelper.show(
        context: context,
        message: result.message,
        type: ToastificationType.error,
      );
    }
    return;
  }

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
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              children: [
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
                if (args == null) ...[
                  GoogleAuthLogin(),

                  const SizedBox(height: 30),
                  const DividerText(text: "OR"),
                  const SizedBox(height: 30),
                ],
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      PrimaryTextField(
                        label: "Your name",
                        controller: nameController,
                        validator: (value) =>
                            value!.isEmpty ? "Name is required" : null,
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
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
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
                          if (!RegExp(
                            r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&]).{8,}$',
                          ).hasMatch(value)) {
                            return "Email must contain one Alphabetical character,one small character,one number and must be min of 8 characters";
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

                const SizedBox(height: 40),
                PrimaryButton(
                  text: "Create Account",
                  onPressed: isDisabled ? () {} : onSubmit,
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
      ),
    );
  }
}
