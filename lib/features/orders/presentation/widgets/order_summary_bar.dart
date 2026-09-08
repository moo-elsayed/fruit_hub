import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/enums/payment_method_type.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';
import 'package:fruit_hub/core/widgets/custom_price_text.dart';

import 'order_payment_type_chip.dart';

class OrderSummaryBar extends StatelessWidget {
  const OrderSummaryBar({
    super.key,
    required this.totalPrice,
    required this.paymentType,
    required this.isExpanded,
    required this.onToggle,
  });

  final double totalPrice;
  final PaymentMethodType paymentType;
  final bool isExpanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) => Column(
    spacing: 8.h,
    children: [
      Row(
        mainAxisAlignment: .spaceBetween,
        children: [
          CustomPriceText(price: totalPrice, isLarge: true),
          OrderPaymentTypeChip(paymentType: paymentType),
        ],
      ),
      GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: onToggle,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
          child: Row(
            spacing: 4.w,
            mainAxisAlignment: .center,
            children: [
              Text(
                isExpanded ? AppStrings.hideDetails : AppStrings.viewDetails,
                style: AppTextStyles.font12Medium.copyWith(
                  color: context.colors.primary,
                ),
              ),
              AnimatedRotation(
                turns: isExpanded ? 0.5 : 0.0,
                duration: const Duration(milliseconds: 250),
                child: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 18.sp,
                  color: context.colors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}
