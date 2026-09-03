import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/features/checkout/domain/entities/payment_option_entity.dart';
import 'package:gap/gap.dart';

import '../../../../core/theming/app_text_styles.dart';

class PaymentOption extends StatelessWidget {
  const PaymentOption({
    super.key,
    required this.paymentOptionEntity,
    required this.onTap,
    required this.isSelected,
  });

  final PaymentOptionEntity paymentOptionEntity;
  final ValueChanged<PaymentOptionEntity> onTap;
  final bool isSelected;

  String getTrailingText(double shippingCost) => shippingCost == 0
      ? AppStrings.freeShipping
      : '$shippingCost ${AppStrings.pounds}';

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () {
      onTap(paymentOptionEntity);
    },
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isSelected ? context.colors.primary : context.colors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 20.h,
            width: 20.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected
                    ? context.colors.primary
                    : context.colors.border,
                width: 2,
              ),
            ),
            padding: const EdgeInsets.all(3),
            child: isSelected
                ? Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: context.colors.primary,
                    ),
                  )
                : null,
          ),
          Gap(10.w),
          Text(
            paymentOptionEntity.title,
            style: AppTextStyles.font13SemiBold.copyWith(
              color: context.colors.mainText,
            ),
          ),
          const Spacer(),
          Text(
            getTrailingText(paymentOptionEntity.shippingCost),
            style: AppTextStyles.font13Bold.copyWith(
              color: context.colors.primary,
            ),
          ),
        ],
      ),
    ),
  );
}
