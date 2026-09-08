import 'package:fruit_hub/core/models/order_model.dart';

abstract class OrdersRemoteDataSource {
  Stream<List<OrderModel>> streamUserOrders();

  Stream<OrderModel> streamOrderById(String orderId);

  Future<void> cancelOrder(String docId);
}
