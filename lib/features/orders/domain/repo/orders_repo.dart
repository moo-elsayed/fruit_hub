import 'package:fruit_hub/core/entities/order_entity.dart';
import 'package:fruit_hub/core/network/network_response.dart';

abstract class OrdersRepo {
  Stream<NetworkResponse<List<OrderEntity>>> streamUserOrders();

  Stream<NetworkResponse<OrderEntity>> streamOrderById(String orderId);

  Future<NetworkResponse<void>> cancelOrder(String docId);
}
