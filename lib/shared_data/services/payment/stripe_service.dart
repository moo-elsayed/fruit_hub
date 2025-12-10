import 'package:dio/dio.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:fruit_hub/core/helpers/api_constants.dart';
import '../../../core/services/payment/payment_input_entity.dart';
import '../../../core/services/payment/payment_output_entity.dart';
import '../../../core/services/payment/payment_service.dart';
import '../../../env.dart';

class StripeService implements PaymentService {
  StripeService(this._dio, this._stripe);

  final Dio _dio;
  final Stripe _stripe;

  @override
  Future<PaymentOutputEntity> makePayment(PaymentInputEntity input) async {
    try {
      String customerId = input.customerId;

      if (customerId.isEmpty) {
        customerId = await _createCustomer();
      }
      var ephemeralKey = await _createEphemeralKey(customerId: customerId);

      var paymentIntent = await _createPaymentIntent(input, customerId);

      await _initPaymentSheet(
        paymentIntentClientSecret: paymentIntent['client_secret'],
        ephemeralKeySecret: ephemeralKey['secret'],
        customerId: customerId,
      );

      await _displayPaymentSheet();

      return PaymentOutputEntity(customerId: customerId);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<Map<String, dynamic>> _createPaymentIntent(
    PaymentInputEntity input,
    String customerId,
  ) async {
    var response = await _dio.post(
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

  Future<Map<String, dynamic>> _createEphemeralKey({
    required String customerId,
  }) async {
    var response = await _dio.post(
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

  Future<String> _createCustomer() async {
    var response = await _dio.post(
      ApiConstants.createCustomerUrl,
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
        headers: {'Authorization': 'Bearer ${Env.stripeSecretKey}'},
      ),
    );
    return response.data['id'];
  }

  Future<void> _displayPaymentSheet() async =>
      await _stripe.presentPaymentSheet();
}
