import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/features/favorites/domain/use_cases/add_item_to_favorites_use_case.dart';
import 'package:fruit_hub/features/favorites/domain/use_cases/get_favorites_use_case.dart';
import 'package:fruit_hub/features/favorites/domain/use_cases/remove_item_from_favorites_use_case.dart';

part 'favorite_state.dart';

class FavoriteCubit extends Cubit<FavoriteState> {
  FavoriteCubit(
    this._addItemToFavoritesUseCase,
    this._removeItemFromFavoritesUseCase,
    this._getFavoritesUseCase,
  ) : super(FavoriteInitial());

  final AddItemToFavoritesUseCase _addItemToFavoritesUseCase;
  final RemoveItemFromFavoritesUseCase _removeItemFromFavoritesUseCase;
  final GetFavoritesUseCase _getFavoritesUseCase;

  List<FruitEntity> _favorites = [];

  bool isFavorite(String productId) =>
      _favorites.any((e) => e.code == productId);
  List<FruitEntity> get favoriteFruits => _favorites;

  Future<void> getFavorites() async {
    if (_favorites.isNotEmpty) {
      emit(GetFavoritesSuccess(_favorites));
      return;
    }
    emit(GetFavoritesLoading());
    final result = await _getFavoritesUseCase.call();
    switch (result) {
      case NetworkSuccess<List<FruitEntity>>():
        _favorites = List.from(result.data!);
        emit(GetFavoritesSuccess(_favorites));
      case NetworkFailure<List<FruitEntity>>():
        emit(GetFavoritesFailure(result.error));
    }
  }

  Future<void> toggleFavorite(FruitEntity fruit) async {
    final productId = fruit.code;
    final bool favorite = isFavorite(productId);

    // Optimistic local update (Instant 0ms)
    if (favorite) {
      _favorites.removeWhere((element) => element.code == productId);
    } else {
      _favorites.insert(0, fruit);
    }
    emit(ToggleFavoriteSuccess(_favorites));

    // Background server call
    final NetworkResponse result = favorite
        ? await _removeItemFromFavoritesUseCase.call(productId)
        : await _addItemToFavoritesUseCase.call(productId);

    if (result is NetworkFailure<void>) {
      if (favorite) {
        _favorites.insert(0, fruit);
      } else {
        _favorites.removeWhere((element) => element.code == productId);
      }
      emit(ToggleFavoriteFailure(result.error));
    }
  }
}
