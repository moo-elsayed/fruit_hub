import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';

class OrderHeaderBadge extends StatelessWidget {
  const OrderHeaderBadge({
    super.key,
    required this.label,
    required this.color,
    this.icon,
    this.showDot = false,
  });

  final String label;
  final Color color;
  final IconData? icon;
  final bool showDot;

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(20.r),
      border: Border.all(
        color: color.withValues(alpha: 0.25),
        width: 1,
      ),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 5.w,
      children: [
        if (showDot)
          Container(
            width: 7.r,
            height: 7.r,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
        if (icon != null)
          Icon(icon, size: 13.sp, color: color),
        Text(label, style: AppTextStyles.font11SemiBold.copyWith(color: color)),
      ],
    ),
  );
}
