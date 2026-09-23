import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/errors/failures.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/features/orders/domain/repo/orders_repo.dart';
import 'package:fruit_hub/features/orders/domain/use_cases/cancel_order_use_case.dart';
import 'package:mocktail/mocktail.dart';

class MockOrdersRepo extends Mock implements OrdersRepo {}

void main() {
  late MockOrdersRepo mockOrdersRepo;
  late CancelOrderUseCase sut;

  const tDocId = 'ORDER_DOC_123';
  final tServerFailure = ServerFailure(error: AppStrings.cannotCancelOrder);

  setUp(() {
    mockOrdersRepo = MockOrdersRepo();
    sut = CancelOrderUseCase(mockOrdersRepo);
  });

  test('should call cancelOrder on OrdersRepo and return NetworkSuccess<void> when repo succeeds', () async {
    // Arrange
    when(() => mockOrdersRepo.cancelOrder(any()))
        .thenAnswer((_) async => const NetworkSuccess(null));

    // Act
    final result = await sut(tDocId);

    // Assert
    expect(result, isA<NetworkSuccess<void>>());
    verify(() => mockOrdersRepo.cancelOrder(tDocId)).called(1);
    verifyNoMoreInteractions(mockOrdersRepo);
  });

  test(
    'should return NetworkFailure when OrdersRepo fails to cancel order',
    () async {
      // Arrange
      when(() => mockOrdersRepo.cancelOrder(any()))
          .thenAnswer((_) async => NetworkFailure(tServerFailure));

      // Act
      final result = await sut(tDocId);

      // Assert
      expect(result, isA<NetworkFailure<void>>());
      final failureResult = result as NetworkFailure<void>;
      expect(failureResult.failure.error, tServerFailure.error);
      verify(() => mockOrdersRepo.cancelOrder(tDocId)).called(1);
      verifyNoMoreInteractions(mockOrdersRepo);
    },
  );
}
