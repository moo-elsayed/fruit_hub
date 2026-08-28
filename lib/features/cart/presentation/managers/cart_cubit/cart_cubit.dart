import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fruit_hub/core/entities/cart_item_entity.dart';
import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/features/cart/domain/use_cases/add_item_to_cart_use_case.dart';
import 'package:fruit_hub/features/cart/domain/use_cases/clear_cart_use_case.dart';
import 'package:fruit_hub/features/cart/domain/use_cases/get_cart_items_use_case.dart';
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
      _cartItems.any((item) => item['fruitCode'] == productId || item['productId'] == productId) ||
      _productsInCart.any((item) => item.fruitEntity.code == productId);

  List<CartItemEntity> get productsInCart => _productsInCart;
  List<Map<String, dynamic>> get cartItems => _cartItems;

  Future<void> addItemToCart(FruitEntity fruit) async {
    final productId = fruit.code;

    // Check if the item is already in the cart
    if (isInCart(productId)) {
      _emitCartSuccess(itemAlreadyExists: true);
      return;
    }

    // 1. Optimistic Local Update (0ms)
    _productsInCart.add(CartItemEntity(fruitEntity: fruit, quantity: 1));
    _addToCartItemsLocal(productId);
    _emitCartSuccess(newItemAdded: true);

    // 2. Background server call
    final result = await _addItemToCartUseCase.call(productId);
    switch (result) {
      case NetworkSuccess<void>():
        break;
      case NetworkFailure<void>():
        // Revert on failure
        _productsInCart.removeWhere(
          (item) => item.fruitEntity.code == productId,
        );
        _removeFromCartItemsLocal(productId);
        _emitCartSuccess();
        emit(CartFailure(result.error));
    }
  }

  Future<void> removeItemFromCart(String productId) async {
    final int index = _productsInCart.indexWhere(
      (item) => item.fruitEntity.code == productId,
    );
    if (index == -1) return;

    final removedItem = _productsInCart[index];
    final cartItemIndex = _cartItems.indexWhere(
      (item) => item['fruitCode'] == productId,
    );
    final removedCartItem = cartItemIndex != -1
        ? Map<String, dynamic>.from(_cartItems[cartItemIndex])
        : null;

    // 1. Optimistic Local Removal (0ms)
    _productsInCart.removeAt(index);
    _removeFromCartItemsLocal(productId);
    _emitCartSuccess(itemRemoved: true);

    // 2. Background server call
    final result = await _removeItemFromCartUseCase.call(productId);
    switch (result) {
      case NetworkSuccess<void>():
        break;
      case NetworkFailure<void>():
        // Revert on failure
        _productsInCart.insert(index, removedItem);
        if (removedCartItem != null) {
          _cartItems.add(removedCartItem);
        }
        _emitCartSuccess();
        emit(CartFailure(result.error));
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
        emit(GetCartItemsFailure(result.error));
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
    if (_cartItems.isEmpty) {
      final cartItemsResult = await _getCartItemsUseCase.call();
      if (cartItemsResult is NetworkSuccess<List<Map<String, dynamic>>>) {
        _cartItems = cartItemsResult.data!;
      }
    }
    if (_cartItems.isEmpty) {
      _productsInCart = [];
      _emitCartSuccess();
      return;
    }
    final result = await _getProductsInCart.call(_cartItems);
    switch (result) {
      case NetworkSuccess<List<CartItemEntity>>():
        _productsInCart = result.data!;
        _emitCartSuccess();
      case NetworkFailure<List<CartItemEntity>>():
        emit(CartFailure(result.error));
    }
  }

  Future<void> incrementItemQuantity(String productId) async {
    await _updateQuantityOptimistically(
      productId: productId,
      isIncrement: true,
    );
  }

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
      // emit(CartFailure(result.error));
    }
  }

  // -----------------------------------------------

  void _removeFromCartItemsLocal(String productId) =>
      _cartItems.removeWhere((item) => item['fruitCode'] == productId);

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
    final int index = _cartItems.indexWhere(
      (element) => element['fruitCode'] == productId,
    );
    if (index != -1) {
      _cartItems[index]['quantity']++;
    } else {
      _cartItems.add({'fruitCode': productId, 'quantity': 1});
    }
  }
}
