import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/features/checkout/domain/repo/checkout_repo.dart';
import '../entities/shipping_config_entity.dart';

class FetchShippingConfigUseCase {
  FetchShippingConfigUseCase(this._checkoutRepo);

  final CheckoutRepo _checkoutRepo;

  Future<NetworkResponse<ShippingConfigEntity>> call() async =>
      _checkoutRepo.fetchShippingConfig();
}
