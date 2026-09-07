import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';
import 'package:gap/gap.dart';

class ReviewStatusBanner extends StatelessWidget {
  const ReviewStatusBanner({
    super.key,
    required this.icon,
    required this.message,
    required this.color,
    this.textStyle,
  });

  final IconData icon;
  final String message;
  final Color color;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
    decoration: BoxDecoration(
      color: context.colors.surface,
      border: Border(top: BorderSide(color: context.colors.border)),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 18.sp),
        Gap(8.w),
        Flexible(
          child: Text(
            message,
            style: (textStyle ?? AppTextStyles.font13Medium).copyWith(
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    ),
  );
}
