import 'package:fruit_hub/core/entities/order_entity.dart';
import 'package:fruit_hub/core/network/network_response.dart';

import '../repo/orders_repo.dart';

class StreamOrderByIdUseCase {
  const StreamOrderByIdUseCase(this._ordersRepo);

  final OrdersRepo _ordersRepo;

  Stream<NetworkResponse<OrderEntity>> call(String orderId) =>
      _ordersRepo.streamOrderById(orderId);
}
