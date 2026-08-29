import 'package:fruit_hub/core/entities/cart_item_entity.dart';
import 'package:fruit_hub/core/network/network_response.dart';

abstract class CartRemoteDataSource {
  Future<NetworkResponse<void>> addItemToCart(
    String productId, {
    int quantity = 1,
  });

  Future<NetworkResponse<void>> removeItemFromCart(String productId);

  Future<NetworkResponse<List<CartItemEntity>>> getProductsInCart();

  Future<NetworkResponse<void>> updateItemQuantity({
    required String productId,
    required int newQuantity,
  });

  Future<NetworkResponse<void>> clearCart();
}
