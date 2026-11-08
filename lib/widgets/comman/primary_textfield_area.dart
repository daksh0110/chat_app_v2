import 'package:flutter/material.dart';
import 'package:my_app/colors/defaullt_color_sheet.dart';

class PrimaryTextAreaField extends StatelessWidget {
  final TextEditingController? controller;
  final String labelText;
  final String hintText;
  final bool disabled;
  final int maxLines;
  final int maxLength;

  const PrimaryTextAreaField({
    super.key,
    this.controller,
    required this.labelText,
    required this.hintText,
    this.disabled = false, // Defaults to enabled
    this.maxLines = 4,
    this.maxLength = 100,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      maxLength: maxLength,
      textAlign: TextAlign.start,
      enabled: !disabled,
      cursorColor: DefaultColorSheet.primary,
      style: TextStyle(
        color: DefaultColorSheet.textPrimary(context),
        fontSize: 16,
      ),
      decoration: InputDecoration(
        alignLabelWithHint: true,
        labelText: labelText,
        labelStyle: TextStyle(color: DefaultColorSheet.textSecondary(context)),
        hintText: hintText,
        hintStyle: TextStyle(color: DefaultColorSheet.inputHintColor(context)),
        counterStyle: TextStyle(color: DefaultColorSheet.textSecondary(context)),
        filled: true,
        fillColor: DefaultColorSheet.inputFieldBg(context),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: DefaultColorSheet.primary),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: DefaultColorSheet.primary, width: 1.5),
        ),
        // Style when the field is disabled
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: DefaultColorSheet.isDark(context)
                ? Colors.white24
                : Colors.black12,
          ),
        ),
      ),
      validator: (value) {
        if (value != null && value.length > maxLength) {
          return '$labelText can be at most $maxLength characters.';
        }
        return null;
      },
    );
  }
}
