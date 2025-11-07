import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/helpers/functions.dart';
import 'package:fruit_hub/core/helpers/network_response.dart';
import 'package:fruit_hub/features/products/domain/repo/products_repo.dart';
import 'package:fruit_hub/features/products/domain/use_cases/get_all_products_use_case.dart';
import 'package:mocktail/mocktail.dart';

class MockProductsRepo extends Mock implements ProductsRepo {}

void main() {
  late GetAllProductsUseCase sut;
  late MockProductsRepo mockProductsRepo;

  List<FruitEntity> fruits = [FruitEntity(), FruitEntity(), FruitEntity()];

  final tSuccessResponse = NetworkSuccess<List<FruitEntity>>(fruits);
  final tFailureResponse = NetworkFailure<List<FruitEntity>>(
    Exception("permission-denied"),
  );

  setUp(() {
    mockProductsRepo = MockProductsRepo();
    sut = GetAllProductsUseCase(mockProductsRepo);
  });

  group('GetAllProductsUseCase', () {
    test(
      'should return a list of fruits when the call to the repository is successful',
      () async {
        // Arrange
        when(
          () => mockProductsRepo.getAllProducts(),
        ).thenAnswer((_) async => tSuccessResponse);
        // Act
        final result = await sut.call();
        // Assert
        expect(result, tSuccessResponse);
        verify(() => mockProductsRepo.getAllProducts()).called(1);
        verifyNoMoreInteractions(mockProductsRepo);
      },
    );

    test(
      'should return a failure when the call to the repository is unsuccessful',
      () async {
        // Arrange
        when(
          () => mockProductsRepo.getAllProducts(),
        ).thenAnswer((_) async => tFailureResponse);

        // Act
        final result = await sut.call();

        // Assert
        expect(result, tFailureResponse);
        expect(getErrorMessage(result), "permission-denied");
        verify(() => mockProductsRepo.getAllProducts()).called(1);
        verifyNoMoreInteractions(mockProductsRepo);
      },
    );
  });
}
