import '../../../../core/helpers/network_response.dart';
import '../repo/cart_repo.dart';

class RemoveItemFromCartUseCase {
  RemoveItemFromCartUseCase(this._cartRepo);

  final CartRepo _cartRepo;

  Future<NetworkResponse<void>> call(String productId) async =>
      _cartRepo.removeItemFromCart(productId);
}
