import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';
import 'package:fruit_hub/features/checkout/domain/entities/shipping_config_entity.dart';

class FreeShippingProgressBar extends StatelessWidget {
  const FreeShippingProgressBar({
    super.key,
    required this.shippingConfig,
    required this.totalPrice,
  });

  final ShippingConfigEntity? shippingConfig;
  final num totalPrice;

  @override
  Widget build(BuildContext context) {
    final config = shippingConfig;
    if (config == null ||
        config.freeShippingThreshold == null ||
        config.freeShippingThreshold! <= 0) {
      return const SizedBox.shrink();
    }

    final double subtotal = totalPrice.toDouble();
    final bool isFree = config.isFreeShipping(subtotal);
    final double remaining = config.remainingForFreeShipping(subtotal);
    final double ratio = config.progressRatio(subtotal);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: isFree
              ? context.colors.primary.withValues(alpha: 0.4)
              : context.colors.border,
          width: 1.w,
        ),
        boxShadow: [
          BoxShadow(
            color: context.colors.mainText.withValues(alpha: 0.02),
            blurRadius: 8.r,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        spacing: 8.h,
        children: [
          Row(
            spacing: 8.w,
            children: [
              Container(
                padding: EdgeInsets.all(6.r),
                decoration: BoxDecoration(
                  color: context.colors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isFree
                      ? Icons.check_circle_rounded
                      : Icons.local_shipping_outlined,
                  size: 16.sp,
                  color: context.colors.primary,
                ),
              ),
              Expanded(
                child: Text(
                  isFree
                      ? AppStrings.congratulationsFreeShipping
                      : AppStrings.addAmountMoreForFreeShipping(
                          '${remaining.formattedPrice} ${AppStrings.pounds}',
                        ),
                  style: isFree
                      ? AppTextStyles.font13Bold.copyWith(
                          color: context.colors.primary,
                        )
                      : AppTextStyles.font12Medium.copyWith(
                          color: context.colors.mainText,
                        ),
                ),
              ),
            ],
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(6.r),
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
              tween: Tween<double>(begin: 0, end: ratio),
              builder: (context, value, _) => LinearProgressIndicator(
                value: value,
                minHeight: 6.h,
                backgroundColor: context.colors.primary.withValues(alpha: 0.12),
                valueColor: AlwaysStoppedAnimation<Color>(
                  context.colors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
