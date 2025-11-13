import '../../../../core/helpers/network_response.dart';
import '../../domain/entities/cart_item_entity.dart';

abstract class CartRemoteDataSource {
  Future<NetworkResponse<void>> addItemToCart(CartItemEntity item);

  Future<NetworkResponse<void>> removeItemFromCart(String productId);
}
