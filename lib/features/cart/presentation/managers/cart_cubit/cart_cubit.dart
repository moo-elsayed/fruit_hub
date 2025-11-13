import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fruit_hub/core/helpers/functions.dart';
import 'package:fruit_hub/core/helpers/network_response.dart';
import 'package:fruit_hub/core/services/database/cart_service.dart';
import 'package:fruit_hub/features/cart/domain/entities/cart_item_entity.dart';
import 'package:fruit_hub/features/cart/domain/use_cases/add_item_to_cart_use_case.dart';
import 'package:fruit_hub/features/cart/domain/use_cases/remove_item_from_cart_use_case.dart';

part 'cart_state.dart';

class CartCubit extends Cubit<CartState> implements CartService {
  CartCubit(this._addItemToCartUseCase, this._removeItemFromCartUseCase)
    : super(CartInitial());

  final AddItemToCartUseCase _addItemToCartUseCase;
  final RemoveItemFromCartUseCase _removeItemFromCartUseCase;

  @override
  Future<void> addItemToCart(CartItemEntity item) async {
    emit(AddItemToCartLoading());
    final result = await _addItemToCartUseCase.call(item);
    switch (result) {
      case NetworkSuccess<void>():
        emit(AddItemToCartSuccess());
      case NetworkFailure<void>():
        emit(AddItemToCartFailure(getErrorMessage(result)));
    }
  }

  @override
  Future<void> removeItemFromCart(String productId) async {
    emit(RemoveItemFromCartLoading());
    final result = await _removeItemFromCartUseCase.call(productId);
    switch (result) {
      case NetworkSuccess<void>():
        emit(RemoveItemFromCartSuccess());
      case NetworkFailure<void>():
        emit(RemoveItemFromCartFailure(getErrorMessage(result)));
    }
  }
}
