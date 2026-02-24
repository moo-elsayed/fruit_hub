import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/theming/app_colors.dart';

class CustomMaterialButton extends StatelessWidget {
  const CustomMaterialButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.textStyle,
    this.maxWidth = false,
    this.isLoading = false,
    this.padding,
    this.color,
    this.side,
    this.borderRadius,
    this.loadingIndicatorColor = AppColors.white,
  });

  final void Function() onPressed;
  final String text;
  final TextStyle? textStyle;
  final bool maxWidth;
  final bool isLoading;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final BorderSide? side;
  final BorderRadiusGeometry? borderRadius;
  final Color loadingIndicatorColor;

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      color: color ?? AppColors.color1B5E37,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      minWidth: maxWidth ? double.infinity : null,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadiusGeometry.circular(16.r),
        side: side ?? BorderSide.none,
      ),
      padding:
          padding ??
          EdgeInsetsGeometry.symmetric(horizontal: 24.w, vertical: 13.h),
      onPressed: onPressed,
      child: isLoading
          ? CupertinoActivityIndicator(color: loadingIndicatorColor)
          : Text(text, style: textStyle),
    );
  }
}
