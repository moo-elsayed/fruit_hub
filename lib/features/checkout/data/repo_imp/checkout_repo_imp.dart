import 'package:fruit_hub/core/helpers/network_response.dart';
import 'package:fruit_hub/features/checkout/data/data_sources/remote/checkout_remote_data_source.dart';
import 'package:fruit_hub/features/checkout/domain/entities/order_entity.dart';
import 'package:fruit_hub/features/checkout/domain/entities/shipping_config_entity.dart';
import 'package:fruit_hub/features/checkout/domain/repo/checkout_repo.dart';

class CheckoutRepoImp implements CheckoutRepo {
  CheckoutRepoImp(this._checkoutRemoteDataSource);

  final CheckoutRemoteDataSource _checkoutRemoteDataSource;

  @override
  Future<NetworkResponse<ShippingConfigEntity>> fetchShippingConfig() async =>
      _checkoutRemoteDataSource.fetchShippingConfig();

  @override
  Future<NetworkResponse<void>> addOrder(OrderEntity order) async =>
      _checkoutRemoteDataSource.addOrder(order);
}
