import 'package:fruit_hub/core/helpers/network_response.dart';
import 'package:fruit_hub/features/checkout/domain/entities/order_entity.dart';
import '../../../../core/services/payment/payment_input_entity.dart';
import '../../../../core/services/payment/payment_output_entity.dart';
import '../entities/shipping_config_entity.dart';

abstract class CheckoutRepo {
  Future<NetworkResponse<ShippingConfigEntity>> fetchShippingConfig();

  Future<NetworkResponse<void>> addOrder(OrderEntity order);

  Future<NetworkResponse<PaymentOutputEntity>> makePayment(
    PaymentInputEntity input,
  );
}
