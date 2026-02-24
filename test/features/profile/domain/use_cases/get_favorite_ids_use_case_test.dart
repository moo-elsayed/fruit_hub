import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/helpers/network_response.dart';
import 'package:fruit_hub/features/profile/domain/repo/profile_repo.dart';
import 'package:fruit_hub/features/profile/domain/use_cases/get_favorite_ids_use_case.dart';
import 'package:mocktail/mocktail.dart';

class MockProfileRepo extends Mock implements ProfileRepo {}

void main() {
  late GetFavoriteIdsUseCase sut;
  late MockProfileRepo mockProfileRepo;

  const tFavoritesList = ['id1', 'id2'];
  final tSuccessResponseOfTypeListOfString = const NetworkSuccess<List<String>>(
    tFavoritesList,
  );
  final tFailureResponseOfTypeListOfString = NetworkFailure<List<String>>(
    Exception("permission-denied"),
  );

  setUp(() {
    mockProfileRepo = MockProfileRepo();
    sut = GetFavoriteIdsUseCase(mockProfileRepo);
  });

  group('GetFavoriteIdsUseCase', () {
    test('should return a list of favorite ids', () async {
      // Arrange
      when(
        () => mockProfileRepo.getFavoriteIds(),
      ).thenAnswer((_) async => tSuccessResponseOfTypeListOfString);
      // Act
      final result = await sut();
      // Assert
      expect(result, tSuccessResponseOfTypeListOfString);
      verify(() => mockProfileRepo.getFavoriteIds()).called(1);
      verifyNoMoreInteractions(mockProfileRepo);
    });

    test('should return a failure response', () async {
      // Arrange
      when(
        () => mockProfileRepo.getFavoriteIds(),
      ).thenAnswer((_) async => tFailureResponseOfTypeListOfString);
      // Act
      final result = await sut();
      // Assert
      expect(result, tFailureResponseOfTypeListOfString);
      verify(() => mockProfileRepo.getFavoriteIds()).called(1);
      verifyNoMoreInteractions(mockProfileRepo);
    });
  });
}
