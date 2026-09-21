import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/errors/failures.dart';
import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/features/search/domain/repo/search_repo.dart';
import 'package:fruit_hub/features/search/domain/use_cases/search_fruits_use_case.dart';
import 'package:mocktail/mocktail.dart';

class MockSearchRepo extends Mock implements SearchRepo {}

void main() {
  late MockSearchRepo mockSearchRepo;
  late SearchFruitsUseCase sut;

  const tQuery = 'تفاح';

  const tFruitEntities = [
    FruitEntity(
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
    ),
  ];

  const tServerFailure = ServerFailure(error: 'Failed to search fruits');

  setUp(() {
    mockSearchRepo = MockSearchRepo();
    sut = SearchFruitsUseCase(mockSearchRepo);
  });

  test(
    'should call searchFruits on SearchRepo with query and return NetworkSuccess<List<FruitEntity>>',
    () async {
      // Arrange
      when(
        () => mockSearchRepo.searchFruits(any()),
      ).thenAnswer((_) async => const NetworkSuccess(tFruitEntities));

      // Act
      final result = await sut(tQuery);

      // Assert
      expect(result, isA<NetworkSuccess<List<FruitEntity>>>());
      final successResult = result as NetworkSuccess<List<FruitEntity>>;
      expect(successResult.data, tFruitEntities);
      verify(() => mockSearchRepo.searchFruits(tQuery)).called(1);
      verifyNoMoreInteractions(mockSearchRepo);
    },
  );

  test(
    'should return NetworkFailure when SearchRepo fails during searchFruits',
    () async {
      // Arrange
      when(
        () => mockSearchRepo.searchFruits(any()),
      ).thenAnswer((_) async => const NetworkFailure(tServerFailure));

      // Act
      final result = await sut(tQuery);

      // Assert
      expect(result, isA<NetworkFailure<List<FruitEntity>>>());
      final failureResult = result as NetworkFailure<List<FruitEntity>>;
      expect(failureResult.failure.error, tServerFailure.error);
      verify(() => mockSearchRepo.searchFruits(tQuery)).called(1);
      verifyNoMoreInteractions(mockSearchRepo);
    },
  );
}
