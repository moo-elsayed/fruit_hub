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
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(horizontal: 70.w),
    child: Column(
      children: [
        Gap(140.h),
        Image.asset(AppAssets.imagesSearchImage),
        Text(
          AppStrings.search,
          style: AppTextStyles.font16Bold.copyWith(
            color: context.colors.bodyText,
          ),
        ),
        Gap(10.h),
        Text(
          text ?? AppStrings.noResults,
          style: AppTextStyles.font13Regular.copyWith(
            color: context.colors.subText,
          ),
        ),
      ],
    ),
  );
}
