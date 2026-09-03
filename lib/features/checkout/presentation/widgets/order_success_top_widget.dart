import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:gap/gap.dart';

import '../../../../core/theming/app_text_styles.dart';

class OrderSuccessTopWidget extends StatelessWidget {
  const OrderSuccessTopWidget({super.key});

  @override
  Widget build(BuildContext context) => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      ZoomIn(
        duration: const Duration(milliseconds: 600),
        child: Icon(
          Icons.check_circle_rounded,
          color: context.colors.success,
          size: 60.sp,
        ),
      ),
      Gap(12.h),
      FadeInDown(
        duration: const Duration(milliseconds: 500),
        child: Column(
          children: [
            Text(
              AppStrings.orderPlacedSuccessfully,
              style: AppTextStyles.font20Bold.copyWith(
                color: context.colors.mainText,
              ),
              textAlign: TextAlign.center,
            ),
            Gap(8.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Text(
                AppStrings.thankYouForYourOrder,
                style: AppTextStyles.font13Regular.copyWith(
                  color: context.colors.subText,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
