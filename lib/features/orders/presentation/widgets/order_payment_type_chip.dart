import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/enums/payment_method_type.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/theming/app_palette.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';

class OrderPaymentTypeChip extends StatelessWidget {
  const OrderPaymentTypeChip({super.key, required this.paymentType});

  final PaymentMethodType paymentType;

  @override
  Widget build(BuildContext context) {
    final (icon, color, label) = switch (paymentType) {
      PaymentMethodType.paypal => (
        Icons.paypal,
        AppPalette.info,
        AppStrings.payByPaypal,
      ),
      PaymentMethodType.card => (
        Icons.credit_card,
        AppPalette.secondaryOrange,
        AppStrings.payByCreditCard,
      ),
      PaymentMethodType.cash => (
        Icons.attach_money,
        AppPalette.accentGreen,
        AppStrings.cashOnDelivery,
      ),
    };

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 4.w,
        children: [
          Icon(icon, size: 12.sp, color: color),
          Text(
            label,
            style: AppTextStyles.font11SemiBold.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
