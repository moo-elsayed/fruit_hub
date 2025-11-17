import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fruit_hub/core/helpers/functions.dart';
import 'package:fruit_hub/core/helpers/network_response.dart';
import 'package:fruit_hub/core/services/database/favorite_service.dart';
import 'package:fruit_hub/features/profile/domain/use_cases/add_item_to_favorites_use_case.dart';
import 'package:fruit_hub/features/profile/domain/use_cases/remove_item_from_favorites_use_case.dart';

part 'favorite_state.dart';

class FavoriteCubit extends Cubit<FavoriteState> implements FavoriteService {
  FavoriteCubit(
    this._addItemToFavoritesUseCase,
    this._removeItemFromFavoritesUseCase,
  ) : super(FavoriteInitial());

  final AddItemToFavoritesUseCase _addItemToFavoritesUseCase;
  final RemoveItemFromFavoritesUseCase _removeItemFromFavoritesUseCase;

  Set<String> _favoriteIds = {};

  void setInitialFavorites(List<dynamic> ids) {
    _favoriteIds = ids.map((e) => e.toString()).toSet();
    emit(FavoriteChanged(_favoriteIds));
  }

  bool isFavorite(String productId) => _favoriteIds.contains(productId);

  @override
  Future<void> addItemToFavorites(String productId) async {
    var result = await _addItemToFavoritesUseCase.call(productId);
    switch (result) {
      case NetworkSuccess<void>():
        emit(AddItemToFavoritesSuccess());
      case NetworkFailure<void>():
        emit(AddItemToFavoritesFailure(getErrorMessage(result).tr()));
    }
  }

  @override
  Future<void> removeItemFromFavorites(String productId) async {
    var result = await _removeItemFromFavoritesUseCase.call(productId);
    switch (result) {
      case NetworkSuccess<void>():
        emit(RemoveItemFromFavoritesSuccess());
      case NetworkFailure<void>():
        emit(RemoveItemFromFavoritesFailure(getErrorMessage(result).tr()));
    }
  }
}
