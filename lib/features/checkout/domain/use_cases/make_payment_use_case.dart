import 'package:fruit_hub/features/checkout/domain/repo/checkout_repo.dart';
import '../../../../core/helpers/network_response.dart';
import '../../../../core/services/payment/payment_input_entity.dart';
import '../../../../core/services/payment/payment_output_entity.dart';

class MakePaymentUseCase {
  MakePaymentUseCase(this._checkoutRepo);

  final CheckoutRepo _checkoutRepo;

  Future<NetworkResponse<PaymentOutputEntity>> call(
    PaymentInputEntity input,
  ) async => _checkoutRepo.makePayment(input);
}
