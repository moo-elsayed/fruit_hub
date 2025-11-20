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
  List<CartItemEntity> _productsInCart = [];

  bool isInCart(String productId) =>
      _cartItems.any((item) => item['productId'] == productId);

  @override
  Future<void> addItemToCart(String productId) async {
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
    final result = await _removeItemFromCartUseCase.call(productId);
    switch (result) {
      case NetworkSuccess<void>():
        _removeFromCartItemsLocal(productId);
        await getProductsInCart(needLoading: false);
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

  Future<void> getProductsInCart({
    bool needLoading = true,
    bool newItemAdded = false,
  }) async {
    if (needLoading) {
      emit(CartLoading());
    }
    final result = await _getProductsInCart.call(_cartItems);
    switch (result) {
      case NetworkSuccess<List<CartItemEntity>>():
        final items = result.data!;
        _productsInCart = items;
        _emitCartSuccess(newItemAdded);
      case NetworkFailure<List<CartItemEntity>>():
        emit(CartFailure(getErrorMessage(result).tr()));
    }
  }

  // @override
  // Future<void> decrementItemQuantity(String productId) async {
  //   final int newQuantity = _getNewQuantity(
  //     productId: productId,
  //     increment: false,
  //   );
  //   _productsInCart
  //           .firstWhere((element) => element.fruitEntity.code == productId)
  //           .quantity =
  //       newQuantity;
  //   if (newQuantity == 0) {
  //     await removeItemFromCart(productId);
  //     return;
  //   } else {
  //     emit(
  //       CartSuccess(
  //         items: _productsInCart,
  //         totalPrice: _calculateTotalPrice(_productsInCart),
  //         totalItemCount: _productsInCart.length,
  //       ),
  //     );
  //     final result = await _updateItemQuantityUseCase.call(
  //       productId: productId,
  //       newQuantity: newQuantity,
  //     );
  //     switch (result) {
  //       case NetworkSuccess<void>():
  //         // await getProductsInCart(false);
  //         break;
  //       case NetworkFailure<void>():
  //         _productsInCart
  //             .firstWhere((element) => element.fruitEntity.code == productId)
  //             .quantity = _getNewQuantity(
  //           productId: productId,
  //           increment: true,
  //         );
  //         emit(CartFailure(getErrorMessage(result).tr()));
  //     }
  //   }
  // }
  //
  // @override
  // Future<void> incrementItemQuantity(String productId) async {
  //   final int newQuantity = _getNewQuantity(productId: productId);
  //   _productsInCart
  //           .firstWhere((element) => element.fruitEntity.code == productId)
  //           .quantity =
  //       newQuantity;
  //   emit(
  //     CartSuccess(
  //       items: _productsInCart,
  //       totalPrice: _calculateTotalPrice(_productsInCart),
  //       totalItemCount: _productsInCart.length,
  //     ),
  //   );
  //   final result = await _updateItemQuantityUseCase.call(
  //     productId: productId,
  //     newQuantity: newQuantity,
  //   );
  //   switch (result) {
  //     case NetworkSuccess<void>():
  //       // await getProductsInCart(false);
  //       break;
  //     case NetworkFailure<void>():
  //       _productsInCart
  //           .firstWhere((element) => element.fruitEntity.code == productId)
  //           .quantity = _getNewQuantity(
  //         productId: productId,
  //         increment: false,
  //       );
  //       emit(CartFailure(getErrorMessage(result).tr()));
  //   }
  // }

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

  void _emitCartSuccess([bool newItemAdded = false]) {
    emit(
      CartSuccess(
        items: List.from(_productsInCart),
        totalItemCount: _productsInCart.length,
        totalPrice: _calculateTotalPrice(_productsInCart),
        newItemAdded: newItemAdded,
      ),
    );
  }

  void _updateLocalListQuantity(String productId, int quantity) {
    final productIndex = _productsInCart.indexWhere(
      (e) => e.fruitEntity.code == productId,
    );
    if (productIndex != -1) {
      _productsInCart[productIndex].quantity = quantity;
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
