part of 'cart_cubit.dart';

@immutable
sealed class CartState {}

final class CartInitial extends CartState {}

final class AddItemToCartLoading extends CartState {}

final class AddItemToCartSuccess extends CartState {}

final class AddItemToCartFailure extends CartState {
  AddItemToCartFailure(this.errorMessage);

  final String errorMessage;
}

final class RemoveItemFromCartLoading extends CartState {}

final class RemoveItemFromCartSuccess extends CartState {}

final class RemoveItemFromCartFailure extends CartState {
  RemoveItemFromCartFailure(this.errorMessage);

  final String errorMessage;
}
