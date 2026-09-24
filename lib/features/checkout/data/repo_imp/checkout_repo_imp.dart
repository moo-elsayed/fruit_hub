import 'package:fruit_hub/core/entities/order_entity.dart';
import 'package:fruit_hub/core/models/order_model.dart';
import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/features/checkout/data/data_sources/remote/checkout_remote_data_source.dart';
import 'package:fruit_hub/features/checkout/data/models/payment_input_model.dart';
import 'package:fruit_hub/features/checkout/data/models/shipping_config_model.dart';
import 'package:fruit_hub/features/checkout/domain/entities/payment_input_entity.dart';
import 'package:fruit_hub/features/checkout/domain/entities/shipping_config_entity.dart';
import 'package:fruit_hub/features/checkout/domain/repo/checkout_repo.dart';

class CheckoutRepoImp implements CheckoutRepo {
  CheckoutRepoImp(this._checkoutRemoteDataSource);

  final CheckoutRemoteDataSource _checkoutRemoteDataSource;

  ShippingConfigEntity? _cachedShippingConfig;

  @override
  Future<NetworkResponse<ShippingConfigEntity>> fetchShippingConfig() async {
    if (_cachedShippingConfig != null) {
      return NetworkSuccess(_cachedShippingConfig!);
    }
    final response = await _checkoutRemoteDataSource.fetchShippingConfig();
    switch (response) {
      case NetworkSuccess<ShippingConfigModel>():
        _cachedShippingConfig = response.data!.toEntity();
        return NetworkSuccess(_cachedShippingConfig!);
      case NetworkFailure<ShippingConfigModel>():
        return NetworkFailure(response.failure);
    }
  }

  @override
  Future<NetworkResponse<void>> addOrder(OrderEntity order) =>
      _checkoutRemoteDataSource.addOrder(OrderModel.fromEntity(order));

  @override
  Future<NetworkResponse<void>> makePayment(PaymentInputEntity input) =>
      _checkoutRemoteDataSource.makePayment(
        PaymentInputModel.fromEntity(input),
      );
}
