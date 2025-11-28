import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/features/checkout/domain/entities/payment_option_entity.dart';
import 'package:gap/gap.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';

class PaymentOption extends StatelessWidget {
  const PaymentOption({
    super.key,
    required this.shippingEntity,
    required this.onTap,
    required this.isSelected,
  });

  final PaymentOptionEntity shippingEntity;
  final VoidCallback onTap;
  final bool isSelected;

  String getTrailingText(double price) =>
      price == 0 ? "free".tr() : "$price ${"pounds".tr()}";

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: .symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: AppColors.colorF7F7F7,
          borderRadius: .circular(12.r),
          border: Border.all(
            color: isSelected ? AppColors.color1B5E37 : AppColors.colorF7F7F7,
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
                      ? AppColors.color1B5E37
                      : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              padding: const .all(3),
              child: isSelected
                  ? Container(
                      decoration: const BoxDecoration(
                        shape: .circle,
                        color: AppColors.color1B5E37,
                      ),
                    )
                  : null,
            ),
            Gap(10.w),
            Expanded(
              child: shippingEntity.subtitle != null
                  ? Column(
                      crossAxisAlignment: .start,
                      spacing: 6.h,
                      children: [
                        Text(
                          shippingEntity.title,
                          style: AppTextStyles.font13BlackSemiBold,
                        ),
                        Text(
                          shippingEntity.subtitle!,
                          style: AppTextStyles.font13color7B7B7BRegular,
                        ),
                      ],
                    )
                  : Text(
                      shippingEntity.title,
                      style: AppTextStyles.font13BlackSemiBold,
                    ),
            ),
            Text(
              getTrailingText(shippingEntity.price),
              style: AppTextStyles.font13color3A8B33Bold,
            ),
          ],
        ),
      ),
    );
  }
}
