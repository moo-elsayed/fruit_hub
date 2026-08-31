import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/features/checkout/domain/entities/payment_input_entity.dart';
import 'package:fruit_hub/features/checkout/domain/entities/payment_output_entity.dart';
import 'package:fruit_hub/features/checkout/domain/repo/checkout_repo.dart';

class MakePaymentUseCase {
  MakePaymentUseCase(this._checkoutRepo);

  final CheckoutRepo _checkoutRepo;

  Future<NetworkResponse<PaymentOutputEntity>> call(
    PaymentInputEntity input,
  ) async => _checkoutRepo.makePayment(input);
}
