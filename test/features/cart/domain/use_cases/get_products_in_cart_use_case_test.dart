import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/helpers/network_response.dart';
import 'package:fruit_hub/core/entities/cart_item_entity.dart';
import 'package:fruit_hub/features/cart/domain/repo/cart_repo.dart';
import 'package:mocktail/mocktail.dart';

class MockCartRepo extends Mock implements CartRepo {}

void main() {
  late MockCartRepo mockCartRepo;
  const tProductId = 'product_id';
  List<CartItemEntity> tCartItems = [
    const CartItemEntity(fruitEntity: FruitEntity(), quantity: 2),
    const CartItemEntity(fruitEntity: FruitEntity(), quantity: 3),
    const CartItemEntity(fruitEntity: FruitEntity(), quantity: 4),
  ];

  final tSuccessResponse = NetworkSuccess<List<CartItemEntity>>(tCartItems);
  final tFailureResponse = NetworkFailure<List<CartItemEntity>>(
    Exception("permission-denied"),
  );

  final cartItems = [
    {'fruitCode': tProductId, 'quantity': 1},
    {'fruitCode': 'banana_yellow', 'quantity': 10},
  ];

  setUp(() {
    mockCartRepo = MockCartRepo();
  });

  group('get products in cart', () {
    test('should get products in cart successfully', () async {
      // Arrange
      when(
        () => mockCartRepo.getProductsInCart(cartItems),
      ).thenAnswer((_) async => tSuccessResponse);
      // Act
      final result = await mockCartRepo.getProductsInCart(cartItems);
      // Assert
      expect(result, tSuccessResponse);
      verify(() => mockCartRepo.getProductsInCart(cartItems)).called(1);
      verifyNoMoreInteractions(mockCartRepo);
    });

    test('should return failure when getting products in cart fails', () async {
      // Arrange
      when(
        () => mockCartRepo.getProductsInCart(cartItems),
      ).thenAnswer((_) async => tFailureResponse);
      // Act
      final result = await mockCartRepo.getProductsInCart(cartItems);
      // Assert
      expect(result, tFailureResponse);
      verify(() => mockCartRepo.getProductsInCart(cartItems)).called(1);
      verifyNoMoreInteractions(mockCartRepo);
    });
  });
}
