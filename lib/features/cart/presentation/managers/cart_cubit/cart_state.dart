part of 'cart_cubit.dart';

@immutable
sealed class CartState {}

final class CartInitial extends CartState {}

class CartLoading extends CartState {}

class CartSuccess extends CartState {
  CartSuccess({
    required this.items,
    required this.totalPrice,
    required this.totalItemCount,
  });

  final List<CartItemEntity> items;
  final double totalPrice;
  final int totalItemCount;
}

class CartFailure extends CartState {
  CartFailure(this.errorMessage);

  final String errorMessage;
}
