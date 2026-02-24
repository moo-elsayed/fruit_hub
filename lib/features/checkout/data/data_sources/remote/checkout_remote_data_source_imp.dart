import 'package:firebase_auth/firebase_auth.dart';
import 'package:fruit_hub/core/helpers/backend_endpoints.dart';
import 'package:fruit_hub/core/helpers/network_response.dart';
import 'package:fruit_hub/core/services/database/database_service.dart';
import 'package:fruit_hub/core/services/payment/payment_input_entity.dart';
import 'package:fruit_hub/core/services/payment/payment_service.dart';
import 'package:fruit_hub/features/checkout/data/data_sources/remote/checkout_remote_data_source.dart';
import 'package:fruit_hub/features/checkout/data/models/order_model.dart';
import 'package:fruit_hub/features/checkout/domain/entities/order_entity.dart';
import 'package:fruit_hub/shared_data/services/payment/payment_input_model.dart';
import '../../../../../core/helpers/app_logger.dart';
import '../../../../../core/helpers/failures.dart';
import '../../../../../core/services/payment/payment_output_entity.dart';
import '../../../domain/entities/shipping_config_entity.dart';
import '../../models/shipping_config_model.dart';

class CheckoutRemoteDataSourceImp implements CheckoutRemoteDataSource {
  CheckoutRemoteDataSourceImp(
    this._databaseService,
    this._paymentService,
    this._auth,
  );

  final DatabaseService _databaseService;
  final PaymentService _paymentService;
  final FirebaseAuth _auth;

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

  @override
  Future<NetworkResponse<PaymentOutputEntity>> makePayment(
    PaymentInputEntity input,
  ) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        return NetworkFailure(Exception("user_not_logged_in"));
      }
      var map = await _databaseService.getData(
        path: BackendEndpoints.getUserData,
        documentId: userId,
      );
      String? savedCustomerId = map['customerId'];
      PaymentOutputEntity paymentOutputEntity;
      if (savedCustomerId != null) {
        PaymentInputModel paymentInputModel = PaymentInputModel.fromEntity(
          input,
        ).copyWith(customerId: savedCustomerId);
        paymentOutputEntity = await _paymentService.makePayment(
          paymentInputModel.toEntity(),
        );
      } else {
        paymentOutputEntity = await _paymentService.makePayment(input);
        await _databaseService.updateData(
          path: BackendEndpoints.updateUserData,
          documentId: userId,
          data: {'customerId': paymentOutputEntity.customerId},
        );
      }
      return const NetworkSuccess();
    } on FirebaseException catch (e) {
      return _handleError(e, "makePayment");
    } catch (e) {
      return _handleError(e, "makePayment");
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
