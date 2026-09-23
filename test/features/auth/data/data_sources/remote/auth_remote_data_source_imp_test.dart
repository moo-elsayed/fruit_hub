import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/backend_endpoints.dart';
import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/features/auth/data/data_sources/remote/auth_remote_data_source_imp.dart';
import 'package:fruit_hub/features/auth/data/models/sign_up_input_model.dart';
import 'package:fruit_hub/features/auth/data/models/user_model.dart';
import 'package:fruit_hub/features/auth/domain/entities/sign_up_input_entity.dart';
import 'package:fruit_hub/features/auth/domain/entities/user_entity.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUserCredential extends Mock implements UserCredential {}

class MockUser extends Mock implements User {}

class MockAdditionalUserInfo extends Mock implements AdditionalUserInfo {}

class MockFacebookAuth extends Mock implements FacebookAuth {}

class MockAccessToken extends Mock implements AccessToken {}

class MockUserInfo extends Mock implements UserInfo {}

class FakeAuthProvider extends Fake implements AuthProvider {}

class FakeAuthCredential extends Fake implements AuthCredential {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeAuthProvider());
    registerFallbackValue(FakeAuthCredential());
  });

  late MockFirebaseAuth mockFirebaseAuth;
  late FakeFirebaseFirestore fakeFirestore;
  late MockFacebookAuth mockFacebookAuth;
  late MockUserCredential mockUserCredential;
  late MockUser mockUser;
  late MockUser mockCurrentUser;
  late AuthRemoteDataSourceImp sut;

  const tUid = 'test_uid_123';
  const tEmail = 'test@example.com';
  const tPassword = 'Password123';
  const tUsername = 'Test User';
  const tPhone = '01012345678';

  const tSignUpInput = SignUpInputModel(
    username: tUsername,
    email: tEmail,
    password: tPassword,
    phone: tPhone,
  );

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    fakeFirestore = FakeFirebaseFirestore();
    mockFacebookAuth = MockFacebookAuth();
    mockUserCredential = MockUserCredential();
    mockUser = MockUser();
    mockCurrentUser = MockUser();

    when(() => mockUser.uid).thenReturn(tUid);
    when(() => mockUser.email).thenReturn(tEmail);
    when(() => mockUser.displayName).thenReturn(tUsername);
    when(() => mockUser.phoneNumber).thenReturn(tPhone);
    when(() => mockUser.photoURL).thenReturn(null);
    when(() => mockUser.providerData).thenReturn([]);
    when(() => mockUser.emailVerified).thenReturn(true);
    when(() => mockUser.updateDisplayName(any())).thenAnswer((_) async {});
    when(() => mockUser.sendEmailVerification()).thenAnswer((_) async {});
    when(() => mockUser.reload()).thenAnswer((_) async {});
    when(() => mockUser.delete()).thenAnswer((_) async {});

    when(() => mockCurrentUser.uid).thenReturn(tUid);
    when(() => mockCurrentUser.email).thenReturn(tEmail);
    when(() => mockCurrentUser.displayName).thenReturn(tUsername);
    when(() => mockCurrentUser.phoneNumber).thenReturn(tPhone);
    when(() => mockCurrentUser.photoURL).thenReturn(null);
    when(() => mockCurrentUser.providerData).thenReturn([]);
    when(() => mockCurrentUser.emailVerified).thenReturn(true);
    when(() => mockCurrentUser.delete()).thenAnswer((_) async {});

    when(() => mockUserCredential.user).thenReturn(mockUser);
    when(() => mockFirebaseAuth.signOut()).thenAnswer((_) async {});
    when(() => mockFirebaseAuth.currentUser).thenReturn(mockCurrentUser);
    when(() => mockFacebookAuth.logOut()).thenAnswer((_) async {});

    sut = AuthRemoteDataSourceImp(
      firebaseAuth: mockFirebaseAuth,
      firestore: fakeFirestore,
      facebookAuth: mockFacebookAuth,
    );
  });

  group('createUserWithEmailAndPassword', () {
    test('should successfully create user, update display name, save to Firestore, send verification, sign out and return NetworkSuccess', () async {
      // Arrange
      when(
        () => mockFirebaseAuth.createUserWithEmailAndPassword(
          email: tEmail,
          password: tPassword,
        ),
      ).thenAnswer((_) async => mockUserCredential);

      // Act
      final result = await sut.createUserWithEmailAndPassword(tSignUpInput);

      // Assert
      expect(result, isA<NetworkSuccess<UserModel>>());
      final user = (result as NetworkSuccess<UserModel>).data;
      expect(user, isNotNull);
      expect(user!.uid, tUid);
      expect(user.name, tUsername);
      expect(user.email, tEmail);
      expect(user.phone, tPhone);

      final doc = await fakeFirestore
          .collection(BackendEndpoints.usersCollection)
          .doc(tUid)
          .get();
      expect(doc.exists, isTrue);
      expect(doc.data()!['name'], tUsername);
      expect(doc.data()!['email'], tEmail);

      verify(() => mockUser.updateDisplayName(tUsername)).called(1);
      verify(() => mockUser.sendEmailVerification()).called(1);
      verify(() => mockFirebaseAuth.signOut()).called(1);
    });

    test('should return NetworkFailure with unexpectedError and delete currentUser when userCredential.user is null', () async {
      // Arrange
      when(
        () => mockFirebaseAuth.createUserWithEmailAndPassword(
          email: tEmail,
          password: tPassword,
        ),
      ).thenAnswer((_) async => mockUserCredential);
      when(() => mockUserCredential.user).thenReturn(null);

      // Act
      final result = await sut.createUserWithEmailAndPassword(tSignUpInput);

      // Assert
      expect(result, isA<NetworkFailure<UserModel>>());
      final failure = (result as NetworkFailure<UserModel>).failure;
      expect(failure.error, AppStrings.unexpectedError);
      verify(() => mockCurrentUser.delete()).called(1);
    });

    test('should return NetworkFailure with emailAlreadyInUse and NOT delete currentUser when code is email-already-in-use', () async {
      // Arrange
      when(
        () => mockFirebaseAuth.createUserWithEmailAndPassword(
          email: tEmail,
          password: tPassword,
        ),
      ).thenThrow(FirebaseAuthException(code: 'email-already-in-use'));

      // Act
      final result = await sut.createUserWithEmailAndPassword(tSignUpInput);

      // Assert
      expect(result, isA<NetworkFailure<UserModel>>());
      final failure = (result as NetworkFailure<UserModel>).failure;
      expect(failure.error, AppStrings.emailAlreadyInUse);
      verifyNever(() => mockCurrentUser.delete());
    });

    test('should return NetworkFailure with weakPassword and delete currentUser when code is weak-password', () async {
      // Arrange
      when(
        () => mockFirebaseAuth.createUserWithEmailAndPassword(
          email: tEmail,
          password: tPassword,
        ),
      ).thenThrow(FirebaseAuthException(code: 'weak-password'));

      // Act
      final result = await sut.createUserWithEmailAndPassword(tSignUpInput);

      // Assert
      expect(result, isA<NetworkFailure<UserModel>>());
      final failure = (result as NetworkFailure<UserModel>).failure;
      expect(failure.error, AppStrings.thePasswordProvidedIsTooWeak);
      verify(() => mockCurrentUser.delete()).called(1);
    });

    test('should return NetworkFailure with unexpectedError and delete currentUser on generic exception', () async {
      // Arrange
      when(
        () => mockFirebaseAuth.createUserWithEmailAndPassword(
          email: tEmail,
          password: tPassword,
        ),
      ).thenThrow(Exception('Generic database failure'));

      // Act
      final result = await sut.createUserWithEmailAndPassword(tSignUpInput);

      // Assert
      expect(result, isA<NetworkFailure<UserModel>>());
      final failure = (result as NetworkFailure<UserModel>).failure;
      expect(failure.error, AppStrings.unexpectedError);
      verify(() => mockCurrentUser.delete()).called(1);
    });
  });

  group('signInWithEmailAndPassword', () {
    test('should return NetworkSuccess with UserModel when email is verified and user exists in Firestore', () async {
      // Arrange
      await fakeFirestore
          .collection(BackendEndpoints.usersCollection)
          .doc(tUid)
          .set({
            'uid': tUid,
            'name': 'Custom DB Name',
            'email': tEmail,
            'phone': '01122334455',
            'isVerified': true,
          });

      when(
        () => mockFirebaseAuth.signInWithEmailAndPassword(
          email: tEmail,
          password: tPassword,
        ),
      ).thenAnswer((_) async => mockUserCredential);

      // Act
      final result = await sut.signInWithEmailAndPassword(
        email: tEmail,
        password: tPassword,
      );

      // Assert
      expect(result, isA<NetworkSuccess<UserModel>>());
      final user = (result as NetworkSuccess<UserModel>).data;
      expect(user, isNotNull);
      expect(user!.name, 'Custom DB Name');
      expect(user.phone, '01122334455');
      expect(user.isVerified, isTrue);

      verify(() => mockUser.reload()).called(1);
    });

    test('should create user in Firestore and return NetworkSuccess if user does not exist in DB yet', () async {
      // Arrange - no user in fakeFirestore
      when(
        () => mockFirebaseAuth.signInWithEmailAndPassword(
          email: tEmail,
          password: tPassword,
        ),
      ).thenAnswer((_) async => mockUserCredential);

      // Act
      final result = await sut.signInWithEmailAndPassword(
        email: tEmail,
        password: tPassword,
      );

      // Assert
      expect(result, isA<NetworkSuccess<UserModel>>());
      final user = (result as NetworkSuccess<UserModel>).data;
      expect(user!.uid, tUid);

      final doc = await fakeFirestore
          .collection(BackendEndpoints.usersCollection)
          .doc(tUid)
          .get();
      expect(doc.exists, isTrue);
    });

    test('should return NetworkFailure with pleaseVerifyYourEmail and sign out when emailVerified is false', () async {
      // Arrange
      when(() => mockCurrentUser.emailVerified).thenReturn(false);
      when(
        () => mockFirebaseAuth.signInWithEmailAndPassword(
          email: tEmail,
          password: tPassword,
        ),
      ).thenAnswer((_) async => mockUserCredential);

      // Act
      final result = await sut.signInWithEmailAndPassword(
        email: tEmail,
        password: tPassword,
      );

      // Assert
      expect(result, isA<NetworkFailure<UserModel>>());
      final failure = (result as NetworkFailure<UserModel>).failure;
      expect(failure.error, AppStrings.pleaseVerifyYourEmail);
      verify(() => mockFirebaseAuth.signOut()).called(1);
    });

    test('should return NetworkFailure with unexpectedError when userCredential.user is null', () async {
      // Arrange
      when(
        () => mockFirebaseAuth.signInWithEmailAndPassword(
          email: tEmail,
          password: tPassword,
        ),
      ).thenAnswer((_) async => mockUserCredential);
      when(() => mockUserCredential.user).thenReturn(null);

      // Act
      final result = await sut.signInWithEmailAndPassword(
        email: tEmail,
        password: tPassword,
      );

      // Assert
      expect(result, isA<NetworkFailure<UserModel>>());
      final failure = (result as NetworkFailure<UserModel>).failure;
      expect(failure.error, AppStrings.unexpectedError);
    });

    test('should return NetworkFailure with invalidCredential when FirebaseAuthException code is user-not-found', () async {
      // Arrange
      when(
        () => mockFirebaseAuth.signInWithEmailAndPassword(
          email: tEmail,
          password: tPassword,
        ),
      ).thenThrow(FirebaseAuthException(code: 'user-not-found'));

      // Act
      final result = await sut.signInWithEmailAndPassword(
        email: tEmail,
        password: tPassword,
      );

      // Assert
      expect(result, isA<NetworkFailure<UserModel>>());
      final failure = (result as NetworkFailure<UserModel>).failure;
      expect(failure.error, AppStrings.invalidCredential);
    });

    test('should return NetworkFailure with wrongPassword when FirebaseAuthException code is wrong-password', () async {
      // Arrange
      when(
        () => mockFirebaseAuth.signInWithEmailAndPassword(
          email: tEmail,
          password: tPassword,
        ),
      ).thenThrow(FirebaseAuthException(code: 'wrong-password'));

      // Act
      final result = await sut.signInWithEmailAndPassword(
        email: tEmail,
        password: tPassword,
      );

      // Assert
      expect(result, isA<NetworkFailure<UserModel>>());
      final failure = (result as NetworkFailure<UserModel>).failure;
      expect(failure.error, AppStrings.wrongPasswordProvidedForThatUser);
    });
  });

  group('googleSignIn', () {
    test('should sign in with Google provider, create user in Firestore and return NetworkSuccess for new user', () async {
      // Arrange
      when(() => mockUser.displayName).thenReturn(null);
      final mockAdditionalInfo = MockAdditionalUserInfo();
      when(() => mockAdditionalInfo.profile).thenReturn({
        'name': 'Google Custom Name',
        'picture': 'https://example.com/avatar.jpg',
      });
      when(() => mockUserCredential.additionalUserInfo)
          .thenReturn(mockAdditionalInfo);

      when(
        () => mockFirebaseAuth.signInWithProvider(
          any(that: isA<GoogleAuthProvider>()),
        ),
      ).thenAnswer((_) async => mockUserCredential);

      // Act
      final result = await sut.googleSignIn();

      // Assert
      expect(result, isA<NetworkSuccess<UserModel>>());
      final user = (result as NetworkSuccess<UserModel>).data;
      expect(user, isNotNull);
      expect(user!.uid, tUid);
      expect(user.name, 'Google Custom Name');

      final doc = await fakeFirestore
          .collection(BackendEndpoints.usersCollection)
          .doc(tUid)
          .get();
      expect(doc.exists, isTrue);
      expect(doc.data()!['name'], 'Google Custom Name');
    });

    test('should preserve stored custom name and update isVerified for existing user', () async {
      // Arrange
      await fakeFirestore
          .collection(BackendEndpoints.usersCollection)
          .doc(tUid)
          .set({
            'uid': tUid,
            'name': 'Existing Custom Name',
            'email': tEmail,
            'isVerified': false,
          });

      final mockAdditionalInfo = MockAdditionalUserInfo();
      when(() => mockAdditionalInfo.profile).thenReturn(null);
      when(() => mockUserCredential.additionalUserInfo)
          .thenReturn(mockAdditionalInfo);

      when(
        () => mockFirebaseAuth.signInWithProvider(
          any(that: isA<GoogleAuthProvider>()),
        ),
      ).thenAnswer((_) async => mockUserCredential);

      // Act
      final result = await sut.googleSignIn();

      // Assert
      expect(result, isA<NetworkSuccess<UserModel>>());
      final user = (result as NetworkSuccess<UserModel>).data;
      expect(user!.name, 'Existing Custom Name');
      expect(user.isVerified, isTrue);

      final doc = await fakeFirestore
          .collection(BackendEndpoints.usersCollection)
          .doc(tUid)
          .get();
      expect(doc.data()!['name'], 'Existing Custom Name');
      expect(doc.data()!['isVerified'], isTrue);
    });

    test('should fallback to userModel.name when stored user in DB has an empty name', () async {
      // Arrange
      await fakeFirestore
          .collection(BackendEndpoints.usersCollection)
          .doc(tUid)
          .set({
            'uid': tUid,
            'name': '   ',
            'email': tEmail,
            'isVerified': false,
          });

      final mockAdditionalInfo = MockAdditionalUserInfo();
      when(() => mockAdditionalInfo.profile).thenReturn(null);
      when(() => mockUserCredential.additionalUserInfo)
          .thenReturn(mockAdditionalInfo);

      when(
        () => mockFirebaseAuth.signInWithProvider(
          any(that: isA<GoogleAuthProvider>()),
        ),
      ).thenAnswer((_) async => mockUserCredential);

      // Act
      final result = await sut.googleSignIn();

      // Assert
      expect(result, isA<NetworkSuccess<UserModel>>());
      final user = (result as NetworkSuccess<UserModel>).data;
      expect(user!.name, tUsername);

      final doc = await fakeFirestore
          .collection(BackendEndpoints.usersCollection)
          .doc(tUid)
          .get();
      expect(doc.data()!['name'], tUsername);
    });

    test(
      'should return NetworkFailure with unexpectedError when user is null',
      () async {
        // Arrange
        when(
          () => mockFirebaseAuth.signInWithProvider(
            any(that: isA<GoogleAuthProvider>()),
          ),
        ).thenAnswer((_) async => mockUserCredential);
        when(() => mockUserCredential.user).thenReturn(null);

        // Act
        final result = await sut.googleSignIn();

        // Assert
        expect(result, isA<NetworkFailure<UserModel>>());
        final failure = (result as NetworkFailure<UserModel>).failure;
        expect(failure.error, AppStrings.unexpectedError);
      },
    );

    test(
      'should return NetworkFailure with unexpectedError on generic error',
      () async {
        // Arrange
        when(
          () => mockFirebaseAuth.signInWithProvider(
            any(that: isA<GoogleAuthProvider>()),
          ),
        ).thenThrow(Exception('Google OAuth failed'));

        // Act
        final result = await sut.googleSignIn();

        // Assert
        expect(result, isA<NetworkFailure<UserModel>>());
        final failure = (result as NetworkFailure<UserModel>).failure;
        expect(failure.error, AppStrings.unexpectedError);
      },
    );
  });

  group('facebookSignIn', () {
    late MockAccessToken mockAccessToken;

    setUp(() {
      mockAccessToken = MockAccessToken();
      when(() => mockAccessToken.tokenString).thenReturn('fb_token_12345');
    });

    test('should sign in with Facebook, retrieve user profile, update Firestore and return NetworkSuccess', () async {
      // Arrange
      when(() => mockUser.displayName).thenReturn(null);
      when(() => mockFacebookAuth.login(permissions: any(named: 'permissions')))
          .thenAnswer(
            (_) async => LoginResult(
              status: LoginStatus.success,
              accessToken: mockAccessToken,
            ),
          );

      final mockAdditionalInfo = MockAdditionalUserInfo();
      when(() => mockAdditionalInfo.profile).thenReturn({
        'name': 'Facebook User Name',
        'picture': {
          'data': {'url': 'https://example.com/fb_avatar.jpg'},
        },
      });
      when(() => mockUserCredential.additionalUserInfo)
          .thenReturn(mockAdditionalInfo);

      when(() => mockFirebaseAuth.signInWithCredential(any()))
          .thenAnswer((_) async => mockUserCredential);

      // Act
      final result = await sut.facebookSignIn();

      // Assert
      expect(result, isA<NetworkSuccess<UserModel>>());
      final user = (result as NetworkSuccess<UserModel>).data;
      expect(user, isNotNull);
      expect(user!.uid, tUid);
      expect(user.name, 'Facebook User Name');
      expect(user.image, 'https://example.com/fb_avatar.jpg');

      final doc = await fakeFirestore
          .collection(BackendEndpoints.usersCollection)
          .doc(tUid)
          .get();
      expect(doc.exists, isTrue);
      expect(doc.data()!['name'], 'Facebook User Name');
    });

    test('should fallback to facebookAuth.getUserData() when additionalUserInfo profile is null', () async {
      // Arrange
      when(() => mockUser.displayName).thenReturn(null);
      when(() => mockFacebookAuth.login(permissions: any(named: 'permissions')))
          .thenAnswer(
            (_) async => LoginResult(
              status: LoginStatus.success,
              accessToken: mockAccessToken,
            ),
          );

      final mockAdditionalInfo = MockAdditionalUserInfo();
      when(() => mockAdditionalInfo.profile).thenReturn(null);
      when(() => mockUserCredential.additionalUserInfo)
          .thenReturn(mockAdditionalInfo);

      when(() => mockFacebookAuth.getUserData()).thenAnswer(
        (_) async => {
          'name': 'Fallback FB Name',
          'picture': 'https://example.com/direct_pic.png',
        },
      );

      when(() => mockFirebaseAuth.signInWithCredential(any()))
          .thenAnswer((_) async => mockUserCredential);

      // Act
      final result = await sut.facebookSignIn();

      // Assert
      expect(result, isA<NetworkSuccess<UserModel>>());
      final user = (result as NetworkSuccess<UserModel>).data;
      expect(user!.name, 'Fallback FB Name');
      expect(user.image, 'https://example.com/direct_pic.png');
      verify(() => mockFacebookAuth.getUserData()).called(1);
    });

    test('should return NetworkFailure with userCanceledSignIn when loginResult status is cancelled', () async {
      // Arrange
      when(() => mockFacebookAuth.login(permissions: any(named: 'permissions')))
          .thenAnswer(
            (_) async =>
                LoginResult(status: LoginStatus.cancelled, accessToken: null),
          );

      // Act
      final result = await sut.facebookSignIn();

      // Assert
      expect(result, isA<NetworkFailure<UserModel>>());
      final failure = (result as NetworkFailure<UserModel>).failure;
      expect(failure.error, AppStrings.userCanceledSignIn);
    });

    test('should return NetworkFailure with unexpectedError when accessToken is null and status is failed', () async {
      // Arrange
      when(() => mockFacebookAuth.login(permissions: any(named: 'permissions')))
          .thenAnswer(
            (_) async =>
                LoginResult(status: LoginStatus.failed, accessToken: null),
          );

      // Act
      final result = await sut.facebookSignIn();

      // Assert
      expect(result, isA<NetworkFailure<UserModel>>());
      final failure = (result as NetworkFailure<UserModel>).failure;
      expect(failure.error, AppStrings.unexpectedError);
    });

    test('should return NetworkFailure with unexpectedError when signInWithCredential.user is null', () async {
      // Arrange
      when(() => mockFacebookAuth.login(permissions: any(named: 'permissions')))
          .thenAnswer(
            (_) async => LoginResult(
              status: LoginStatus.success,
              accessToken: mockAccessToken,
            ),
          );

      when(() => mockUserCredential.user).thenReturn(null);
      when(() => mockFirebaseAuth.signInWithCredential(any()))
          .thenAnswer((_) async => mockUserCredential);

      // Act
      final result = await sut.facebookSignIn();

      // Assert
      expect(result, isA<NetworkFailure<UserModel>>());
      final failure = (result as NetworkFailure<UserModel>).failure;
      expect(failure.error, AppStrings.unexpectedError);
    });

    test(
      'should return NetworkFailure when Facebook login throws an exception',
      () async {
        // Arrange
        when(
          () => mockFacebookAuth.login(permissions: any(named: 'permissions')),
        ).thenThrow(Exception('Facebook SDK unavailable'));

        // Act
        final result = await sut.facebookSignIn();

        // Assert
        expect(result, isA<NetworkFailure<UserModel>>());
        final failure = (result as NetworkFailure<UserModel>).failure;
        expect(failure.error, AppStrings.unexpectedError);
      },
    );
  });

  group('forgetPassword', () {
    test(
      'should send password reset email when email exists in Firestore',
      () async {
        // Arrange
        await fakeFirestore
            .collection(BackendEndpoints.usersCollection)
            .doc(tUid)
            .set({
              'uid': tUid,
              'email': tEmail,
              'name': tUsername,
              'isVerified': true,
            });

        when(() => mockFirebaseAuth.sendPasswordResetEmail(email: tEmail))
            .thenAnswer((_) async {});

        // Act
        final result = await sut.forgetPassword(tEmail);

        // Assert
        expect(result, isA<NetworkSuccess<void>>());
        verify(() => mockFirebaseAuth.sendPasswordResetEmail(email: tEmail))
            .called(1);
      },
    );

    test('should return NetworkFailure with noUserFoundForThatEmail and NOT call sendPasswordResetEmail when email does not exist in DB', () async {
      // Arrange - no user added to fakeFirestore

      // Act
      final result = await sut.forgetPassword('nonexistent@example.com');

      // Assert
      expect(result, isA<NetworkFailure<void>>());
      final failure = (result as NetworkFailure<void>).failure;
      expect(failure.error, AppStrings.noUserFoundForThatEmail);
      verifyNever(
        () =>
            mockFirebaseAuth.sendPasswordResetEmail(email: any(named: 'email')),
      );
    });

    test('should return NetworkFailure with invalidEmail when FirebaseAuthException is invalid-email', () async {
      // Arrange
      await fakeFirestore
          .collection(BackendEndpoints.usersCollection)
          .doc(tUid)
          .set({
            'uid': tUid,
            'email': tEmail,
            'name': tUsername,
            'isVerified': true,
          });

      when(() => mockFirebaseAuth.sendPasswordResetEmail(email: tEmail))
          .thenThrow(FirebaseAuthException(code: 'invalid-email'));

      // Act
      final result = await sut.forgetPassword(tEmail);

      // Assert
      expect(result, isA<NetworkFailure<void>>());
      final failure = (result as NetworkFailure<void>).failure;
      expect(failure.error, AppStrings.invalidEmail);
    });
  });

  group('getUserInfo', () {
    test('should return NetworkSuccess with UserModel when user document exists in Firestore', () async {
      // Arrange
      await fakeFirestore
          .collection(BackendEndpoints.usersCollection)
          .doc(tUid)
          .set({
            'uid': tUid,
            'name': tUsername,
            'email': tEmail,
            'phone': tPhone,
            'isVerified': true,
          });

      // Act
      final result = await sut.getUserInfo(tUid);

      // Assert
      expect(result, isA<NetworkSuccess<UserModel>>());
      final user = (result as NetworkSuccess<UserModel>).data;
      expect(user!.uid, tUid);
      expect(user.name, tUsername);
      expect(user.email, tEmail);
      expect(user.phone, tPhone);
      expect(user.isVerified, isTrue);
    });

    test('should resolve isVerified to true if Firestore has false but auth currentUser has emailVerified true', () async {
      // Arrange
      await fakeFirestore
          .collection(BackendEndpoints.usersCollection)
          .doc(tUid)
          .set({
            'uid': tUid,
            'name': tUsername,
            'email': tEmail,
            'isVerified': false,
          });

      when(() => mockCurrentUser.emailVerified).thenReturn(true);

      // Act
      final result = await sut.getUserInfo(tUid);

      // Assert
      expect(result, isA<NetworkSuccess<UserModel>>());
      final user = (result as NetworkSuccess<UserModel>).data;
      expect(user!.isVerified, isTrue);
    });

    test(
      'should return NetworkFailure with userNotFound when doc does not exist',
      () async {
        // Arrange - doc does not exist

        // Act
        final result = await sut.getUserInfo('non_existent_uid');

        // Assert
        expect(result, isA<NetworkFailure<UserModel>>());
        final failure = (result as NetworkFailure<UserModel>).failure;
        expect(failure.error, AppStrings.userNotFound);
      },
    );
  });

  group('signOut', () {
    test('should call firebaseAuth.signOut and facebookAuth.logOut and return NetworkSuccess', () async {
      // Arrange - mocks ready

      // Act
      final result = await sut.signOut();

      // Assert
      expect(result, isA<NetworkSuccess<void>>());
      verify(() => mockFirebaseAuth.signOut()).called(1);
      verify(() => mockFacebookAuth.logOut()).called(1);
    });

    test('should return NetworkSuccess even if facebookAuth.logOut throws an error', () async {
      // Arrange
      when(() => mockFacebookAuth.logOut())
          .thenThrow(Exception('FB logout error'));

      // Act
      final result = await sut.signOut();

      // Assert
      expect(result, isA<NetworkSuccess<void>>());
      verify(() => mockFirebaseAuth.signOut()).called(1);
    });

    test('should return NetworkFailure with unexpectedError when firebaseAuth.signOut throws an exception', () async {
      // Arrange
      when(() => mockFirebaseAuth.signOut())
          .thenThrow(Exception('Sign out failed'));

      // Act
      final result = await sut.signOut();

      // Assert
      expect(result, isA<NetworkFailure<void>>());
      final failure = (result as NetworkFailure<void>).failure;
      expect(failure.error, AppStrings.unexpectedError);
    });
  });

  group('Model and Entity Mappings', () {
    test('UserModel toUserEntity and fromUserEntity should map all properties correctly', () {
      // Arrange
      const entity = UserEntity(
        uid: 'user_99',
        name: 'John Doe',
        email: 'john@example.com',
        phone: '0123456789',
        image: 'https://example.com/pic.png',
        isVerified: true,
      );

      // Act
      final model = UserModel.fromUserEntity(entity);

      // Assert
      expect(model.uid, entity.uid);
      expect(model.name, entity.name);
      expect(model.email, entity.email);
      expect(model.phone, entity.phone);
      expect(model.image, entity.image);
      expect(model.isVerified, entity.isVerified);

      final mappedEntity = model.toUserEntity();
      expect(mappedEntity, equals(entity));
    });

    test('UserModel fromJson and toJson should serialize and deserialize correctly with fallback values', () {
      // Arrange
      final json = {
        'uid': 'u100',
        'name': 'Alice',
        'email': 'alice@example.com',
        'phoneNumber': '01000000000',
        'imageUrl': 'https://example.com/alice.jpg',
        'isVerified': true,
      };

      // Act
      final model = UserModel.fromJson(json);

      // Assert
      expect(model.uid, 'u100');
      expect(model.name, 'Alice');
      expect(model.email, 'alice@example.com');
      expect(model.phone, '01000000000');
      expect(model.image, 'https://example.com/alice.jpg');
      expect(model.isVerified, isTrue);

      final outputJson = model.toJson();
      expect(outputJson['uid'], 'u100');
      expect(outputJson['name'], 'Alice');
      expect(outputJson['email'], 'alice@example.com');
      expect(outputJson['phone'], '01000000000');
      expect(outputJson['image'], 'https://example.com/alice.jpg');
      expect(outputJson['isVerified'], isTrue);
    });

    test('UserModel fromJson should handle missing/null fields with default fallbacks', () {
      // Act
      final model = UserModel.fromJson({});

      // Assert
      expect(model.uid, '');
      expect(model.name, '');
      expect(model.email, '');
      expect(model.phone, '');
      expect(model.image, '');
      expect(model.isVerified, isFalse);
    });

    test('UserModel fromFirebaseUser should extract name from providerData when displayName is empty', () {
      // Arrange
      final mockProvider = MockUserInfo();
      when(() => mockProvider.displayName).thenReturn('Provider Name');

      final user = MockUser();
      when(() => user.uid).thenReturn('u_prov');
      when(() => user.displayName).thenReturn(null);
      when(() => user.email).thenReturn('user@provider.com');
      when(() => user.phoneNumber).thenReturn(null);
      when(() => user.photoURL).thenReturn(null);
      when(() => user.emailVerified).thenReturn(true);
      when(() => user.providerData).thenReturn([mockProvider]);

      // Act
      final model = UserModel.fromFirebaseUser(user);

      // Assert
      expect(model.name, 'Provider Name');
    });

    test('UserModel fromFirebaseUser should extract name from email prefix when all display names are missing', () {
      // Arrange
      final user = MockUser();
      when(() => user.uid).thenReturn('u_email');
      when(() => user.displayName).thenReturn('');
      when(() => user.email).thenReturn('custom_user@domain.com');
      when(() => user.phoneNumber).thenReturn(null);
      when(() => user.photoURL).thenReturn(null);
      when(() => user.emailVerified).thenReturn(false);
      when(() => user.providerData).thenReturn([]);

      // Act
      final model = UserModel.fromFirebaseUser(user);

      // Assert
      expect(model.name, 'custom_user');
    });

    test('SignUpInputModel toEntity, fromEntity, fromJson and toJson should map properties correctly', () {
      // Arrange
      const entity = SignUpInputEntity(
        email: 'signup@test.com',
        password: 'pass',
        username: 'signup_user',
        phone: '01099999999',
      );

      // Act
      final model = SignUpInputModel.fromEntity(entity);

      // Assert
      expect(model.email, entity.email);
      expect(model.password, entity.password);
      expect(model.username, entity.username);
      expect(model.phone, entity.phone);

      final mappedEntity = model.toEntity();
      expect(mappedEntity.email, entity.email);
      expect(mappedEntity.username, entity.username);

      final json = model.toJson();
      final fromJsonModel = SignUpInputModel.fromJson(json);
      expect(fromJsonModel.email, entity.email);
      expect(fromJsonModel.username, entity.username);
      expect(fromJsonModel.password, entity.password);
      expect(fromJsonModel.phone, entity.phone);
    });

    test(
      'SignUpInputModel fromJson should fallback gracefully when keys are null',
      () {
        // Act
        final model = SignUpInputModel.fromJson({});

        // Assert
        expect(model.email, '');
        expect(model.password, '');
        expect(model.username, '');
        expect(model.phone, '');
      },
    );
  });
}
