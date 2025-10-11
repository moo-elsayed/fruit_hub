import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theming/app_text_styles.dart';

class CustomSectionHeader extends StatelessWidget {
  const CustomSectionHeader({super.key, required this.sectionName});

  final String sectionName;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsGeometry.symmetric(horizontal: 16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(sectionName, style: AppTextStyles.font16color0C0D0DBold),
          Text("more".tr(), style: AppTextStyles.font13color949D9ERegular),
        ],
      ),
    );
  }
}
