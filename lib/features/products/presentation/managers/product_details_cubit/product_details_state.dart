part of 'product_details_cubit.dart';

@immutable
sealed class ProductDetailsState {}

final class ProductDetailsInitial extends ProductDetailsState {}

final class ProductDetailsLoading extends ProductDetailsState {}

final class ProductDetailsSuccess extends ProductDetailsState {
  ProductDetailsSuccess(this.fruit);

  final FruitEntity fruit;
}

final class ProductDetailsFailure extends ProductDetailsState {
  ProductDetailsFailure(this.error);

  final String error;
}
