import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/entities/cart_item_entity.dart';
import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:gap/gap.dart';

import 'cart_item.dart';

class CartItemsListView extends StatelessWidget {
  const CartItemsListView({super.key, this.cartItems, this.itemCount});

  final List<CartItemEntity>? cartItems;
  final int? itemCount;

  @override
  Widget build(BuildContext context) => ListView.separated(
    padding: EdgeInsets.only(bottom: 212.h),
    itemCount: itemCount ?? cartItems!.length,
    separatorBuilder: (context, index) => Gap(8.h),
    itemBuilder: (context, index) => CartItem(
      key: ValueKey(cartItems?[index].fruitEntity.code),
      cartItemEntity: itemCount != null
          ? const CartItemEntity(fruitEntity: FruitEntity())
          : cartItems![index],
    ),
  );
}
