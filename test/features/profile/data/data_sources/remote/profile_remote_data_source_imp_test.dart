import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/helpers/functions.dart';
import 'package:fruit_hub/core/helpers/network_response.dart';
import 'package:fruit_hub/core/services/database/database_service.dart';
import 'package:fruit_hub/core/services/database/query_parameters.dart';
import 'package:fruit_hub/features/profile/data/data_sources/remote/profile_remote_data_source_imp.dart';
import 'package:mocktail/mocktail.dart';

class MockDatabaseService extends Mock implements DatabaseService {}

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

void main() {
  late ProfileRemoteDataSourceImp sut;
  late MockDatabaseService mockDatabaseService;
  late MockFirebaseAuth mockFirebaseAuth;
  late MockUser mockUser;

  const tPath = 'users';
  const tUserId = 'test_user_id_123';
  const tProductId = 'apple_red';
  final tFirebaseException = FirebaseException(
    plugin: 'firestore',
    code: 'permission-denied',
    message: 'Permission denied on collection.',
  );
  const tRawData = [
    {
      'name': 'mango',
      'description':
          'Este combo é composto por uma seleção de frutas vermelhas frescas e suculentas, incluindo morangos, framboesas, mirtilos e amoras. Elas são ricas em antioxidantes, vitaminas e fibras, tornando-as uma opção saudável e deliciosa para qualquer hora do dia. São perfeitas para consumir in natura, em saladas de frutas, smoothies, iogurtes ou como ingrediente em diversas receitas.',
      'price': 18.5,
      'imagePath': 'assets/images/combo_frutas_vermelhas.png',
      'code': 'FV001',
      'isFeatured': true,
      'avgRating': 4.8,
      'ratingCount': 250,
      'isOrganic': true,
      'daysUntilExpiration': 5,
      'unitAmount': 500,
      'numberOfCalories': 57,
      'reviews': [],
      'sellingCount': 100,
    },
  ];

  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
    registerFallbackValue(const QueryParameters());
  });

  setUp(() {
    mockDatabaseService = MockDatabaseService();
    mockFirebaseAuth = MockFirebaseAuth();
    mockUser = MockUser();
    sut = ProfileRemoteDataSourceImp(mockDatabaseService, mockFirebaseAuth);
    when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);
    when(() => mockUser.uid).thenReturn(tUserId);
  });

  group('add item to favorites', () {
    test(
      'should return NetworkSuccess when updateData is successful',
      () async {
        // Arrange
        when(
          () => mockDatabaseService.updateData(
            path: tPath,
            documentId: tUserId,
            data: captureAny(named: 'data'),
          ),
        ).thenAnswer((_) async => Future.value());
        // Act
        final result = await sut.addItemToFavorites(tProductId);
        // Assert
        expect(result, isA<NetworkSuccess<void>>());
        final capturedData =
            verify(
                  () => mockDatabaseService.updateData(
                    path: tPath,
                    documentId: tUserId,
                    data: captureAny(named: 'data'),
                  ),
                ).captured.first
                as Map<String, dynamic>;
        expect(capturedData['favoriteIds'], isA<FieldValue>());
        verify(() => mockFirebaseAuth.currentUser).called(1);
        verifyNoMoreInteractions(mockDatabaseService);
      },
    );

    test('should return NetworkFailure when user is not logged in', () async {
      // Arrange
      when(() => mockFirebaseAuth.currentUser).thenReturn(null);
      // Act
      final result = await sut.addItemToFavorites(tProductId);
      // Assert
      expect(result, isA<NetworkFailure>());
      expect(getErrorMessage(result), contains("user_not_logged_in"));
      verify(() => mockFirebaseAuth.currentUser).called(1);
      verifyNever(
        () => mockDatabaseService.updateData(
          path: any(named: 'path'),
          documentId: any(named: 'documentId'),
          data: any(named: 'data'),
        ),
      );
      verifyNoMoreInteractions(mockDatabaseService);
    });

    test(
      'should return NetworkFailure when FirebaseException occurs',
      () async {
        // Arrange
        when(
          () => mockDatabaseService.updateData(
            path: tPath,
            documentId: tUserId,
            data: captureAny(named: 'data'),
          ),
        ).thenThrow(tFirebaseException);
        // Act
        final result = await sut.addItemToFavorites(tProductId);
        // Assert
        expect(result, isA<NetworkFailure>());
        expect(getErrorMessage(result), contains("permission-denied"));
        verify(() => mockFirebaseAuth.currentUser).called(1);
        verify(
          () => mockDatabaseService.updateData(
            path: tPath,
            documentId: tUserId,
            data: captureAny(named: 'data'),
          ),
        ).called(1);
        verifyNoMoreInteractions(mockDatabaseService);
      },
    );
  });

  group('remove item from favorites', () {
    test(
      'should return NetworkSuccess when updateData is successful',
      () async {
        // Arrange
        when(
          () => mockDatabaseService.updateData(
            path: tPath,
            documentId: tUserId,
            data: captureAny(named: 'data'),
          ),
        ).thenAnswer((_) async => Future.value());
        // Act
        final result = await sut.removeItemFromFavorites(tProductId);
        // Assert
        expect(result, isA<NetworkSuccess<void>>());
        final capturedData =
            verify(
                  () => mockDatabaseService.updateData(
                    path: tPath,
                    documentId: tUserId,
                    data: captureAny(named: 'data'),
                  ),
                ).captured.first
                as Map<String, dynamic>;
        expect(capturedData['favoriteIds'], isA<FieldValue>());
        verify(() => mockFirebaseAuth.currentUser).called(1);
        verifyNoMoreInteractions(mockDatabaseService);
      },
    );

    test('should return NetworkFailure when user is not logged in', () async {
      // Arrange
      when(() => mockFirebaseAuth.currentUser).thenReturn(null);
      // Act
      final result = await sut.removeItemFromFavorites(tProductId);
      // Assert
      expect(result, isA<NetworkFailure>());
      expect(getErrorMessage(result), contains("user_not_logged_in"));
      verify(() => mockFirebaseAuth.currentUser).called(1);
      verifyNever(
        () => mockDatabaseService.updateData(
          path: any(named: 'path'),
          documentId: any(named: 'documentId'),
          data: any(named: 'data'),
        ),
      );
      verifyNoMoreInteractions(mockDatabaseService);
    });

    test(
      'should return NetworkFailure when FirebaseException occurs',
      () async {
        // Arrange
        when(
          () => mockDatabaseService.updateData(
            path: tPath,
            documentId: tUserId,
            data: captureAny(named: 'data'),
          ),
        ).thenThrow(tFirebaseException);
        // Act
        final result = await sut.removeItemFromFavorites(tProductId);
        // Assert
        expect(result, isA<NetworkFailure>());
        expect(getErrorMessage(result), contains("permission-denied"));
        verify(() => mockFirebaseAuth.currentUser).called(1);
        verify(
          () => mockDatabaseService.updateData(
            path: tPath,
            documentId: tUserId,
            data: captureAny(named: 'data'),
          ),
        ).called(1);
        verifyNoMoreInteractions(mockDatabaseService);
      },
    );
  });

  group('get favorite ids', () {
    const favoritesIds = 'favoriteIds';
    test(
      'should return NetworkSuccess with list of IDs when data exists',
      () async {
        // Arrange
        final tFavoritesList = ['id1', 'id2'];
        final tUserData = {favoritesIds: tFavoritesList};
        when(
          () => mockDatabaseService.getData(path: tPath, documentId: tUserId),
        ).thenAnswer((_) async => tUserData);
        // Act
        final result = await sut.getFavoriteIds();
        // Assert
        expect(result, isA<NetworkSuccess<List<String>>>());
        expect((result as NetworkSuccess<List<String>>).data, tFavoritesList);
        verify(() => mockFirebaseAuth.currentUser).called(1);
        verify(
          () => mockDatabaseService.getData(path: tPath, documentId: tUserId),
        ).called(1);
        verifyNoMoreInteractions(mockDatabaseService);
      },
    );

    test(
      'should return NetworkSuccess with empty list when key does not exist',
      () async {
        // Arrange
        final tUserData = {'name': 'John Doe'};
        when(
          () => mockDatabaseService.getData(path: tPath, documentId: tUserId),
        ).thenAnswer((_) async => tUserData);
        // Act
        final result = await sut.getFavoriteIds();
        // Assert
        expect(result, isA<NetworkSuccess<List<String>>>());
        expect((result as NetworkSuccess<List<String>>).data, isEmpty);
        verify(() => mockFirebaseAuth.currentUser).called(1);
        verify(
          () => mockDatabaseService.getData(path: tPath, documentId: tUserId),
        ).called(1);
        verifyNoMoreInteractions(mockDatabaseService);
      },
    );

    test('should return NetworkFailure when user is not logged in', () async {
      // Arrange
      when(() => mockFirebaseAuth.currentUser).thenReturn(null);
      // Act
      final result = await sut.getFavoriteIds();
      // Assert
      expect(result, isA<NetworkFailure>());
      expect(getErrorMessage(result), contains("user_not_logged_in"));
      verify(() => mockFirebaseAuth.currentUser).called(1);
      verifyNever(
        () => mockDatabaseService.getData(
          path: any(named: 'path'),
          documentId: any(named: 'documentId'),
        ),
      );
      verifyNoMoreInteractions(mockDatabaseService);
    });

    test(
      'should return NetworkFailure when FirebaseException occurs',
      () async {
        // Arrange
        when(
          () => mockDatabaseService.getData(path: tPath, documentId: tUserId),
        ).thenThrow(tFirebaseException);
        // Act
        final result = await sut.getFavoriteIds();
        // Assert
        expect(result, isA<NetworkFailure>());
        expect(getErrorMessage(result), contains("permission-denied"));
        verify(() => mockFirebaseAuth.currentUser).called(1);
        verify(
          () => mockDatabaseService.getData(path: tPath, documentId: tUserId),
        ).called(1);
        verifyNoMoreInteractions(mockDatabaseService);
      },
    );
  });

  group('get favorites', () {
    const queryProducts = 'products';
    final tIds = ['apple_id_1'];
    test(
      'should return NetworkSuccess with List<FruitEntity> when data exists',
      () async {
        // Arrange
        when(
          () => mockDatabaseService.queryData(
            path: queryProducts,
            query: any(named: 'query'),
          ),
        ).thenAnswer((_) async => tRawData);
        // Act
        final result = await sut.getFavorites(tIds);
        // Assert
        expect(result, isA<NetworkSuccess<List<FruitEntity>>>());
        expect(
          (result as NetworkSuccess<List<FruitEntity>>).data,
          isA<List<FruitEntity>>(),
        );
        verify(
          () => mockDatabaseService.queryData(
            path: queryProducts,
            query: any(
              named: 'query',
              that: isA<QueryParameters>().having(
                (q) => q.whereInIds,
                'whereInIds',
                tIds,
              ),
            ),
          ),
        ).called(1);
        verifyNoMoreInteractions(mockDatabaseService);
      },
    );

    test(
      'should return NetworkSuccess with empty list immediately if ids is empty',
      () async {
        // Arrange
        // Act
        final result = await sut.getFavorites([]);
        // Assert
        expect(result, isA<NetworkSuccess<List<FruitEntity>>>());
        expect((result as NetworkSuccess<List<FruitEntity>>).data, isEmpty);
        verifyNever(
          () => mockDatabaseService.queryData(
            path: queryProducts,
            query: any(named: 'query'),
          ),
        );
        verifyNoMoreInteractions(mockDatabaseService);
      },
    );

    test(
      'should return NetworkFailure when FirebaseException occurs',
      () async {
        // Arrange
        when(
          () => mockDatabaseService.queryData(
            path: queryProducts,
            query: any(named: 'query'),
          ),
        ).thenThrow(tFirebaseException);
        // Act
        final result = await sut.getFavorites(tIds);
        // Assert
        expect(result, isA<NetworkFailure>());
        expect(getErrorMessage(result), contains("permission-denied"));
        verify(
          () => mockDatabaseService.queryData(
            path: queryProducts,
            query: any(named: 'query'),
          ),
        ).called(1);
        verifyNoMoreInteractions(mockDatabaseService);
      },
    );

    test(
      'should return NetworkFailure when Parsing/Generic Exception occurs',
      () async {
        // Arrange
        when(
          () => mockDatabaseService.queryData(
            path: queryProducts,
            query: any(named: 'query'),
          ),
        ).thenThrow(Exception("parsing error"));
        // Act
        final result = await sut.getFavorites(tIds);
        // Assert
        expect(result, isA<NetworkFailure>());
        expect(getErrorMessage(result), contains("parsing error"));
        verify(
          () => mockDatabaseService.queryData(
            path: queryProducts,
            query: any(named: 'query'),
          ),
        ).called(1);
        verifyNoMoreInteractions(mockDatabaseService);
      },
    );
  });
}
