import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/entities/review_entity.dart';
import 'package:fruit_hub/core/errors/failures.dart';
import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/features/home/domain/repo/home_repo.dart';
import 'package:fruit_hub/features/home/domain/use_cases/get_best_seller_products_use_case.dart';
import 'package:mocktail/mocktail.dart';

class MockHomeRepo extends Mock implements HomeRepo {}

void main() {
  late MockHomeRepo mockHomeRepo;
  late GetBestSellerProductsUseCase sut;

  const tFruitEntity1 = FruitEntity(
    code: 'APPLE_01',
    name: 'تفاح أحمر',
    description: 'تفاح طازج ولذيذ',
    price: 30.0,
    imagePath: 'assets/images/apple.png',
    isFeatured: true,
    avgRating: 4.8,
    ratingCount: 15,
    isOrganic: true,
    daysUntilExpiration: 10,
    weightInGrams: 1000,
    numberOfCalories: 52,
    reviews: [
      ReviewEntity(
        name: 'أحمد',
        image: 'img.png',
        description: 'ممتاز',
        date: '2026-09-20',
        rating: 5.0,
        userId: 'u1',
      ),
    ],
  );

  const tFruitEntity2 = FruitEntity(
    code: 'BANANA_01',
    name: 'موز إكوادوري',
    description: 'موز طازج ومغذي',
    price: 25.0,
    imagePath: 'assets/images/banana.png',
    isFeatured: false,
    avgRating: 4.5,
    ratingCount: 8,
    isOrganic: false,
    daysUntilExpiration: 5,
    weightInGrams: 1200,
    numberOfCalories: 89,
    reviews: [],
  );

  setUp(() {
    mockHomeRepo = MockHomeRepo();
    sut = GetBestSellerProductsUseCase(mockHomeRepo);
  });

  group('GetBestSellerProductsUseCase', () {
    test('should return NetworkSuccess with list of FruitEntity when repo succeeds', () async {
      // Arrange
      const expectedProducts = [tFruitEntity1, tFruitEntity2];
      when(() => mockHomeRepo.getBestSellerProducts())
          .thenAnswer((_) async => const NetworkSuccess(expectedProducts));

      // Act
      final result = await sut();

      // Assert
      expect(result, isA<NetworkSuccess<List<FruitEntity>>>());
      final data = (result as NetworkSuccess<List<FruitEntity>>).data;
      expect(data, equals(expectedProducts));
      verify(() => mockHomeRepo.getBestSellerProducts()).called(1);
      verifyNoMoreInteractions(mockHomeRepo);
    });

    test(
      'should return NetworkFailure with same failure when repo fails',
      () async {
        // Arrange
        const expectedFailure = ServerFailure(error: 'حدث خطأ في جلب البيانات');
        when(() => mockHomeRepo.getBestSellerProducts())
            .thenAnswer((_) async => const NetworkFailure(expectedFailure));

        // Act
        final result = await sut();

        // Assert
        expect(result, isA<NetworkFailure<List<FruitEntity>>>());
        final failure = (result as NetworkFailure<List<FruitEntity>>).failure;
        expect(failure, equals(expectedFailure));
        verify(() => mockHomeRepo.getBestSellerProducts()).called(1);
        verifyNoMoreInteractions(mockHomeRepo);
      },
    );
  });
}
