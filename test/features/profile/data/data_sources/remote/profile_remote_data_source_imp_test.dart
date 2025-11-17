import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/helpers/functions.dart';
import 'package:fruit_hub/core/helpers/network_response.dart';
import 'package:fruit_hub/core/services/database/database_service.dart';
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

  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
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
}
