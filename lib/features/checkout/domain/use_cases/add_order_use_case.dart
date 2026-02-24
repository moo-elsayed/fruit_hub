import 'package:fruit_hub/features/checkout/domain/repo/checkout_repo.dart';
import '../../../../core/helpers/network_response.dart';
import '../entities/order_entity.dart';

class AddOrderUseCase {
  AddOrderUseCase(this._checkoutRepo);

  final CheckoutRepo _checkoutRepo;

  Future<NetworkResponse<void>> call(OrderEntity order) async =>
      _checkoutRepo.addOrder(order);
}
