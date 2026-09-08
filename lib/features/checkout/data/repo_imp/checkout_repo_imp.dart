import 'package:fruit_hub/core/entities/order_entity.dart';
import 'package:fruit_hub/core/models/order_model.dart';
import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/features/checkout/data/data_sources/remote/checkout_remote_data_source.dart';
import 'package:fruit_hub/features/checkout/data/models/payment_input_model.dart';
import 'package:fruit_hub/features/checkout/data/models/payment_output_model.dart';
import 'package:fruit_hub/features/checkout/data/models/shipping_config_model.dart';
import 'package:fruit_hub/features/checkout/domain/entities/payment_input_entity.dart';
import 'package:fruit_hub/features/checkout/domain/entities/payment_output_entity.dart';
import 'package:fruit_hub/features/checkout/domain/entities/shipping_config_entity.dart';
import 'package:fruit_hub/features/checkout/domain/repo/checkout_repo.dart';

class CheckoutRepoImp implements CheckoutRepo {
  CheckoutRepoImp(this._checkoutRemoteDataSource);

  final CheckoutRemoteDataSource _checkoutRemoteDataSource;

  @override
  Future<NetworkResponse<ShippingConfigEntity>> fetchShippingConfig() async {
    final response = await _checkoutRemoteDataSource.fetchShippingConfig();
    switch (response) {
      case NetworkSuccess<ShippingConfigModel>():
        return NetworkSuccess(response.data!.toEntity());
      case NetworkFailure<ShippingConfigModel>():
        return NetworkFailure(response.failure);
    }
  }

  @override
  Future<NetworkResponse<void>> addOrder(OrderEntity order) async {
    final model = OrderModel.fromEntity(order);
    return await _checkoutRemoteDataSource.addOrder(model);
  }

  @override
  Future<NetworkResponse<PaymentOutputEntity>> makePayment(
    PaymentInputEntity input,
  ) async {
    final model = PaymentInputModel.fromEntity(input);
    final response = await _checkoutRemoteDataSource.makePayment(model);
    switch (response) {
      case NetworkSuccess<PaymentOutputModel>():
        return NetworkSuccess(response.data!.toEntity());
      case NetworkFailure<PaymentOutputModel>():
        return NetworkFailure(response.failure);
    }
  }
}
