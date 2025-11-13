import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/features/cart/domain/entities/cart_item_entity.dart';
import '../../../../core/theming/app_colors.dart';
import 'cart_item.dart';

class CartItemsListView extends StatelessWidget {
  const CartItemsListView({super.key, required this.cartItems});

  final List<CartItemEntity> cartItems;

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.sizeOf(context);
    return ListView.separated(
      itemCount: cartItems.length,
      itemBuilder: (context, index) {
        return Column(
          children: [
            if (index == 0) buildDivider(),
            CartItem(size: size, cartItemEntity: cartItems[index]),
            if (index == cartItems.length - 1) buildDivider(),
          ],
        );
      },
      separatorBuilder: (context, index) => buildDivider(),
    );
  }

  Divider buildDivider() => Divider(height: 10.h, color: AppColors.colorF1F1F5);
}
