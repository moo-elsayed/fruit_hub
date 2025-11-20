import '../../../../core/helpers/network_response.dart';
import '../entities/cart_item_entity.dart';
import '../repo/cart_repo.dart';

class GetProductsInCartUseCase {
  GetProductsInCartUseCase(this._cartRepo);

  final CartRepo _cartRepo;

  Future<NetworkResponse<List<CartItemEntity>>> call(
    List<Map<String, dynamic>> cartItems,
  ) async => await _cartRepo.getProductsInCart(cartItems);
}
