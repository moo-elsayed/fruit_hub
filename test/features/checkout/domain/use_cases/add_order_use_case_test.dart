import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/entities/order_entity.dart';
import 'package:fruit_hub/core/errors/failures.dart';
import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/features/checkout/domain/repo/checkout_repo.dart';
import 'package:fruit_hub/features/checkout/domain/use_cases/add_order_use_case.dart';
import 'package:mocktail/mocktail.dart';

class MockCheckoutRepo extends Mock implements CheckoutRepo {}

void main() {
  late MockCheckoutRepo mockCheckoutRepo;
  late AddOrderUseCase sut;

  const tOrderEntity = OrderEntity(
    uId: 'user_123',
    orderId: 1001,
    totalPrice: 150.0,
  );

  const tFailure = ServerFailure(error: 'Failed to add order');

  setUp(() {
    mockCheckoutRepo = MockCheckoutRepo();
    sut = AddOrderUseCase(mockCheckoutRepo);
  });

  group('AddOrderUseCase', () {
    test('should return NetworkSuccess when checkout repo succeeds', () async {
      // Arrange
      when(() => mockCheckoutRepo.addOrder(tOrderEntity))
          .thenAnswer((_) async => const NetworkSuccess(null));

      // Act
      final result = await sut(tOrderEntity);

      // Assert
      expect(result, isA<NetworkSuccess<void>>());
      verify(() => mockCheckoutRepo.addOrder(tOrderEntity)).called(1);
      verifyNoMoreInteractions(mockCheckoutRepo);
    });

    test(
      'should return NetworkFailure with same failure when checkout repo fails',
      () async {
        // Arrange
        when(() => mockCheckoutRepo.addOrder(tOrderEntity))
            .thenAnswer((_) async => const NetworkFailure(tFailure));

        // Act
        final result = await sut(tOrderEntity);

        // Assert
        expect(result, isA<NetworkFailure<void>>());
        final failure = (result as NetworkFailure<void>).failure;
        expect(failure, equals(tFailure));
        expect(failure.error, tFailure.error);
        verify(() => mockCheckoutRepo.addOrder(tOrderEntity)).called(1);
        verifyNoMoreInteractions(mockCheckoutRepo);
      },
    );
  });
}
