import 'package:fruit_hub/core/network/network_response.dart';

import '../repo/orders_repo.dart';

class CancelOrderUseCase {
  const CancelOrderUseCase(this._ordersRepo);

  final OrdersRepo _ordersRepo;

  Future<NetworkResponse<void>> call(String docId) =>
      _ordersRepo.cancelOrder(docId);
}
