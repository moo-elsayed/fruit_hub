import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/features/favorites/domain/use_cases/add_item_to_favorites_use_case.dart';
import 'package:fruit_hub/features/favorites/domain/use_cases/get_favorite_ids_use_case.dart';
import 'package:fruit_hub/features/favorites/domain/use_cases/get_favorites_use_case.dart';
import 'package:fruit_hub/features/favorites/domain/use_cases/remove_item_from_favorites_use_case.dart';

part 'favorite_state.dart';

class FavoriteCubit extends Cubit<FavoriteState> {
  FavoriteCubit(
    this._addItemToFavoritesUseCase,
    this._removeItemFromFavoritesUseCase,
    this._getFavoriteIdsUseCase,
    this._getFavoritesUseCase,
  ) : super(FavoriteInitial());

  final AddItemToFavoritesUseCase _addItemToFavoritesUseCase;
  final RemoveItemFromFavoritesUseCase _removeItemFromFavoritesUseCase;
  final GetFavoriteIdsUseCase _getFavoriteIdsUseCase;
  final GetFavoritesUseCase _getFavoritesUseCase;

  Set<String> _favoriteIds = {};
  List<FruitEntity> _favorites = [];

  bool isFavorite(String productId) => _favoriteIds.contains(productId);
  List<FruitEntity> get favoriteFruits => _favorites;
  Set<String> get favoriteIds => _favoriteIds;

  Future<void> getFavoriteIds() async {
    final result = await _getFavoriteIdsUseCase.call();
    switch (result) {
      case NetworkSuccess<List<String>>():
        _setFavorites(result.data!);
        emit(GetFavoriteIdsSuccess());
      case NetworkFailure<List<String>>():
        emit(GetFavoriteIdsFailure(result.error));
    }
  }

  Future<void> getFavorites() async {
    if (_favorites.isNotEmpty) {
      emit(GetFavoritesSuccess(_favorites));
      return;
    }
    emit(GetFavoritesLoading());
    if (_favoriteIds.isEmpty) {
      final idsResult = await _getFavoriteIdsUseCase.call();
      if (idsResult is NetworkSuccess<List<String>>) {
        _setFavorites(idsResult.data!);
      }
    }
    if (_favoriteIds.isEmpty) {
      _favorites = [];
      emit(GetFavoritesSuccess(_favorites));
      return;
    }
    final result = await _getFavoritesUseCase.call(_favoriteIds.toList());
    switch (result) {
      case NetworkSuccess<List<FruitEntity>>():
        _favorites = List.from(result.data!);
        _favoriteIds = _favorites.map((e) => e.code).toSet();
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
      _favoriteIds.remove(productId);
      _favorites.removeWhere((element) => element.code == productId);
    } else {
      _favoriteIds.add(productId);
      _favorites.insert(0, fruit);
    }
    emit(ToggleFavoriteSuccess(_favoriteIds, _favorites));

    // Background server call
    final NetworkResponse result = favorite
        ? await _removeItemFromFavoritesUseCase.call(productId)
        : await _addItemToFavoritesUseCase.call(productId);

    switch (result) {
      case NetworkSuccess<void>():
        break;
      case NetworkFailure<void>():
        // Revert on failure
        if (favorite) {
          _favoriteIds.add(productId);
          _favorites.insert(0, fruit);
        } else {
          _favoriteIds.remove(productId);
          _favorites.removeWhere((element) => element.code == productId);
        }
        emit(ToggleFavoriteSuccess(_favoriteIds, _favorites));
        emit(ToggleFavoriteFailure(result.error));
    }
  }

  // -----------------------------------------------------------------

  void _setFavorites(List<String> ids) =>
      _favoriteIds = ids.map((e) => e.toString()).toSet();
}
