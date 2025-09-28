import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

abstract class AppToast {
  static void showToast({
    required BuildContext context,
    required String title,
    String? description,
    required ToastificationType type,
  }) {
    toastification.show(
      context: context,
      type: type,
      title: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      alignment: Alignment.topCenter,
      description: description != null
          ? Text(
              description,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
            )
          : null,
      primaryColor: Colors.white,
      autoCloseDuration: const Duration(seconds: 2, milliseconds: 500),
      progressBarTheme: ProgressIndicatorThemeData(
        color: type == ToastificationType.success
            ? Colors.green
            : type == ToastificationType.info
            ? Colors.blue
            : type == ToastificationType.warning
            ? Colors.orange
            : Colors.red,
      ),
      backgroundColor: type == ToastificationType.success
          ? Colors.green
          : type == ToastificationType.info
          ? Colors.blue
          : type == ToastificationType.warning
          ? Colors.orange
          : Colors.red,
      foregroundColor: Colors.white,
    );
  }
}
