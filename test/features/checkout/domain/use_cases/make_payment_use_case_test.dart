import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/errors/failures.dart';
import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/features/checkout/domain/entities/payment_input_entity.dart';
import 'package:fruit_hub/features/checkout/domain/repo/checkout_repo.dart';
import 'package:fruit_hub/features/checkout/domain/use_cases/make_payment_use_case.dart';
import 'package:mocktail/mocktail.dart';

class MockCheckoutRepo extends Mock implements CheckoutRepo {}

void main() {
  late MockCheckoutRepo mockCheckoutRepo;
  late MakePaymentUseCase sut;

  final tPaymentInputEntity = PaymentInputEntity(
    amount: 150.0,
    currency: 'usd',
    customerId: 'cus_123',
  );

  const tFailure = ServerFailure(error: 'Payment failed');

  setUp(() {
    mockCheckoutRepo = MockCheckoutRepo();
    sut = MakePaymentUseCase(mockCheckoutRepo);
  });

  group('MakePaymentUseCase', () {
    test('should return NetworkSuccess when checkout repo succeeds', () async {
      // Arrange
      when(() => mockCheckoutRepo.makePayment(tPaymentInputEntity))
          .thenAnswer((_) async => const NetworkSuccess(null));

      // Act
      final result = await sut(tPaymentInputEntity);

      // Assert
      expect(result, isA<NetworkSuccess<void>>());
      verify(() => mockCheckoutRepo.makePayment(tPaymentInputEntity)).called(1);
      verifyNoMoreInteractions(mockCheckoutRepo);
    });

    test(
      'should return NetworkFailure with same failure when checkout repo fails',
      () async {
        // Arrange
        when(() => mockCheckoutRepo.makePayment(tPaymentInputEntity))
            .thenAnswer((_) async => const NetworkFailure(tFailure));

        // Act
        final result = await sut(tPaymentInputEntity);

        // Assert
        expect(result, isA<NetworkFailure<void>>());
        final failure = (result as NetworkFailure<void>).failure;
        expect(failure, equals(tFailure));
        expect(failure.error, tFailure.error);
        verify(() => mockCheckoutRepo.makePayment(tPaymentInputEntity))
            .called(1);
        verifyNoMoreInteractions(mockCheckoutRepo);
      },
    );
  });
}
