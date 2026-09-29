import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';
import 'package:fruit_hub/features/checkout/domain/entities/address_entity.dart';

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
      spacing: 6.h,
      children: [
        Row(
          spacing: 4.w,
          children: [
            Icon(
              Icons.local_shipping_outlined,
              size: 16.sp,
              color: context.colors.primary,
            ),
            Text(
              AppStrings.shippingAddress,
              style: AppTextStyles.font13Bold.copyWith(
                color: context.colors.mainText,
              ),
            ),
          ],
        ),
        Text(
          address.formattedLocation,
          style: AppTextStyles.font12Medium.copyWith(
            color: context.colors.bodyText,
          ),
        ),
        if (address.phone.isNotEmpty) ...[
          Row(
            spacing: 4.w,
            children: [
              Icon(
                Icons.phone_outlined,
                size: 13.sp,
                color: context.colors.subText,
              ),
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
