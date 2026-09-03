import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fruit_hub/core/entities/cart_item_entity.dart';
import 'package:fruit_hub/core/widgets/custom_price_text.dart';
import 'package:fruit_hub/core/widgets/custom_quantity_selector.dart';

import '../managers/cart_cubit/cart_cubit.dart';

class CartItemActionButtons extends StatelessWidget {
  const CartItemActionButtons({super.key, required this.cartItemEntity});

  final CartItemEntity cartItemEntity;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      CustomQuantitySelector(
        quantity: cartItemEntity.quantity,
        onIncrement: () => context.read<CartCubit>().incrementItemQuantity(
          cartItemEntity.fruitEntity.code,
        ),
        onDecrement: () => context.read<CartCubit>().decrementItemQuantity(
          cartItemEntity.fruitEntity.code,
        ),
      ),
      const Spacer(),
      CustomPriceText(price: cartItemEntity.totalPrice),
    ],
  );
}
