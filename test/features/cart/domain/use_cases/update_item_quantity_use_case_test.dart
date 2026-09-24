import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/errors/failures.dart';
import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/features/cart/domain/repo/cart_repo.dart';
import 'package:fruit_hub/features/cart/domain/use_cases/update_item_quantity_use_case.dart';
import 'package:mocktail/mocktail.dart';

class MockCartRepo extends Mock implements CartRepo {}

void main() {
  late MockCartRepo mockCartRepo;
  late UpdateItemQuantityUseCase sut;

  const tProductId = 'APPLE_01';
  const tNewQuantity = 5;
  const tFailure = ServerFailure(error: 'Failed to update item quantity');

  setUp(() {
    mockCartRepo = MockCartRepo();
    sut = UpdateItemQuantityUseCase(mockCartRepo);
  });

  group('UpdateItemQuantityUseCase', () {
    test(
      'should return NetworkSuccess when cart repo succeeds',
      () async {
        // Arrange
        when(
          () => mockCartRepo.updateItemQuantity(
            productId: tProductId,
            newQuantity: tNewQuantity,
          ),
        ).thenAnswer((_) async => const NetworkSuccess(null));

        // Act
        final result = await sut(
          productId: tProductId,
          newQuantity: tNewQuantity,
        );

        // Assert
        expect(result, isA<NetworkSuccess<void>>());
        verify(
          () => mockCartRepo.updateItemQuantity(
            productId: tProductId,
            newQuantity: tNewQuantity,
          ),
        ).called(1);
        verifyNoMoreInteractions(mockCartRepo);
      },
    );

    test(
      'should return NetworkFailure with same failure when cart repo fails',
      () async {
        // Arrange
        when(
          () => mockCartRepo.updateItemQuantity(
            productId: tProductId,
            newQuantity: tNewQuantity,
          ),
        ).thenAnswer((_) async => const NetworkFailure(tFailure));

        // Act
        final result = await sut(
          productId: tProductId,
          newQuantity: tNewQuantity,
        );

        // Assert
        expect(result, isA<NetworkFailure<void>>());
        final failure = (result as NetworkFailure<void>).failure;
        expect(failure, equals(tFailure));
        expect(failure.error, tFailure.error);
        verify(
          () => mockCartRepo.updateItemQuantity(
            productId: tProductId,
            newQuantity: tNewQuantity,
          ),
        ).called(1);
        verifyNoMoreInteractions(mockCartRepo);
      },
    );
  });
}
