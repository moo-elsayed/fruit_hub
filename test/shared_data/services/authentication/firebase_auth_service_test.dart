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

void main() {
  late MockFirebaseAuth mockFirebaseAuth;
  late MockGoogleSignIn mockGoogleSignIn;
  late MockFacebookAuth mockFacebookAuth;
  late MockUserCredential mockUserCredential;
  late MockUser mockUser;
  late FirebaseAuthService firebaseAuthService;

  const tEmail = 'test@test.com';
  const tPassword = 'password123';
  const tUserEntity = UserEntity(
    uid: '123',
    email: tEmail,
    name: 'Test User',
    isVerified: false,
  );

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    mockGoogleSignIn = MockGoogleSignIn();
    mockFacebookAuth = MockFacebookAuth();
    mockUserCredential = MockUserCredential();
    mockUser = MockUser();
    firebaseAuthService = FirebaseAuthService(
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
        var call = await firebaseAuthService.createUserWithEmailAndPassword(
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
        var call = firebaseAuthService.createUserWithEmailAndPassword(
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
        var call = firebaseAuthService.createUserWithEmailAndPassword(
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
        var call = await firebaseAuthService.signInWithEmailAndPassword(
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
        var call = firebaseAuthService.signInWithEmailAndPassword(
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
      var call = firebaseAuthService.signInWithEmailAndPassword(
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
      await firebaseAuthService.forgetPassword(tEmail);
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
      var call = firebaseAuthService.forgetPassword(tEmail);
      // Assert
      expect(call, throwsException);
    });
  });

  group('delete current user', () {
    test('should call delete on currentUser successfully', () async {
      // Arrange
      // Act
      await firebaseAuthService.deleteCurrentUser();
      // Assert
      verify(() => mockUser.delete()).called(1);
    });

    test('should re-throw exception on failure', () {
      // Arrange
      when(() => mockUser.delete()).thenThrow(Exception('Failed to delete'));
      // Act
      var call = firebaseAuthService.deleteCurrentUser();
      // Assert
      expect(call, throwsException);
    });

    test('should complete silently if currentUser is null', () async {
      // Arrange
      when(() => mockFirebaseAuth.currentUser).thenReturn(null);
      // Act
      await firebaseAuthService.deleteCurrentUser();
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
        await firebaseAuthService.sendEmailVerification();
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
      var call = firebaseAuthService.sendEmailVerification();
      // Assert
      expect(call, throwsException);
    });

    test('should complete silently if currentUser is null', () async {
      // Arrange
      when(() => mockFirebaseAuth.currentUser).thenReturn(null);
      // Act
      await firebaseAuthService.sendEmailVerification();
      // Assert
      verifyNever(() => mockUser.sendEmailVerification());
    });
  });
  group('sign out', () {
    test('should call signOut on success', () {
      // Arrange
      // Act
      firebaseAuthService.signOut();
      // Assert
      verify(() => mockFirebaseAuth.signOut()).called(1);
    });

    test('should re-throw exception on failure', () {
      // Arrange
      when(
        () => mockFirebaseAuth.signOut(),
      ).thenThrow(Exception('Failed to sign out'));
      // Act
      var call = firebaseAuthService.signOut();
      // Assert
      expect(call, throwsException);
    });
  });
}
