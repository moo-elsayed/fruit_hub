import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/errors/failures.dart';
import 'package:fruit_hub/core/models/fruit_model.dart';
import 'package:fruit_hub/core/models/review_model.dart';
import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/features/favorites/data/data_sources/remote/favorites_remote_data_source.dart';
import 'package:fruit_hub/features/favorites/data/repo_imp/favorites_repo_imp.dart';
import 'package:mocktail/mocktail.dart';

class MockFavoritesRemoteDataSource extends Mock
    implements FavoritesRemoteDataSource {}

void main() {
  late MockFavoritesRemoteDataSource mockFavoritesRemoteDataSource;
  late FavoritesRepoImp sut;

  const tProductId1 = 'prod_apple_01';
  const tProductId2 = 'prod_banana_02';

  final tFruitModel1 = FruitModel(
    code: tProductId1,
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
    sellingCount: 100,
    reviews: [
      const ReviewModel(
        name: 'أحمد',
        image: 'assets/images/user1.png',
        description: 'جودة ممتازة',
        date: '2026-09-01',
        rating: 5.0,
        userId: 'user_1',
      ),
    ],
  );

  final tFruitModel2 = FruitModel(
    code: tProductId2,
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
    sellingCount: 250,
    reviews: const [],
  );

  setUp(() {
    mockFavoritesRemoteDataSource = MockFavoritesRemoteDataSource();
    sut = FavoritesRepoImp(mockFavoritesRemoteDataSource);
  });

  group('addItemToFavorites', () {
    test(
      'should return NetworkSuccess when remote data source succeeds',
      () async {
        // Arrange
        when(
          () => mockFavoritesRemoteDataSource.addItemToFavorites(tProductId1),
        ).thenAnswer((_) async => const NetworkSuccess(null));

        // Act
        final result = await sut.addItemToFavorites(tProductId1);

        // Assert
        expect(result, isA<NetworkSuccess<void>>());
        verify(
          () => mockFavoritesRemoteDataSource.addItemToFavorites(tProductId1),
        ).called(1);
        verifyNoMoreInteractions(mockFavoritesRemoteDataSource);
      },
    );

    test(
      'should return NetworkFailure when remote data source fails',
      () async {
        // Arrange
        const tFailure = ServerFailure(
          error: 'Failed to add item to favorites',
        );
        when(
          () => mockFavoritesRemoteDataSource.addItemToFavorites(tProductId1),
        ).thenAnswer((_) async => const NetworkFailure(tFailure));

        // Act
        final result = await sut.addItemToFavorites(tProductId1);

        // Assert
        expect(result, isA<NetworkFailure<void>>());
        final failure = (result as NetworkFailure<void>).failure;
        expect(failure.error, 'Failed to add item to favorites');
        verify(
          () => mockFavoritesRemoteDataSource.addItemToFavorites(tProductId1),
        ).called(1);
        verifyNoMoreInteractions(mockFavoritesRemoteDataSource);
      },
    );
  });

  group('removeItemFromFavorites', () {
    test(
      'should return NetworkSuccess when remote data source succeeds',
      () async {
        // Arrange
        when(
          () => mockFavoritesRemoteDataSource.removeItemFromFavorites(
            tProductId1,
          ),
        ).thenAnswer((_) async => const NetworkSuccess(null));

        // Act
        final result = await sut.removeItemFromFavorites(tProductId1);

        // Assert
        expect(result, isA<NetworkSuccess<void>>());
        verify(
          () => mockFavoritesRemoteDataSource.removeItemFromFavorites(
            tProductId1,
          ),
        ).called(1);
        verifyNoMoreInteractions(mockFavoritesRemoteDataSource);
      },
    );

    test(
      'should return NetworkFailure when remote data source fails',
      () async {
        // Arrange
        const tFailure = ServerFailure(
          error: 'Failed to remove item from favorites',
        );
        when(
          () => mockFavoritesRemoteDataSource.removeItemFromFavorites(
            tProductId1,
          ),
        ).thenAnswer((_) async => const NetworkFailure(tFailure));

        // Act
        final result = await sut.removeItemFromFavorites(tProductId1);

        // Assert
        expect(result, isA<NetworkFailure<void>>());
        final failure = (result as NetworkFailure<void>).failure;
        expect(failure.error, 'Failed to remove item from favorites');
        verify(
          () => mockFavoritesRemoteDataSource.removeItemFromFavorites(
            tProductId1,
          ),
        ).called(1);
        verifyNoMoreInteractions(mockFavoritesRemoteDataSource);
      },
    );
  });

  group('getFavorites', () {
    test('should return NetworkSuccess with mapped FruitEntity list when remote data source returns NetworkSuccess with FruitModel list', () async {
      // Arrange
      when(
        () => mockFavoritesRemoteDataSource.getFavorites(),
      ).thenAnswer((_) async => NetworkSuccess([tFruitModel1, tFruitModel2]));

      // Act
      final result = await sut.getFavorites();

      // Assert
      expect(result, isA<NetworkSuccess<List<FruitEntity>>>());
      final entities = (result as NetworkSuccess<List<FruitEntity>>).data!;
      expect(entities, hasLength(2));

      expect(entities[0].code, tFruitModel1.code);
      expect(entities[0].name, tFruitModel1.name);
      expect(entities[0].description, tFruitModel1.description);
      expect(entities[0].price, tFruitModel1.price);
      expect(entities[0].imagePath, tFruitModel1.imagePath);
      expect(entities[0].isFeatured, tFruitModel1.isFeatured);
      expect(entities[0].avgRating, tFruitModel1.avgRating);
      expect(entities[0].ratingCount, tFruitModel1.ratingCount);
      expect(entities[0].isOrganic, tFruitModel1.isOrganic);
      expect(entities[0].daysUntilExpiration, tFruitModel1.daysUntilExpiration);
      expect(entities[0].weightInGrams, tFruitModel1.weightInGrams);
      expect(entities[0].numberOfCalories, tFruitModel1.numberOfCalories);
      expect(entities[0].reviews, hasLength(1));
      expect(entities[0].reviews.first.name, 'أحمد');
      expect(entities[0].reviews.first.userId, 'user_1');

      expect(entities[1].code, tFruitModel2.code);
      expect(entities[1].name, tFruitModel2.name);
      expect(entities[1].price, tFruitModel2.price);
      expect(entities[1].reviews, isEmpty);

      verify(() => mockFavoritesRemoteDataSource.getFavorites()).called(1);
      verifyNoMoreInteractions(mockFavoritesRemoteDataSource);
    });

    test('should return NetworkSuccess with empty list when remote data source returns NetworkSuccess with empty list', () async {
      // Arrange
      when(() => mockFavoritesRemoteDataSource.getFavorites())
          .thenAnswer((_) async => const NetworkSuccess(<FruitModel>[]));

      // Act
      final result = await sut.getFavorites();

      // Assert
      expect(result, isA<NetworkSuccess<List<FruitEntity>>>());
      final entities = (result as NetworkSuccess<List<FruitEntity>>).data!;
      expect(entities, isEmpty);
      verify(() => mockFavoritesRemoteDataSource.getFavorites()).called(1);
      verifyNoMoreInteractions(mockFavoritesRemoteDataSource);
    });

    test('should return NetworkSuccess with empty list when remote data source returns NetworkSuccess with null data', () async {
      // Arrange
      when(() => mockFavoritesRemoteDataSource.getFavorites())
          .thenAnswer((_) async => const NetworkSuccess(null));

      // Act
      final result = await sut.getFavorites();

      // Assert
      expect(result, isA<NetworkSuccess<List<FruitEntity>>>());
      final entities = (result as NetworkSuccess<List<FruitEntity>>).data!;
      expect(entities, isEmpty);
      verify(() => mockFavoritesRemoteDataSource.getFavorites()).called(1);
      verifyNoMoreInteractions(mockFavoritesRemoteDataSource);
    });

    test('should return NetworkFailure when remote data source returns NetworkFailure', () async {
      // Arrange
      const tFailure = ServerFailure(error: 'Failed to get favorites');
      when(() => mockFavoritesRemoteDataSource.getFavorites())
          .thenAnswer((_) async => const NetworkFailure(tFailure));

      // Act
      final result = await sut.getFavorites();

      // Assert
      expect(result, isA<NetworkFailure<List<FruitEntity>>>());
      final failure = (result as NetworkFailure<List<FruitEntity>>).failure;
      expect(failure.error, 'Failed to get favorites');
      verify(() => mockFavoritesRemoteDataSource.getFavorites()).called(1);
      verifyNoMoreInteractions(mockFavoritesRemoteDataSource);
    });
  });
}
