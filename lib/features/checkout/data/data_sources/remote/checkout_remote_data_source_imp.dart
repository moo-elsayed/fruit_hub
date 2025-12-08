import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fruit_hub/core/helpers/backend_endpoints.dart';
import 'package:fruit_hub/core/helpers/network_response.dart';
import 'package:fruit_hub/core/services/database/database_service.dart';
import 'package:fruit_hub/features/checkout/data/data_sources/remote/checkout_remote_data_source.dart';
import 'package:fruit_hub/features/checkout/data/models/order_model.dart';
import 'package:fruit_hub/features/checkout/domain/entities/order_entity.dart';
import '../../../../../core/helpers/app_logger.dart';
import '../../../../../core/helpers/failures.dart';
import '../../../domain/entities/shipping_config_entity.dart';
import '../../models/shipping_config_model.dart';

class CheckoutRemoteDataSourceImp implements CheckoutRemoteDataSource {
  CheckoutRemoteDataSourceImp(this._databaseService);

  final DatabaseService _databaseService;

  @override
  Future<NetworkResponse<ShippingConfigEntity>> fetchShippingConfig() async {
    try {
      var response = await _databaseService.getData(
        path: BackendEndpoints.fetchShippingCost,
        documentId: BackendEndpoints.shippingConfigId,
      );
      var shippingConfigEntity = ShippingConfigModel.fromJson(
        response,
      ).toEntity();
      return NetworkSuccess(shippingConfigEntity);
    } on FirebaseException catch (e) {
      return _handleError(e, "fetchShippingConfig");
    } catch (e) {
      return _handleError(e, "fetchShippingConfig");
    }
  }

  @override
  Future<NetworkResponse<void>> addOrder(OrderEntity order) async {
    try {
      OrderModel orderModel = OrderModel.fromEntity(order);
      await _databaseService.addData(
        path: BackendEndpoints.addOrder,
        data: orderModel.toJson(),
      );
      return const NetworkSuccess();
    } on FirebaseException catch (e) {
      return _handleError(e, "addOrder");
    } catch (e) {
      return _handleError(e, "addOrder");
    }
  }

  // ------------------------------------

  NetworkFailure<T> _handleError<T>(Object e, String functionName) {
    AppLogger.error("error occurred in $functionName", error: e);
    if (e is FirebaseException) {
      return NetworkFailure(
        Exception(ServerFailure.fromFirebaseException(e).errorMessage),
      );
    }
    return NetworkFailure(Exception("error_occurred_please_try_again"));
  }
}
