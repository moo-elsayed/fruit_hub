import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/helpers/network_response.dart';
import 'package:fruit_hub/features/cart/domain/entities/cart_item_entity.dart';
import 'package:fruit_hub/features/cart/domain/repo/cart_repo.dart';
import 'package:fruit_hub/features/cart/domain/use_cases/get_cart_items_use_case.dart';
import 'package:mocktail/mocktail.dart';

class MockCartRepo extends Mock implements CartRepo {}

void main() {
  late GetCartItemsUseCase sut;
  late MockCartRepo mockCartRepo;
  List<CartItemEntity> tCartItems = [
    CartItemEntity(fruitEntity: FruitEntity(), quantity: 2),
    CartItemEntity(fruitEntity: FruitEntity(), quantity: 3),
    CartItemEntity(fruitEntity: FruitEntity(), quantity: 4),
  ];

  final tSuccessResponse = NetworkSuccess<List<CartItemEntity>>(tCartItems);
  final tFailureResponse = NetworkFailure<List<CartItemEntity>>(
    Exception("permission-denied"),
  );

  setUp(() {
    mockCartRepo = MockCartRepo();
    sut = GetCartItemsUseCase(mockCartRepo);
  });

  group('get cart items use case', () {
    test('should get cart items from the repo successfully', () async {
      // Arrange
      when(
        () => mockCartRepo.getCartItems(),
      ).thenAnswer((_) async => tSuccessResponse);
      // Act
      final result = await sut.call();
      // Assert
      expect(result, tSuccessResponse);
      verify(() => mockCartRepo.getCartItems()).called(1);
      verifyNoMoreInteractions(mockCartRepo);
    });

    test('should return failure when getting cart items fails', () async {
      // Arrange
      when(
        () => mockCartRepo.getCartItems(),
      ).thenAnswer((_) async => tFailureResponse);
      // Act
      final result = await sut.call();
      // Assert
      expect(result, tFailureResponse);
      verify(() => mockCartRepo.getCartItems()).called(1);
      verifyNoMoreInteractions(mockCartRepo);
    });
  });
}
