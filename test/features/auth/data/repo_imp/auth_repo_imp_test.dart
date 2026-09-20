import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/errors/failures.dart';
import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/features/auth/data/data_sources/remote/auth_remote_data_source.dart';
import 'package:fruit_hub/features/auth/data/models/sign_up_input_model.dart';
import 'package:fruit_hub/features/auth/data/models/user_model.dart';
import 'package:fruit_hub/features/auth/data/repo_imp/auth_repo_imp.dart';
import 'package:fruit_hub/features/auth/domain/entities/sign_up_input_entity.dart';
import 'package:fruit_hub/features/auth/domain/entities/user_entity.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class FakeSignUpInputModel extends Fake implements SignUpInputModel {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeSignUpInputModel());
  });

  late MockAuthRemoteDataSource mockAuthRemoteDataSource;
  late AuthRepoImp sut;

  const tUid = 'uid_123';
  const tEmail = 'test@example.com';
  const tPassword = 'Password123';
  const tUsername = 'Test User';
  const tPhone = '01012345678';
  const tImage = 'https://example.com/avatar.png';

  const tSignUpInputEntity = SignUpInputEntity(
    email: tEmail,
    password: tPassword,
    username: tUsername,
    phone: tPhone,
  );

  final tUserModel = UserModel(
    uid: tUid,
    name: tUsername,
    email: tEmail,
    phone: tPhone,
    image: tImage,
    isVerified: true,
  );

  const tUserEntity = UserEntity(
    uid: tUid,
    name: tUsername,
    email: tEmail,
    phone: tPhone,
    image: tImage,
    isVerified: true,
  );

  const tServerFailure = ServerFailure(error: 'Operation failed');

  setUp(() {
    mockAuthRemoteDataSource = MockAuthRemoteDataSource();
    sut = AuthRepoImp(mockAuthRemoteDataSource);
  });

  group('createUserWithEmailAndPassword', () {
    test(
      'should map SignUpInputEntity to SignUpInputModel, call remote data source, and return NetworkSuccess<UserEntity>',
      () async {
        // Arrange
        when(
          () => mockAuthRemoteDataSource.createUserWithEmailAndPassword(any()),
        ).thenAnswer((_) async => NetworkSuccess(tUserModel));

        // Act
        final result = await sut.createUserWithEmailAndPassword(
          tSignUpInputEntity,
        );

        // Assert
        expect(result, isA<NetworkSuccess<UserEntity>>());
        final successResult = result as NetworkSuccess<UserEntity>;
        expect(successResult.data, tUserEntity);

        final captured =
            verify(
                  () => mockAuthRemoteDataSource.createUserWithEmailAndPassword(
                    captureAny(),
                  ),
                ).captured.single
                as SignUpInputModel;

        expect(captured.email, tSignUpInputEntity.email);
        expect(captured.password, tSignUpInputEntity.password);
        expect(captured.username, tSignUpInputEntity.username);
        expect(captured.phone, tSignUpInputEntity.phone);
        verifyNoMoreInteractions(mockAuthRemoteDataSource);
      },
    );

    test(
      'should return NetworkSuccess with null data when remote data source returns NetworkSuccess with null data',
      () async {
        // Arrange
        when(
          () => mockAuthRemoteDataSource.createUserWithEmailAndPassword(any()),
        ).thenAnswer((_) async => const NetworkSuccess<UserModel>(null));

        // Act
        final result = await sut.createUserWithEmailAndPassword(
          tSignUpInputEntity,
        );

        // Assert
        expect(result, isA<NetworkSuccess<UserEntity>>());
        final successResult = result as NetworkSuccess<UserEntity>;
        expect(successResult.data, isNull);
        verify(
          () => mockAuthRemoteDataSource.createUserWithEmailAndPassword(any()),
        ).called(1);
        verifyNoMoreInteractions(mockAuthRemoteDataSource);
      },
    );

    test(
      'should return NetworkFailure when remote data source returns NetworkFailure',
      () async {
        // Arrange
        when(
          () => mockAuthRemoteDataSource.createUserWithEmailAndPassword(any()),
        ).thenAnswer((_) async => const NetworkFailure(tServerFailure));

        // Act
        final result = await sut.createUserWithEmailAndPassword(
          tSignUpInputEntity,
        );

        // Assert
        expect(result, isA<NetworkFailure<UserEntity>>());
        final failureResult = result as NetworkFailure<UserEntity>;
        expect(failureResult.failure, tServerFailure);
        expect(failureResult.error, tServerFailure.error);
        verify(
          () => mockAuthRemoteDataSource.createUserWithEmailAndPassword(any()),
        ).called(1);
        verifyNoMoreInteractions(mockAuthRemoteDataSource);
      },
    );
  });

  group('signInWithEmailAndPassword', () {
    test(
      'should forward email and password to remote data source and return NetworkSuccess<UserEntity>',
      () async {
        // Arrange
        when(
          () => mockAuthRemoteDataSource.signInWithEmailAndPassword(
            email: tEmail,
            password: tPassword,
          ),
        ).thenAnswer((_) async => NetworkSuccess(tUserModel));

        // Act
        final result = await sut.signInWithEmailAndPassword(
          email: tEmail,
          password: tPassword,
        );

        // Assert
        expect(result, isA<NetworkSuccess<UserEntity>>());
        final successResult = result as NetworkSuccess<UserEntity>;
        expect(successResult.data, tUserEntity);
        verify(
          () => mockAuthRemoteDataSource.signInWithEmailAndPassword(
            email: tEmail,
            password: tPassword,
          ),
        ).called(1);
        verifyNoMoreInteractions(mockAuthRemoteDataSource);
      },
    );

    test(
      'should return NetworkSuccess with null data when remote data source returns NetworkSuccess with null data',
      () async {
        // Arrange
        when(
          () => mockAuthRemoteDataSource.signInWithEmailAndPassword(
            email: tEmail,
            password: tPassword,
          ),
        ).thenAnswer((_) async => const NetworkSuccess<UserModel>(null));

        // Act
        final result = await sut.signInWithEmailAndPassword(
          email: tEmail,
          password: tPassword,
        );

        // Assert
        expect(result, isA<NetworkSuccess<UserEntity>>());
        final successResult = result as NetworkSuccess<UserEntity>;
        expect(successResult.data, isNull);
        verify(
          () => mockAuthRemoteDataSource.signInWithEmailAndPassword(
            email: tEmail,
            password: tPassword,
          ),
        ).called(1);
        verifyNoMoreInteractions(mockAuthRemoteDataSource);
      },
    );

    test(
      'should return NetworkFailure when remote data source returns NetworkFailure',
      () async {
        // Arrange
        when(
          () => mockAuthRemoteDataSource.signInWithEmailAndPassword(
            email: tEmail,
            password: tPassword,
          ),
        ).thenAnswer((_) async => const NetworkFailure(tServerFailure));

        // Act
        final result = await sut.signInWithEmailAndPassword(
          email: tEmail,
          password: tPassword,
        );

        // Assert
        expect(result, isA<NetworkFailure<UserEntity>>());
        final failureResult = result as NetworkFailure<UserEntity>;
        expect(failureResult.failure, tServerFailure);
        expect(failureResult.error, tServerFailure.error);
        verify(
          () => mockAuthRemoteDataSource.signInWithEmailAndPassword(
            email: tEmail,
            password: tPassword,
          ),
        ).called(1);
        verifyNoMoreInteractions(mockAuthRemoteDataSource);
      },
    );
  });

  group('googleSignIn', () {
    test(
      'should call remote data source googleSignIn and return NetworkSuccess<UserEntity>',
      () async {
        // Arrange
        when(
          () => mockAuthRemoteDataSource.googleSignIn(),
        ).thenAnswer((_) async => NetworkSuccess(tUserModel));

        // Act
        final result = await sut.googleSignIn();

        // Assert
        expect(result, isA<NetworkSuccess<UserEntity>>());
        final successResult = result as NetworkSuccess<UserEntity>;
        expect(successResult.data, tUserEntity);
        verify(() => mockAuthRemoteDataSource.googleSignIn()).called(1);
        verifyNoMoreInteractions(mockAuthRemoteDataSource);
      },
    );

    test(
      'should return NetworkSuccess with null data when remote data source returns NetworkSuccess with null data',
      () async {
        // Arrange
        when(
          () => mockAuthRemoteDataSource.googleSignIn(),
        ).thenAnswer((_) async => const NetworkSuccess<UserModel>(null));

        // Act
        final result = await sut.googleSignIn();

        // Assert
        expect(result, isA<NetworkSuccess<UserEntity>>());
        final successResult = result as NetworkSuccess<UserEntity>;
        expect(successResult.data, isNull);
        verify(() => mockAuthRemoteDataSource.googleSignIn()).called(1);
        verifyNoMoreInteractions(mockAuthRemoteDataSource);
      },
    );

    test(
      'should return NetworkFailure when remote data source returns NetworkFailure',
      () async {
        // Arrange
        when(
          () => mockAuthRemoteDataSource.googleSignIn(),
        ).thenAnswer((_) async => const NetworkFailure(tServerFailure));

        // Act
        final result = await sut.googleSignIn();

        // Assert
        expect(result, isA<NetworkFailure<UserEntity>>());
        final failureResult = result as NetworkFailure<UserEntity>;
        expect(failureResult.failure, tServerFailure);
        expect(failureResult.error, tServerFailure.error);
        verify(() => mockAuthRemoteDataSource.googleSignIn()).called(1);
        verifyNoMoreInteractions(mockAuthRemoteDataSource);
      },
    );
  });

  group('facebookSignIn', () {
    test(
      'should call remote data source facebookSignIn and return NetworkSuccess<UserEntity>',
      () async {
        // Arrange
        when(
          () => mockAuthRemoteDataSource.facebookSignIn(),
        ).thenAnswer((_) async => NetworkSuccess(tUserModel));

        // Act
        final result = await sut.facebookSignIn();

        // Assert
        expect(result, isA<NetworkSuccess<UserEntity>>());
        final successResult = result as NetworkSuccess<UserEntity>;
        expect(successResult.data, tUserEntity);
        verify(() => mockAuthRemoteDataSource.facebookSignIn()).called(1);
        verifyNoMoreInteractions(mockAuthRemoteDataSource);
      },
    );

    test(
      'should return NetworkSuccess with null data when remote data source returns NetworkSuccess with null data',
      () async {
        // Arrange
        when(
          () => mockAuthRemoteDataSource.facebookSignIn(),
        ).thenAnswer((_) async => const NetworkSuccess<UserModel>(null));

        // Act
        final result = await sut.facebookSignIn();

        // Assert
        expect(result, isA<NetworkSuccess<UserEntity>>());
        final successResult = result as NetworkSuccess<UserEntity>;
        expect(successResult.data, isNull);
        verify(() => mockAuthRemoteDataSource.facebookSignIn()).called(1);
        verifyNoMoreInteractions(mockAuthRemoteDataSource);
      },
    );

    test(
      'should return NetworkFailure when remote data source returns NetworkFailure',
      () async {
        // Arrange
        when(
          () => mockAuthRemoteDataSource.facebookSignIn(),
        ).thenAnswer((_) async => const NetworkFailure(tServerFailure));

        // Act
        final result = await sut.facebookSignIn();

        // Assert
        expect(result, isA<NetworkFailure<UserEntity>>());
        final failureResult = result as NetworkFailure<UserEntity>;
        expect(failureResult.failure, tServerFailure);
        expect(failureResult.error, tServerFailure.error);
        verify(() => mockAuthRemoteDataSource.facebookSignIn()).called(1);
        verifyNoMoreInteractions(mockAuthRemoteDataSource);
      },
    );
  });

  group('getUserInfo', () {
    test(
      'should call remote data source getUserInfo with uid and return NetworkSuccess<UserEntity>',
      () async {
        // Arrange
        when(
          () => mockAuthRemoteDataSource.getUserInfo(tUid),
        ).thenAnswer((_) async => NetworkSuccess(tUserModel));

        // Act
        final result = await sut.getUserInfo(tUid);

        // Assert
        expect(result, isA<NetworkSuccess<UserEntity>>());
        final successResult = result as NetworkSuccess<UserEntity>;
        expect(successResult.data, tUserEntity);
        verify(() => mockAuthRemoteDataSource.getUserInfo(tUid)).called(1);
        verifyNoMoreInteractions(mockAuthRemoteDataSource);
      },
    );

    test(
      'should return NetworkSuccess with null data when remote data source returns NetworkSuccess with null data',
      () async {
        // Arrange
        when(
          () => mockAuthRemoteDataSource.getUserInfo(tUid),
        ).thenAnswer((_) async => const NetworkSuccess<UserModel>(null));

        // Act
        final result = await sut.getUserInfo(tUid);

        // Assert
        expect(result, isA<NetworkSuccess<UserEntity>>());
        final successResult = result as NetworkSuccess<UserEntity>;
        expect(successResult.data, isNull);
        verify(() => mockAuthRemoteDataSource.getUserInfo(tUid)).called(1);
        verifyNoMoreInteractions(mockAuthRemoteDataSource);
      },
    );

    test(
      'should return NetworkFailure when remote data source returns NetworkFailure',
      () async {
        // Arrange
        when(
          () => mockAuthRemoteDataSource.getUserInfo(tUid),
        ).thenAnswer((_) async => const NetworkFailure(tServerFailure));

        // Act
        final result = await sut.getUserInfo(tUid);

        // Assert
        expect(result, isA<NetworkFailure<UserEntity>>());
        final failureResult = result as NetworkFailure<UserEntity>;
        expect(failureResult.failure, tServerFailure);
        expect(failureResult.error, tServerFailure.error);
        verify(() => mockAuthRemoteDataSource.getUserInfo(tUid)).called(1);
        verifyNoMoreInteractions(mockAuthRemoteDataSource);
      },
    );
  });

  group('forgetPassword', () {
    test(
      'should call remote data source forgetPassword with email and return NetworkSuccess<void>',
      () async {
        // Arrange
        when(
          () => mockAuthRemoteDataSource.forgetPassword(tEmail),
        ).thenAnswer((_) async => const NetworkSuccess<void>());

        // Act
        final result = await sut.forgetPassword(tEmail);

        // Assert
        expect(result, isA<NetworkSuccess<void>>());
        verify(() => mockAuthRemoteDataSource.forgetPassword(tEmail)).called(1);
        verifyNoMoreInteractions(mockAuthRemoteDataSource);
      },
    );

    test(
      'should return NetworkFailure when remote data source returns NetworkFailure',
      () async {
        // Arrange
        when(
          () => mockAuthRemoteDataSource.forgetPassword(tEmail),
        ).thenAnswer((_) async => const NetworkFailure<void>(tServerFailure));

        // Act
        final result = await sut.forgetPassword(tEmail);

        // Assert
        expect(result, isA<NetworkFailure<void>>());
        final failureResult = result as NetworkFailure<void>;
        expect(failureResult.failure, tServerFailure);
        expect(failureResult.error, tServerFailure.error);
        verify(() => mockAuthRemoteDataSource.forgetPassword(tEmail)).called(1);
        verifyNoMoreInteractions(mockAuthRemoteDataSource);
      },
    );
  });

  group('signOut', () {
    test(
      'should call remote data source signOut and return NetworkSuccess<void>',
      () async {
        // Arrange
        when(
          () => mockAuthRemoteDataSource.signOut(),
        ).thenAnswer((_) async => const NetworkSuccess<void>());

        // Act
        final result = await sut.signOut();

        // Assert
        expect(result, isA<NetworkSuccess<void>>());
        verify(() => mockAuthRemoteDataSource.signOut()).called(1);
        verifyNoMoreInteractions(mockAuthRemoteDataSource);
      },
    );

    test(
      'should return NetworkFailure when remote data source returns NetworkFailure',
      () async {
        // Arrange
        when(
          () => mockAuthRemoteDataSource.signOut(),
        ).thenAnswer((_) async => const NetworkFailure<void>(tServerFailure));

        // Act
        final result = await sut.signOut();

        // Assert
        expect(result, isA<NetworkFailure<void>>());
        final failureResult = result as NetworkFailure<void>;
        expect(failureResult.failure, tServerFailure);
        expect(failureResult.error, tServerFailure.error);
        verify(() => mockAuthRemoteDataSource.signOut()).called(1);
        verifyNoMoreInteractions(mockAuthRemoteDataSource);
      },
    );
  });
}
