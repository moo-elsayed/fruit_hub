import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/core/services/payment/payment_input_entity.dart';
import 'package:fruit_hub/core/services/payment/payment_output_entity.dart';
import '../../models/order_model.dart';
import '../../models/shipping_config_model.dart';

abstract class CheckoutRemoteDataSource {
  Future<NetworkResponse<ShippingConfigModel>> fetchShippingConfig();

  Future<NetworkResponse<void>> addOrder(OrderModel order);

  Future<NetworkResponse<PaymentOutputEntity>> makePayment(
    PaymentInputEntity input,
  );
}
