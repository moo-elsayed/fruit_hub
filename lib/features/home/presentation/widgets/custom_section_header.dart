import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';

import '../../../../core/theming/app_text_styles.dart';

class CustomSectionHeader extends StatelessWidget {
  const CustomSectionHeader({
    super.key,
    required this.sectionName,
    required this.onTap,
  });

  final String sectionName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsetsGeometry.symmetric(horizontal: 16.w),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          sectionName,
          style: AppTextStyles.font16Bold.copyWith(
            color: context.colors.mainText,
          ),
        ),
        GestureDetector(
          onTap: onTap,
          child: Text(
            AppStrings.more,
            style: AppTextStyles.font13Regular.copyWith(
              color: context.colors.subText,
            ),
          ),
        ),
      ],
    ),
  );
}
