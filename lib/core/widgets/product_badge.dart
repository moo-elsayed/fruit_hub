import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';

class ProductBadge extends StatelessWidget {
  const ProductBadge({
    super.key,
    required this.icon,
    required this.color,
    this.tooltip,
  });

  final IconData icon;
  final Color color;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final badge = Container(
      width: 24.r,
      height: 24.r,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: context.colors.surface.withValues(alpha: 0.85),
        border: Border.all(color: color.withValues(alpha: 0.35), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Center(
        child: Icon(icon, size: 13.sp, color: color),
      ),
    );

    if (tooltip != null) {
      return Tooltip(
        message: tooltip!,
        triggerMode: TooltipTriggerMode.tap,
        preferBelow: false,
        verticalOffset: 16.h,
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
        showDuration: const Duration(seconds: 2),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(8.r),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        textStyle: AppTextStyles.font11Bold.copyWith(
          color: context.colors.mainText,
        ),
        child: badge,
      );
    }

    return badge;
  }
}
