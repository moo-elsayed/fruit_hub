import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/errors/failures.dart';
import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/features/cart/domain/repo/cart_repo.dart';
import 'package:fruit_hub/features/cart/domain/use_cases/remove_item_from_cart_use_case.dart';
import 'package:mocktail/mocktail.dart';

class MockCartRepo extends Mock implements CartRepo {}

void main() {
  late MockCartRepo mockCartRepo;
  late RemoveItemFromCartUseCase sut;

  const tProductId = 'APPLE_01';
  const tFailure = ServerFailure(error: 'Failed to remove item from cart');

  setUp(() {
    mockCartRepo = MockCartRepo();
    sut = RemoveItemFromCartUseCase(mockCartRepo);
  });

  group('RemoveItemFromCartUseCase', () {
    test(
      'should return NetworkSuccess when cart repo succeeds',
      () async {
        // Arrange
        when(
          () => mockCartRepo.removeItemFromCart(tProductId),
        ).thenAnswer((_) async => const NetworkSuccess(null));

        // Act
        final result = await sut(tProductId);

        // Assert
        expect(result, isA<NetworkSuccess<void>>());
        verify(() => mockCartRepo.removeItemFromCart(tProductId)).called(1);
        verifyNoMoreInteractions(mockCartRepo);
      },
    );

    test(
      'should return NetworkFailure with same failure when cart repo fails',
      () async {
        // Arrange
        when(
          () => mockCartRepo.removeItemFromCart(tProductId),
        ).thenAnswer((_) async => const NetworkFailure(tFailure));

        // Act
        final result = await sut(tProductId);

        // Assert
        expect(result, isA<NetworkFailure<void>>());
        final failure = (result as NetworkFailure<void>).failure;
        expect(failure, equals(tFailure));
        expect(failure.error, tFailure.error);
        verify(() => mockCartRepo.removeItemFromCart(tProductId)).called(1);
        verifyNoMoreInteractions(mockCartRepo);
      },
    );
  });
}
