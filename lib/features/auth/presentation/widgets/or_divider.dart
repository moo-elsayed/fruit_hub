import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';

class OrDivider extends StatelessWidget {
  const OrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 18.w,
      children: [
        buildDivider(),
        Text("or".tr(), style: AppTextStyles.font16color0C0D0DSemiBold),
        buildDivider(),
      ],
    );
  }

  Expanded buildDivider() =>
      const Expanded(child: Divider(color: AppColors.colorDDDFDF));
}
