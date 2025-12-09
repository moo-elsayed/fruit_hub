import 'package:fruit_hub/features/cart/data/data_sources/remote/cart_remote_data_source.dart';
import 'package:fruit_hub/core/entities/cart_item_entity.dart';
import 'package:fruit_hub/features/cart/domain/repo/cart_repo.dart';
import '../../../../core/helpers/network_response.dart';

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
  ) async => await _cartRemoteDataSource.getProductsInCart(cartItems);

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
