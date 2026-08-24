import 'package:flutter/material.dart';

/// A wrapper widget that dismisses the keyboard (unfocuses primary focus)
/// when tapping anywhere outside interactive text fields.
class CustomKeyboardUnfocus extends StatelessWidget {
  const CustomKeyboardUnfocus({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
    behavior: HitTestBehavior.opaque,
    child: child,
  );
}
