import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/features/auth/domain/entities/user_entity.dart';
import 'package:fruit_hub/shared_data/services/authentication/firebase_auth_service.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockGoogleSignIn extends Mock implements GoogleSignIn {}

class MockFacebookAuth extends Mock implements FacebookAuth {}

class MockUserCredential extends Mock implements UserCredential {}

class MockUser extends Mock implements User {}

class MockGoogleSignInAccount extends Mock implements GoogleSignInAccount {}

class MockGoogleSignInAuthentication extends Mock
    implements GoogleSignInAuthentication {}

class MockAuthCredential extends Mock implements AuthCredential {}

class MockLoginResult extends Mock implements LoginResult {}

class MockAccessToken extends Mock implements AccessToken {}

class MockFirebaseAuthException extends Mock implements FirebaseAuthException {}

void registerFallbacks() {
  registerFallbackValue(MockAuthCredential());
  registerFallbackValue(MockFirebaseAuthException());
}

void main() {
  late MockFirebaseAuth mockFirebaseAuth;
  late MockGoogleSignIn mockGoogleSignIn;
  late MockFacebookAuth mockFacebookAuth;
  late MockUserCredential mockUserCredential;
  late MockUser mockUser;
  late FirebaseAuthService sut;
  late MockGoogleSignInAccount mockGoogleSignInAccount;
  late MockGoogleSignInAuthentication mockGoogleSignInAuthentication;
  late MockLoginResult mockLoginResult;
  late MockAccessToken mockAccessToken;

  const tEmail = 'test@test.com';
  const tPassword = 'password123';
  const tUserEntity = UserEntity(
    uid: '123',
    email: tEmail,
    name: 'Test User',
    isVerified: false,
  );
  const tMockIdToken = 'mock-id-token';
  const tMockFbToken = 'mock-fb-token';
  setUpAll(() {
    registerFallbacks();
  });

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    mockGoogleSignIn = MockGoogleSignIn();
    mockFacebookAuth = MockFacebookAuth();
    mockUserCredential = MockUserCredential();
    mockUser = MockUser();
    mockGoogleSignInAccount = MockGoogleSignInAccount();
    mockGoogleSignInAuthentication = MockGoogleSignInAuthentication();
    mockLoginResult = MockLoginResult();
    mockAccessToken = MockAccessToken();

    sut = FirebaseAuthService(
      mockFirebaseAuth,
      mockGoogleSignIn,
      mockFacebookAuth,
    );
    when(() => mockUserCredential.user).thenReturn(mockUser);
    when(() => mockUser.uid).thenReturn(tUserEntity.uid);
    when(() => mockUser.email).thenReturn(tUserEntity.email);
    when(() => mockUser.displayName).thenReturn(tUserEntity.name);
    when(() => mockUser.emailVerified).thenReturn(tUserEntity.isVerified);
    when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);
    when(() => mockUserCredential.user).thenReturn(mockUser);
    when(() => mockUser.delete()).thenAnswer((_) async => Future.value());
    when(
      () => mockUser.sendEmailVerification(),
    ).thenAnswer((_) async => Future.value());
    when(
      () => mockFirebaseAuth.sendPasswordResetEmail(email: any(named: 'email')),
    ).thenAnswer((_) async => Future.value());
    when(
      () => mockFirebaseAuth.signOut(),
    ).thenAnswer((_) async => Future.value());
    when(() => mockGoogleSignIn.signOut()).thenAnswer((_) async {});
    when(
      () => mockGoogleSignIn.initialize(
        clientId: any(named: 'clientId'),
        serverClientId: any(named: 'serverClientId'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => mockGoogleSignIn.attemptLightweightAuthentication(),
    ).thenAnswer((_) async => mockGoogleSignInAccount);
    when(
      () => mockGoogleSignInAccount.authentication,
    ).thenReturn(mockGoogleSignInAuthentication);
    when(() => mockGoogleSignInAuthentication.idToken).thenReturn(tMockIdToken);
    when(
      () => mockFirebaseAuth.signInWithCredential(any()),
    ).thenAnswer((_) async => mockUserCredential);
    when(
      () => mockFacebookAuth.login(permissions: any(named: 'permissions')),
    ).thenAnswer((_) async => mockLoginResult);
    when(() => mockLoginResult.accessToken).thenReturn(mockAccessToken);
    when(() => mockAccessToken.tokenString).thenReturn(tMockFbToken);
  });

  group('create user & login with email', () {
    test(
      'createUserWithEmailAndPassword should return UserEntity on success',
      () async {
        // Arrange
        when(
          () => mockFirebaseAuth.createUserWithEmailAndPassword(
            email: tEmail,
            password: tPassword,
          ),
        ).thenAnswer((_) async => mockUserCredential);
        // Act
        var call = await sut.createUserWithEmailAndPassword(
          email: tEmail,
          password: tPassword,
        );
        // Assert
        expect(call, equals(tUserEntity));
        verify(
          () => mockFirebaseAuth.createUserWithEmailAndPassword(
            email: tEmail,
            password: tPassword,
          ),
        ).called(1);
      },
    );

    test(
      'createUserWithEmailAndPassword should throw Exception if credential.user is null',
      () {
        // Arrange
        when(() => mockUserCredential.user).thenReturn(null);
        when(
          () => mockFirebaseAuth.createUserWithEmailAndPassword(
            email: tEmail,
            password: tPassword,
          ),
        ).thenAnswer((_) async => mockUserCredential);
        // Act
        var call = sut.createUserWithEmailAndPassword(
          email: tEmail,
          password: tPassword,
        );
        // Assert
        expect(call, throwsException);
      },
    );

    test(
      'createUserWithEmailAndPassword should re-throw exception on failure',
      () {
        // Arrange
        when(
          () => mockFirebaseAuth.createUserWithEmailAndPassword(
            email: tEmail,
            password: tPassword,
          ),
        ).thenThrow(Exception('Failed to create user'));
        // Act
        var call = sut.createUserWithEmailAndPassword(
          email: tEmail,
          password: tPassword,
        );
        // Assert
        expect(call, throwsException);
      },
    );

    test(
      'signInWithEmailAndPassword should return UserEntity on success',
      () async {
        // Arrange
        when(
          () => mockFirebaseAuth.signInWithEmailAndPassword(
            email: tEmail,
            password: tPassword,
          ),
        ).thenAnswer((_) async => mockUserCredential);
        // Act
        var call = await sut.signInWithEmailAndPassword(
          email: tEmail,
          password: tPassword,
        );
        // Assert
        expect(call, equals(tUserEntity));
      },
    );

    test(
      'signInWithEmailAndPassword should throw Exception if credential.user is null',
      () {
        // Arrange
        when(() => mockUserCredential.user).thenReturn(null);
        when(
          () => mockFirebaseAuth.signInWithEmailAndPassword(
            email: tEmail,
            password: tPassword,
          ),
        ).thenAnswer((_) async => mockUserCredential);
        // Act
        var call = sut.signInWithEmailAndPassword(
          email: tEmail,
          password: tPassword,
        );
        // Assert
        expect(call, throwsException);
      },
    );

    test('signInWithEmailAndPassword should re-throw exception on failure', () {
      // Arrange
      when(
        () => mockFirebaseAuth.signInWithEmailAndPassword(
          email: tEmail,
          password: tPassword,
        ),
      ).thenThrow(Exception('Failed to sign in'));
      // Act
      var call = sut.signInWithEmailAndPassword(
        email: tEmail,
        password: tPassword,
      );
      // Assert
      expect(call, throwsException);
    });
  });

  group('forget password', () {
    test('should call sendPasswordResetEmail on success', () async {
      // Arrange
      // Act
      await sut.forgetPassword(tEmail);
      // Assert
      verify(
        () => mockFirebaseAuth.sendPasswordResetEmail(email: tEmail),
      ).called(1);
    });

    test('should re-throw exception on failure', () {
      // Arrange
      when(
        () => mockFirebaseAuth.sendPasswordResetEmail(email: tEmail),
      ).thenThrow(Exception('Failed to send password reset email'));
      // Act
      var call = sut.forgetPassword(tEmail);
      // Assert
      expect(call, throwsException);
    });
  });

  group('delete current user', () {
    test('should call delete on currentUser successfully', () async {
      // Arrange
      // Act
      await sut.deleteCurrentUser();
      // Assert
      verify(() => mockUser.delete()).called(1);
    });

    test('should re-throw exception on failure', () {
      // Arrange
      when(() => mockUser.delete()).thenThrow(Exception('Failed to delete'));
      // Act
      var call = sut.deleteCurrentUser();
      // Assert
      expect(call, throwsException);
    });

    test('should complete silently if currentUser is null', () async {
      // Arrange
      when(() => mockFirebaseAuth.currentUser).thenReturn(null);
      // Act
      await sut.deleteCurrentUser();
      // Assert
      verifyNever(() => mockUser.delete());
    });
  });

  group('send password reset email', () {
    test(
      'should call sendEmailVerification on currentUser successfully',
      () async {
        // Arrange
        // Act
        await sut.sendEmailVerification();
        // Assert
        verify(() => mockUser.sendEmailVerification()).called(1);
      },
    );

    test('should re-throw exception on failure', () {
      // Arrange
      when(
        () => mockUser.sendEmailVerification(),
      ).thenThrow(Exception('Failed to send email verification'));
      // Act
      var call = sut.sendEmailVerification();
      // Assert
      expect(call, throwsException);
    });

    test('should complete silently if currentUser is null', () async {
      // Arrange
      when(() => mockFirebaseAuth.currentUser).thenReturn(null);
      // Act
      await sut.sendEmailVerification();
      // Assert
      verifyNever(() => mockUser.sendEmailVerification());
    });
  });
  group('sign out', () {
    test('should call signOut on success', () {
      // Arrange
      // Act
      sut.signOut();
      // Assert
      verify(() => mockFirebaseAuth.signOut()).called(1);
    });

    test('should re-throw exception on failure', () {
      // Arrange
      when(
        () => mockFirebaseAuth.signOut(),
      ).thenThrow(Exception('Failed to sign out'));
      // Act
      var call = sut.signOut();
      // Assert
      expect(call, throwsException);
    });
  });

  group('sign in with google', () {
    test('should return UserEntity on success', () async {
      // Arrange
      // Act
      var call = await sut.googleSignIn();
      // Assert
      expect(call, equals(tUserEntity));
      verify(() => mockGoogleSignIn.signOut()).called(1);
      verify(
        () => mockGoogleSignIn.attemptLightweightAuthentication(),
      ).called(1);
      verify(() => mockFirebaseAuth.signInWithCredential(any())).called(1);
    });

    test('should throw "canceled" Exception when user cancels', () async {
      // Arrange
      when(
        () => mockGoogleSignIn.attemptLightweightAuthentication(),
      ).thenAnswer((_) async => null);
      // Act
      var call = sut.googleSignIn();
      // Assert
      expect(
        call,
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('canceled'),
          ),
        ),
      );
    });

    test(
      'should throw "Could not retrieve" Exception when idToken is null',
      () {
        // Arrange
        when(() => mockGoogleSignInAuthentication.idToken).thenReturn(null);
        // Act
        var call = sut.googleSignIn();
        // Assert
        expect(
          call,
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Could not retrieve'),
            ),
          ),
        );
      },
    );

    test('should re-throw exception if signInWithCredential fails', () {
      // Arrange
      when(
        () => mockFirebaseAuth.signInWithCredential(any()),
      ).thenThrow(Exception('Failed to sign in with credential'));
      // Act
      var call = sut.googleSignIn();
      // Assert
      expect(call, throwsException);
    });

    test('should throw Exception if credential.user is null after sign in', () {
      // Arrange
      when(() => mockUserCredential.user).thenReturn(null);
      // Act
      var call = sut.googleSignIn();
      // Assert
      expect(
        call,
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('null after sign in'),
          ),
        ),
      );
    });
  });

  group('sign in with facebook', () {
    test('should return UserEntity on success', () async {
      // Arrange
      // Act
      var call = await sut.facebookSignIn();
      // Assert
      expect(call, equals(tUserEntity));
      verify(
        () => mockFacebookAuth.login(permissions: any(named: 'permissions')),
      ).called(1);
      verify(() => mockFirebaseAuth.signInWithCredential(any())).called(1);
    });

    test('should re-throw exception if facebookAuth.login fails', () {
      // Arrange
      when(
        () => mockFacebookAuth.login(permissions: any(named: 'permissions')),
      ).thenThrow(Exception('Failed to login with Facebook'));
      // Act
      var call = sut.facebookSignIn();
      // Assert
      expect(call, throwsException);
    });

    test('should throw "access token is null" Exception', () {
      // Arrange
      when(() => mockLoginResult.accessToken).thenReturn(null);
      // Act
      var call = sut.facebookSignIn();
      // Assert
      expect(
        call,
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('access token is null'),
          ),
        ),
      );
    });

    test('should re-throw exception if signInWithCredential fails', () {
      // Arrange
      when(
        () => mockFirebaseAuth.signInWithCredential(any()),
      ).thenThrow(Exception('Failed to sign in with credential'));
      // Act
      var call = sut.facebookSignIn();
      // Assert
      expect(call, throwsException);
    });

    test('should throw "user is null" Exception', () {
      // Arrange
      when(() => mockUserCredential.user).thenReturn(null);
      // Act
      var call = sut.facebookSignIn();
      // Assert
      expect(
        call,
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('null after sign in'),
          ),
        ),
      );
    });

    test(
      'should attempt to link with Google when account-exists-with-different-credential',
      () async {
        // Arrange
        final mockException = MockFirebaseAuthException();
        final mockCredential = MockAuthCredential();
        when(
          () => mockException.code,
        ).thenReturn('account-exists-with-different-credential');
        when(() => mockException.credential).thenReturn(mockCredential);
        var callCount = 0;
        when(() => mockFirebaseAuth.signInWithCredential(any())).thenAnswer((
          _,
        ) async {
          if (++callCount == 1) {
            throw mockException;
          } else {
            return mockUserCredential;
          }
        });
        when(
          () => mockUser.linkWithCredential(any()),
        ).thenAnswer((_) async => mockUserCredential);
        // Act
        final result = await sut.facebookSignIn();
        // Assert
        expect(result, equals(tUserEntity));
        verify(
          () => mockGoogleSignIn.attemptLightweightAuthentication(),
        ).called(1);
        verify(() => mockUser.linkWithCredential(mockCredential)).called(1);
      },
    );

    test('should re-throw original exception if pendingCred is null', () {
      // Arrange
      final mockException = MockFirebaseAuthException();
      when(
        () => mockException.code,
      ).thenReturn('account-exists-with-different-credential');
      when(() => mockException.credential).thenReturn(null);
      when(
        () => mockFirebaseAuth.signInWithCredential(any()),
      ).thenThrow(mockException);
      // Act
      var call = sut.facebookSignIn();
      // Assert
      expect(call, throwsException);
    });

    test(
      'should re-throw original exception if googleSignInInternal fails during linking',
      () {
        // Arrange
        final mockException = MockFirebaseAuthException();
        final mockCredential = MockAuthCredential();
        when(
          () => mockException.code,
        ).thenReturn('account-exists-with-different-credential');
        when(() => mockException.credential).thenReturn(mockCredential);
        final googleError = Exception('Google sign in failed');
        var callCount = 0;
        when(() => mockFirebaseAuth.signInWithCredential(any())).thenAnswer((
          _,
        ) async {
          if (++callCount == 1) {
            throw mockException;
          } else {
            return mockUserCredential;
          }
        });
        when(
          () => mockGoogleSignIn.attemptLightweightAuthentication(),
        ).thenThrow(googleError);
        // Act
        var call = sut.facebookSignIn();
        // Assert
        expect(call, throwsA(mockException));
      },
    );

    test(
      'should re-throw original exception if linkWithCredential fails during linking',
      () {
        // Arrange
        final mockException = MockFirebaseAuthException();
        final mockCredential = MockAuthCredential();
        when(
          () => mockException.code,
        ).thenReturn('account-exists-with-different-credential');
        when(() => mockException.credential).thenReturn(mockCredential);
        final googleError = Exception('Google sign in failed');
        var callCount = 0;
        when(() => mockFirebaseAuth.signInWithCredential(any())).thenAnswer((
          _,
        ) async {
          if (++callCount == 1) {
            throw mockException;
          } else {
            return mockUserCredential;
          }
        });
        when(() => mockUser.linkWithCredential(any())).thenThrow(googleError);
        // Act
        var call = sut.facebookSignIn();
        // Assert
        expect(call, throwsA(mockException));
      },
    );
  });
}
