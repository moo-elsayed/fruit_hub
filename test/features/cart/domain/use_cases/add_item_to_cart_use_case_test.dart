import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/errors/failures.dart';
import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/features/cart/domain/repo/cart_repo.dart';
import 'package:fruit_hub/features/cart/domain/use_cases/add_item_to_cart_use_case.dart';
import 'package:mocktail/mocktail.dart';

class MockCartRepo extends Mock implements CartRepo {}

void main() {
  late MockCartRepo mockCartRepo;
  late AddItemToCartUseCase sut;

  const tProductId = 'APPLE_01';
  const tFailure = ServerFailure(error: 'Failed to add item to cart');

  setUp(() {
    mockCartRepo = MockCartRepo();
    sut = AddItemToCartUseCase(mockCartRepo);
  });

  group('AddItemToCartUseCase', () {
    test(
      'should return NetworkSuccess when cart repo succeeds with custom quantity',
      () async {
        // Arrange
        when(
          () => mockCartRepo.addItemToCart(tProductId, quantity: 3),
        ).thenAnswer((_) async => const NetworkSuccess(null));

        // Act
        final result = await sut(tProductId, quantity: 3);

        // Assert
        expect(result, isA<NetworkSuccess<void>>());
        verify(
          () => mockCartRepo.addItemToCart(tProductId, quantity: 3),
        ).called(1);
        verifyNoMoreInteractions(mockCartRepo);
      },
    );

    test(
      'should return NetworkSuccess and default quantity of 1 when quantity is not specified',
      () async {
        // Arrange
        when(
          () => mockCartRepo.addItemToCart(tProductId, quantity: 1),
        ).thenAnswer((_) async => const NetworkSuccess(null));

        // Act
        final result = await sut(tProductId);

        // Assert
        expect(result, isA<NetworkSuccess<void>>());
        verify(
          () => mockCartRepo.addItemToCart(tProductId, quantity: 1),
        ).called(1);
        verifyNoMoreInteractions(mockCartRepo);
      },
    );

    test(
      'should return NetworkFailure with same failure when cart repo fails',
      () async {
        // Arrange
        when(
          () => mockCartRepo.addItemToCart(tProductId, quantity: 1),
        ).thenAnswer((_) async => const NetworkFailure(tFailure));

        // Act
        final result = await sut(tProductId);

        // Assert
        expect(result, isA<NetworkFailure<void>>());
        final failure = (result as NetworkFailure<void>).failure;
        expect(failure, equals(tFailure));
        expect(failure.error, tFailure.error);
        verify(
          () => mockCartRepo.addItemToCart(tProductId, quantity: 1),
        ).called(1);
        verifyNoMoreInteractions(mockCartRepo);
      },
    );
  });
}
