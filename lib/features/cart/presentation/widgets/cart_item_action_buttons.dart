import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fruit_hub/core/entities/cart_item_entity.dart';
import 'package:fruit_hub/core/widgets/custom_price_text.dart';
import 'package:fruit_hub/core/widgets/custom_quantity_selector.dart';
import '../managers/cart_cubit/cart_cubit.dart';

class CartItemActionButtons extends StatefulWidget {
  const CartItemActionButtons({super.key, required this.cartItemEntity});

  final CartItemEntity cartItemEntity;

  @override
  State<CartItemActionButtons> createState() => _CartItemActionButtonsState();
}

class _CartItemActionButtonsState extends State<CartItemActionButtons> {
  bool _isEnable = true;

  Future<void> _handleQuantityChange(bool isIncrement) async {
    if (!_isEnable) return;

    setState(() => _isEnable = false);

    if (isIncrement) {
      await context.read<CartCubit>().incrementItemQuantity(
        widget.cartItemEntity.fruitEntity.code,
      );
    } else {
      await context.read<CartCubit>().decrementItemQuantity(
        widget.cartItemEntity.fruitEntity.code,
      );
    }

    await Future.delayed(const Duration(milliseconds: 250));
    if (mounted) {
      setState(() => _isEnable = true);
    }
  }

  @override
  Widget build(BuildContext context) => Row(
    children: [
      CustomQuantitySelector(
        quantity: widget.cartItemEntity.quantity,
        isEnabled: _isEnable,
        onIncrement: () => _handleQuantityChange(true),
        onDecrement: () => _handleQuantityChange(false),
      ),
      const Spacer(),
      CustomPriceText(price: widget.cartItemEntity.totalPrice),
    ],
  );
}
