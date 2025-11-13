import 'package:fruit_hub/core/helpers/network_response.dart';
import 'package:fruit_hub/features/cart/domain/repo/cart_repo.dart';
import '../entities/cart_item_entity.dart';

class AddItemToCartUseCase {
  AddItemToCartUseCase(this._cartRepo);

  final CartRepo _cartRepo;

  Future<NetworkResponse<void>> call(CartItemEntity item) async =>
      _cartRepo.addItemToCart(item);
}
