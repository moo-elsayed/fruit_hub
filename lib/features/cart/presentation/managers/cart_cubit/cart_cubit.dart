import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fruit_hub/core/helpers/functions.dart';
import 'package:fruit_hub/core/helpers/network_response.dart';
import 'package:fruit_hub/core/services/database/cart_service.dart';
import 'package:fruit_hub/features/cart/domain/entities/cart_item_entity.dart';
import 'package:fruit_hub/features/cart/domain/use_cases/add_item_to_cart_use_case.dart';
import 'package:fruit_hub/features/cart/domain/use_cases/get_cart_items_use_case.dart';
import 'package:fruit_hub/features/cart/domain/use_cases/remove_item_from_cart_use_case.dart';
import 'package:fruit_hub/features/cart/domain/use_cases/update_item_quantity_use_case.dart';

part 'cart_state.dart';

class CartCubit extends Cubit<CartState> implements CartService {
  CartCubit(
    this._addItemToCartUseCase,
    this._removeItemFromCartUseCase,
    this._getCartItemsUseCase,
    this._updateItemQuantityUseCase,
  ) : super(CartInitial());

  final AddItemToCartUseCase _addItemToCartUseCase;
  final RemoveItemFromCartUseCase _removeItemFromCartUseCase;
  final GetCartItemsUseCase _getCartItemsUseCase;
  final UpdateItemQuantityUseCase _updateItemQuantityUseCase;

  @override
  Future<void> addItemToCart(CartItemEntity item) async {
    final result = await _addItemToCartUseCase.call(item);
    switch (result) {
      case NetworkSuccess<void>():
        await getCartItems(false);
      case NetworkFailure<void>():
        emit(CartFailure(getErrorMessage(result).tr()));
    }
  }

  @override
  Future<void> removeItemFromCart(String productId) async {
    final result = await _removeItemFromCartUseCase.call(productId);
    switch (result) {
      case NetworkSuccess<void>():
        await getCartItems(false);
      case NetworkFailure<void>():
        emit(CartFailure(getErrorMessage(result).tr()));
    }
  }

  Future<void> getCartItems([bool needLoading = true]) async {
    if (needLoading) {
      emit(CartLoading());
    }
    final result = await _getCartItemsUseCase.call();
    switch (result) {
      case NetworkSuccess<List<CartItemEntity>>():
        final items = result.data!;
        emit(
          CartSuccess(
            items: items,
            totalItemCount: items.length,
            totalPrice: _calculateTotalPrice(items),
          ),
        );
      case NetworkFailure<List<CartItemEntity>>():
        emit(CartFailure(getErrorMessage(result).tr()));
    }
  }

  @override
  Future<void> decrementItemQuantity(String productId) async {
    final int? newQuantity = _getNewQuantity(
      productId: productId,
      increment: false,
    );
    if (newQuantity == null) return;
    if (newQuantity == 0) {
      await removeItemFromCart(productId);
      return;
    } else {
      final result = await _updateItemQuantityUseCase.call(
        productId: productId,
        newQuantity: newQuantity,
      );
      switch (result) {
        case NetworkSuccess<void>():
          await getCartItems(false);
        case NetworkFailure<void>():
          emit(CartFailure(getErrorMessage(result).tr()));
      }
    }
  }

  @override
  Future<void> incrementItemQuantity(String productId) async {
    final int? newQuantity = _getNewQuantity(productId: productId);
    if (newQuantity == null) return;
    final result = await _updateItemQuantityUseCase.call(
      productId: productId,
      newQuantity: newQuantity,
    );
    switch (result) {
      case NetworkSuccess<void>():
        await getCartItems(false);
      case NetworkFailure<void>():
        emit(CartFailure(getErrorMessage(result).tr()));
    }
  }

  // -----------------------------------------------

  double _calculateTotalPrice(List<CartItemEntity> items) => items
      .map((e) => e.totalPrice)
      .fold(0, (value, element) => value + element);

  int? _getNewQuantity({required String productId, bool increment = true}) {
    final currentState = state;
    if (currentState is! CartSuccess) {
      return null;
    }
    try {
      final item = currentState.items.firstWhere(
        (i) => i.fruitEntity.code == productId,
      );
      return increment ? item.quantity + 1 : item.quantity - 1;
    } catch (e) {
      return null;
    }
  }
}
