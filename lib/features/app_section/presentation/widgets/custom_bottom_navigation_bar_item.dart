import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:gap/gap.dart';
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
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      alignment: Alignment.center,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: ScaleTransition(scale: animation, child: child),
        ),
        child: !active
            ? SvgPicture.asset(
                entity.outlineIcon,
                height: 20.h,
                width: 20.w,
                colorFilter: ColorFilter.mode(
                  context.colors.subText,
                  BlendMode.srcIn,
                ),
              )
            : DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: .circular(16.r),
                  color: context.colors.surface,
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 15.r,
                      backgroundColor: context.colors.primary,
                      child: SvgPicture.asset(
                        entity.filledIcon,
                        fit: BoxFit.scaleDown,
                      ),
                    ),
                    Gap(4.w),
                    Text(
                      entity.label,
                      style: AppTextStyles.font11SemiBold.copyWith(
                        color: context.colors.primary,
                      ),
                    ),
                    Gap(7.w),
                  ],
                ),
              ),
      ),
    ),
  );
}
