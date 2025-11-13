import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theming/app_colors.dart';

class CustomActionButton extends StatelessWidget {
  const CustomActionButton({
    super.key,
    required this.onTap,
    this.radius,
    this.backgroundColor,
    required this.child,
  });

  final VoidCallback onTap;
  final double? radius;
  final Color? backgroundColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: radius ?? 18.r,
        backgroundColor: backgroundColor ?? AppColors.color1B5E37,
        child: child,
      ),
    );
  }
}