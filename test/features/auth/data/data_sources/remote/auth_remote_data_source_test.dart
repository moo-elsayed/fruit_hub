import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/helpers/backend_endpoints.dart';
import 'package:fruit_hub/core/helpers/functions.dart';
import 'package:fruit_hub/core/helpers/network_response.dart';
import 'package:fruit_hub/core/services/authentication/auth_service.dart';
import 'package:fruit_hub/core/services/database/database_service.dart';
import 'package:fruit_hub/features/auth/data/data_sources/remote/auth_remote_data_source_imp.dart';
import 'package:fruit_hub/features/auth/domain/entities/user_entity.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthService extends Mock implements AuthService {}

class MockDatabaseService extends Mock implements DatabaseService {}

class MockFirebaseAuthException extends Mock implements FirebaseAuthException {}

void arrangeGetOrUpdateDBSuccess(MockDatabaseService mockDatabaseService) {
  when(
    () => mockDatabaseService.checkIfDataExists(
      path: any(named: 'path'),
      documentId: any(named: 'documentId'),
    ),
  ).thenAnswer((_) async => true);

  when(
    () => mockDatabaseService.updateData(
      path: any(named: 'path'),
      documentId: any(named: 'documentId'),
      data: any(named: 'data'),
    ),
  ).thenAnswer((_) async => Future.value());
}

void main() {
  late AuthRemoteDataSourceImp sut;
  late MockAuthService mockAuthService;
  late MockDatabaseService mockDatabaseService;
  late MockFirebaseAuthException mockFirebaseAuthException;
  const tEmail = 'test@test.com';
  const tPassword = 'password123';
  const tUsername = 'Test User';
  const tUserEntity = UserEntity(uid: '123', email: tEmail, isVerified: false);

  setUp(() {
    mockAuthService = MockAuthService();
    mockDatabaseService = MockDatabaseService();
    mockFirebaseAuthException = MockFirebaseAuthException();
    sut = AuthRemoteDataSourceImp(
      mockAuthService,
      mockDatabaseService,
    );

    when(
      () => mockAuthService.createUserWithEmailAndPassword(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async => tUserEntity);
    when(
      () => mockAuthService.sendEmailVerification(),
    ).thenAnswer((_) async => Future.value());

    when(
      () => mockAuthService.deleteCurrentUser(),
    ).thenAnswer((_) async => Future.value());

    when(
      () => mockDatabaseService.addData(
        docId: any(named: 'docId'),
        path: any(named: 'path'),
        data: any(named: 'data'),
      ),
    ).thenAnswer((_) async => Future.value());
  });

  group('createUserWithEmailAndPassword', () {
    test('should return NetworkSuccess with UserEntity', () async {
      // Arrange
      // Act
      final result = await sut
          .createUserWithEmailAndPassword(
            email: tEmail,
            password: tPassword,
            username: tUsername,
          );
      // Assert
      expect(result, isA<NetworkSuccess<UserEntity>>());
      expect((result as NetworkSuccess).data.name, equals(tUsername));
      verifyInOrder([
        () => mockAuthService.createUserWithEmailAndPassword(
          email: tEmail,
          password: tPassword,
        ),
        () => mockDatabaseService.addData(
          docId: tUserEntity.uid,
          path: BackendEndpoints.addUserData,
          data: any(named: 'data'),
        ),
        () => mockAuthService.sendEmailVerification(),
      ]);

      verifyNever(() => mockAuthService.deleteCurrentUser());
    });

    test(
      'should return NetworkFailure and delete user if auth fails (general auth error)',
      () async {
        // Arrange
        when(() => mockFirebaseAuthException.code).thenReturn('weak-password');
        when(
          () => mockFirebaseAuthException.message,
        ).thenReturn('Weak password');
        when(
          () => mockAuthService.createUserWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenThrow(mockFirebaseAuthException);
        // Act
        final result = await sut
            .createUserWithEmailAndPassword(
              email: tEmail,
              password: tPassword,
              username: tUsername,
            );
        // Assert
        expect(result, isA<NetworkFailure>());
        expect(
          getErrorMessage(result),
          contains('the_password_provided_is_too_weak'),
        );
        verify(() => mockAuthService.deleteCurrentUser()).called(1);
        verifyNever(
          () => mockDatabaseService.addData(
            docId: any(named: 'docId'),
            path: any(named: 'path'),
            data: any(named: 'data'),
          ),
        );
      },
    );
    test(
      'should return NetworkFailure but NOT delete user if code is "email-already-in-use"',
      () async {
        // Arrange
        when(
          () => mockFirebaseAuthException.code,
        ).thenReturn('email-already-in-use');
        when(
          () => mockFirebaseAuthException.message,
        ).thenReturn('Email already in use');
        when(
          () => mockAuthService.createUserWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenThrow(mockFirebaseAuthException);

        // Act
        final result = await sut
            .createUserWithEmailAndPassword(
              email: tEmail,
              password: tPassword,
              username: tUsername,
            );

        // Assert
        expect(result, isA<NetworkFailure>());
        expect(
          getErrorMessage(result),
          contains('the_account_already_exists_for_that_email'),
        );
        verifyNever(() => mockAuthService.deleteCurrentUser());
      },
    );
    test(
      'should return NetworkFailure and delete user if addData (database) fails',
      () async {
        // Arrange
        when(
          () => mockDatabaseService.addData(
            docId: any(named: 'docId'),
            path: any(named: 'path'),
            data: any(named: 'data'),
          ),
        ).thenThrow(Exception('Database failed'));
        // Act
        final result = await sut
            .createUserWithEmailAndPassword(
              email: tEmail,
              password: tPassword,
              username: tUsername,
            );
        // Assert
        expect(result, isA<NetworkFailure>());
        verify(() => mockAuthService.deleteCurrentUser()).called(1);
        verifyNever(() => mockAuthService.sendEmailVerification());
      },
    );
  });

  group('signInWithEmailAndPassword', () {
    final tVerifiedUserEntity = tUserEntity.copyWith(
      isVerified: true,
      name: tUsername,
    );

    final tUnverifiedUserEntity = tUserEntity.copyWith(
      isVerified: false,
      name: tUsername,
    );

    test('should return NetworkSuccess if user is verified', () async {
      // Arrange
      when(
        () => mockAuthService.signInWithEmailAndPassword(
          email: tEmail,
          password: tPassword,
        ),
      ).thenAnswer((_) async => tVerifiedUserEntity);
      arrangeGetOrUpdateDBSuccess(mockDatabaseService);

      // Act
      final result = await sut.signInWithEmailAndPassword(
        email: tEmail,
        password: tPassword,
      );

      // Assert
      expect(result, isA<NetworkSuccess<UserEntity>>());
      expect((result as NetworkSuccess).data.isVerified, isTrue);
      verify(
        () => mockDatabaseService.checkIfDataExists(
          path: BackendEndpoints.checkIfUserExists,
          documentId: tVerifiedUserEntity.uid,
        ),
      ).called(1);
      verify(
        () => mockDatabaseService.updateData(
          path: BackendEndpoints.updateUserData,
          documentId: tVerifiedUserEntity.uid,
          data: any(named: 'data'),
        ),
      ).called(1);
      verifyNever(() => mockAuthService.sendEmailVerification());
    });

    test(
      'should return NetworkFailure and send verification if user is NOT verified',
      () async {
        // Arrange
        when(
          () => mockAuthService.signInWithEmailAndPassword(
            email: tEmail,
            password: tPassword,
          ),
        ).thenAnswer((_) async => tUnverifiedUserEntity);
        // Act
        final result = await sut.signInWithEmailAndPassword(
          email: tEmail,
          password: tPassword,
        );
        // Assert
        expect(result, isA<NetworkFailure>());
        expect(getErrorMessage(result), contains('please_verify_your_email'));
        verify(() => mockAuthService.sendEmailVerification()).called(1);
        verifyNever(
          () => mockDatabaseService.checkIfDataExists(
            path: any(named: 'path'),
            documentId: any(named: 'documentId'),
          ),
        );
      },
    );

    test('should return NetworkFailure if auth itself fails', () async {
      // Arrange
      when(() => mockFirebaseAuthException.code).thenReturn('wrong-password');
      when(
        () => mockFirebaseAuthException.message,
      ).thenReturn('Wrong password');
      when(
        () => mockAuthService.signInWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(mockFirebaseAuthException);
      // Act
      final result = await sut.signInWithEmailAndPassword(
        email: tEmail,
        password: tPassword,
      );
      // Assert
      expect(result, isA<NetworkFailure>());
      expect(
        getErrorMessage(result),
        contains("wrong_password_provided_for_that_user"),
      );
      verifyNever(() => mockAuthService.sendEmailVerification());
      verifyNever(
        () => mockDatabaseService.checkIfDataExists(
          path: any(named: 'path'),
          documentId: any(named: 'documentId'),
        ),
      );
    });

    test(
      'should return NetworkFailure if _getOrUpdateUserFromDB fails',
      () async {
        // Arrange
        when(
          () => mockAuthService.signInWithEmailAndPassword(
            email: tEmail,
            password: tPassword,
          ),
        ).thenAnswer((_) async => tVerifiedUserEntity);

        final tException = Exception('Database failed');
        when(
          () => mockDatabaseService.checkIfDataExists(
            path: any(named: 'path'),
            documentId: any(named: 'documentId'),
          ),
        ).thenThrow(tException);

        // Act
        final result = await sut.signInWithEmailAndPassword(
          email: tEmail,
          password: tPassword,
        );
        // Assert
        expect(result, isA<NetworkFailure>());
        expect(
          getErrorMessage(result),
          contains('error_occurred_please_try_again'),
        );
      },
    );
  });

  group('googleSignIn', () {
    final tGoogledUserEntity = tUserEntity.copyWith(
      name: tUsername,
      isVerified: true,
    );

    test('should return NetworkSuccess', () async {
      // Arrange
      when(
        () => mockAuthService.googleSignIn(),
      ).thenAnswer((_) async => tGoogledUserEntity);
      arrangeGetOrUpdateDBSuccess(mockDatabaseService);
      // Act
      final result = await sut.googleSignIn();
      // Assert
      expect(result, isA<NetworkSuccess<UserEntity>>());
      expect((result as NetworkSuccess).data.uid, tGoogledUserEntity.uid);
      verify(() => mockAuthService.googleSignIn()).called(1);
      verify(
        () => mockDatabaseService.checkIfDataExists(
          path: BackendEndpoints.checkIfUserExists,
          documentId: tGoogledUserEntity.uid,
        ),
      ).called(1);
    });

    test('should return NetworkFailure if auth itself fails', () async {
      // Arrange
      when(
        () => mockFirebaseAuthException.code,
      ).thenReturn('network-request-failed');
      when(() => mockFirebaseAuthException.message).thenReturn('Network error');
      when(
        () => mockAuthService.googleSignIn(),
      ).thenThrow(mockFirebaseAuthException);
      // Act
      final result = await sut.googleSignIn();
      // Assert
      expect(result, isA<NetworkFailure>());
      expect(getErrorMessage(result), contains("network_error_message"));
      verifyNever(
        () => mockDatabaseService.checkIfDataExists(
          path: any(named: 'path'),
          documentId: any(named: 'documentId'),
        ),
      );
    });

    test(
      'should return NetworkFailure if _getOrUpdateUserFromDB fails',
      () async {
        // Arrange
        when(
          () => mockAuthService.googleSignIn(),
        ).thenAnswer((_) async => tGoogledUserEntity);

        final tException = Exception('Database failed');
        when(
          () => mockDatabaseService.checkIfDataExists(
            path: any(named: 'path'),
            documentId: any(named: 'documentId'),
          ),
        ).thenThrow(tException);

        // Act
        final result = await sut.googleSignIn();
        // Assert
        expect(result, isA<NetworkFailure>());
        expect(
          getErrorMessage(result),
          contains('error_occurred_please_try_again'),
        );
      },
    );
  });

  group('forget password', () {
    test(
      'should return NetworkSuccess if email exists and auth call succeeds',
      () async {
        // Arrange
        when(
          () => mockDatabaseService.checkIfFieldExists(
            path: BackendEndpoints.checkIfEmailExists,
            fieldName: 'email',
            fieldValue: tEmail,
          ),
        ).thenAnswer((_) async => true);
        when(
          () => mockAuthService.forgetPassword(tEmail),
        ).thenAnswer((_) async => Future.value());
        // Act
        final result = await sut.forgetPassword(tEmail);
        // Assert
        expect(result, isA<NetworkSuccess<void>>());
        verify(
          () => mockDatabaseService.checkIfFieldExists(
            path: BackendEndpoints.checkIfEmailExists,
            fieldName: 'email',
            fieldValue: tEmail,
          ),
        ).called(1);
        verify(() => mockAuthService.forgetPassword(tEmail)).called(1);
      },
    );

    test('should return NetworkFailure if email does NOT exist', () async {
      // Arrange
      when(
        () => mockDatabaseService.checkIfFieldExists(
          path: BackendEndpoints.checkIfEmailExists,
          fieldName: 'email',
          fieldValue: tEmail,
        ),
      ).thenAnswer((_) async => false);

      // Act
      final result = await sut.forgetPassword(tEmail);

      // Assert
      expect(result, isA<NetworkFailure>());
      expect(getErrorMessage(result), contains('no_user_found_for_that_email'));
      verifyNever(() => mockAuthService.forgetPassword(tEmail));
    });

    test(
      'should return NetworkFailure if checkIfEmailExists (DB) fails',
      () async {
        // Arrange
        final tException = Exception('Database failed');
        when(
          () => mockDatabaseService.checkIfFieldExists(
            path: any(named: 'path'),
            fieldName: any(named: 'fieldName'),
            fieldValue: any(named: 'fieldValue'),
          ),
        ).thenThrow(tException);
        // Act
        final result = await sut.forgetPassword(tEmail);
        // Assert
        expect(result, isA<NetworkFailure>());
        expect(
          getErrorMessage(result),
          contains('error_occurred_please_try_again'),
        );
      },
    );

    test(
      'should return NetworkFailure if forgetPassword (Auth) fails',
      () async {
        // Arrange
        when(
          () => mockDatabaseService.checkIfFieldExists(
            path: BackendEndpoints.checkIfEmailExists,
            fieldName: 'email',
            fieldValue: tEmail,
          ),
        ).thenAnswer((_) async => true);
        // Act
        final result = await sut.forgetPassword(tEmail);
        // Assert
        expect(result, isA<NetworkFailure>());
        expect(
          getErrorMessage(result),
          contains('error_occurred_please_try_again'),
        );
      },
    );
  });

  group('signOut', () {
    test('should return NetworkSuccess on success', () async {
      // Arrange
      when(
        () => mockAuthService.signOut(),
      ).thenAnswer((_) async => Future.value());
      // Act
      final result = await sut.signOut();
      // Assert
      expect(result, isA<NetworkSuccess<void>>());
      verify(() => mockAuthService.signOut()).called(1);
    });
    test('should return NetworkFailure on failure', () async {
      // Arrange
      when(
        () => mockAuthService.signOut(),
      ).thenThrow(Exception('Sign out failed'));
      // Act
      final result = await sut.signOut();
      // Assert
      expect(result, isA<NetworkFailure>());
      expect(
        getErrorMessage(result),
        contains('error_occurred_please_try_again'),
      );
    });
  });

  group('facebookSignIn', () {
    final tFacebookUserEntity = tUserEntity.copyWith(
      name: tUsername,
      isVerified: true,
    );

    test('should return NetworkSuccess', () async {
      // Arrange
      when(
        () => mockAuthService.facebookSignIn(),
      ).thenAnswer((_) async => tFacebookUserEntity);
      arrangeGetOrUpdateDBSuccess(mockDatabaseService);
      // Act
      final result = await sut.facebookSignIn();
      // Assert
      expect(result, isA<NetworkSuccess<UserEntity>>());
      expect((result as NetworkSuccess).data.uid, tFacebookUserEntity.uid);
      verify(() => mockAuthService.facebookSignIn()).called(1);
      verify(
        () => mockDatabaseService.checkIfDataExists(
          path: BackendEndpoints.checkIfUserExists,
          documentId: tFacebookUserEntity.uid,
        ),
      ).called(1);
    });

    test('should return NetworkFailure if auth itself fails', () async {
      // Arrange
      when(
        () => mockFirebaseAuthException.code,
      ).thenReturn('network-request-failed');
      when(
        () => mockFirebaseAuthException.message,
      ).thenReturn('Facebook error');
      when(
        () => mockAuthService.facebookSignIn(),
      ).thenThrow(mockFirebaseAuthException);
      // Act
      final result = await sut.facebookSignIn();
      // Assert
      expect(result, isA<NetworkFailure>());
      expect(getErrorMessage(result), contains('network_error_message'));
      verifyNever(
        () => mockDatabaseService.checkIfDataExists(
          path: any(named: 'path'),
          documentId: any(named: 'documentId'),
        ),
      );
    });

    test(
      'should return NetworkFailure if _getOrUpdateUserFromDB fails',
          () async {
        // Arrange
        when(
              () => mockAuthService.facebookSignIn(),
        ).thenAnswer((_) async => tFacebookUserEntity);

        final tException = Exception('Database failed');
        when(
              () => mockDatabaseService.checkIfDataExists(
            path: any(named: 'path'),
            documentId: any(named: 'documentId'),
          ),
        ).thenThrow(tException);

        // Act
        final result = await sut.facebookSignIn();
        // Assert
        expect(result, isA<NetworkFailure>());
        expect(
          getErrorMessage(result),
          contains('error_occurred_please_try_again'),
        );
      },
    );
  });
}
