import 'package:fruit_hub/core/network/network_response.dart';
import '../../models/order_model.dart';
import '../../models/payment_input_model.dart';
import '../../models/payment_output_model.dart';
import '../../models/shipping_config_model.dart';

abstract class CheckoutRemoteDataSource {
  Future<NetworkResponse<ShippingConfigModel>> fetchShippingConfig();

  Future<NetworkResponse<void>> addOrder(OrderModel order);

  Future<NetworkResponse<PaymentOutputModel>> makePayment(
    PaymentInputModel input,
  );
}
