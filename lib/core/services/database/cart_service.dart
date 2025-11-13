import '../../../features/cart/domain/entities/cart_item_entity.dart';

abstract class CartService {
  Future<void> addItemToCart(CartItemEntity item);

  Future<void> removeItemFromCart(String productId);
}
