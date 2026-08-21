import 'package:fruit_hub/core/entities/cart_item_entity.dart';
import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/features/cart/data/data_sources/remote/cart_remote_data_source.dart';
import 'package:fruit_hub/features/cart/domain/repo/cart_repo.dart';
import 'package:fruit_hub/shared_data/models/fruit_model.dart';

class CartRepoImp implements CartRepo {
  CartRepoImp(this._cartRemoteDataSource);

  final CartRemoteDataSource _cartRemoteDataSource;

  @override
  Future<NetworkResponse<void>> addItemToCart(String productId) async =>
      await _cartRemoteDataSource.addItemToCart(productId);

  @override
  Future<NetworkResponse<void>> removeItemFromCart(String productId) async =>
      await _cartRemoteDataSource.removeItemFromCart(productId);

  @override
  Future<NetworkResponse<List<CartItemEntity>>> getProductsInCart(
    List<Map<String, dynamic>> cartItems,
  ) async {
    if (cartItems.isEmpty) {
      return const NetworkSuccess([]);
    }
    final productIds = cartItems.map((e) => e['fruitCode'] as String).toList();
    final response = await _cartRemoteDataSource.getCartProducts(productIds);
    switch (response) {
      case NetworkSuccess<List<FruitModel>>():
        final List<FruitModel> productModels = response.data ?? [];
        final List<CartItemEntity> cartItemsList = [];
        for (final productModel in productModels) {
          final cartItemMap = cartItems.firstWhere(
            (element) => element['fruitCode'] == productModel.code,
          );
          cartItemsList.add(
            CartItemEntity(
              quantity: cartItemMap['quantity'] as int,
              fruitEntity: productModel.toEntity(),
            ),
          );
        }
        return NetworkSuccess(cartItemsList);
      case NetworkFailure<List<FruitModel>>():
        return NetworkFailure(response.failure);
    }
  }

  @override
  Future<NetworkResponse<void>> updateItemQuantity({
    required String productId,
    required int newQuantity,
  }) async => await _cartRemoteDataSource.updateItemQuantity(
    productId: productId,
    newQuantity: newQuantity,
  );

  @override
  Future<NetworkResponse<List<Map<String, dynamic>>>> getCartItems() async =>
      _cartRemoteDataSource.getCartItems();

  @override
  Future<NetworkResponse<void>> clearCart() async =>
      _cartRemoteDataSource.clearCart();
}
