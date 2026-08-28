import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fruit_hub/core/helpers/app_assets.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';
import 'package:gap/gap.dart';

class CustomEmptyStateWidget extends StatelessWidget {
  const CustomEmptyStateWidget({
    super.key,
    this.title,
    this.text,
    this.imagePath,
    this.svgPath,
    this.customIcon,
  });

  final String? title;
  final String? text;
  final String? imagePath;
  final String? svgPath;
  final Widget? customIcon;

  @override
  Widget build(BuildContext context) => Center(
    child: SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (customIcon != null)
            customIcon!
          else if (svgPath != null)
            SvgPicture.asset(
              svgPath!,
              height: 120.h,
              width: 120.w,
              fit: BoxFit.contain,
            )
          else
            Image.asset(
              imagePath ?? AppAssets.imagesSearchImage,
              height: 140.h,
              width: 140.w,
              fit: BoxFit.contain,
            ),
          Gap(16.h),
          Text(
            title ?? AppStrings.search,
            style: AppTextStyles.font16Bold.copyWith(
              color: context.colors.bodyText,
            ),
          ),
          Gap(8.h),
          Text(
            text ?? AppStrings.noResults,
            textAlign: TextAlign.center,
            style: AppTextStyles.font13Regular.copyWith(
              color: context.colors.subText,
            ),
          ),
        ],
      ),
    ),
  );
}
