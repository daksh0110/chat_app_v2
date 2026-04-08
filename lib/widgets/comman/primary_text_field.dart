import 'package:flutter/material.dart';
import 'package:my_app/colors/defaullt_color_sheet.dart';
import 'primary_text.dart';

class PrimaryTextField extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final bool disabled;

  const PrimaryTextField({
    super.key,
    required this.label,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.validator,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        PrimaryText(
          label,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: DefaultColorSheet.primary,
        ),
        const SizedBox(height: 8),

        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            border: const UnderlineInputBorder(),
            enabled: !disabled,
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: DefaultColorSheet.primary),
            ),

            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: DefaultColorSheet.primary,
                width: 1.5,
              ),
            ),

            // 🔴 ERROR STATES
            errorBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: DefaultColorSheet.error,
                width: 1.5,
              ),
            ),

            focusedErrorBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: DefaultColorSheet.error,
                width: 1.5,
              ),
            ),

            errorStyle: const TextStyle(
              color: DefaultColorSheet.error,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}
