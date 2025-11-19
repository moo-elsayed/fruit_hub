import 'package:fruit_hub/features/cart/domain/repo/cart_repo.dart';
import '../../../../core/helpers/network_response.dart';

class GetCartItemsUseCase {
  GetCartItemsUseCase(this._cartRepo);

  final CartRepo _cartRepo;

  Future<NetworkResponse<List<Map<String, dynamic>>>> call() async =>
      _cartRepo.getCartItems();
}
