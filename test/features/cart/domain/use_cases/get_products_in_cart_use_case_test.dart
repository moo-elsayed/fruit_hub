import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/entities/cart_item_entity.dart';
import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/errors/failures.dart';
import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/features/cart/domain/repo/cart_repo.dart';
import 'package:fruit_hub/features/cart/domain/use_cases/get_products_in_cart_use_case.dart';
import 'package:mocktail/mocktail.dart';

class MockCartRepo extends Mock implements CartRepo {}

void main() {
  late MockCartRepo mockCartRepo;
  late GetProductsInCartUseCase sut;

  const tFruit = FruitEntity(
    name: 'تفاح أحمر',
    description: 'تفاح أحمر طازج',
    price: 25.0,
    imagePath: 'assets/images/red_apple.png',
    code: 'APPLE_01',
  );

  const tCartItem = CartItemEntity(fruitEntity: tFruit, quantity: 2);
  const tFailure = ServerFailure(error: 'Failed to get products in cart');

  setUp(() {
    mockCartRepo = MockCartRepo();
    sut = GetProductsInCartUseCase(mockCartRepo);
  });

  group('GetProductsInCartUseCase', () {
    test(
      'should return NetworkSuccess with list of CartItemEntity when cart repo succeeds',
      () async {
        // Arrange
        when(
          () => mockCartRepo.getProductsInCart(),
        ).thenAnswer((_) async => const NetworkSuccess([tCartItem]));

        // Act
        final result = await sut();

        // Assert
        expect(result, isA<NetworkSuccess<List<CartItemEntity>>>());
        final data = (result as NetworkSuccess<List<CartItemEntity>>).data;
        expect(data, equals([tCartItem]));
        verify(() => mockCartRepo.getProductsInCart()).called(1);
        verifyNoMoreInteractions(mockCartRepo);
      },
    );

    test(
      'should return NetworkFailure with same failure when cart repo fails',
      () async {
        // Arrange
        when(
          () => mockCartRepo.getProductsInCart(),
        ).thenAnswer((_) async => const NetworkFailure(tFailure));

        // Act
        final result = await sut();

        // Assert
        expect(result, isA<NetworkFailure<List<CartItemEntity>>>());
        final failure =
            (result as NetworkFailure<List<CartItemEntity>>).failure;
        expect(failure, equals(tFailure));
        expect(failure.error, tFailure.error);
        verify(() => mockCartRepo.getProductsInCart()).called(1);
        verifyNoMoreInteractions(mockCartRepo);
      },
    );
  });
}
