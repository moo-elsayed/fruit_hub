import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/helpers/functions.dart';
import 'package:fruit_hub/core/helpers/network_response.dart';
import 'package:fruit_hub/features/profile/data/data_sources/remote/profile_remote_data_source.dart';
import 'package:fruit_hub/features/profile/data/repo_imp/profile_repo_imp.dart';
import 'package:mocktail/mocktail.dart';

class MockProfileRemoteDataSource extends Mock
    implements ProfileRemoteDataSource {}

void main() {
  late ProfileRepoImp sut;
  late MockProfileRemoteDataSource mockProfileRemoteDataSource;

  const tProductId = 'apple_red';
  final tSuccessResponseOfTypeVoid = const NetworkSuccess<void>();
  final tFailureResponseOfTypeVoid = NetworkFailure<void>(
    Exception("permission-denied"),
  );
  const tFavoritesList = ['id1', 'id2'];
  final tSuccessResponseOfTypeListOfString = const NetworkSuccess<List<String>>(
    tFavoritesList,
  );
  final tFailureResponseOfTypeListOfString = NetworkFailure<List<String>>(
    Exception("permission-denied"),
  );
  List<FruitEntity> fruits = [const FruitEntity(), const FruitEntity(), const FruitEntity()];

  final tSuccessResponseOfTypeListFruitEntity =
      NetworkSuccess<List<FruitEntity>>(fruits);
  final tFailureResponseOfTypeListFruitEntity =
      NetworkFailure<List<FruitEntity>>(Exception("permission-denied"));

  setUp(() {
    mockProfileRemoteDataSource = MockProfileRemoteDataSource();
    sut = ProfileRepoImp(mockProfileRemoteDataSource);
  });

  group('ProfileRepoImp', () {
    group('add item to favorites', () {
      test(
        'should call addItemToFavorites from remote data source with correct params when success response',
        () async {
          // Arrange
          when(
            () => mockProfileRemoteDataSource.addItemToFavorites(tProductId),
          ).thenAnswer((_) async => tSuccessResponseOfTypeVoid);
          // Act
          var result = await sut.addItemToFavorites(tProductId);
          // Assert
          expect(result, tSuccessResponseOfTypeVoid);
          verify(
            () => mockProfileRemoteDataSource.addItemToFavorites(tProductId),
          ).called(1);
          verifyNoMoreInteractions(mockProfileRemoteDataSource);
        },
      );

      test(
        'should return failure when addItemToCart from remote data source returns failure response',
        () async {
          // Arrange
          when(
            () => mockProfileRemoteDataSource.addItemToFavorites(tProductId),
          ).thenAnswer((_) async => tFailureResponseOfTypeVoid);
          // Act
          var result = await sut.addItemToFavorites(tProductId);
          // Assert
          expect(result, tFailureResponseOfTypeVoid);
          expect(getErrorMessage(result), "permission-denied");
          verify(
            () => mockProfileRemoteDataSource.addItemToFavorites(tProductId),
          ).called(1);
          verifyNoMoreInteractions(mockProfileRemoteDataSource);
        },
      );
    });

    group('remove item from favorites', () {
      test(
        'should call removeItemFromFavorites from remote data source with correct params when success response',
        () async {
          // Arrange
          when(
            () =>
                mockProfileRemoteDataSource.removeItemFromFavorites(tProductId),
          ).thenAnswer((_) async => tSuccessResponseOfTypeVoid);
          // Act
          var result = await sut.removeItemFromFavorites(tProductId);
          // Assert
          expect(result, tSuccessResponseOfTypeVoid);
          verify(
            () =>
                mockProfileRemoteDataSource.removeItemFromFavorites(tProductId),
          ).called(1);
          verifyNoMoreInteractions(mockProfileRemoteDataSource);
        },
      );

      test(
        'should return failure when removeItemFromFavorites from remote data source returns failure response',
        () async {
          // Arrange
          when(
            () =>
                mockProfileRemoteDataSource.removeItemFromFavorites(tProductId),
          ).thenAnswer((_) async => tFailureResponseOfTypeVoid);
          // Act
          var result = await sut.removeItemFromFavorites(tProductId);
          // Assert
          expect(result, tFailureResponseOfTypeVoid);
          expect(getErrorMessage(result), "permission-denied");
          verify(
            () =>
                mockProfileRemoteDataSource.removeItemFromFavorites(tProductId),
          ).called(1);
          verifyNoMoreInteractions(mockProfileRemoteDataSource);
        },
      );
    });

    group('get favorite ids', () {
      test(
        'should call getFavoriteIds from remote data source with correct params when success response',
        () async {
          // Arrange
          when(
            () => mockProfileRemoteDataSource.getFavoriteIds(),
          ).thenAnswer((_) async => tSuccessResponseOfTypeListOfString);
          // Act
          var result = await sut.getFavoriteIds();
          // Assert
          expect(result, tSuccessResponseOfTypeListOfString);
          verify(() => mockProfileRemoteDataSource.getFavoriteIds()).called(1);
          verifyNoMoreInteractions(mockProfileRemoteDataSource);
        },
      );

      test(
        'should return failure when getFavoriteIds from remote data source returns failure response',
        () async {
          // Arrange
          when(
            () => mockProfileRemoteDataSource.getFavoriteIds(),
          ).thenAnswer((_) async => tFailureResponseOfTypeListOfString);
          // Act
          var result = await sut.getFavoriteIds();
          // Assert
          expect(result, tFailureResponseOfTypeListOfString);
          expect(getErrorMessage(result), "permission-denied");
          verify(() => mockProfileRemoteDataSource.getFavoriteIds()).called(1);
          verifyNoMoreInteractions(mockProfileRemoteDataSource);
        },
      );
    });

    group('get favorites', () {
      final tIds = ['apple_id_1'];
      test(
        'should call getFavorites from remote data source with correct params when success response',
        () async {
          // Arrange
          when(
            () => mockProfileRemoteDataSource.getFavorites(tIds),
          ).thenAnswer((_) async => tSuccessResponseOfTypeListFruitEntity);
          // Act
          var result = await sut.getFavorites(tIds);
          // Assert
          expect(result, tSuccessResponseOfTypeListFruitEntity);
          verify(
            () => mockProfileRemoteDataSource.getFavorites(tIds),
          ).called(1);
          verifyNoMoreInteractions(mockProfileRemoteDataSource);
        },
      );

      test(
        'should return failure when getFavorites from remote data source returns failure response',
        () async {
          // Arrange
          when(
            () => mockProfileRemoteDataSource.getFavorites(tIds),
          ).thenAnswer((_) async => tFailureResponseOfTypeListFruitEntity);
          // Act
          var result = await sut.getFavorites(tIds);
          // Assert
          expect(result, tFailureResponseOfTypeListFruitEntity);
          expect(getErrorMessage(result), "permission-denied");
          verify(
            () => mockProfileRemoteDataSource.getFavorites(tIds),
          ).called(1);
          verifyNoMoreInteractions(mockProfileRemoteDataSource);
        },
      );
    });
  });
}
