import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/entities/order_entity.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/theming/app_palette.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';
import 'package:fruit_hub/core/widgets/app_toasts.dart';
import 'package:fruit_hub/core/widgets/custom_price_text.dart';
import 'package:toastification/toastification.dart';

import 'receipt_info_row.dart';

class OrderReceiptCard extends StatelessWidget {
  const OrderReceiptCard({super.key, required this.orderEntity});

  final OrderEntity orderEntity;

  void _copyOrderId(BuildContext context) {
    Clipboard.setData(ClipboardData(text: '${orderEntity.orderId}'));
    AppToast.show(
      context: context,
      title: AppStrings.orderCopied,
      type: ToastificationType.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = orderEntity.totalPrice;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: context.isDarkMode
            ? context.colors.surface
            : AppPalette.bgLightSecondary,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: context.colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12.h,
        children: [
          // Order ID & Copy Action
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 4.w,
                children: [
                  Text(
                    '${AppStrings.orderNumber}:',
                    style: AppTextStyles.font14Regular.copyWith(
                      color: context.colors.subText,
                    ),
                  ),
                  Text(
                    '#${orderEntity.orderId}',
                    style: AppTextStyles.font14Bold.copyWith(
                      color: context.colors.primary,
                    ),
                  ),
                ],
              ),
              InkWell(
                borderRadius: BorderRadius.circular(8.r),
                onTap: () => _copyOrderId(context),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 4.w,
                  children: [
                    Icon(
                      Icons.copy_rounded,
                      size: 16.sp,
                      color: context.colors.primary,
                    ),
                    Text(
                      AppStrings.copy,
                      style: AppTextStyles.font12Medium.copyWith(
                        color: context.colors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Divider(color: context.colors.border, height: 0),
          // Payment Method
          ReceiptInfoRow(
            icon: Icons.payment_rounded,
            label: AppStrings.paymentMethod,
            value: orderEntity.paymentOption.title,
          ),
          // Delivery Address
          ReceiptInfoRow(
            icon: Icons.location_on_outlined,
            label: AppStrings.deliveryAddress,
            value:
                '${orderEntity.address.city}, ${orderEntity.address.streetName}',
          ),
          Divider(color: context.colors.border, height: 0),
          // Total Amount
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.total,
                style: AppTextStyles.font16Bold.copyWith(
                  color: context.colors.mainText,
                ),
              ),
              CustomPriceText(price: total, isLarge: true),
            ],
          ),
        ],
      ),
    );
  }
}
