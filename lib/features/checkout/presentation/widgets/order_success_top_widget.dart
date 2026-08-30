import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:gap/gap.dart';
import '../../../../core/helpers/app_assets.dart';
import '../../../../core/theming/app_text_styles.dart';

class OrderSuccessTopWidget extends StatelessWidget {
  const OrderSuccessTopWidget({super.key, required this.orderId});

  final int orderId;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      SvgPicture.asset(AppAssets.svgsSuccess),
      Gap(33.h),
      Text(
        AppStrings.itWasDoneSuccessfully,
        style: AppTextStyles.font16Bold.copyWith(
          color: context.colors.mainText,
        ),
      ),
      Gap(9.h),
      Text(
        '${AppStrings.orderNumber}: $orderId#',
        style: AppTextStyles.font14Regular.copyWith(
          color: context.colors.subText,
        ),
      ),
    ],
  );
}
