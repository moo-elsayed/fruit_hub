import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fruit_hub/core/enums/step_item_state.dart';
import 'package:fruit_hub/core/helpers/app_assets.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/theming/app_palette.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';
import 'package:gap/gap.dart';

class CustomStepItem extends StatelessWidget {
  const CustomStepItem({
    super.key,
    required this.state,
    required this.stepNumber,
    required this.stepText,
  });

  final StepItemState state;
  final int stepNumber;
  final String stepText;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        switchInCurve: Curves.easeOutBack,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (child, animation) => RotationTransition(
          turns: animation,
          child: ScaleTransition(scale: animation, child: child),
        ),
        child: switch (state) {
          StepItemState.completed => const _StepCompletedIcon(),
          StepItemState.current => _StepCurrentBadge(stepNumber: stepNumber),
          StepItemState.upcoming => _StepUpcomingBadge(stepNumber: stepNumber),
        },
      ),
      Gap(4.w),
      AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 300),
        style: switch (state) {
          StepItemState.current => AppTextStyles.font13Bold.copyWith(
            color: context.colors.primary,
          ),
          StepItemState.completed => AppTextStyles.font13SemiBold.copyWith(
            color: context.colors.primary,
          ),
          StepItemState.upcoming => AppTextStyles.font13SemiBold.copyWith(
            color: context.colors.subText,
          ),
        },
        child: Text(stepText),
      ),
    ],
  );
}

class _StepCompletedIcon extends StatelessWidget {
  const _StepCompletedIcon();

  @override
  Widget build(BuildContext context) => SvgPicture.asset(
    AppAssets.iconsIconCheck,
    key: const ValueKey('completed'),
  );
}

class _StepCurrentBadge extends StatelessWidget {
  const _StepCurrentBadge({required this.stepNumber});

  final int stepNumber;

  @override
  Widget build(BuildContext context) => Container(
    key: const ValueKey('current'),
    height: 23.h,
    width: 23.w,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: context.colors.primary,
    ),
    alignment: Alignment.center,
    child: Text(
      stepNumber.toString(),
      style: AppTextStyles.font13Bold.copyWith(color: AppPalette.white),
    ),
  );
}

class _StepUpcomingBadge extends StatelessWidget {
  const _StepUpcomingBadge({required this.stepNumber});

  final int stepNumber;

  @override
  Widget build(BuildContext context) => Container(
    key: const ValueKey('upcoming'),
    height: 23.h,
    width: 23.w,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: context.colors.surface,
    ),
    alignment: Alignment.center,
    child: Text(
      stepNumber.toString(),
      style: AppTextStyles.font13SemiBold.copyWith(
        color: context.colors.mainText,
      ),
    ),
  );
}
