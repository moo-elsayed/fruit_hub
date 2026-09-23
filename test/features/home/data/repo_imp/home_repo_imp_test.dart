import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/errors/failures.dart';
import 'package:fruit_hub/core/models/fruit_model.dart';
import 'package:fruit_hub/core/models/review_model.dart';
import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/features/home/data/data_sources/remote/home_remote_data_source.dart';
import 'package:fruit_hub/features/home/data/repo_imp/home_repo_imp.dart';
import 'package:mocktail/mocktail.dart';

class MockHomeRemoteDataSource extends Mock implements HomeRemoteDataSource {}

void main() {
  late MockHomeRemoteDataSource mockHomeRemoteDataSource;
  late HomeRepoImp sut;

  final tFruitModel1 = FruitModel(
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
    sellingCount: 100,
    reviews: [
      const ReviewModel(
        name: 'أحمد',
        image: 'img.png',
        description: 'ممتاز',
        date: '2026-09-20',
        rating: 5.0,
        userId: 'u1',
      ),
    ],
  );

  final tFruitModel2 = FruitModel(
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
    sellingCount: 85,
    reviews: [],
  );

  setUp(() {
    mockHomeRemoteDataSource = MockHomeRemoteDataSource();
    sut = HomeRepoImp(mockHomeRemoteDataSource);
  });

  group('HomeRepoImp - getBestSellerProducts', () {
    test('should return NetworkSuccess with mapped FruitEntity list when data source returns NetworkSuccess', () async {
      // Arrange
      when(
        () => mockHomeRemoteDataSource.getBestSellerProducts(),
      ).thenAnswer((_) async => NetworkSuccess([tFruitModel1, tFruitModel2]));

      // Act
      final result = await sut.getBestSellerProducts();

      // Assert
      expect(result, isA<NetworkSuccess<List<FruitEntity>>>());
      final entities = (result as NetworkSuccess<List<FruitEntity>>).data!;
      expect(entities.length, 2);

      expect(entities[0].code, tFruitModel1.code);
      expect(entities[0].name, tFruitModel1.name);
      expect(entities[0].price, tFruitModel1.price);
      expect(entities[0].description, tFruitModel1.description);
      expect(entities[0].imagePath, tFruitModel1.imagePath);
      expect(entities[0].isFeatured, tFruitModel1.isFeatured);
      expect(entities[0].avgRating, tFruitModel1.avgRating);
      expect(entities[0].ratingCount, tFruitModel1.ratingCount);
      expect(entities[0].isOrganic, tFruitModel1.isOrganic);
      expect(entities[0].daysUntilExpiration, tFruitModel1.daysUntilExpiration);
      expect(entities[0].weightInGrams, tFruitModel1.weightInGrams);
      expect(entities[0].numberOfCalories, tFruitModel1.numberOfCalories);
      expect(entities[0].reviews.length, 1);
      expect(entities[0].reviews.first.name, 'أحمد');

      expect(entities[1].code, tFruitModel2.code);
      expect(entities[1].name, tFruitModel2.name);
      expect(entities[1].price, tFruitModel2.price);
      expect(entities[1].reviews, isEmpty);

      verify(() => mockHomeRemoteDataSource.getBestSellerProducts()).called(1);
      verifyNoMoreInteractions(mockHomeRemoteDataSource);
    });

    test('should return NetworkSuccess with empty list when data source returns NetworkSuccess with null or empty list', () async {
      // Arrange
      when(() => mockHomeRemoteDataSource.getBestSellerProducts())
          .thenAnswer((_) async => const NetworkSuccess(null));

      // Act
      final result = await sut.getBestSellerProducts();

      // Assert
      expect(result, isA<NetworkSuccess<List<FruitEntity>>>());
      final entities = (result as NetworkSuccess<List<FruitEntity>>).data!;
      expect(entities, isEmpty);

      verify(() => mockHomeRemoteDataSource.getBestSellerProducts()).called(1);
      verifyNoMoreInteractions(mockHomeRemoteDataSource);
    });

    test('should return NetworkFailure with same ServerFailure when data source returns NetworkFailure', () async {
      // Arrange
      const expectedFailure = ServerFailure(error: 'فشل الاتصال بالخادم');
      when(() => mockHomeRemoteDataSource.getBestSellerProducts())
          .thenAnswer((_) async => const NetworkFailure(expectedFailure));

      // Act
      final result = await sut.getBestSellerProducts();

      // Assert
      expect(result, isA<NetworkFailure<List<FruitEntity>>>());
      final failure = (result as NetworkFailure<List<FruitEntity>>).failure;
      expect(failure, equals(expectedFailure));
      expect(failure.error, 'فشل الاتصال بالخادم');

      verify(() => mockHomeRemoteDataSource.getBestSellerProducts()).called(1);
      verifyNoMoreInteractions(mockHomeRemoteDataSource);
    });
  });
}
