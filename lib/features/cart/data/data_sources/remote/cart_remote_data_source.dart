import '../../../../../core/helpers/network_response.dart';
import '../../../../../core/entities/cart_item_entity.dart';

abstract class CartRemoteDataSource {
  Future<NetworkResponse<void>> addItemToCart(String productId);

  Future<NetworkResponse<void>> removeItemFromCart(String productId);

  Future<NetworkResponse<List<Map<String, dynamic>>>> getCartItems();

  Future<NetworkResponse<List<CartItemEntity>>> getProductsInCart(
    List<Map<String, dynamic>> cartItems,
  );

  Future<NetworkResponse<void>> updateItemQuantity({
    required String productId,
    required int newQuantity,
  });
}
