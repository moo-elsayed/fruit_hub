import 'package:fruit_hub/core/helpers/network_response.dart';
import 'package:fruit_hub/features/cart/domain/repo/cart_repo.dart';

class AddItemToCartUseCase {
  AddItemToCartUseCase(this._cartRepo);

  final CartRepo _cartRepo;

  Future<NetworkResponse<void>> call(String productId) async =>
      _cartRepo.addItemToCart(productId);
}
