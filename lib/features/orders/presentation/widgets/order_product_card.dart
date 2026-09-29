import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/entities/order_item_entity.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';
import 'package:fruit_hub/core/widgets/custom_network_image.dart';
import 'package:fruit_hub/core/widgets/custom_price_text.dart';

class OrderProductCard extends StatelessWidget {
  const OrderProductCard({super.key, required this.product});

  final OrderItemEntity product;

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.all(8.r),
    decoration: BoxDecoration(
      color: context.colors.background,
      borderRadius: BorderRadius.circular(10.r),
      border: Border.all(color: context.colors.border, width: 0.8),
    ),
    child: Row(
      spacing: 10.w,
      children: [
        Container(
          width: 44.r,
          height: 44.r,
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: CustomNetworkImage(image: product.imagePath, fit: .cover),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 2.h,
            children: [
              Text(
                product.name,
                style: AppTextStyles.font13Bold.copyWith(
                  color: context.colors.mainText,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (product.code.isNotEmpty) ...[
                Text(
                  '${AppStrings.codeLabel}${product.code}',
                  style: AppTextStyles.font11Medium.copyWith(
                    color: context.colors.subText,
                  ),
                ),
              ],
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          spacing: 2.h,
          children: [
            CustomPriceText(price: product.totalPrice),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: context.colors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Text(
                'x${product.quantity}',
                style: AppTextStyles.font10Bold.copyWith(
                  color: context.colors.primary,
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
