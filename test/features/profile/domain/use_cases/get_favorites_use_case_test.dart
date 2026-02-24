import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/helpers/network_response.dart';
import 'package:fruit_hub/features/profile/domain/repo/profile_repo.dart';
import 'package:fruit_hub/features/profile/domain/use_cases/get_favorites_use_case.dart';
import 'package:mocktail/mocktail.dart';

class MockProfileRepo extends Mock implements ProfileRepo {}

void main() {
  late GetFavoritesUseCase sut;
  late MockProfileRepo mockProfileRepo;

  List<FruitEntity> fruits = [const FruitEntity(), const FruitEntity(), const FruitEntity()];

  final tSuccessResponseOfTypeListFruitEntity =
      NetworkSuccess<List<FruitEntity>>(fruits);
  final tFailureResponseOfTypeListFruitEntity =
      NetworkFailure<List<FruitEntity>>(Exception("permission-denied"));

  setUp(() {
    mockProfileRepo = MockProfileRepo();
    sut = GetFavoritesUseCase(mockProfileRepo);
  });

  group("GetFavoritesUseCase", () {
    final tIds = ['apple_id_1'];
    test('should get favorites from repo successfully', () async {
      // Arrange
      when(
        () => mockProfileRepo.getFavorites(tIds),
      ).thenAnswer((_) async => tSuccessResponseOfTypeListFruitEntity);
      // Act
      final result = await sut(tIds);
      // Assert
      expect(result, tSuccessResponseOfTypeListFruitEntity);
      verify(() => mockProfileRepo.getFavorites(tIds)).called(1);
      verifyNoMoreInteractions(mockProfileRepo);
    });

    test('should return failure when repo fails', () async {
      // Arrange
      when(
        () => mockProfileRepo.getFavorites(tIds),
      ).thenAnswer((_) async => tFailureResponseOfTypeListFruitEntity);
      // Act
      final result = await sut(tIds);
      // Assert
      expect(result, tFailureResponseOfTypeListFruitEntity);
      verify(() => mockProfileRepo.getFavorites(tIds)).called(1);
      verifyNoMoreInteractions(mockProfileRepo);
    });
  });
}
