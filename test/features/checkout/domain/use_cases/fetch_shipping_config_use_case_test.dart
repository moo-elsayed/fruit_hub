import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/errors/failures.dart';
import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/features/checkout/domain/entities/shipping_config_entity.dart';
import 'package:fruit_hub/features/checkout/domain/repo/checkout_repo.dart';
import 'package:fruit_hub/features/checkout/domain/use_cases/fetch_shipping_config_use_case.dart';
import 'package:mocktail/mocktail.dart';

class MockCheckoutRepo extends Mock implements CheckoutRepo {}

void main() {
  late MockCheckoutRepo mockCheckoutRepo;
  late FetchShippingConfigUseCase sut;

  const tShippingConfigEntity = ShippingConfigEntity(
    shippingCost: 30.0,
    freeShippingThreshold: 200.0,
  );

  const tFailure = ServerFailure(error: 'Failed to fetch shipping config');

  setUp(() {
    mockCheckoutRepo = MockCheckoutRepo();
    sut = FetchShippingConfigUseCase(mockCheckoutRepo);
  });

  group('FetchShippingConfigUseCase', () {
    test('should return NetworkSuccess with ShippingConfigEntity when checkout repo succeeds', () async {
      // Arrange
      when(() => mockCheckoutRepo.fetchShippingConfig())
          .thenAnswer((_) async => const NetworkSuccess(tShippingConfigEntity));

      // Act
      final result = await sut();

      // Assert
      expect(result, isA<NetworkSuccess<ShippingConfigEntity>>());
      final data = (result as NetworkSuccess<ShippingConfigEntity>).data;
      expect(data, equals(tShippingConfigEntity));
      expect(data!.shippingCost, 30.0);
      expect(data.freeShippingThreshold, 200.0);
      verify(() => mockCheckoutRepo.fetchShippingConfig()).called(1);
      verifyNoMoreInteractions(mockCheckoutRepo);
    });

    test(
      'should return NetworkFailure with same failure when checkout repo fails',
      () async {
        // Arrange
        when(() => mockCheckoutRepo.fetchShippingConfig())
            .thenAnswer((_) async => const NetworkFailure(tFailure));

        // Act
        final result = await sut();

        // Assert
        expect(result, isA<NetworkFailure<ShippingConfigEntity>>());
        final failure =
            (result as NetworkFailure<ShippingConfigEntity>).failure;
        expect(failure, equals(tFailure));
        expect(failure.error, tFailure.error);
        verify(() => mockCheckoutRepo.fetchShippingConfig()).called(1);
        verifyNoMoreInteractions(mockCheckoutRepo);
      },
    );
  });
}
