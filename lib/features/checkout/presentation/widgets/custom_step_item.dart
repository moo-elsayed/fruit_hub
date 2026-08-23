import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:gap/gap.dart';
import '../../../../core/helpers/app_assets.dart';
import '../../../../core/theming/app_text_styles.dart';

class CustomStepItem extends StatelessWidget {
  const CustomStepItem({
    super.key,
    required this.isActive,
    required this.stepNumber,
    required this.stepText,
  });

  final bool isActive;
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
        child: isActive ? _activeIcon() : _inActiveIcon(context),
      ),
      Gap(4.w),
      AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 300),
        style: isActive
            ? AppTextStyles.font13Bold.copyWith(color: context.colors.primary)
            : AppTextStyles.font13SemiBold.copyWith(
                color: context.colors.subText,
              ),
        child: Text(stepText),
      ),
    ],
  );

  SvgPicture _activeIcon() =>
      SvgPicture.asset(AppAssets.iconsIconCheck, key: const ValueKey('active'));

  Container _inActiveIcon(BuildContext context) => Container(
    key: const ValueKey('inactive'),
    height: 20.h,
    width: 20.w,
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
