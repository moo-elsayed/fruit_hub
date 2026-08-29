import 'package:fruit_hub/core/network/network_response.dart';
import '../../../../core/entities/cart_item_entity.dart';
import '../repo/cart_repo.dart';

class GetProductsInCartUseCase {
  GetProductsInCartUseCase(this._cartRepo);

  final CartRepo _cartRepo;

  Future<NetworkResponse<List<CartItemEntity>>> call() async =>
      await _cartRepo.getProductsInCart();
}
