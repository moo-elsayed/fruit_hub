part of 'checkout_cubit.dart';

@immutable
sealed class CheckoutState {}

final class CheckoutInitial extends CheckoutState {}

final class AddOrderLoading extends CheckoutState {}

final class AddOrderSuccess extends CheckoutState {}

final class AddOrderFailure extends CheckoutState {
  AddOrderFailure(this.errorMessage);

  final String errorMessage;
}
