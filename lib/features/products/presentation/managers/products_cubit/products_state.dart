part of 'products_cubit.dart';

@immutable
sealed class ProductsState {}

final class ProductsInitial extends ProductsState {}

final class GetAllProductsLoading extends ProductsState {}

final class GetAllProductsSuccess extends ProductsState {
  GetAllProductsSuccess(this.fruits);

  final List<FruitEntity> fruits;
}

final class GetAllProductsFailure extends ProductsState {
  GetAllProductsFailure(this.error);

  final String error;
}

final class GetProductDetailsLoading extends ProductsState {}

final class GetProductDetailsSuccess extends ProductsState {
  GetProductDetailsSuccess(this.fruit);

  final FruitEntity fruit;
}

final class GetProductDetailsFailure extends ProductsState {
  GetProductDetailsFailure(this.error);

  final String error;
}
