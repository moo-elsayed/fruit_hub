import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/errors/failures.dart';
import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/features/cart/domain/repo/cart_repo.dart';
import 'package:fruit_hub/features/cart/domain/use_cases/clear_cart_use_case.dart';
import 'package:mocktail/mocktail.dart';

class MockCartRepo extends Mock implements CartRepo {}

void main() {
  late MockCartRepo mockCartRepo;
  late ClearCartUseCase sut;

  const tFailure = ServerFailure(error: 'Failed to clear cart');

  setUp(() {
    mockCartRepo = MockCartRepo();
    sut = ClearCartUseCase(mockCartRepo);
  });

  group('ClearCartUseCase', () {
    test(
      'should return NetworkSuccess when cart repo succeeds',
      () async {
        // Arrange
        when(
          () => mockCartRepo.clearCart(),
        ).thenAnswer((_) async => const NetworkSuccess(null));

        // Act
        final result = await sut();

        // Assert
        expect(result, isA<NetworkSuccess<void>>());
        verify(() => mockCartRepo.clearCart()).called(1);
        verifyNoMoreInteractions(mockCartRepo);
      },
    );

    test(
      'should return NetworkFailure with same failure when cart repo fails',
      () async {
        // Arrange
        when(
          () => mockCartRepo.clearCart(),
        ).thenAnswer((_) async => const NetworkFailure(tFailure));

        // Act
        final result = await sut();

        // Assert
        expect(result, isA<NetworkFailure<void>>());
        final failure = (result as NetworkFailure<void>).failure;
        expect(failure, equals(tFailure));
        expect(failure.error, tFailure.error);
        verify(() => mockCartRepo.clearCart()).called(1);
        verifyNoMoreInteractions(mockCartRepo);
      },
    );
  });
}
