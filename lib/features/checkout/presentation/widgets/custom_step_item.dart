import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../generated/assets.dart';

class CustomStepItem extends StatelessWidget {
  const CustomStepItem({
    super.key,
    required this.isActive,
    required this.stepNumber,
    required this.step,
  });

  final bool isActive;
  final int stepNumber;
  final String step;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 4.w,
      children: [
        isActive
            ? SvgPicture.asset(Assets.iconsIconCheck)
            : Container(
                padding: .all(8.r),
                decoration: const BoxDecoration(
                  shape: .circle,
                  color: AppColors.colorF2F3F3,
                ),
                child: Text(
                  stepNumber.toString(),
                  style: AppTextStyles.font13color0C0D0DSemiBold,
                ),
              ),
        Text(
          step,
          style: isActive
              ? AppTextStyles.font13color1B5E37Bold
              : AppTextStyles.font13colorAAAAAASemiBold,
        ),
      ],
    );
  }
}
