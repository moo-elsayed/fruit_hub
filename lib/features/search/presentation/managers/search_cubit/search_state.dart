part of 'search_cubit.dart';

@immutable
sealed class SearchState {}

final class SearchInitial extends SearchState {}

final class SearchLoading extends SearchState {}

final class SearchSuccess extends SearchState {
  SearchSuccess(this.products);

  final List<FruitEntity> products;
}

final class SearchFailure extends SearchState {
  SearchFailure(this.errorMessage);

  final String errorMessage;
}
