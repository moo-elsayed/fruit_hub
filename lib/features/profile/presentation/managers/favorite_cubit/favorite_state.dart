part of 'favorite_cubit.dart';

@immutable
sealed class FavoriteState {}

final class FavoriteInitial extends FavoriteState {}

final class GetFavoriteIdsSuccess extends FavoriteState {}

final class GetFavoriteIdsFailure extends FavoriteState {
  GetFavoriteIdsFailure(this.errorMessage);

  final String errorMessage;
}

final class GetFavoritesLoading extends FavoriteState {}

final class GetFavoritesSuccess extends FavoriteState {
  GetFavoritesSuccess(this.favorites);

  final List<FruitEntity> favorites;
}

final class GetFavoritesFailure extends FavoriteState {
  GetFavoritesFailure(this.errorMessage);

  final String errorMessage;
}

final class ToggleFavoriteSuccess extends FavoriteState {
  ToggleFavoriteSuccess(this.favoriteIds);

  final Set<String> favoriteIds;
}

final class ToggleFavoriteFailure extends FavoriteState {
  ToggleFavoriteFailure(this.errorMessage);

  final String errorMessage;
}
