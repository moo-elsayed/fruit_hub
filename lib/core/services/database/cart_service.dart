
abstract class CartService {
  Future<void> addItemToCart(String productId);

  Future<void> removeItemFromCart(String productId);

  Future<void> incrementItemQuantity(String productId);

  Future<void> decrementItemQuantity(String productId);
}
