import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/helpers/app_assets.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';
import 'package:gap/gap.dart';

class SearchPlaceholderWidget extends StatelessWidget {
  const SearchPlaceholderWidget({super.key, this.text});

  final String? text;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              AppAssets.imagesSearchImage,
              height: 140.h,
              width: 140.w,
              fit: BoxFit.contain,
            ),
            Gap(16.h),
            Text(
              AppStrings.search,
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
    ),
  );
}
