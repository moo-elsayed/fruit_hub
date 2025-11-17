part of 'favorite_cubit.dart';

@immutable
sealed class FavoriteState {}

final class FavoriteInitial extends FavoriteState {}

final class FavoriteChanged extends FavoriteState {
  final Set<String> favoriteIds;

  FavoriteChanged(this.favoriteIds);
}

final class FavoriteFailure extends FavoriteState {
  final String errMessage;

  FavoriteFailure(this.errMessage);
}

final class AddItemToFavoritesSuccess extends FavoriteState {}

final class AddItemToFavoritesFailure extends FavoriteState {
  AddItemToFavoritesFailure(this.errorMessage);

  final String errorMessage;
}

final class RemoveItemFromFavoritesSuccess extends FavoriteState {}

final class RemoveItemFromFavoritesFailure extends FavoriteState {
  RemoveItemFromFavoritesFailure(this.errorMessage);

  final String errorMessage;
}
