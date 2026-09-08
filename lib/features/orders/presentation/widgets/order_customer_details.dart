import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';
import 'package:fruit_hub/features/checkout/domain/entities/address_entity.dart';
import 'package:gap/gap.dart';

class OrderCustomerDetails extends StatelessWidget {
  const OrderCustomerDetails({super.key, required this.address});

  final AddressEntity address;

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.all(12.r),
    decoration: BoxDecoration(
      color: context.colors.background,
      borderRadius: BorderRadius.circular(10.r),
      border: Border.all(color: context.colors.border, width: 0.8),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.local_shipping_outlined,
              size: 16.sp,
              color: context.colors.primary,
            ),
            Gap(6.w),
            Text(
              AppStrings.shippingAddress,
              style: AppTextStyles.font13Bold.copyWith(
                color: context.colors.mainText,
              ),
            ),
          ],
        ),
        Gap(8.h),
        Text(
          address.formattedLocation,
          style: AppTextStyles.font12Medium.copyWith(
            color: context.colors.bodyText,
          ),
        ),
        if (address.phone.isNotEmpty) ...[
          Gap(6.h),
          Row(
            children: [
              Icon(
                Icons.phone_outlined,
                size: 13.sp,
                color: context.colors.subText,
              ),
              Gap(4.w),
              Text(
                address.phone,
                style: AppTextStyles.font12Medium.copyWith(
                  color: context.colors.subText,
                ),
              ),
            ],
          ),
        ],
      ],
    ),
  );
}
