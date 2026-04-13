import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/colors/defaullt_color_sheet.dart';
import 'package:my_app/core/app_routes.dart';
import 'package:my_app/core/network/api_client.dart';
import 'package:my_app/data/services/user_api_service.dart';
import 'package:my_app/modal/screens/signup/register_user_argument.dart';
import 'package:my_app/providers/auth_notifier_provider.dart';
import 'package:my_app/widgets/comman/primary_button.dart';
import 'package:my_app/widgets/comman/primary_text.dart';
import 'package:my_app/widgets/comman/primary_text_field.dart';
import 'package:my_app/widgets/comman/toast_notification.dart';
import 'package:toastification/toastification.dart';

class GooglePasswordSetup extends ConsumerStatefulWidget {
  const GooglePasswordSetup({super.key});

  @override
  ConsumerState<GooglePasswordSetup> createState() =>
      _GooglePasswordSetupState();
}

class _GooglePasswordSetupState extends ConsumerState<GooglePasswordSetup> {
  final _formKey = GlobalKey<FormState>();

  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool get isFormFilled =>
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
    }
  }

  @override
  void initState() {
    super.initState();
    passwordController.addListener(_onTextChange);
    confirmPasswordController.addListener(_onTextChange);
  }

  void _onTextChange() => setState(() {});

  void onSubmit() async {
    final password = passwordController.text;
    final ApiClient apiClient = ApiClient();
    final result = await UserApiService(apiClient).googleAuthSetPassword(
      token: args?.token ?? '',
      password: password,
      id: args?.id ?? '',
    );
    if (result.success) {
      await ref
          .read(authProvider.notifier)
          .login(result.data?.accessToken ?? '');
      final profile = await UserApiService(
        apiClient,
      ).getMyProfile(token: result.data?.accessToken ?? '');

      if (!mounted) return;

      Navigator.of(
        context,
      ).pushNamed(AppRoutes.profileSetup, arguments: profile.data);
    } else {
      ToastHelper.show(
        context: context,
        message: result.message,
        type: ToastificationType.error,
      );
    }
  }

  @override
  void dispose() {
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
                  "Set Your Password",
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                const SizedBox(height: 16),
                const PrimaryText(
                  "Complete your account setup by setting a password.",
                  textAlign: TextAlign.center,
                  color: DefaultColorSheet.grey500,
                ),
                const SizedBox(height: 30),
                if (args != null) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: DefaultColorSheet.grey100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const PrimaryText(
                              "Name: ",
                              fontWeight: FontWeight.w500,
                            ),
                            PrimaryText(args!.name ?? ''),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const PrimaryText(
                              "Email: ",
                              fontWeight: FontWeight.w500,
                            ),
                            PrimaryText(args!.email ?? ''),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
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
                            return "Password must contain at least one uppercase letter, one lowercase letter, one number, one special character, and be at least 8 characters long";
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
                  text: "Complete Setup",
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
