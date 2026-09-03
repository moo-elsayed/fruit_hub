import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fruit_hub/core/helpers/app_assets.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';

class CustomArrowBack extends StatelessWidget {
  const CustomArrowBack({super.key, this.onTap, this.padding, this.size});

  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final double? size;

  @override
  Widget build(BuildContext context) {
    final double buttonSize = size ?? 40.r;
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: Ink(
        width: buttonSize,
        height: buttonSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: context.colors.surface,
          border: Border.all(color: context.colors.border, width: 1.w),
          boxShadow: [
            BoxShadow(
              color: context.colors.mainText.withValues(alpha: 0.04),
              blurRadius: 8.r,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap ?? () => context.pop(),
          child: Padding(
            padding: padding ?? EdgeInsets.all(8.r),
            child: Transform.rotate(
              angle: context.isArabic ? 0 : pi,
              child: SvgPicture.asset(
                AppAssets.iconsArrowBack,
                fit: BoxFit.scaleDown,
                colorFilter: ColorFilter.mode(
                  context.colors.mainText,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
