import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/helpers/functions.dart';
import 'package:fruit_hub/core/helpers/network_response.dart';
import 'package:fruit_hub/features/home/domain/repo/home_repo.dart';
import 'package:fruit_hub/features/home/domain/use_cases/get_best_seller_products_use_case.dart';
import 'package:mocktail/mocktail.dart';

class MockHomeRepo extends Mock implements HomeRepo {}

void main() {
  late GetBestSellerProductsUseCase sut;
  late MockHomeRepo mockHomeRepo;

  List<FruitEntity> fruits = [FruitEntity(), FruitEntity(), FruitEntity()];

  final tSuccessResponse = NetworkSuccess<List<FruitEntity>>(fruits);
  final tFailureResponse = NetworkFailure<List<FruitEntity>>(
    Exception("permission-denied"),
  );

  setUp(() {
    mockHomeRepo = MockHomeRepo();
    sut = GetBestSellerProductsUseCase(mockHomeRepo);
  });

  group("GetBestSellerProductsUseCase", () {
    test(
      'should return a list of fruits when the call to the repository is successful',
      () async {
        // Arrange
        when(
          () => mockHomeRepo.getBestSellerProducts(),
        ).thenAnswer((_) async => tSuccessResponse);

        // Act
        final result = await sut.call();

        // Assert
        expect(result, tSuccessResponse);
        verify(() => mockHomeRepo.getBestSellerProducts()).called(1);
        verifyNoMoreInteractions(mockHomeRepo);
      },
    );

    test(
      'should return a failure when the call to the repository fails',
      () async {
        // Arrange
        when(
          () => mockHomeRepo.getBestSellerProducts(),
        ).thenAnswer((_) async => tFailureResponse);

        // Act
        final result = await sut.call();

        // Assert
        expect(result, tFailureResponse);
        expect(getErrorMessage(result), "permission-denied");
        verify(() => mockHomeRepo.getBestSellerProducts()).called(1);
        verifyNoMoreInteractions(mockHomeRepo);
      },
    );
  });
}
