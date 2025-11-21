part of 'cart_cubit.dart';

@immutable
sealed class CartState {}

final class CartInitial extends CartState {}

final class GetCartItemsLoading extends CartState {}

final class GetCartItemsSuccess extends CartState {}

final class GetCartItemsFailure extends CartState {
  GetCartItemsFailure(this.errorMessage);

  final String errorMessage;
}

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
    this.newItemAdded = false,
    this.itemRemoved = false,
  });

  final List<CartItemEntity> items;
  final double totalPrice;
  final int totalItemCount;
  final bool newItemAdded;
  final bool itemRemoved;
}

final class CartFailure extends CartState {
  CartFailure(this.errorMessage);

  final String errorMessage;
}
