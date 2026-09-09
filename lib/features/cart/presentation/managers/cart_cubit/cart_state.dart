part of 'cart_cubit.dart';

@immutable
sealed class CartState {}

final class CartInitial extends CartState {}

final class CartLoading extends CartState {
  CartLoading({this.itemRemoved = false, this.newItemAdded = false});

  final bool itemRemoved;
  final bool newItemAdded;
}

final class CartSuccess extends CartState {
  CartSuccess({
    required this.items,
    required this.totalPrice,
    required this.totalItemCount,
    this.shippingConfig,
    this.newItemAdded = false,
    this.itemRemoved = false,
    this.itemAlreadyExists = false,
  });

  final List<CartItemEntity> items;
  final double totalPrice;
  final int totalItemCount;
  final ShippingConfigEntity? shippingConfig;
  final bool newItemAdded;
  final bool itemRemoved;
  final bool itemAlreadyExists;
}

final class CartFailure extends CartState {
  CartFailure(this.errorMessage);

  final String errorMessage;
}
