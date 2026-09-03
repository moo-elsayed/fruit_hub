import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';

import '../../../../core/theming/app_text_styles.dart';

class OrDivider extends StatelessWidget {
  const OrDivider({super.key});

  @override
  Widget build(BuildContext context) => Row(
    spacing: 18.w,
    children: [
      Expanded(child: Divider(color: context.colors.border)),
      Text(
        AppStrings.or,
        style: AppTextStyles.font16SemiBold.copyWith(
          color: context.colors.mainText,
        ),
      ),
      Expanded(child: Divider(color: context.colors.border)),
    ],
  );
}
