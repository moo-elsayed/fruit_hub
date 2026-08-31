import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fruit_hub/core/entities/cart_item_entity.dart';
import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/features/cart/domain/use_cases/add_item_to_cart_use_case.dart';
import 'package:fruit_hub/features/cart/domain/use_cases/clear_cart_use_case.dart';
import 'package:fruit_hub/features/cart/domain/use_cases/get_products_in_cart_use_case.dart';
import 'package:fruit_hub/features/cart/domain/use_cases/remove_item_from_cart_use_case.dart';
import 'package:fruit_hub/features/cart/domain/use_cases/update_item_quantity_use_case.dart';

part 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  CartCubit(
    this._addItemToCartUseCase,
    this._removeItemFromCartUseCase,
    this._getProductsInCart,
    this._updateItemQuantityUseCase,
    this._clearCartUseCase,
  ) : super(CartInitial());

  final AddItemToCartUseCase _addItemToCartUseCase;
  final RemoveItemFromCartUseCase _removeItemFromCartUseCase;
  final GetProductsInCartUseCase _getProductsInCart;
  final UpdateItemQuantityUseCase _updateItemQuantityUseCase;
  final ClearCartUseCase _clearCartUseCase;

  List<CartItemEntity> _productsInCart = [];
  final Map<String, Timer> _debounceTimers = {};
  final Map<String, int> _serverSyncedQuantities = {};

  bool isInCart(String productId) =>
      _productsInCart.any((item) => item.fruitEntity.code == productId);

  CartItemEntity? getCartItem(String productId) {
    final index = _productsInCart.indexWhere(
      (item) => item.fruitEntity.code == productId,
    );
    return index != -1 ? _productsInCart[index] : null;
  }

  List<CartItemEntity> get productsInCart => _productsInCart;

  Future<void> addItemToCart(FruitEntity fruit, {int quantity = 1}) async {
    final productId = fruit.code;

    // Check if the item is already in the cart
    if (isInCart(productId)) {
      _emitCartSuccess(itemAlreadyExists: true);
      return;
    }

    // 1. Optimistic Local Update (0ms)
    _productsInCart.add(CartItemEntity(fruitEntity: fruit, quantity: quantity));
    _emitCartSuccess(newItemAdded: true);

    // 2. Background server call
    final result = await _addItemToCartUseCase.call(
      productId,
      quantity: quantity,
    );
    if (result is NetworkFailure<void>) {
      // Revert on failure
      _productsInCart.removeWhere((item) => item.fruitEntity.code == productId);
      _emitCartSuccess();
      emit(CartFailure(result.error));
    }
  }

  Future<void> removeItemFromCart(String productId) async {
    _debounceTimers[productId]?.cancel();
    _debounceTimers.remove(productId);
    _serverSyncedQuantities.remove(productId);

    final int index = _productsInCart.indexWhere(
      (item) => item.fruitEntity.code == productId,
    );
    if (index == -1) return;

    final removedItem = _productsInCart[index];

    // 1. Optimistic Local Removal (0ms)
    _productsInCart.removeAt(index);
    _emitCartSuccess(itemRemoved: true);

    // 2. Background server call
    final result = await _removeItemFromCartUseCase.call(productId);
    if (result is NetworkFailure<void>) {
      // Revert on failure
      _productsInCart.insert(index, removedItem);
      _emitCartSuccess();
      emit(CartFailure(result.error));
    }
  }

  Future<void> clearCart() async {
    for (final timer in _debounceTimers.values) {
      timer.cancel();
    }
    _debounceTimers.clear();
    _serverSyncedQuantities.clear();

    emit(CartLoading());
    final result = await _clearCartUseCase.call();
    switch (result) {
      case NetworkSuccess<void>():
        _productsInCart.clear();
        _emitCartSuccess();
      case NetworkFailure<void>():
        emit(CartFailure(result.error));
    }
  }

  Future<void> getProductsInCart({bool needLoading = true}) async {
    if (_productsInCart.isNotEmpty) {
      _emitCartSuccess();
      return;
    }
    if (needLoading) {
      emit(CartLoading());
    }
    final result = await _getProductsInCart.call();
    switch (result) {
      case NetworkSuccess<List<CartItemEntity>>():
        _productsInCart = result.data!;
        _emitCartSuccess();
      case NetworkFailure<List<CartItemEntity>>():
        emit(CartFailure(result.error));
    }
  }

  void incrementItemQuantity(String productId) =>
      _updateQuantityOptimistically(productId: productId, isIncrement: true);

  void decrementItemQuantity(String productId) =>
      _updateQuantityOptimistically(productId: productId, isIncrement: false);

  void _updateQuantityOptimistically({
    required String productId,
    required bool isIncrement,
  }) {
    final index = _productsInCart.indexWhere(
      (e) => e.fruitEntity.code == productId,
    );
    if (index == -1) return;

    final currentItem = _productsInCart[index];
    final int currentQuantity = currentItem.quantity;
    final int newQuantity = isIncrement
        ? currentQuantity + 1
        : currentQuantity - 1;

    if (newQuantity == 0) {
      removeItemFromCart(productId);
      return;
    }

    // Save the baseline server-synced quantity before debounce sequence starts
    _serverSyncedQuantities.putIfAbsent(productId, () => currentQuantity);

    // 1. Instant optimistic local update (0ms UI latency)
    _updateLocalListQuantity(productId, newQuantity);
    _emitCartSuccess();

    // 2. Debounce server sync
    _debounceTimers[productId]?.cancel();
    _debounceTimers[productId] = Timer(
      const Duration(milliseconds: 500),
      () async {
        _debounceTimers.remove(productId);

        final itemIndex = _productsInCart.indexWhere(
          (e) => e.fruitEntity.code == productId,
        );
        if (itemIndex == -1) return;
        final targetQuantity = _productsInCart[itemIndex].quantity;

        final result = await _updateItemQuantityUseCase.call(
          productId: productId,
          newQuantity: targetQuantity,
        );

        switch (result) {
          case NetworkSuccess<void>():
            _serverSyncedQuantities.remove(productId);
          case NetworkFailure<void>():
            final fallbackQuantity =
                _serverSyncedQuantities.remove(productId) ?? currentQuantity;
            _updateLocalListQuantity(productId, fallbackQuantity);
            _emitCartSuccess();
            emit(CartFailure(result.error));
        }
      },
    );
  }

  // -----------------------------------------------

  double _calculateTotalPrice(List<CartItemEntity> items) => items
      .map((e) => e.totalPrice)
      .fold(0, (value, element) => value + element);

  void _emitCartSuccess({
    bool newItemAdded = false,
    bool itemRemoved = false,
    bool itemAlreadyExists = false,
  }) {
    emit(
      CartSuccess(
        items: List.from(_productsInCart),
        totalItemCount: _productsInCart.length,
        totalPrice: _calculateTotalPrice(_productsInCart),
        newItemAdded: newItemAdded,
        itemRemoved: itemRemoved,
        itemAlreadyExists: itemAlreadyExists,
      ),
    );
  }

  void _updateLocalListQuantity(String productId, int quantity) {
    final productIndex = _productsInCart.indexWhere(
      (e) => e.fruitEntity.code == productId,
    );
    if (productIndex != -1) {
      final oldItem = _productsInCart[productIndex];
      _productsInCart[productIndex] = oldItem.copyWith(quantity: quantity);
    }
  }

  @override
  Future<void> close() {
    for (final timer in _debounceTimers.values) {
      timer.cancel();
    }
    _debounceTimers.clear();
    _serverSyncedQuantities.clear();
    return super.close();
  }
}
