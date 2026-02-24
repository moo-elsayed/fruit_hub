import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/helpers/functions.dart';
import 'package:fruit_hub/core/helpers/network_response.dart';
import 'package:fruit_hub/core/services/payment/payment_input_entity.dart';
import 'package:fruit_hub/core/services/payment/payment_output_entity.dart';
import 'package:fruit_hub/features/checkout/domain/repo/checkout_repo.dart';
import 'package:fruit_hub/features/checkout/domain/use_cases/make_payment_use_case.dart';
import 'package:mocktail/mocktail.dart';

class MockCheckoutRepo extends Mock implements CheckoutRepo {}

class FakePaymentInputEntity extends Fake implements PaymentInputEntity {}

void main() {
  late MakePaymentUseCase sut;
  late MockCheckoutRepo mockCheckoutRepo;

  final tPaymentInputEntity = PaymentInputEntity(amount: 100, currency: 'USD');
  final tException = Exception('DataSource error');
  final tPaymentOutputEntity = const PaymentOutputEntity(customerId: 'cus_123');
  final tSuccessResponseOfTypePaymentOutputEntity =
      NetworkSuccess<PaymentOutputEntity>(tPaymentOutputEntity);
  final tFailureResponseOfTypePaymentOutputEntity =
      NetworkFailure<PaymentOutputEntity>(tException);

  setUpAll(() {
    registerFallbackValue(FakePaymentInputEntity());
  });

  setUp(() {
    mockCheckoutRepo = MockCheckoutRepo();
    sut = MakePaymentUseCase(mockCheckoutRepo);
  });

  group("MakePaymentUseCase", () {
    test(
      'should return NetworkSuccess when makePayment is successful',
      () async {
        // Arrange
        when(
          () => mockCheckoutRepo.makePayment(any()),
        ).thenAnswer((_) async => tSuccessResponseOfTypePaymentOutputEntity);
        // Act
        final result = await sut(tPaymentInputEntity);
        // Assert
        expect(result, tSuccessResponseOfTypePaymentOutputEntity);
        verify(() => mockCheckoutRepo.makePayment(any())).called(1);
      },
    );

    test(
      'should return NetworkFailure when makePayment throws an exception',
      () async {
        // Arrange
        when(
          () => mockCheckoutRepo.makePayment(any()),
        ).thenAnswer((_) async => tFailureResponseOfTypePaymentOutputEntity);
        // Act
        final result = await sut(tPaymentInputEntity);
        // Assert
        expect(result, tFailureResponseOfTypePaymentOutputEntity);
        expect(getErrorMessage(result), 'DataSource error');
        verify(() => mockCheckoutRepo.makePayment(any())).called(1);
        verifyNoMoreInteractions(mockCheckoutRepo);
      },
    );
  });
}
