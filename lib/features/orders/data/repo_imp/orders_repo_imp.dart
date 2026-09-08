import 'package:fruit_hub/core/entities/order_entity.dart';
import 'package:fruit_hub/core/errors/failures.dart';
import 'package:fruit_hub/core/network/api_helper.dart';
import 'package:fruit_hub/core/network/network_response.dart';

import '../../domain/repo/orders_repo.dart';
import '../data_sources/remote/orders_remote_data_source.dart';

class OrdersRepoImp implements OrdersRepo {
  const OrdersRepoImp(this._remoteDataSource);

  final OrdersRemoteDataSource _remoteDataSource;

  @override
  Stream<NetworkResponse<List<OrderEntity>>> streamUserOrders() =>
      _remoteDataSource
          .streamUserOrders()
          .map<NetworkResponse<List<OrderEntity>>>(
            (models) =>
                NetworkSuccess(models.map((m) => m.toEntity()).toList()),
          )
          .handleError(
            (error) => NetworkFailure<List<OrderEntity>>(
              ServerFailure.fromException(error),
            ),
          );

  @override
  Stream<NetworkResponse<OrderEntity>> streamOrderById(String orderId) =>
      _remoteDataSource
          .streamOrderById(orderId)
          .map<NetworkResponse<OrderEntity>>(
            (model) => NetworkSuccess(model.toEntity()),
          )
          .handleError(
            (error) =>
                NetworkFailure<OrderEntity>(ServerFailure.fromException(error)),
          );

  @override
  Future<NetworkResponse<void>> cancelOrder(String docId) =>
      ApiHelper.executeSafely(
        () => _remoteDataSource.cancelOrder(docId),
        functionName: 'cancelOrder',
      );
}
