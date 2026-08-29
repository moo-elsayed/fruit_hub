import 'package:fruit_hub/core/entities/cart_item_entity.dart';
import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/features/cart/data/data_sources/remote/cart_remote_data_source.dart';
import 'package:fruit_hub/features/cart/domain/repo/cart_repo.dart';

class CartRepoImp implements CartRepo {
  CartRepoImp(this._cartRemoteDataSource);

  final CartRemoteDataSource _cartRemoteDataSource;

  @override
  Future<NetworkResponse<void>> addItemToCart(
    String productId, {
    int quantity = 1,
  }) async =>
      await _cartRemoteDataSource.addItemToCart(productId, quantity: quantity);

  @override
  Future<NetworkResponse<void>> removeItemFromCart(String productId) async =>
      await _cartRemoteDataSource.removeItemFromCart(productId);

  @override
  Future<NetworkResponse<List<CartItemEntity>>> getProductsInCart() async =>
      await _cartRemoteDataSource.getProductsInCart();

  @override
  Future<NetworkResponse<void>> updateItemQuantity({
    required String productId,
    required int newQuantity,
  }) async => await _cartRemoteDataSource.updateItemQuantity(
    productId: productId,
    newQuantity: newQuantity,
  );

  @override
  Future<NetworkResponse<void>> clearCart() async =>
      _cartRemoteDataSource.clearCart();
}
