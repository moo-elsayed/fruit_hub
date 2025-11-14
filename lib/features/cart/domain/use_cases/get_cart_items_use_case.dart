import '../../../../core/helpers/network_response.dart';
import '../entities/cart_item_entity.dart';
import '../repo/cart_repo.dart';

class GetCartItemsUseCase {
  GetCartItemsUseCase(this._cartRepo);

  final CartRepo _cartRepo;

  Future<NetworkResponse<List<CartItemEntity>>> call() async =>
      await _cartRepo.getCartItems();
}
