import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/helpers/functions.dart';
import 'package:fruit_hub/core/helpers/network_response.dart';
import 'package:fruit_hub/features/cart/domain/repo/cart_repo.dart';
import 'package:fruit_hub/features/cart/domain/use_cases/add_item_to_cart_use_case.dart';
import 'package:mocktail/mocktail.dart';

class MockCartRepo extends Mock implements CartRepo {}

void main() {
  late AddItemToCartUseCase sut;
  late MockCartRepo mockCartRepo;
  const tProductId = 'product_id';
  final tSuccessResponseOfTypeVoid = const NetworkSuccess<void>();
  final tFailureResponseOfTypeVoid = NetworkFailure<void>(
    Exception("permission-denied"),
  );

  setUp(() {
    mockCartRepo = MockCartRepo();
    sut = AddItemToCartUseCase(mockCartRepo);
  });

  group('addItemToCartUseCase', () {
    test(
      'should call addItemToCartUseCase from repo with correct params when called with correct params',
      () async {
        // Arrange
        when(
          () => mockCartRepo.addItemToCart(tProductId),
        ).thenAnswer((_) async => tSuccessResponseOfTypeVoid);
        // Act
        var result = await sut.call(tProductId);
        // Assert
        expect(result, tSuccessResponseOfTypeVoid);
        verify(() => mockCartRepo.addItemToCart(tProductId)).called(1);
        verifyNoMoreInteractions(mockCartRepo);
      },
    );

    test(
      'should return failure when addItemToCartUseCase from repo fails',
      () async {
        // Arrange
        when(
          () => mockCartRepo.addItemToCart(tProductId),
        ).thenAnswer((_) async => tFailureResponseOfTypeVoid);
        // Act
        var result = await sut.call(tProductId);
        // Assert
        expect(result, tFailureResponseOfTypeVoid);
        expect(getErrorMessage(result), "permission-denied");
        verify(() => mockCartRepo.addItemToCart(tProductId)).called(1);
        verifyNoMoreInteractions(mockCartRepo);
      },
    );
  });
}
