import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/helpers/functions.dart';
import 'package:fruit_hub/core/helpers/network_response.dart';
import 'package:fruit_hub/features/search/data/data_sources/search_remote_data_source.dart';
import 'package:fruit_hub/features/search/data/repo_imp/search_repo_imp.dart';
import 'package:mocktail/mocktail.dart';

class MockSearchRemoteDataSource extends Mock
    implements SearchRemoteDataSource {}

void main() {
  late SearchRepoImp sut;
  late MockSearchRemoteDataSource mockSearchRemoteDataSource;
  const tSearchQuery = 'man';
  List<FruitEntity> fruits = [FruitEntity(), FruitEntity(), FruitEntity()];

  final tSuccessResponse = NetworkSuccess<List<FruitEntity>>(fruits);
  final tFailureResponse = NetworkFailure<List<FruitEntity>>(
    Exception("permission-denied"),
  );

  setUp(() {
    mockSearchRemoteDataSource = MockSearchRemoteDataSource();
    sut = SearchRepoImp(mockSearchRemoteDataSource);
  });

  group('search repo imp', () {
    test(
      'should call searchFruits on remote data source and return NetworkSuccess',
      () async {
        // Arrange
        when(
          () => mockSearchRemoteDataSource.searchFruits(tSearchQuery),
        ).thenAnswer((_) async => tSuccessResponse);
        // Act
        final result = await sut.searchFruits(tSearchQuery);
        // Assert
        expect(result, tSuccessResponse);
        verify(() => mockSearchRemoteDataSource.searchFruits(tSearchQuery));
        verifyNoMoreInteractions(mockSearchRemoteDataSource);
      },
    );

    test(
      'should call searchFruits on remote data source and return NetworkFailure',
      () async {
        // Arrange
        when(
          () => mockSearchRemoteDataSource.searchFruits(tSearchQuery),
        ).thenAnswer((_) async => tFailureResponse);
        // Act
        final result = await sut.searchFruits(tSearchQuery);
        // Assert
        expect(result, tFailureResponse);
        expect(getErrorMessage(result), "permission-denied");
        verify(() => mockSearchRemoteDataSource.searchFruits(tSearchQuery));
        verifyNoMoreInteractions(mockSearchRemoteDataSource);
      },
    );
  });
}
