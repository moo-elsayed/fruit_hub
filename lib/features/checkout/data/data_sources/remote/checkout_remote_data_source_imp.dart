import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:fruit_hub/core/errors/exceptions.dart';
import 'package:fruit_hub/core/helpers/api_constants.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/backend_endpoints.dart';
import 'package:fruit_hub/core/network/api_helper.dart';
import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/env.dart';
import 'package:fruit_hub/features/checkout/data/data_sources/remote/checkout_remote_data_source.dart';
import 'package:fruit_hub/features/checkout/data/models/order_model.dart';
import 'package:fruit_hub/features/checkout/data/models/payment_input_model.dart';
import 'package:fruit_hub/features/checkout/data/models/payment_output_model.dart';

import '../../models/shipping_config_model.dart';

class CheckoutRemoteDataSourceImp implements CheckoutRemoteDataSource {
  CheckoutRemoteDataSourceImp({
    Dio? dio,
    Stripe? stripe,
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  }) : _dio = dio ?? Dio(),
       _stripe = stripe ?? Stripe.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance;

  final Dio _dio;
  final Stripe _stripe;
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
  Future<NetworkResponse<PaymentOutputModel>> makePayment(
    PaymentInputModel input,
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
    String? customerId = map[BackendEndpoints.customerIdField];

    if (customerId == null || customerId.isEmpty) {
      customerId = await _createCustomer();
      await _firestore
          .collection(BackendEndpoints.usersCollection)
          .doc(userId)
          .set({
            BackendEndpoints.customerIdField: customerId,
          }, SetOptions(merge: true));
    }

    final ephemeralKey = await _createEphemeralKey(customerId: customerId);
    final paymentIntent = await _createPaymentIntent(input, customerId);

    await _initPaymentSheet(
      paymentIntentClientSecret: paymentIntent['client_secret'],
      ephemeralKeySecret: ephemeralKey['secret'],
      customerId: customerId,
    );

    await _displayPaymentSheet();

    return PaymentOutputModel(customerId: customerId);
  }, functionName: 'makePayment');

  // -----------------------------------------------
  // Stripe Helpers
  // -----------------------------------------------

  Future<String> _createCustomer() async {
    final response = await _dio.post(
      ApiConstants.createCustomerUrl,
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
        headers: {'Authorization': 'Bearer ${Env.stripeSecretKey}'},
      ),
    );
    return response.data['id'];
  }

  Future<Map<String, dynamic>> _createEphemeralKey({
    required String customerId,
  }) async {
    final response = await _dio.post(
      ApiConstants.createEphemeralKeyUrl,
      data: {'customer': customerId},
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
        headers: {
          'Authorization': 'Bearer ${Env.stripeSecretKey}',
          'Stripe-Version': '2024-06-20',
        },
      ),
    );
    return response.data;
  }

  Future<Map<String, dynamic>> _createPaymentIntent(
    PaymentInputModel input,
    String customerId,
  ) async {
    final response = await _dio.post(
      ApiConstants.createPaymentIntentUrl,
      data: {
        'amount': input.amountInCents,
        'currency': input.currency,
        'customer': customerId,
        'payment_method_types[]': 'card',
      },
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
        headers: {'Authorization': 'Bearer ${Env.stripeSecretKey}'},
      ),
    );
    return response.data;
  }

  Future<void> _initPaymentSheet({
    required String paymentIntentClientSecret,
    required String ephemeralKeySecret,
    required String customerId,
  }) async => await _stripe.initPaymentSheet(
    paymentSheetParameters: SetupPaymentSheetParameters(
      paymentIntentClientSecret: paymentIntentClientSecret,
      customerEphemeralKeySecret: ephemeralKeySecret,
      customerId: customerId,
      merchantDisplayName: 'Fruit Hub',
    ),
  );

  Future<void> _displayPaymentSheet() async =>
      await _stripe.presentPaymentSheet();
}
