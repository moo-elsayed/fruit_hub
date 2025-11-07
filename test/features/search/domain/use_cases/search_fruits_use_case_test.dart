import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/helpers/functions.dart';
import 'package:fruit_hub/core/helpers/network_response.dart';
import 'package:fruit_hub/features/search/domain/repo/search_repo.dart';
import 'package:fruit_hub/features/search/domain/use_cases/search_fruits_use_case.dart';
import 'package:mocktail/mocktail.dart';

class MockSearchRepo extends Mock implements SearchRepo {}

void main() {
  late SearchFruitsUseCase sut;
  late MockSearchRepo mockSearchRepo;

  List<FruitEntity> fruits = [FruitEntity(), FruitEntity(), FruitEntity()];
  const tSearchQuery = 'man';
  final tSuccessResponse = NetworkSuccess<List<FruitEntity>>(fruits);
  final tFailureResponse = NetworkFailure<List<FruitEntity>>(
    Exception("permission-denied"),
  );

  setUp(() {
    mockSearchRepo = MockSearchRepo();
    sut = SearchFruitsUseCase(mockSearchRepo);
  });

  group('search fruits use case', () {
    test(
      'should return a list of fruits when the call to the repository is successful',
      () async {
        // Arrange
        when(
          () => mockSearchRepo.searchFruits(tSearchQuery),
        ).thenAnswer((_) async => tSuccessResponse);
        // Act
        final result = await sut.call(tSearchQuery);
        // Assert
        expect(result, tSuccessResponse);
        verify(() => mockSearchRepo.searchFruits(tSearchQuery)).called(1);
        verifyNoMoreInteractions(mockSearchRepo);
      },
    );

    test(
      'should return a failure when the call to the repository is unsuccessful',
      () async {
        // Arrange
        when(
          () => mockSearchRepo.searchFruits(tSearchQuery),
        ).thenAnswer((_) async => tFailureResponse);

        // Act
        final result = await sut.call(tSearchQuery);

        // Assert
        expect(result, tFailureResponse);
        expect(getErrorMessage(result), "permission-denied");
        verify(() => mockSearchRepo.searchFruits(tSearchQuery)).called(1);
        verifyNoMoreInteractions(mockSearchRepo);
      },
    );
  });
}
