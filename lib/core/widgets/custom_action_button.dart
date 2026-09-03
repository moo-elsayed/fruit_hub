import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../helpers/extensions.dart';

class CustomActionButton extends StatelessWidget {
  const CustomActionButton({
    super.key,
    required this.onTap,
    this.radius,
    this.backgroundColor,
    this.border,
    required this.child,
    this.opacity,
  });

  final VoidCallback onTap;
  final double? radius;
  final double? opacity;
  final Color? backgroundColor;
  final BoxBorder? border;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final size = (radius ?? 16.r) * 2;
    return Opacity(
      opacity: opacity ?? 1,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: backgroundColor ?? context.colors.primary,
            border: border,
          ),
          child: Center(child: child),
        ),
      ),
    );
  }
}
