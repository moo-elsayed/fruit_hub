part of 'products_cubit.dart';

@immutable
sealed class ProductsState {}

final class ProductsInitial extends ProductsState {}

final class GetProductsLoading extends ProductsState {}

final class GetProductsSuccess extends ProductsState {
  GetProductsSuccess({
    required this.fruits,
    required this.hasMore,
    this.isLoadingMore = false,
    required this.filter,
  });

  final List<FruitEntity> fruits;
  final bool hasMore;
  final bool isLoadingMore;
  final ProductsFilterEntity filter;

  GetProductsSuccess copyWith({
    List<FruitEntity>? fruits,
    bool? hasMore,
    bool? isLoadingMore,
    ProductsFilterEntity? filter,
  }) => GetProductsSuccess(
    fruits: fruits ?? this.fruits,
    hasMore: hasMore ?? this.hasMore,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    filter: filter ?? this.filter,
  );
}

final class GetProductsFailure extends ProductsState {
  GetProductsFailure(this.error);

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
