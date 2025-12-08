import '../../../../../core/helpers/network_response.dart';
import '../../../domain/entities/order_entity.dart';
import '../../../domain/entities/shipping_config_entity.dart';

abstract class CheckoutRemoteDataSource {
  Future<NetworkResponse<ShippingConfigEntity>> fetchShippingConfig();

  Future<NetworkResponse<void>> addOrder(OrderEntity order);
}
