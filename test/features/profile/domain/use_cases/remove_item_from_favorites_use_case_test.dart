import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/helpers/functions.dart';
import 'package:fruit_hub/core/helpers/network_response.dart';
import 'package:fruit_hub/features/profile/domain/repo/profile_repo.dart';
import 'package:fruit_hub/features/profile/domain/use_cases/remove_item_from_favorites_use_case.dart';
import 'package:mocktail/mocktail.dart';

class MockProfileRepo extends Mock implements ProfileRepo {}

void main() {
  late RemoveItemFromFavoritesUseCase sut;
  late MockProfileRepo mockRepo;

  const tProductId = 'apple_red';
  final tSuccessResponseOfTypeVoid = const NetworkSuccess<void>();
  final tFailureResponseOfTypeVoid = NetworkFailure<void>(
    Exception("permission-denied"),
  );

  setUp(() {
    mockRepo = MockProfileRepo();
    sut = RemoveItemFromFavoritesUseCase(mockRepo);
  });

  group('RemoveItemFromFavoritesUseCase', () {
    test('should call repo with correct params and return success', () async {
      // Arrange
      when(
        () => mockRepo.removeItemFromFavorites(tProductId),
      ).thenAnswer((_) async => tSuccessResponseOfTypeVoid);
      // Act
      final result = await sut(tProductId);
      // Assert
      expect(result, tSuccessResponseOfTypeVoid);
      verify(() => mockRepo.removeItemFromFavorites(tProductId));
      verifyNoMoreInteractions(mockRepo);
    });

    test('should call repo with correct params and return failure', () async {
      // Arrange
      when(
        () => mockRepo.removeItemFromFavorites(tProductId),
      ).thenAnswer((_) async => tFailureResponseOfTypeVoid);
      // Act
      final result = await sut(tProductId);
      // Assert
      expect(result, tFailureResponseOfTypeVoid);
      expect(getErrorMessage(result), "permission-denied");
      verify(() => mockRepo.removeItemFromFavorites(tProductId));
      verifyNoMoreInteractions(mockRepo);
    });
  });
}
