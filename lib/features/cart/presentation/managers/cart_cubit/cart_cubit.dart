import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fruit_hub/core/helpers/functions.dart';
import 'package:fruit_hub/core/helpers/network_response.dart';
import 'package:fruit_hub/core/services/database/cart_service.dart';
import 'package:fruit_hub/core/entities/cart_item_entity.dart';
import 'package:fruit_hub/features/cart/domain/use_cases/add_item_to_cart_use_case.dart';
import 'package:fruit_hub/features/cart/domain/use_cases/clear_cart_use_case.dart';
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
    this._clearCartUseCase,
  ) : super(CartInitial());

  final AddItemToCartUseCase _addItemToCartUseCase;
  final RemoveItemFromCartUseCase _removeItemFromCartUseCase;
  final GetProductsInCartUseCase _getProductsInCart;
  final UpdateItemQuantityUseCase _updateItemQuantityUseCase;
  final GetCartItemsUseCase _getCartItemsUseCase;
  final ClearCartUseCase _clearCartUseCase;

  List<Map<String, dynamic>> _cartItems = [];
  List<CartItemEntity> _productsInCart = [];

  bool isInCart(String productId) =>
      _cartItems.any((item) => item['productId'] == productId);

  @override
  Future<void> addItemToCart(String productId) async {
    emit(CartLoading(newItemAdded: true));
    final result = await _addItemToCartUseCase.call(productId);
    switch (result) {
      case NetworkSuccess<void>():
        _addToCartItemsLocal(productId);
        await getProductsInCart(needLoading: false, newItemAdded: true);
      case NetworkFailure<void>():
        emit(CartFailure(getErrorMessage(result).tr()));
    }
  }

  @override
  Future<void> removeItemFromCart(String productId) async {
    emit(CartLoading(itemRemoved: true));
    final result = await _removeItemFromCartUseCase.call(productId);
    switch (result) {
      case NetworkSuccess<void>():
        _removeFromCartItemsLocal(productId);
        await getProductsInCart(needLoading: false, itemRemoved: true);
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

  Future<void> clearCart() async {
    emit(CartLoading());
    final result = await _clearCartUseCase.call();
    switch (result) {
      case NetworkSuccess<void>():
        _cartItems.clear();
        _productsInCart.clear();
        _emitCartSuccess();
      case NetworkFailure<void>():
        emit(CartFailure(getErrorMessage(result).tr()));
    }
  }

  Future<void> getProductsInCart({
    bool needLoading = true,
    bool newItemAdded = false,
    bool itemRemoved = false,
  }) async {
    if (needLoading) {
      emit(CartLoading());
    }
    final result = await _getProductsInCart.call(_cartItems);
    switch (result) {
      case NetworkSuccess<List<CartItemEntity>>():
        final items = result.data!;
        _productsInCart = items;
        _emitCartSuccess(newItemAdded: newItemAdded, itemRemoved: itemRemoved);
      case NetworkFailure<List<CartItemEntity>>():
        emit(CartFailure(getErrorMessage(result).tr()));
    }
  }

  @override
  Future<void> incrementItemQuantity(String productId) async {
    await _updateQuantityOptimistically(
      productId: productId,
      isIncrement: true,
    );
  }

  @override
  Future<void> decrementItemQuantity(String productId) async {
    await _updateQuantityOptimistically(
      productId: productId,
      isIncrement: false,
    );
  }

  Future<void> _updateQuantityOptimistically({
    required String productId,
    required bool isIncrement,
  }) async {
    final index = _productsInCart.indexWhere(
      (e) => e.fruitEntity.code == productId,
    );
    if (index == -1) return;

    final currentItem = _productsInCart[index];
    final int oldQuantity = currentItem.quantity;
    final int newQuantity = isIncrement ? oldQuantity + 1 : oldQuantity - 1;

    if (newQuantity == 0) {
      await removeItemFromCart(productId);
      return;
    }

    _updateLocalListQuantity(productId, newQuantity);
    _emitCartSuccess();

    final result = await _updateItemQuantityUseCase.call(
      productId: productId,
      newQuantity: newQuantity,
    );

    switch (result) {
      case NetworkSuccess<void>():
        break;

      case NetworkFailure<void>():
        _updateLocalListQuantity(productId, oldQuantity);
        _emitCartSuccess();
      // emit(CartFailure(getErrorMessage(result).tr()));
    }
  }

  // -----------------------------------------------

  void _removeFromCartItemsLocal(String productId) =>
      _cartItems.removeWhere((item) => item['fruitCode'] == productId);

  double _calculateTotalPrice(List<CartItemEntity> items) => items
      .map((e) => e.totalPrice)
      .fold(0, (value, element) => value + element);

  void _emitCartSuccess({bool newItemAdded = false, bool itemRemoved = false}) {
    emit(
      CartSuccess(
        items: List.from(_productsInCart),
        totalItemCount: _productsInCart.length,
        totalPrice: _calculateTotalPrice(_productsInCart),
        newItemAdded: newItemAdded,
        itemRemoved: itemRemoved,
      ),
    );
  }

  void _updateLocalListQuantity(String productId, int quantity) {
    final productIndex = _productsInCart.indexWhere(
      (e) => e.fruitEntity.code == productId,
    );
    if (productIndex != -1) {
      final oldItem = _productsInCart[productIndex];
      _productsInCart[productIndex] = CartItemEntity(
        fruitEntity: oldItem.fruitEntity,
        quantity: quantity,
      );
      _productsInCart[productIndex] = oldItem.copyWith(quantity: quantity);
    }
    final cartIndex = _cartItems.indexWhere((e) => e['fruitCode'] == productId);
    if (cartIndex != -1) {
      _cartItems[cartIndex]['quantity'] = quantity;
    }
  }

  void _addToCartItemsLocal(String productId) {
    int index = _cartItems.indexWhere(
      (element) => element['fruitCode'] == productId,
    );
    if (index != -1) {
      _cartItems[index]['quantity']++;
    } else {
      _cartItems.add({'fruitCode': productId, 'quantity': 1});
    }
  }
}
