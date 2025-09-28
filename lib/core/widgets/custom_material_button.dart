import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      color: color,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      minWidth: maxWidth ? double.infinity : null,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadiusGeometry.circular(10.r),
        side: side ?? BorderSide.none,
      ),
      padding:
          padding ??
          EdgeInsetsGeometry.symmetric(horizontal: 24.w, vertical: 12.h),
      onPressed: onPressed,
      child: isLoading
          ? const CupertinoActivityIndicator(color: Colors.white)
          : Text(text, style: textStyle),
    );
  }
}
