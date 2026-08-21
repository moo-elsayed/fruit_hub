import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fruit_hub/core/errors/exceptions.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/backend_endpoints.dart';
import 'package:fruit_hub/core/network/api_helper.dart';
import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/core/services/payment/payment_input_entity.dart';
import 'package:fruit_hub/core/services/payment/payment_output_entity.dart';
import 'package:fruit_hub/core/services/payment/payment_service.dart';
import 'package:fruit_hub/features/checkout/data/data_sources/remote/checkout_remote_data_source.dart';
import 'package:fruit_hub/features/checkout/data/models/order_model.dart';
import 'package:fruit_hub/shared_data/services/payment/payment_input_model.dart';
import '../../models/shipping_config_model.dart';

class CheckoutRemoteDataSourceImp implements CheckoutRemoteDataSource {
  CheckoutRemoteDataSourceImp({
    required this._paymentService,
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance;

  final PaymentService _paymentService;
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  @override
  Future<NetworkResponse<ShippingConfigModel>> fetchShippingConfig() async =>
      ApiHelper.executeSafely(() async {
        final doc = await _firestore
            .collection(BackendEndpoints.constantsCollection)
            .doc(BackendEndpoints.shippingConfigDoc)
            .get();
        if (!doc.exists || doc.data() == null) {
          throw BusinessException(AppStrings.unexpectedError);
        }
        return ShippingConfigModel.fromJson(doc.data()!);
      }, functionName: 'fetchShippingConfig');

  @override
  Future<NetworkResponse<void>> addOrder(OrderModel order) async =>
      ApiHelper.executeSafely(() async {
        await _firestore
            .collection(BackendEndpoints.ordersCollection)
            .add(order.toJson());
      }, functionName: 'addOrder');

  @override
  Future<NetworkResponse<PaymentOutputEntity>> makePayment(
    PaymentInputEntity input,
  ) async => ApiHelper.executeSafely(() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw BusinessException(AppStrings.userNotFound);
    }
    final userDoc = await _firestore
        .collection(BackendEndpoints.usersCollection)
        .doc(userId)
        .get();
    final map = userDoc.data() ?? {};
    final String? savedCustomerId = map[BackendEndpoints.customerIdField];
    PaymentOutputEntity paymentOutputEntity;
    if (savedCustomerId != null) {
      final PaymentInputModel paymentInputModel = PaymentInputModel.fromEntity(
        input,
      ).copyWith(customerId: savedCustomerId);
      paymentOutputEntity = await _paymentService.makePayment(
        paymentInputModel.toEntity(),
      );
    } else {
      paymentOutputEntity = await _paymentService.makePayment(input);
      await _firestore
          .collection(BackendEndpoints.usersCollection)
          .doc(userId)
          .update({
            BackendEndpoints.customerIdField: paymentOutputEntity.customerId,
          });
    }
    return paymentOutputEntity;
  }, functionName: 'makePayment');
}
