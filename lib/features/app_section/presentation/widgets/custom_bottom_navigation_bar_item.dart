import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../domain/entities/bottom_navigation_bar_entity.dart';

class CustomBottomNavigationItem extends StatelessWidget {
  const CustomBottomNavigationItem({
    super.key,
    required this.entity,
    required this.active,
    required this.onTap,
  });

  final BottomNavigationBarEntity entity;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedSize(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        alignment: Alignment.center,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(scale: animation, child: child),
            );
          },
          child: !active
              ? SvgPicture.asset(
                  entity.outlineIcon,
                  height: 20.h,
                  width: 20.w,
                  colorFilter: const ColorFilter.mode(
                    AppColors.color4E5556,
                    BlendMode.srcIn,
                  ),
                )
              : DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: .circular(16.r),
                    color: AppColors.colorF3F5F7,
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 15.r,
                        backgroundColor: AppColors.color1B5E37,
                        child: SvgPicture.asset(
                          entity.filledIcon,
                          fit: BoxFit.scaleDown,
                        ),
                      ),
                      Gap(4.w),
                      Text(
                        entity.label,
                        style: AppTextStyles.font11color1B5E37semiBold,
                      ),
                      Gap(7.w),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
