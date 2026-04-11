import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';
import 'package:my_app/widgets/comman/primary_text.dart';

class ToastHelper {
  static void show({
    required BuildContext context,
    required String message,
    ToastificationType type = ToastificationType.success,
    Duration duration = const Duration(seconds: 2),
  }) {
    toastification.show(
      context: context,
      title: PrimaryText(message, color: Colors.white, fontSize: 15),
      type: type,
      autoCloseDuration: duration,
      style: ToastificationStyle.fillColored,
    );
  }
}
