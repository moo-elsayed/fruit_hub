import 'package:fruit_hub/core/services/payment/payment_input_entity.dart';
import 'package:fruit_hub/core/services/payment/payment_output_entity.dart';

abstract class PaymentService {
  Future<PaymentOutputEntity> makePayment(PaymentInputEntity input);
}
