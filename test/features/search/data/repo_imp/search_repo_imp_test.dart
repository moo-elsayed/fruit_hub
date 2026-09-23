import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/errors/failures.dart';
import 'package:fruit_hub/core/models/fruit_model.dart';
import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/features/search/data/data_sources/remote/search_remote_data_source.dart';
import 'package:fruit_hub/features/search/data/repo_imp/search_repo_imp.dart';
import 'package:mocktail/mocktail.dart';

class MockSearchRemoteDataSource extends Mock
    implements SearchRemoteDataSource {}

void main() {
  late MockSearchRemoteDataSource mockSearchRemoteDataSource;
  late SearchRepoImp sut;

  const tQuery = 'تفاح';

  final tFruitModel1 = FruitModel(
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
    sellingCount: 100,
    reviews: const [],
  );

  final tFruitModel2 = FruitModel(
    name: 'تفاح أخضر',
    description: 'تفاح أخضر حامض',
    price: 30.0,
    imagePath: 'assets/images/apple_green.png',
    code: 'APPLE_02',
    isFeatured: false,
    avgRating: 4.0,
    ratingCount: 8,
    isOrganic: false,
    daysUntilExpiration: 12,
    weightInGrams: 450,
    numberOfCalories: 48,
    sellingCount: 60,
    reviews: const [],
  );

  const tFruitEntity1 = FruitEntity(
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

  const tFruitEntity2 = FruitEntity(
    name: 'تفاح أخضر',
    description: 'تفاح أخضر حامض',
    price: 30.0,
    imagePath: 'assets/images/apple_green.png',
    code: 'APPLE_02',
    isFeatured: false,
    avgRating: 4.0,
    ratingCount: 8,
    isOrganic: false,
    daysUntilExpiration: 12,
    weightInGrams: 450,
    numberOfCalories: 48,
    reviews: [],
  );

  const tServerFailure = ServerFailure(error: 'Failed to fetch search results');

  setUp(() {
    mockSearchRemoteDataSource = MockSearchRemoteDataSource();
    sut = SearchRepoImp(mockSearchRemoteDataSource);
  });

  group('searchFruits', () {
    test('should call searchRemoteDataSource.searchFruits with correct query and return NetworkSuccess with mapped entities when remote data source succeeds', () async {
      // Arrange
      when(
        () => mockSearchRemoteDataSource.searchFruits(any()),
      ).thenAnswer((_) async => NetworkSuccess([tFruitModel1, tFruitModel2]));

      // Act
      final result = await sut.searchFruits(tQuery);

      // Assert
      expect(result, isA<NetworkSuccess<List<FruitEntity>>>());
      final successResult = result as NetworkSuccess<List<FruitEntity>>;
      expect(successResult.data, equals([tFruitEntity1, tFruitEntity2]));
      verify(() => mockSearchRemoteDataSource.searchFruits(tQuery)).called(1);
      verifyNoMoreInteractions(mockSearchRemoteDataSource);
    });

    test('should return NetworkSuccess with empty list when remote data source returns NetworkSuccess with empty list', () async {
      // Arrange
      when(() => mockSearchRemoteDataSource.searchFruits(any()))
          .thenAnswer((_) async => const NetworkSuccess([]));

      // Act
      final result = await sut.searchFruits(tQuery);

      // Assert
      expect(result, isA<NetworkSuccess<List<FruitEntity>>>());
      final successResult = result as NetworkSuccess<List<FruitEntity>>;
      expect(successResult.data, isEmpty);
      verify(() => mockSearchRemoteDataSource.searchFruits(tQuery)).called(1);
      verifyNoMoreInteractions(mockSearchRemoteDataSource);
    });

    test('should return NetworkSuccess with empty list when remote data source returns NetworkSuccess with null data', () async {
      // Arrange
      when(() => mockSearchRemoteDataSource.searchFruits(any()))
          .thenAnswer((_) async => const NetworkSuccess(null));

      // Act
      final result = await sut.searchFruits(tQuery);

      // Assert
      expect(result, isA<NetworkSuccess<List<FruitEntity>>>());
      final successResult = result as NetworkSuccess<List<FruitEntity>>;
      expect(successResult.data, isEmpty);
      verify(() => mockSearchRemoteDataSource.searchFruits(tQuery)).called(1);
      verifyNoMoreInteractions(mockSearchRemoteDataSource);
    });

    test('should return NetworkFailure with same failure when remote data source returns NetworkFailure', () async {
      // Arrange
      when(() => mockSearchRemoteDataSource.searchFruits(any()))
          .thenAnswer((_) async => const NetworkFailure(tServerFailure));

      // Act
      final result = await sut.searchFruits(tQuery);

      // Assert
      expect(result, isA<NetworkFailure<List<FruitEntity>>>());
      final failureResult = result as NetworkFailure<List<FruitEntity>>;
      expect(failureResult.failure.error, tServerFailure.error);
      verify(() => mockSearchRemoteDataSource.searchFruits(tQuery)).called(1);
      verifyNoMoreInteractions(mockSearchRemoteDataSource);
    });
  });
}
