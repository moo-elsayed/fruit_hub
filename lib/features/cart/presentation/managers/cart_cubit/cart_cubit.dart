import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fruit_hub/core/helpers/functions.dart';
import 'package:fruit_hub/core/helpers/network_response.dart';
import 'package:fruit_hub/core/services/database/cart_service.dart';
import 'package:fruit_hub/features/cart/domain/entities/cart_item_entity.dart';
import 'package:fruit_hub/features/cart/domain/use_cases/add_item_to_cart_use_case.dart';
import 'package:fruit_hub/features/cart/domain/use_cases/get_cart_items_use_case.dart';
import 'package:fruit_hub/features/cart/domain/use_cases/get_products_in_cart_use_case.dart';
import 'package:fruit_hub/features/cart/domain/use_cases/remove_item_from_cart_use_case.dart';
import 'package:fruit_hub/features/cart/domain/use_cases/update_item_quantity_use_case.dart';

part 'cart_state.dart';

class CartCubit extends Cubit<CartState> implements CartService {
  CartCubit(
    this._addItemToCartUseCase,
    this._removeItemFromCartUseCase,
    this._getProductsInCart,
    this._updateItemQuantityUseCase,
    this._getCartItemsUseCase,
  ) : super(CartInitial());

  final AddItemToCartUseCase _addItemToCartUseCase;
  final RemoveItemFromCartUseCase _removeItemFromCartUseCase;
  final GetProductsInCartUseCase _getProductsInCart;
  final UpdateItemQuantityUseCase _updateItemQuantityUseCase;
  final GetCartItemsUseCase _getCartItemsUseCase;

  List<Map<String, dynamic>> _cartItems = [];

  bool isInCart(String productId) =>
      _cartItems.any((item) => item['productId'] == productId);

  @override
  Future<void> addItemToCart(String productId) async {
    final result = await _addItemToCartUseCase.call(productId);
    switch (result) {
      case NetworkSuccess<void>():
        _addToCartItems(productId);
        await getProductsInCart(false);
      case NetworkFailure<void>():
        emit(CartFailure(getErrorMessage(result).tr()));
    }
  }

  @override
  Future<void> removeItemFromCart(String productId) async {
    final result = await _removeItemFromCartUseCase.call(productId);
    switch (result) {
      case NetworkSuccess<void>():
        _removeFromCartItems(productId);
        await getProductsInCart(false);
      case NetworkFailure<void>():
        emit(CartFailure(getErrorMessage(result).tr()));
    }
  }

  Future<void> getCartItems() async {
    emit(GetCartItemsLoading());
    final result = await _getCartItemsUseCase.call();
    switch (result) {
      case NetworkSuccess<List<Map<String, dynamic>>>():
        _cartItems = result.data!;
        emit(GetCartItemsSuccess());
      case NetworkFailure<List<Map<String, dynamic>>>():
        emit(GetCartItemsFailure(getErrorMessage(result).tr()));
    }
  }

  Future<void> getProductsInCart([bool needLoading = true]) async {
    if (needLoading) {
      emit(CartLoading());
    }
    final result = await _getProductsInCart.call(_cartItems);
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
    final int newQuantity = _getNewQuantity(
      productId: productId,
      increment: false,
    );
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
          await getProductsInCart(false);
        case NetworkFailure<void>():
          emit(CartFailure(getErrorMessage(result).tr()));
      }
    }
  }

  @override
  Future<void> incrementItemQuantity(String productId) async {
    final int newQuantity = _getNewQuantity(productId: productId);
    final result = await _updateItemQuantityUseCase.call(
      productId: productId,
      newQuantity: newQuantity,
    );
    switch (result) {
      case NetworkSuccess<void>():
        await getProductsInCart(false);
      case NetworkFailure<void>():
        emit(CartFailure(getErrorMessage(result).tr()));
    }
  }

  // -----------------------------------------------

  void _addToCartItems(String productId) {
    int index = _cartItems.indexWhere(
      (element) => element['fruitCode'] == productId,
    );
    if (index != -1) {
      _cartItems[index]['quantity']++;
    } else {
      _cartItems.add({'fruitCode': productId, 'quantity': 1});
    }
  }

  void _removeFromCartItems(String productId) =>
      _cartItems.removeWhere((item) => item['fruitCode'] == productId);

  double _calculateTotalPrice(List<CartItemEntity> items) => items
      .map((e) => e.totalPrice)
      .fold(0, (value, element) => value + element);

  int _getNewQuantity({required String productId, bool increment = true}) {
    int index = _cartItems.indexWhere(
      (element) => element['fruitCode'] == productId,
    );
    return increment
        ? ++_cartItems[index]['quantity']
        : --_cartItems[index]['quantity'];
  }
}
