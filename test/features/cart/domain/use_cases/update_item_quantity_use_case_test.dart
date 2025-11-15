import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/helpers/network_response.dart';
import 'package:fruit_hub/features/cart/domain/repo/cart_repo.dart';
import 'package:fruit_hub/features/cart/domain/use_cases/update_item_quantity_use_case.dart';
import 'package:mocktail/mocktail.dart';

class MockCartRepo extends Mock implements CartRepo {}

void main() {
  late UpdateItemQuantityUseCase sut;
  late MockCartRepo mockCartRepo;

  const tProductId = 'product_id';
  const tNewQuantity = 5;
  final tSuccessResponseOfTypeVoid = const NetworkSuccess<void>();
  final tFailureResponseOfTypeVoid = NetworkFailure<void>(
    Exception("permission-denied"),
  );

  setUp(() {
    mockCartRepo = MockCartRepo();
    sut = UpdateItemQuantityUseCase(mockCartRepo);
  });

  group('update item quantity use case', () {
    test(
      'should call update item quantity from repo with correct params when success response is received from repo',
      () async {
        // Arrange
        when(
          () => mockCartRepo.updateItemQuantity(
            productId: tProductId,
            newQuantity: tNewQuantity,
          ),
        ).thenAnswer((_) async => tSuccessResponseOfTypeVoid);
        // Act
        var result = await sut.call(
          productId: tProductId,
          newQuantity: tNewQuantity,
        );
        // Assert
        expect(result, tSuccessResponseOfTypeVoid);
        verify(
          () => mockCartRepo.updateItemQuantity(
            productId: tProductId,
            newQuantity: tNewQuantity,
          ),
        );
        verifyNoMoreInteractions(mockCartRepo);
      },
    );

    test(
      'should call update item quantity from repo with correct params when failure response is received from repo',
      () async {
        // Arrange
        when(
          () => mockCartRepo.updateItemQuantity(
            productId: tProductId,
            newQuantity: tNewQuantity,
          ),
        ).thenAnswer((_) async => tFailureResponseOfTypeVoid);
        // Act
        var result = await sut.call(
          productId: tProductId,
          newQuantity: tNewQuantity,
        );
        // Assert
        expect(result, tFailureResponseOfTypeVoid);
        verify(
          () => mockCartRepo.updateItemQuantity(
            productId: tProductId,
            newQuantity: tNewQuantity,
          ),
        );
        verifyNoMoreInteractions(mockCartRepo);
      },
    );
  });
}
