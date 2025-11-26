import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/helpers/functions.dart';
import 'package:fruit_hub/core/helpers/network_response.dart';
import 'package:fruit_hub/features/home/data/data_sources/remote/home_remote_data_source.dart';
import 'package:fruit_hub/features/home/data/repo_imp/home_repo_imp.dart';
import 'package:mocktail/mocktail.dart';

class MockHomeRemoteDataSource extends Mock implements HomeRemoteDataSource {}

void main() {
  late HomeRepoImp sut;
  late MockHomeRemoteDataSource mockHomeRemoteDataSource;

  List<FruitEntity> fruits = [const FruitEntity(), const FruitEntity(), const FruitEntity()];

  final tSuccessResponse = NetworkSuccess<List<FruitEntity>>(fruits);
  final tFailureResponse = NetworkFailure<List<FruitEntity>>(
    Exception("permission-denied"),
  );

  setUp(() {
    mockHomeRemoteDataSource = MockHomeRemoteDataSource();
    sut = HomeRepoImp(mockHomeRemoteDataSource);
  });

  group("HomeRepoImp", () {
    test(
      'should call getBestSellerProducts on remote data source and return NetworkSuccess',
      () async {
        // Arrange
        when(
          () => mockHomeRemoteDataSource.getBestSellerProducts(),
        ).thenAnswer((_) async => tSuccessResponse);
        // Act
        final result = await sut.getBestSellerProducts();
        // Assert
        expect(result, tSuccessResponse);
        verify(
          () => mockHomeRemoteDataSource.getBestSellerProducts(),
        ).called(1);
        verifyNoMoreInteractions(mockHomeRemoteDataSource);
      },
    );

    test(
      'should call getBestSellerProducts on remote data source and return NetworkFailure',
      () async {
        // Arrange
        when(
          () => mockHomeRemoteDataSource.getBestSellerProducts(),
        ).thenAnswer((_) async => tFailureResponse);

        // Act
        final result = await sut.getBestSellerProducts();

        // Assert
        expect(result, tFailureResponse);
        expect(getErrorMessage(result), "permission-denied");
        verify(
          () => mockHomeRemoteDataSource.getBestSellerProducts(),
        ).called(1);
        verifyNoMoreInteractions(mockHomeRemoteDataSource);
      },
    );
  });
}
