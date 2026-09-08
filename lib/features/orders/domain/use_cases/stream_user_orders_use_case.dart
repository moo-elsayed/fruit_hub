import 'package:fruit_hub/core/entities/order_entity.dart';
import 'package:fruit_hub/core/network/network_response.dart';

import '../repo/orders_repo.dart';

class StreamUserOrdersUseCase {
  const StreamUserOrdersUseCase(this._ordersRepo);

  final OrdersRepo _ordersRepo;

  Stream<NetworkResponse<List<OrderEntity>>> call() =>
      _ordersRepo.streamUserOrders();
}
