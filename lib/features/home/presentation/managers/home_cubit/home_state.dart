part of 'home_cubit.dart';

@immutable
sealed class HomeState {}

final class HomeInitial extends HomeState {}

final class GetBestSellerProductsLoading extends HomeState {}

final class GetBestSellerProductsSuccess extends HomeState {
  GetBestSellerProductsSuccess(this.fruits);

  final List<FruitEntity> fruits;
}

final class GetBestSellerProductsFailure extends HomeState {
  GetBestSellerProductsFailure(this.error);

  final String error;
}
