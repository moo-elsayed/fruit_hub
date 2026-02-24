import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';
import 'package:fruit_hub/generated/assets.dart';
import 'package:gap/gap.dart';

class SearchPlaceholderWidget extends StatelessWidget {
  const SearchPlaceholderWidget({super.key, this.text});

  final String? text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 70.w),
      child: Column(
        children: [
          Gap(140.h),
          Image.asset(Assets.imagesSearchImage),
          Text("search".tr(), style: AppTextStyles.font16color616A6BBold),
          Gap(10.h),
          Text(
            text ?? "no_results".tr(),
            style: AppTextStyles.font13color949D9ERegular,
          ),
        ],
      ),
    );
  }
}
