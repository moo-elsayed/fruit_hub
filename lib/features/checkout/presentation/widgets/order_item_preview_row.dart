import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/entities/cart_item_entity.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';
import 'package:fruit_hub/core/widgets/custom_network_image.dart';
import 'package:fruit_hub/core/widgets/custom_price_text.dart';
import 'package:fruit_hub/core/widgets/quantity_badge.dart';

class OrderItemPreviewRow extends StatelessWidget {
  const OrderItemPreviewRow({super.key, required this.item});

  final CartItemEntity item;

  @override
  Widget build(BuildContext context) => Row(
    spacing: 12.w,
    children: [
      Container(
        width: 48.r,
        height: 48.r,
        decoration: BoxDecoration(
          color: context.colors.background,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.r),
          child: CustomNetworkImage(
            image: item.fruitEntity.imagePath,
            fit: BoxFit.contain,
          ),
        ),
      ),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 4.h,
          children: [
            Text(
              item.fruitEntity.name,
              style: AppTextStyles.font13Bold.copyWith(
                color: context.colors.mainText,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            QuantityBadge(quantity: item.quantity),
          ],
        ),
      ),
      CustomPriceText(price: item.totalPrice),
    ],
  );
}
