import 'package:flutter/widgets.dart';

class ProfileCardItem {
  const ProfileCardItem({
    required this.icon,
    required this.title,
    this.trailingText,
    this.trailingWidget,
    this.showArrow = true,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? trailingText;
  final Widget? trailingWidget;
  final bool showArrow;
  final VoidCallback? onTap;
}
