import '../../../../../core/helpers/network_response.dart';
import '../../../../../core/services/payment/payment_input_entity.dart';
import '../../../../../core/services/payment/payment_output_entity.dart';
import '../../../domain/entities/order_entity.dart';
import '../../../domain/entities/shipping_config_entity.dart';

abstract class CheckoutRemoteDataSource {
  Future<NetworkResponse<ShippingConfigEntity>> fetchShippingConfig();

  Future<NetworkResponse<void>> addOrder(OrderEntity order);

  Future<NetworkResponse<PaymentOutputEntity>> makePayment(PaymentInputEntity input);
}
