import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/entities/review_entity.dart';
import 'package:fruit_hub/core/errors/failures.dart';
import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/features/favorites/domain/repo/favorites_repo.dart';
import 'package:fruit_hub/features/favorites/domain/use_cases/get_favorites_use_case.dart';
import 'package:mocktail/mocktail.dart';

class MockFavoritesRepo extends Mock implements FavoritesRepo {}

void main() {
  late MockFavoritesRepo mockFavoritesRepo;
  late GetFavoritesUseCase sut;

  const tFruitEntity1 = FruitEntity(
    code: 'prod_apple_01',
    name: 'تفاح أحمر',
    description: 'تفاح أحمر طازج ولذيذ',
    price: 25.0,
    imagePath: 'assets/images/red_apple.png',
    isFeatured: true,
    avgRating: 4.5,
    ratingCount: 10,
    isOrganic: true,
    daysUntilExpiration: 14,
    weightInGrams: 500,
    numberOfCalories: 52,
    reviews: [
      ReviewEntity(
        name: 'أحمد',
        image: 'assets/images/user1.png',
        description: 'جودة ممتازة',
        date: '2026-09-01',
        rating: 5.0,
        userId: 'user_1',
      ),
    ],
  );

  const tFruitEntity2 = FruitEntity(
    code: 'prod_banana_02',
    name: 'موز بلدي',
    description: 'موز طازج ومغذي',
    price: 15.0,
    imagePath: 'assets/images/banana.png',
    isFeatured: false,
    avgRating: 4.0,
    ratingCount: 5,
    isOrganic: true,
    daysUntilExpiration: 5,
    weightInGrams: 1000,
    numberOfCalories: 89,
    reviews: [],
  );

  setUp(() {
    mockFavoritesRepo = MockFavoritesRepo();
    sut = GetFavoritesUseCase(mockFavoritesRepo);
  });

  group('GetFavoritesUseCase', () {
    test('should return NetworkSuccess with list of FruitEntity when favorites repo succeeds', () async {
      // Arrange
      const expectedFruits = [tFruitEntity1, tFruitEntity2];
      when(() => mockFavoritesRepo.getFavorites())
          .thenAnswer((_) async => const NetworkSuccess(expectedFruits));

      // Act
      final result = await sut();

      // Assert
      expect(result, isA<NetworkSuccess<List<FruitEntity>>>());
      final data = (result as NetworkSuccess<List<FruitEntity>>).data;
      expect(data, equals(expectedFruits));
      verify(() => mockFavoritesRepo.getFavorites()).called(1);
      verifyNoMoreInteractions(mockFavoritesRepo);
    });

    test('should return NetworkFailure with same failure when favorites repo fails', () async {
      // Arrange
      const tFailure = ServerFailure(error: 'Failed to get favorites');
      when(() => mockFavoritesRepo.getFavorites())
          .thenAnswer((_) async => const NetworkFailure(tFailure));

      // Act
      final result = await sut();

      // Assert
      expect(result, isA<NetworkFailure<List<FruitEntity>>>());
      final failure = (result as NetworkFailure<List<FruitEntity>>).failure;
      expect(failure, equals(tFailure));
      verify(() => mockFavoritesRepo.getFavorites()).called(1);
      verifyNoMoreInteractions(mockFavoritesRepo);
    });
  });
}
