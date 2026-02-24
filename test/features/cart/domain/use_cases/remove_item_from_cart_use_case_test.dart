import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/helpers/network_response.dart';
import 'package:fruit_hub/features/cart/domain/repo/cart_repo.dart';
import 'package:fruit_hub/features/cart/domain/use_cases/remove_item_from_cart_use_case.dart';
import 'package:mocktail/mocktail.dart';

class MockCartRepo extends Mock implements CartRepo {}

void main() {
  late RemoveItemFromCartUseCase sut;
  late MockCartRepo mockCartRepo;
  const tProductId = 'product_id';
  final tSuccessResponseOfTypeVoid = const NetworkSuccess<void>();
  final tFailureResponseOfTypeVoid = NetworkFailure<void>(
    Exception("permission-denied"),
  );

  setUp(() {
    mockCartRepo = MockCartRepo();
    sut = RemoveItemFromCartUseCase(mockCartRepo);
  });

  group('addItemToCartUseCase', () {
    test('should call addItemToCartUseCase from repo with correct params', () async {
      // Arrange
      when(() => mockCartRepo.removeItemFromCart(tProductId)).thenAnswer((_) async => tSuccessResponseOfTypeVoid);
      // Act
      var result = await sut.call(tProductId);
      // Assert
      expect(result, tSuccessResponseOfTypeVoid);
      verify(() => mockCartRepo.removeItemFromCart(tProductId)).called(1);
      verifyNoMoreInteractions(mockCartRepo);
    },);

    test('should return failure when addItemToCartUseCase from repo fails with correct params', () async {
      // Arrange
      when(() => mockCartRepo.removeItemFromCart(tProductId)).thenAnswer((_) async => tFailureResponseOfTypeVoid);
      // Act
      var result = await sut.call(tProductId);
      // Assert
      expect(result, tFailureResponseOfTypeVoid);
      verify(() => mockCartRepo.removeItemFromCart(tProductId)).called(1);
      verifyNoMoreInteractions(mockCartRepo);
    });
  },);

}
