import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/helpers/functions.dart';
import 'package:fruit_hub/core/helpers/network_response.dart';
import 'package:fruit_hub/features/cart/domain/repo/cart_repo.dart';
import 'package:fruit_hub/features/cart/domain/use_cases/get_cart_items_use_case.dart';
import 'package:mocktail/mocktail.dart';

class MockCartRepo extends Mock implements CartRepo {}

void main() {
  late GetCartItemsUseCase sut;
  late MockCartRepo mockCartRepo;
  const tProductId = 'product_id';

  final cartItems = [
    {'fruitCode': tProductId, 'quantity': 1},
    {'fruitCode': 'banana_yellow', 'quantity': 10},
  ];

  final tSuccessResponseOfTypeListMapStringDynamic =
      NetworkSuccess<List<Map<String, dynamic>>>(cartItems);
  final tFailureResponseOfTypeListMapStringDynamic =
      NetworkFailure<List<Map<String, dynamic>>>(
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
      ).thenAnswer((_) async => tSuccessResponseOfTypeListMapStringDynamic);
      // Act
      final result = await sut.call();
      // Assert
      expect(result, tSuccessResponseOfTypeListMapStringDynamic);
      verify(() => mockCartRepo.getCartItems()).called(1);
      verifyNoMoreInteractions(mockCartRepo);
    });

    test('should return failure when getting cart items fails', () async {
      // Arrange
      when(
        () => mockCartRepo.getCartItems(),
      ).thenAnswer((_) async => tFailureResponseOfTypeListMapStringDynamic);
      // Act
      final result = await sut.call();
      // Assert
      expect(result, tFailureResponseOfTypeListMapStringDynamic);
      expect(getErrorMessage(result), "permission-denied");
      verify(() => mockCartRepo.getCartItems()).called(1);
      verifyNoMoreInteractions(mockCartRepo);
    });
  });
}
