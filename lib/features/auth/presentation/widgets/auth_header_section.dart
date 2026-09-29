import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';
import 'package:gap/gap.dart';

class AuthHeaderSection extends StatelessWidget {
  const AuthHeaderSection({
    super.key,
    required this.title,
    required this.subtitle,
    this.imagePath,
    this.icon,
    this.customBadge,
  }) : assert(
         imagePath != null || icon != null || customBadge != null,
         'Either imagePath, icon, or customBadge must be provided',
       );

  final String title;
  final String subtitle;
  final String? imagePath;
  final IconData? icon;
  final Widget? customBadge;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      _AuthHeaderBadge(
        imagePath: imagePath,
        icon: icon,
        customBadge: customBadge,
      ),
      Gap(16.h),
      Text(
        title,
        style: AppTextStyles.font24Bold.copyWith(
          color: context.colors.mainText,
        ),
      ),
      Gap(6.h),
      Text(
        subtitle,
        textAlign: TextAlign.center,
        style: AppTextStyles.font14Regular.copyWith(
          color: context.colors.subText,
        ),
      ),
    ],
  );
}

class _AuthHeaderBadge extends StatelessWidget {
  const _AuthHeaderBadge({this.imagePath, this.icon, this.customBadge});

  final String? imagePath;
  final IconData? icon;
  final Widget? customBadge;

  @override
  Widget build(BuildContext context) {
    if (customBadge != null) return customBadge!;

    if (imagePath != null) {
      return Container(
        width: 72.r,
        height: 72.r,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: context.colors.surface,
          border: Border.all(
            color: context.colors.primary.withValues(alpha: 0.3),
            width: 2.w,
          ),
          boxShadow: [
            BoxShadow(
              color: context.colors.primary.withValues(alpha: 0.1),
              blurRadius: 16.r,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipOval(child: Image.asset(imagePath!, fit: BoxFit.cover)),
      );
    }

    return Container(
      width: 72.r,
      height: 72.r,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: context.colors.primary.withValues(alpha: 0.1),
        border: Border.all(
          color: context.colors.primary.withValues(alpha: 0.3),
          width: 2.w,
        ),
      ),
      child: Icon(icon, size: 34.sp, color: context.colors.primary),
    );
  }
}
