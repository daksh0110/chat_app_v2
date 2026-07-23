import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_app/colors/defaullt_color_sheet.dart';
import 'package:pinput/pinput.dart';

class OtpInputField extends StatelessWidget {
  final TextEditingController controller;
  final int length;
  final Function(String)? onChanged;

  const OtpInputField({
    super.key,
    required this.controller,
    this.length = 4,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 50,
      height: 55,
      textStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        border: Border.all(
          color: DefaultColorSheet.green400,
          width: 2,
        ),
      ),
    );

    final submittedPinTheme = defaultPinTheme;

    return Pinput(
      length: length,
      controller: controller,
      onChanged: onChanged,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      defaultPinTheme: defaultPinTheme,
      focusedPinTheme: focusedPinTheme,
      submittedPinTheme: submittedPinTheme,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      autofocus: true,
    );
  }
}
