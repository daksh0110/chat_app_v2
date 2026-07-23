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
      decoration: InputDecoration(
        alignLabelWithHint: true,
        labelText: labelText,
        hintText: hintText,
        filled: true,
        fillColor: disabled
            ? DefaultColorSheet.primary.withOpacity(0.02)
            : DefaultColorSheet.primary.withOpacity(0.04),
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
            color: DefaultColorSheet.primary.withOpacity(0.2),
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
