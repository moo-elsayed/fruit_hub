import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/errors/failures.dart';
import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/features/products/domain/repo/products_repo.dart';
import 'package:fruit_hub/features/products/domain/use_cases/get_product_details_use_case.dart';
import 'package:mocktail/mocktail.dart';

class MockProductsRepo extends Mock implements ProductsRepo {}

void main() {
  late MockProductsRepo mockProductsRepo;
  late GetProductDetailsUseCase sut;

  const tCode = 'APPLE_01';

  const tFruitEntity = FruitEntity(
    name: 'تفاح أحمر',
    description: 'تفاح طازج ولذيذ',
    price: 25.0,
    imagePath: 'assets/images/apple_red.png',
    code: 'APPLE_01',
    isFeatured: true,
    avgRating: 4.5,
    ratingCount: 15,
    isOrganic: true,
    daysUntilExpiration: 10,
    weightInGrams: 500,
    numberOfCalories: 52,
    reviews: [],
  );

  const tServerFailure = ServerFailure(error: 'المنتج غير موجود');

  setUp(() {
    mockProductsRepo = MockProductsRepo();
    sut = GetProductDetailsUseCase(mockProductsRepo);
  });

  test('should call getProductDetails on ProductsRepo with code and return NetworkSuccess with FruitEntity when repo succeeds', () async {
    // Arrange
    when(() => mockProductsRepo.getProductDetails(any()))
        .thenAnswer((_) async => const NetworkSuccess(tFruitEntity));

    // Act
    final result = await sut(tCode);

    // Assert
    expect(result, isA<NetworkSuccess<FruitEntity>>());
    final successResult = result as NetworkSuccess<FruitEntity>;
    expect(successResult.data, equals(tFruitEntity));
    verify(() => mockProductsRepo.getProductDetails(tCode)).called(1);
    verifyNoMoreInteractions(mockProductsRepo);
  });

  test('should return NetworkFailure when ProductsRepo fails during getProductDetails', () async {
    // Arrange
    when(() => mockProductsRepo.getProductDetails(any()))
        .thenAnswer((_) async => const NetworkFailure(tServerFailure));

    // Act
    final result = await sut(tCode);

    // Assert
    expect(result, isA<NetworkFailure<FruitEntity>>());
    final failureResult = result as NetworkFailure<FruitEntity>;
    expect(failureResult.failure.error, tServerFailure.error);
    verify(() => mockProductsRepo.getProductDetails(tCode)).called(1);
    verifyNoMoreInteractions(mockProductsRepo);
  });
}
