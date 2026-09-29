import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/theming/app_palette.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';

class OrderTimelinePreview extends StatelessWidget {
  const OrderTimelinePreview({super.key, this.currentStep = 1});

  final int currentStep;

  static final List<(String, IconData)> _steps = [
    (AppStrings.orderPlaced, Icons.check_circle_rounded),
    (AppStrings.orderPreparing, Icons.inventory_2_outlined),
    (AppStrings.orderOnTheWay, Icons.delivery_dining_outlined),
    (AppStrings.orderDelivered, Icons.home_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    final activeIndex = currentStep.clamp(0, _steps.length - 1);
    final isAllCompleted = activeIndex == _steps.length - 1;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: context.isDarkMode
            ? context.colors.surface
            : AppPalette.bgLightSecondary,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: context.colors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(_steps.length * 2 - 1, (index) {
          if (index.isOdd) {
            final prevIndex = index ~/ 2;
            final isCompleted = prevIndex < activeIndex || isAllCompleted;
            return Expanded(
              child: Container(
                height: 2.h,
                margin: EdgeInsets.only(top: 17.r),
                color: isCompleted
                    ? context.colors.primary
                    : context.colors.border,
              ),
            );
          }

          final stepIndex = index ~/ 2;
          final (title, icon) = _steps[stepIndex];
          final isCompleted =
              stepIndex < activeIndex ||
              (stepIndex == activeIndex && isAllCompleted);
          final isCurrent = stepIndex == activeIndex && !isAllCompleted;

          final Color circleBg;
          final Color iconColor;
          final Border? border;

          if (isCompleted) {
            circleBg = context.colors.primary;
            iconColor = AppPalette.white;
            border = null;
          } else if (isCurrent) {
            circleBg = context.colors.primary.withValues(alpha: 0.15);
            iconColor = context.colors.primary;
            border = Border.all(color: context.colors.primary, width: 1.5);
          } else {
            circleBg = context.colors.background;
            iconColor = context.colors.subText;
            border = Border.all(color: context.colors.border);
          }

          return Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 6.h,
              children: [
                Container(
                  width: 34.r,
                  height: 34.r,
                  decoration: BoxDecoration(
                    color: circleBg,
                    shape: BoxShape.circle,
                    border: border,
                  ),
                  child: Icon(icon, size: 18.sp, color: iconColor),
                ),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: AppTextStyles.font11Regular.copyWith(
                    color: stepIndex > activeIndex
                        ? context.colors.subText
                        : context.colors.mainText,
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
