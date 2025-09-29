import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theming/colors.dart';

class OnboardingIndicator extends StatelessWidget {
  const OnboardingIndicator({
    super.key,
    required this.currentIndex,
    required this.length,
  });

  final int length;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(length, (index) {
        bool isActive = index <= currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: isActive ? 10.w : 9.w,
          height: isActive ? 10.h : 9.h,
          margin: EdgeInsetsDirectional.only(
            end: index == length - 1 ? 0 : 10.w,
          ),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive
                ? AppColors.color1B5E37
                : AppColors.colorEBF6EA,
          ),
        );
      }),
    );
  }
}
