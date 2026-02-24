import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/helpers/network_response.dart';
import 'package:fruit_hub/features/checkout/domain/entities/shipping_config_entity.dart';
import 'package:fruit_hub/features/checkout/domain/repo/checkout_repo.dart';
import 'package:fruit_hub/features/checkout/domain/use_cases/fetch_shipping_config_use_case.dart';
import 'package:mocktail/mocktail.dart';

class MockCheckoutRepo extends Mock implements CheckoutRepo {}

void main() {
  late FetchShippingConfigUseCase sut;
  late MockCheckoutRepo mockCheckoutRepo;

  final tShippingConfigEntity = const ShippingConfigEntity(shippingCost: 50.0);
  final tSuccessResponseOfTypeShippingConfigEntity =
      NetworkSuccess<ShippingConfigEntity>(tShippingConfigEntity);
  final tFailureResponseOfTypeShippingConfigEntity =
      NetworkFailure<ShippingConfigEntity>(Exception("permission-denied"));

  setUp(() {
    mockCheckoutRepo = MockCheckoutRepo();
    sut = FetchShippingConfigUseCase(mockCheckoutRepo);
  });

  group("FetchShippingConfigUseCase", () {
    test(
      'should return NetworkSuccess when fetchShippingConfig is successful',
      () async {
        // Arrange
        when(
          () => mockCheckoutRepo.fetchShippingConfig(),
        ).thenAnswer((_) async => tSuccessResponseOfTypeShippingConfigEntity);
        // Act
        final result = await sut.call();
        // Assert
        expect(result, tSuccessResponseOfTypeShippingConfigEntity);
        verify(() => mockCheckoutRepo.fetchShippingConfig()).called(1);
        verifyNoMoreInteractions(mockCheckoutRepo);
      },
    );

    test(
      'should return NetworkFailure when fetchShippingConfig throws an exception',
      () async {
        // Arrange
        when(
          () => mockCheckoutRepo.fetchShippingConfig(),
        ).thenAnswer((_) async => tFailureResponseOfTypeShippingConfigEntity);
        // Act
        final result = await sut.call();
        // Assert
        expect(result, tFailureResponseOfTypeShippingConfigEntity);
        verify(() => mockCheckoutRepo.fetchShippingConfig()).called(1);
        verifyNoMoreInteractions(mockCheckoutRepo);
      },
    );
  });
}
