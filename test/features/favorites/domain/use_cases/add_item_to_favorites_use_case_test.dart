import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/errors/failures.dart';
import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/features/favorites/domain/repo/favorites_repo.dart';
import 'package:fruit_hub/features/favorites/domain/use_cases/add_item_to_favorites_use_case.dart';
import 'package:mocktail/mocktail.dart';

class MockFavoritesRepo extends Mock implements FavoritesRepo {}

void main() {
  late MockFavoritesRepo mockFavoritesRepo;
  late AddItemToFavoritesUseCase sut;

  const tProductId = 'prod_apple_01';

  setUp(() {
    mockFavoritesRepo = MockFavoritesRepo();
    sut = AddItemToFavoritesUseCase(mockFavoritesRepo);
  });

  group('AddItemToFavoritesUseCase', () {
    test('should return NetworkSuccess when favorites repo succeeds', () async {
      // Arrange
      when(() => mockFavoritesRepo.addItemToFavorites(tProductId))
          .thenAnswer((_) async => const NetworkSuccess(null));

      // Act
      final result = await sut(tProductId);

      // Assert
      expect(result, isA<NetworkSuccess<void>>());
      verify(() => mockFavoritesRepo.addItemToFavorites(tProductId)).called(1);
      verifyNoMoreInteractions(mockFavoritesRepo);
    });

    test('should return NetworkFailure with same failure when favorites repo fails', () async {
      // Arrange
      const tFailure = ServerFailure(error: 'Failed to add item to favorites');
      when(() => mockFavoritesRepo.addItemToFavorites(tProductId))
          .thenAnswer((_) async => const NetworkFailure(tFailure));

      // Act
      final result = await sut(tProductId);

      // Assert
      expect(result, isA<NetworkFailure<void>>());
      final failure = (result as NetworkFailure<void>).failure;
      expect(failure, equals(tFailure));
      verify(() => mockFavoritesRepo.addItemToFavorites(tProductId)).called(1);
      verifyNoMoreInteractions(mockFavoritesRepo);
    });
  });
}
