import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../generated/assets.dart';

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
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          switchInCurve: Curves.easeOutBack,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (child, animation) {
            return RotationTransition(
              turns: animation,
              child: ScaleTransition(scale: animation, child: child),
            );
          },
          child: isActive ? _activeIcon() : _inActiveIcon(),
        ),
        Gap(4.w),
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 300),
          style: isActive
              ? AppTextStyles.font13color1B5E37Bold
              : AppTextStyles.font13colorAAAAAASemiBold,
          child: Text(stepText),
        ),
      ],
    );
  }

  SvgPicture _activeIcon() =>
      SvgPicture.asset(Assets.iconsIconCheck, key: const ValueKey('active'));

  Container _inActiveIcon() => Container(
    key: const ValueKey('inactive'),
    height: 20.h,
    width: 20.w,
    decoration: const BoxDecoration(
      shape: BoxShape.circle,
      color: AppColors.colorF2F3F3,
    ),
    alignment: Alignment.center,
    child: Text(
      stepNumber.toString(),
      style: AppTextStyles.font13color0C0D0DSemiBold,
    ),
  );
}
