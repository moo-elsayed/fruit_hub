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
      borderSide: BorderSide.none,
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      closeButton: const ToastCloseButton(showType: CloseButtonShowType.none),
      alignment: Alignment.topCenter,
      description: description != null
          ? Text(
              description,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
            )
          : null,
      primaryColor: Colors.white,
      autoCloseDuration: const Duration(seconds: 2),
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
