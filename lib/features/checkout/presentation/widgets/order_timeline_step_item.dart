import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/enums/step_item_state.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/theming/app_palette.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';
import 'package:gap/gap.dart';

class OrderTimelineStepItem extends StatelessWidget {
  const OrderTimelineStepItem({
    super.key,
    required this.title,
    required this.icon,
    required this.state,
  });

  final String title;
  final IconData icon;
  final StepItemState state;

  (Color, Color, Border?) _getColors(BuildContext context) => switch (state) {
    StepItemState.completed => (context.colors.primary, AppPalette.white, null),
    StepItemState.current => (
      context.colors.primary.withValues(alpha: 0.15),
      context.colors.primary,
      Border.all(color: context.colors.primary, width: 1.5),
    ),
    StepItemState.upcoming => (
      context.colors.background,
      context.colors.subText,
      Border.all(color: context.colors.border),
    ),
  };

  @override
  Widget build(BuildContext context) {
    final (circleBg, iconColor, border) = _getColors(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
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
        Gap(6.h),
        Text(
          title,
          style: AppTextStyles.font11Regular.copyWith(
            color: state == StepItemState.upcoming
                ? context.colors.subText
                : context.colors.mainText,
            fontWeight: state == StepItemState.current
                ? FontWeight.bold
                : FontWeight.normal,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
