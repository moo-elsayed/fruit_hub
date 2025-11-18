import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/helpers/functions.dart';
import 'package:fruit_hub/core/helpers/network_response.dart';
import 'package:fruit_hub/core/services/database/favorite_service.dart';
import 'package:fruit_hub/features/profile/domain/use_cases/add_item_to_favorites_use_case.dart';
import 'package:fruit_hub/features/profile/domain/use_cases/get_favorite_ids_use_case.dart';
import 'package:fruit_hub/features/profile/domain/use_cases/get_favorites_use_case.dart';
import 'package:fruit_hub/features/profile/domain/use_cases/remove_item_from_favorites_use_case.dart';

part 'favorite_state.dart';

class FavoriteCubit extends Cubit<FavoriteState> implements FavoriteService {
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

  Future<void> getFavoriteIds() async {
    var result = await _getFavoriteIdsUseCase.call();
    switch (result) {
      case NetworkSuccess<List<String>>():
        _setFavorites(result.data!);
        emit(GetFavoriteIdsSuccess());
      case NetworkFailure<List<String>>():
        emit(GetFavoriteIdsFailure(getErrorMessage(result).tr()));
    }
  }

  Future<void> getFavorites() async {
    emit(GetFavoritesLoading());
    var result = await _getFavoritesUseCase.call(_favoriteIds.toList());
    switch (result) {
      case NetworkSuccess<List<FruitEntity>>():
        emit(GetFavoritesSuccess(result.data!));
      case NetworkFailure<List<FruitEntity>>():
        emit(GetFavoritesFailure(getErrorMessage(result).tr()));
    }
  }

  @override
  bool isFavorite(String productId) => _favoriteIds.contains(productId);

  @override
  Future<void> toggleFavorite(String productId) async {
    NetworkResponse result;
    bool favorite = isFavorite(productId);
    if (favorite) {
      result = await _removeItemFromFavoritesUseCase.call(productId);
    } else {
      result = await _addItemToFavoritesUseCase.call(productId);
    }
    switch (result) {
      case NetworkSuccess<void>():
        favorite ? _favoriteIds.remove(productId) : _favoriteIds.add(productId);
        emit(ToggleFavoriteSuccess(_favoriteIds));
      case NetworkFailure<void>():
        emit(ToggleFavoriteFailure(getErrorMessage(result).tr()));
    }
  }

  // -----------------------------------------------------------------

  void _setFavorites(List<String> ids) =>
      _favoriteIds = ids.map((e) => e.toString()).toSet();
}
