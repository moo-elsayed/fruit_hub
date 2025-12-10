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

final class MakePaymentLoading extends CheckoutState {}

final class MakePaymentSuccess extends CheckoutState {}

final class MakePaymentFailure extends CheckoutState {
  MakePaymentFailure(this.errorMessage);

  final String errorMessage;
}
