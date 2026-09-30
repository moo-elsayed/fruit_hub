import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';

class QuantityBadge extends StatelessWidget {
  const QuantityBadge({
    super.key,
    required this.quantity,
    this.color,
    this.backgroundColor,
  });

  final int quantity;
  final Color? color;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
    decoration: BoxDecoration(
      color:
          backgroundColor ??
          (color ?? context.colors.primary).withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(4.r),
    ),
    child: Text(
      'x$quantity',
      style: AppTextStyles.font10Bold.copyWith(
        color: color ?? context.colors.primary,
      ),
    ),
  );
}
