import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/entities/cart_item_entity.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/routing/routes.dart';
import 'package:fruit_hub/core/theming/app_palette.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';
import 'package:fruit_hub/core/widgets/custom_material_button.dart';
import 'package:fruit_hub/core/widgets/custom_price_text.dart';
import 'package:gap/gap.dart';

class CartCheckoutBottomBar extends StatelessWidget {
  const CartCheckoutBottomBar({
    super.key,
    required this.cartItems,
    required this.totalPrice,
  });

  final List<CartItemEntity> cartItems;
  final num totalPrice;

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.all(14.r),
    decoration: BoxDecoration(
      color: context.colors.surface,
      borderRadius: BorderRadius.circular(18.r),
      border: Border.all(color: context.colors.border, width: 1.w),
      boxShadow: [
        BoxShadow(
          color: context.colors.mainText.withValues(alpha: 0.06),
          blurRadius: 16.r,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppStrings.total,
              style: AppTextStyles.font14Medium.copyWith(
                color: context.colors.subText,
              ),
            ),
            CustomPriceText(price: totalPrice, isLarge: true),
          ],
        ),
        Gap(10.h),
        CustomMaterialButton(
          onPressed: () =>
              context.pushNamed(Routes.checkoutView, arguments: cartItems),
          text: AppStrings.checkout,
          maxWidth: true,
          borderRadius: BorderRadius.circular(14.r),
          padding: EdgeInsets.symmetric(vertical: 12.h),
          textStyle: AppTextStyles.font16Bold.copyWith(color: AppPalette.white),
        ),
      ],
    ),
  );
}
