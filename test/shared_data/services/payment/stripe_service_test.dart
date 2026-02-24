import 'package:dio/dio.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/services/payment/payment_input_entity.dart';
import 'package:fruit_hub/shared_data/services/payment/stripe_service.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

class MockStripe extends Mock implements Stripe {}

void main() {
  late StripeService sut;
  late MockDio mockDio;
  late MockStripe mockStripe;

  final tInputWithId = PaymentInputEntity(
    amount: 100,
    currency: 'USD',
    customerId: 'cus_exist_123',
  );

  final tInputNoId = PaymentInputEntity(
    amount: 100,
    currency: 'USD',
    customerId: '',
  );

  setUpAll(() {
    registerFallbackValue(RequestOptions(path: ''));
    registerFallbackValue(const SetupPaymentSheetParameters());
  });

  setUp(() {
    mockDio = MockDio();
    mockStripe = MockStripe();
    sut = StripeService(mockDio, mockStripe);
  });

  group("StripeService", () {
    group('makePayment', () {
      test(
        'should create customer, ephemeral key, payment intent and present sheet',
        () async {
          // Arrange
          // 1. Create Customer Response
          when(
            () => mockDio.post(
              any(that: contains('customers')),
              data: any(named: 'data'),
              options: any(named: 'options'),
            ),
          ).thenAnswer(
            (_) async => Response(
              requestOptions: RequestOptions(path: ''),
              data: {'id': 'cus_new_999'},
              statusCode: 200,
            ),
          );
          // 2. Ephemeral Key & Payment Intent Response
          when(
            () => mockDio.post(
              any(that: contains('ephemeral_keys')),
              data: any(named: 'data'),
              options: any(named: 'options'),
            ),
          ).thenAnswer(
            (_) async => Response(
              requestOptions: RequestOptions(path: ''),
              data: {'secret': 'ek_123'},
              statusCode: 200,
            ),
          );
          when(
            () => mockDio.post(
              any(that: contains('payment_intents')),
              data: any(named: 'data'),
              options: any(named: 'options'),
            ),
          ).thenAnswer(
            (_) async => Response(
              requestOptions: RequestOptions(path: ''),
              data: {'client_secret': 'pi_123'},
              statusCode: 200,
            ),
          );
          // 3. Stripe SDK Success
          when(
            () => mockStripe.initPaymentSheet(
              paymentSheetParameters: any(named: 'paymentSheetParameters'),
            ),
          ).thenAnswer((_) async => Future.value());
          when(
            () => mockStripe.presentPaymentSheet(),
          ).thenAnswer((_) async => Future.value());
          // Act
          final result = await sut.makePayment(tInputNoId);
          // Assert
          expect(result.customerId, 'cus_new_999');
          verify(
            () => mockDio.post(
              any(that: contains('customers')),
              data: any(named: 'data'),
              options: any(named: 'options'),
            ),
          ).called(1);
          verify(
            () => mockDio.post(
              any(that: contains('ephemeral_keys')),
              data: any(named: 'data'),
              options: any(named: 'options'),
            ),
          ).called(1);
          verify(
            () => mockDio.post(
              any(that: contains('payment_intents')),
              data: any(named: 'data'),
              options: any(named: 'options'),
            ),
          ).called(1);
          verify(() => mockStripe.presentPaymentSheet()).called(1);
        },
      );

      test('should NOT create new customer if ID is provided', () async {
        // Arrange
        // 2. Ephemeral Key & Payment Intent Response
        when(
          () => mockDio.post(
            any(that: contains('ephemeral_keys')),
            data: any(named: 'data'),
            options: any(named: 'options'),
          ),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: {'secret': 'ek_123'},
            statusCode: 200,
          ),
        );
        when(
          () => mockDio.post(
            any(that: contains('payment_intents')),
            data: any(named: 'data'),
            options: any(named: 'options'),
          ),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: {'client_secret': 'pi_123'},
            statusCode: 200,
          ),
        );
        // 3. Stripe SDK Success
        when(
          () => mockStripe.initPaymentSheet(
            paymentSheetParameters: any(named: 'paymentSheetParameters'),
          ),
        ).thenAnswer((_) async => Future.value());
        when(
          () => mockStripe.presentPaymentSheet(),
        ).thenAnswer((_) async => Future.value());
        // Act
        final result = await sut.makePayment(tInputWithId);
        // Assert
        expect(result.customerId, 'cus_exist_123');
        verifyNever(
          () => mockDio.post(
            any(that: contains('customers')),
            data: any(named: 'data'),
            options: any(named: 'options'),
          ),
        );
        verify(
          () => mockDio.post(
            any(that: contains('ephemeral_keys')),
            data: any(named: 'data'),
            options: any(named: 'options'),
          ),
        ).called(1);
        verify(
          () => mockDio.post(
            any(that: contains('payment_intents')),
            data: any(named: 'data'),
            options: any(named: 'options'),
          ),
        ).called(1);
        verify(() => mockStripe.presentPaymentSheet()).called(1);
      });
      test('should throw Exception when API call fails', () {
        // Arrange
        when(
          () => mockDio.post(
            any(that: contains('payment_intents')),
            data: any(named: 'data'),
            options: any(named: 'options'),
          ),
        ).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: ''),
            error: 'No Internet',
            type: DioExceptionType.connectionError,
          ),
        );
        // Act & Assert
        expect(() => sut.makePayment(tInputWithId), throwsA(isA<Exception>()));
        verifyNever(
          () => mockStripe.initPaymentSheet(
            paymentSheetParameters: any(named: 'paymentSheetParameters'),
          ),
        );
      });
      test('should throw Exception when Stripe Payment Sheet fails', () async {
        // Arrange
        when(
          () => mockDio.post(
            any(),
            data: any(named: 'data'),
            options: any(named: 'options'),
          ),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: {'id': 'cus', 'secret': 'sec', 'client_secret': 'pi'},
            statusCode: 200,
          ),
        );
        when(
          () => mockStripe.initPaymentSheet(
            paymentSheetParameters: any(named: 'paymentSheetParameters'),
          ),
        ).thenAnswer((_) async => Future.value());

        when(() => mockStripe.presentPaymentSheet()).thenThrow(
          const StripeException(
            error: LocalizedErrorMessage(
              code: FailureCode.Canceled,
              localizedMessage: 'Cancelled',
              message: 'Cancelled',
            ),
          ),
        );
        // Act & Assert
        expect(() => sut.makePayment(tInputWithId), throwsA(isA<Exception>()));
      });
    });
  });
}
