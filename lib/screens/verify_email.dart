import 'dart:async';

import 'package:flutter/material.dart';
import 'package:my_app/colors/defaullt_color_sheet.dart';
import 'package:my_app/core/network/api_client.dart';
import 'package:my_app/data/services/user_api_service.dart';
import 'package:my_app/modal/screens/verifyEmail/verify_screen_arguments.dart';
import 'package:my_app/widgets/comman/otp_input_field.dart';
import 'package:my_app/widgets/comman/primary_button.dart';
import 'package:my_app/widgets/comman/primary_text.dart';
import 'package:my_app/widgets/comman/toast_notification.dart';
import 'package:toastification/toastification.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailState();
}

class _VerifyEmailState extends State<VerifyEmailScreen> {
  final TextEditingController otpController = TextEditingController();

  bool get isDisabled => otpController.text.length != 4;
  late String email;
  late String verificationToken;

  Timer? _timer;
  int _start = 60;
  bool resendOtpDisable = true;
  bool isResending = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args =
        ModalRoute.of(context)!.settings.arguments as VerifyScreenArguments;

    email = args.email;
    verificationToken = args.verificationToken;
    startTimer();
  }

  void startTimer() {
    _timer?.cancel();

    setState(() {
      resendOtpDisable = true;
      _start = 60;
    });

    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
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

  void resendOtp() async {
    if (resendOtpDisable || isResending) return;

    setState(() {
      isResending = true;
    });

    final apiClient = ApiClient();
    final result = await UserApiService(
      apiClient,
    ).sendEmailVerificationOtp(email: email);

    setState(() {
      isResending = false;
    });

    if (result.success) {
      verificationToken =
          result.data?.newVerificationToken ?? verificationToken;

      ToastHelper.show(context: context, message: result.message);

      startTimer();
    } else {
      setState(() {
        resendOtpDisable = false;
      });

      ToastHelper.show(
        context: context,
        message: result.message,
        type: ToastificationType.error,
      );
    }
  }

  void onSubmit() async {
    final apiClient = ApiClient();

    final result = await UserApiService(apiClient).verifyEmailVerificationOtp(
      otp: otpController.text,
      verificationToken: verificationToken,
    );

    if (result.success) {
      ToastHelper.show(context: context, message: result.message);
      // await ref.read(authProvider.notifier).login(data?.accessToken ?? "");
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
    _timer?.cancel();
    otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              const SizedBox(height: 20),

              const PrimaryText(
                "Verify Email",
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),

              const SizedBox(height: 16),

              PrimaryText(
                "Enter the 4-digit code sent to\n$email",
                fontSize: 14,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              OtpInputField(
                controller: otpController,
                length: 4,
                onChanged: (_) => setState(() {}),
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const PrimaryText("Didn't receive OTP? ", fontSize: 12),

                  GestureDetector(
                    onTap: resendOtpDisable ? null : resendOtp,
                    child: PrimaryText(
                      resendOtpDisable ? "Resend in $_start s" : "Resend OTP",
                      color: resendOtpDisable
                          ? DefaultSelectionStyle.defaultColor
                          : DefaultColorSheet.green400,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const Spacer(),

              PrimaryButton(
                text: "Verify",
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
    );
  }
}
