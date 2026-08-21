import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/shared_data/models/fruit_model.dart';

abstract class CartRemoteDataSource {
  Future<NetworkResponse<void>> addItemToCart(String productId);

  Future<NetworkResponse<void>> removeItemFromCart(String productId);

  Future<NetworkResponse<List<Map<String, dynamic>>>> getCartItems();

  Future<NetworkResponse<List<FruitModel>>> getCartProducts(
    List<String> productIds,
  );

  Future<NetworkResponse<void>> updateItemQuantity({
    required String productId,
    required int newQuantity,
  });

  Future<NetworkResponse<void>> clearCart();
}
