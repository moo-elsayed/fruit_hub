import 'package:fruit_hub/features/cart/domain/repo/cart_repo.dart';
import '../../../../core/helpers/network_response.dart';

class ClearCartUseCase {
  ClearCartUseCase(this._cartRepo);

  final CartRepo _cartRepo;

  Future<NetworkResponse<void>> call() async => await _cartRepo.clearCart();
}
