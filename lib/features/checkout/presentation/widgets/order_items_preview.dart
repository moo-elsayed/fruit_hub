import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/entities/cart_item_entity.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/theming/app_palette.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';

import 'order_item_preview_row.dart';

class OrderItemsPreview extends StatelessWidget {
  const OrderItemsPreview({super.key, required this.products});

  final List<CartItemEntity> products;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const SizedBox.shrink();

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
          Row(
            spacing: 6.w,
            children: [
              Text(
                AppStrings.orderedItems,
                style: AppTextStyles.font14Bold.copyWith(
                  color: context.colors.mainText,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: context.colors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  '${products.length}',
                  style: AppTextStyles.font12Bold.copyWith(
                    color: context.colors.primary,
                  ),
                ),
              ),
            ],
          ),
          Divider(color: context.colors.border, height: 0),
          for (int i = 0; i < products.length; i++) ...[
            if (i > 0) Divider(color: context.colors.border, height: 0),
            OrderItemPreviewRow(item: products[i]),
          ],
        ],
      ),
    );
  }
}
