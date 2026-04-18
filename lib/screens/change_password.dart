import 'dart:async';

import 'package:flutter/material.dart';
import 'package:my_app/colors/defaullt_color_sheet.dart';
import 'package:my_app/core/app_routes.dart';
import 'package:my_app/core/network/api_client.dart';
import 'package:my_app/data/changePassword/changePasswordState.dart';
import 'package:my_app/data/services/user_api_service.dart';
import 'package:my_app/modal/screens/changePassword/change_password_state.dart';
import 'package:my_app/widgets/comman/otp_input_field.dart';
import 'package:my_app/widgets/comman/primary_button.dart';
import 'package:my_app/widgets/comman/primary_text.dart';
import 'package:my_app/widgets/comman/primary_text_field.dart';
import 'package:my_app/widgets/comman/toast_notification.dart';
import 'package:toastification/toastification.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final _formKey = GlobalKey<FormState>();
  final apiClient = ApiClient();
  bool resendOtpDisable = true;
  Timer? _timer;
  int _start = 60;

  void startTimer() {
    _timer?.cancel();
    setState(() {
      resendOtpDisable = true;
      _start = 60;
    });

    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) => setState(() {
        if (_start <= 0) {
          timer.cancel();
          resendOtpDisable = false;
        } else {
          _start = _start - 1;
        }
      }),
    );
  }

  late List<ChangePasswordState> data;
  final Map<String, TextEditingController> controllers = {};
  int currentIndex = 0;
  String resetToken = "";
  bool loading = false;

  @override
  void initState() {
    super.initState();

    data = changePasswordInitialState.map((e) => e.copyWith()).toList();

    for (var field in data) {
      controllers[field.name] = TextEditingController();
      controllers[field.name]?.addListener(() => setState(() {}));
    }

    controllers["otp"] = TextEditingController();
    controllers["otp"]?.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    for (var controller in controllers.values) {
      controller.dispose();
    }
    _timer?.cancel();

    super.dispose();
  }

  void _nextStep() async {
    if (!_formKey.currentState!.validate()) return;
    switch (currentIndex) {
      case 0:
        _sendOtp(resend: false);
        break;
      case 1:
        _verifyOtp();
        break;
      case 2:
        _changePassword();
        break;
    }
  }

  void _sendOtp({required bool resend}) async {
    if (loading) return;

    setState(() => loading = true);

    try {
      final response = await UserApiService(
        apiClient,
      ).sendOtp(email: controllers["email"]!.text);

      if (response.success) {
        resetToken = response.data?.resetToken ?? "";

        if (!mounted) return;

        ToastHelper.show(context: context, message: response.message);

        if (!resend) {
          setState(() {
            if (currentIndex < data.length - 1) {
              data[currentIndex] = data[currentIndex].copyWith(
                status: ChangePasswordStatus.success,
              );
              currentIndex++;
            }
          });
        }

        startTimer();
      } else {
        if (!mounted) return;

        ToastHelper.show(
          context: context,
          message: response.message,
          type: ToastificationType.error,
        );
      }
    } catch (e, stackTrace) {
      debugPrint("Send OTP error: $e");
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      ToastHelper.show(
        context: context,
        message: "Failed to send OTP. Try again.",
        type: ToastificationType.error,
      );
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  void _changePassword() async {
    if (loading) return;

    setState(() => loading = true);

    try {
      final response = await UserApiService(apiClient).changePassword(
        resetToken: resetToken,
        newpassword: controllers["changePassword"]!.text,
      );

      if (response.success) {
        if (!mounted) return;

        ToastHelper.show(context: context, message: response.message);

        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(AppRoutes.onboarding, (route) => false);

        setState(() {
          if (currentIndex < data.length - 1) {
            data[currentIndex] = data[currentIndex].copyWith(
              status: ChangePasswordStatus.success,
            );
            currentIndex++;
          }
        });
      } else {
        if (!mounted) return;

        ToastHelper.show(
          context: context,
          message: response.message,
          type: ToastificationType.error,
        );
      }
    } catch (e, stackTrace) {
      debugPrint("Error changing password: $e");
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      ToastHelper.show(
        context: context,
        message: "Something went wrong. Please try again.",
        type: ToastificationType.error,
      );
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  void _verifyOtp() async {
    if (loading) return;

    setState(() => loading = true);

    try {
      final response = await UserApiService(
        apiClient,
      ).verifyOtp(resetToken: resetToken, otp: controllers["otp"]!.text);

      if (response.success) {
        if (!mounted) return;

        ToastHelper.show(context: context, message: response.message);

        setState(() {
          if (currentIndex < data.length - 1) {
            data[currentIndex] = data[currentIndex].copyWith(
              status: ChangePasswordStatus.success,
            );
            currentIndex++;
          }
        });
      } else {
        if (!mounted) return;

        ToastHelper.show(
          context: context,
          message: response.message,
          type: ToastificationType.error,
        );
      }
    } catch (e, stackTrace) {
      debugPrint("Verify OTP error: $e");
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      ToastHelper.show(
        context: context,
        message: "OTP verification failed.",
        type: ToastificationType.error,
      );
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  bool get isDisabled {
    if (currentIndex == 0) {
      return !RegExp(
        data[0].matchCondition,
      ).hasMatch(controllers["email"]!.text);
    } else if (currentIndex == 1) {
      return controllers["otp"]!.text.length != 4;
    } else {
      final password = controllers["changePassword"]!.text;
      final confirm = controllers["confirmPassword"]!.text;

      final validPassword = RegExp(data[2].matchCondition).hasMatch(password);

      return !(validPassword && password == confirm);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentState = data[currentIndex];

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
          child: Form(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            key: _formKey,
            child: Column(
              children: [
                const PrimaryText(
                  "Change Password",
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 24),

                /// 🔥 ANIMATED UI
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) {
                    final offsetAnimation = Tween<Offset>(
                      begin: const Offset(1, 0),
                      end: Offset.zero,
                    ).animate(animation);

                    return SlideTransition(
                      position: offsetAnimation,
                      child: FadeTransition(opacity: animation, child: child),
                    );
                  },
                  child: currentIndex >= 2
                      ? _buildPasswordUI()
                      : _buildEmailOtpUI(),
                ),

                const Spacer(),

                PrimaryButton(
                  text: currentState.buttonMessage,
                  onPressed: (isDisabled || loading)
                      ? () {}
                      : () {
                          _nextStep();
                        },
                  backgroundColor: (isDisabled || loading)
                      ? DefaultColorSheet.disbaledButton
                      : DefaultColorSheet.primary,
                  borderColor: (isDisabled || loading)
                      ? DefaultColorSheet.disbaledButton
                      : DefaultColorSheet.primary,
                  textColor: (isDisabled || loading)
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

  Widget _buildEmailOtpUI() {
    return Column(
      key: const ValueKey("emailOtp"),
      children: [
        PrimaryTextField(
          label: "Email",
          controller: controllers["email"],
          keyboardType: TextInputType.emailAddress,
          disabled: data[0].status == ChangePasswordStatus.success,
          validator: (value) {
            if (currentIndex != 0) return null;

            if (value == null || value.isEmpty) {
              return "Email is required";
            }

            if (!RegExp(data[0].matchCondition).hasMatch(value)) {
              return "Enter a valid email";
            }

            return null;
          },
        ),

        if (data[0].status == ChangePasswordStatus.success) ...[
          const SizedBox(height: 24),

          const PrimaryText(
            "An email has been sent to your email address",
            fontSize: 14,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 30),

          OtpInputField(
            controller: controllers["otp"]!,
            length: 4,
            onChanged: (_) => setState(() {}),
          ),

          const SizedBox(height: 8),

          /// OTP ERROR
          // if (currentIndex == 1 &&
          //     controllers["otp"]!.text.length != 4 &&
          //     controllers["otp"]!.text.isNotEmpty)
          //   const Text(
          //     "Enter valid OTP",
          //     style: TextStyle(color: Colors.red, fontSize: 12),
          //   ),
          if (currentIndex == 1) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const PrimaryText("Did'nt receive otp yet? ", fontSize: 12),
                InkWell(
                  onTap: resendOtpDisable ? null : () => _sendOtp(resend: true),
                  child: PrimaryText(
                    "Resend Otp",
                    color: resendOtpDisable
                        ? DefaultSelectionStyle.defaultColor
                        : DefaultColorSheet.green400,
                    fontSize: 12,
                  ),
                ),
                PrimaryText("($_start)", fontSize: 12),
              ],
            ),
          ],
        ],
      ],
    );
  }

  Widget _buildPasswordUI() {
    return Center(
      child: Column(
        key: const ValueKey("password"),
        mainAxisSize: MainAxisSize.min,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              children: [
                PrimaryTextField(
                  label: "New Password",
                  controller: controllers["changePassword"],
                  keyboardType: TextInputType.visiblePassword,
                  validator: (value) {
                    if (currentIndex < 2) return null;

                    if (!RegExp(data[2].matchCondition).hasMatch(value ?? "") &&
                        controllers["changePassword"]!.text.isNotEmpty) {
                      return "Weak password";
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 20),

                PrimaryTextField(
                  label: "Confirm Password",
                  controller: controllers["confirmPassword"],
                  keyboardType: TextInputType.visiblePassword,
                  validator: (value) {
                    if (currentIndex < 2) return null;

                    if (value != controllers["changePassword"]!.text &&
                        controllers["confirmPassword"]!.text.isNotEmpty) {
                      return "Passwords do not match";
                    }

                    return null;
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
