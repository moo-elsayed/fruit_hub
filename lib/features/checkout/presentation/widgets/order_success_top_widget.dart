import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../generated/assets.dart';

class OrderSuccessTopWidget extends StatelessWidget {
  const OrderSuccessTopWidget({super.key, required this.orderId});

  final int orderId;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SvgPicture.asset(Assets.svgsSuccess),
        Gap(33.h),
        Text(
          "It_was_done_successfully!".tr(),
          style: AppTextStyles.font16color0C0D0DBold,
        ),
        Gap(9.h),
        Text("${"order_number".tr()}: $orderId#"),
      ],
    );
  }
}
