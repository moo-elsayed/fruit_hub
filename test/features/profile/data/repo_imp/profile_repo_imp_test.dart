import 'package:flutter_test/flutter_test.dart';
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
  });
}
