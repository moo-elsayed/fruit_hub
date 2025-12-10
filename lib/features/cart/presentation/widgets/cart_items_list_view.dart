import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/entities/cart_item_entity.dart';
import '../../../../core/theming/app_colors.dart';
import 'cart_item.dart';

class CartItemsListView extends StatelessWidget {
  const CartItemsListView({super.key, this.cartItems, this.itemCount});

  final List<CartItemEntity>? cartItems;
  final int? itemCount;

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.sizeOf(context);
    return ListView.separated(
      padding: EdgeInsetsGeometry.only(top: 14.h, bottom: 80.h),
      itemCount: itemCount ?? cartItems!.length,
      itemBuilder: (context, index) {
        return Column(
          children: [
            if (index == 0) buildDivider(),
            CartItem(
              size: size,
              cartItemEntity: itemCount != null
                  ? const CartItemEntity(fruitEntity: FruitEntity())
                  : cartItems![index],
            ),
            if ((cartItems != null && index == cartItems!.length - 1) ||
                (itemCount != null && index == itemCount! - 1))
              buildDivider(),
          ],
        );
      },
      separatorBuilder: (context, index) => buildDivider(),
    );
  }

  Divider buildDivider() => Divider(height: 10.h, color: AppColors.colorF1F1F5);
}
