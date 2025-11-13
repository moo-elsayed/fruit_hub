import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/widgets/custom_material_button.dart';
import 'package:fruit_hub/features/cart/domain/entities/cart_item_entity.dart';
import 'package:fruit_hub/features/cart/presentation/widgets/products_count.dart';
import 'package:fruit_hub/features/cart/presentation/widgets/cart_items_list_view.dart';
import 'package:gap/gap.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/widgets/custom_app_bar.dart';

class Cart extends StatefulWidget {
  const Cart({super.key});

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {
  var cartItemsList = [
    CartItemEntity(fruitEntity: FruitEntity()),
    CartItemEntity(fruitEntity: FruitEntity()),
    CartItemEntity(fruitEntity: FruitEntity()),
    CartItemEntity(fruitEntity: FruitEntity()),
    CartItemEntity(fruitEntity: FruitEntity()),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsetsGeometry.only(top: 10.h),
          child: CustomAppBar(title: "cart_app_bar".tr()),
        ),
        Gap(8.h),
        ProductsCount(count: cartItemsList.length),
        Gap(14.h),
        Expanded(child: CartItemsListView(cartItems: cartItemsList)),
        Padding(
          padding: EdgeInsetsGeometry.symmetric(
            horizontal: 16.w,
            vertical: 8.h,
          ),
          child: CustomMaterialButton(
            onPressed: () {},
            maxWidth: true,
            text: "${"checkout".tr()} 120 ${"pounds".tr()}",
            textStyle: AppTextStyles.font16WhiteBold,
          ),
        ),
      ],
    );
  }
}
