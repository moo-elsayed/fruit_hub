import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../helpers/extensions.dart';

class CustomActionButton extends StatelessWidget {
  const CustomActionButton({
    super.key,
    required this.onTap,
    this.radius,
    this.backgroundColor,
    required this.child,
    this.opacity,
  });

  final VoidCallback onTap;
  final double? radius;
  final double? opacity;
  final Color? backgroundColor;
  final Widget child;

  @override
  Widget build(BuildContext context) => Opacity(
    opacity: opacity ?? 1,
    child: GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: radius ?? 18.r,
        backgroundColor: backgroundColor ?? context.colors.primary,
        child: child,
      ),
    ),
  );
}
