import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/helpers/network_response.dart';
import 'package:fruit_hub/features/auth/data/data_sources/remote/auth_remote_data_source.dart';
import 'package:fruit_hub/features/auth/data/repo_imp/auth_repo_imp.dart';
import 'package:fruit_hub/features/auth/domain/entities/user_entity.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

void main() {
  late AuthRepoImp sut;
  late MockAuthRemoteDataSource mockAuthRemoteDataSource;

  const tEmail = 'test@test.com';
  const tPassword = 'password123';
  const tUsername = 'Test User';
  const tUserEntity = UserEntity(uid: '123');

  final tException = Exception('DataSource error');
  final tSuccessResponseOfTypeUserEntity = const NetworkSuccess<UserEntity>(
    tUserEntity,
  );
  final tFailureResponseOfTypeUserEntity = NetworkFailure<UserEntity>(
    tException,
  );
  final tSuccessResponseOfTypeVoid = const NetworkSuccess<void>(null);
  final tFailureResponseOfTypeVoid = NetworkFailure<void>(tException);

  setUp(() {
    mockAuthRemoteDataSource = MockAuthRemoteDataSource();
    sut = AuthRepoImp(mockAuthRemoteDataSource);
  });

  group('createUserWithEmailAndPassword', () {
    test('should call data source and return NetworkSuccess', () async {
      // Arrange
      when(
        () => mockAuthRemoteDataSource.createUserWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
          username: any(named: 'username'),
        ),
      ).thenAnswer((_) async => tSuccessResponseOfTypeUserEntity);
      // Act
      final result = await sut.createUserWithEmailAndPassword(
        email: tEmail,
        password: tPassword,
        username: tUsername,
      );
      // Assert
      expect(result, tSuccessResponseOfTypeUserEntity);
      verify(
        () => mockAuthRemoteDataSource.createUserWithEmailAndPassword(
          email: tEmail,
          password: tPassword,
          username: tUsername,
        ),
      ).called(1);
    });

    test('should return NetworkFailure when data source fails', () async {
      // Arrange
      when(
        () => mockAuthRemoteDataSource.createUserWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
          username: any(named: 'username'),
        ),
      ).thenAnswer((_) async => tFailureResponseOfTypeUserEntity);
      // Act
      final result = await sut.createUserWithEmailAndPassword(
        email: tEmail,
        password: tPassword,
        username: tUsername,
      );
      // Assert
      expect(result, equals(tFailureResponseOfTypeUserEntity));
      verify(
        () => mockAuthRemoteDataSource.createUserWithEmailAndPassword(
          email: tEmail,
          password: tPassword,
          username: tUsername,
        ),
      ).called(1);
    });
  });

  group('signInWithEmailAndPassword', () {
    test('should call data source and return NetworkSuccess', () async {
      // Arrange
      when(
        () => mockAuthRemoteDataSource.signInWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => tSuccessResponseOfTypeUserEntity);
      // Act
      final result = await sut.signInWithEmailAndPassword(
        email: tEmail,
        password: tPassword,
      );
      // Assert
      expect(result, tSuccessResponseOfTypeUserEntity);
      verify(
        () => mockAuthRemoteDataSource.signInWithEmailAndPassword(
          email: tEmail,
          password: tPassword,
        ),
      ).called(1);
    });

    test('should return NetworkFailure when data source fails', () async {
      // Arrange
      when(
        () => mockAuthRemoteDataSource.signInWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => tFailureResponseOfTypeUserEntity);
      // Act
      final result = await sut.signInWithEmailAndPassword(
        email: tEmail,
        password: tPassword,
      );
      // Assert
      expect(result, equals(tFailureResponseOfTypeUserEntity));
      verify(
        () => mockAuthRemoteDataSource.signInWithEmailAndPassword(
          email: tEmail,
          password: tPassword,
        ),
      ).called(1);
    });
  });

  group('signOut', () {
    test('should call data source and return NetworkSuccess', () async {
      // Arrange
      when(
        () => mockAuthRemoteDataSource.signOut(),
      ).thenAnswer((_) async => tSuccessResponseOfTypeVoid);
      // Act
      final result = await sut.signOut();
      // Assert
      expect(result, tSuccessResponseOfTypeVoid);
      verify(() => mockAuthRemoteDataSource.signOut()).called(1);
    });

    test('should return NetworkFailure when data source fails', () async {
      // Arrange
      when(
        () => mockAuthRemoteDataSource.signOut(),
      ).thenAnswer((_) async => tFailureResponseOfTypeVoid);
      // Act
      final result = await sut.signOut();
      // Assert
      expect(result, equals(tFailureResponseOfTypeVoid));
      verify(() => mockAuthRemoteDataSource.signOut()).called(1);
    });
  });

  group('forgetPassword', () {
    test('should call data source and return NetworkSuccess', () async {
      // Arrange
      when(
        () => mockAuthRemoteDataSource.forgetPassword(tEmail),
      ).thenAnswer((_) async => tSuccessResponseOfTypeVoid);
      // Act
      final result = await sut.forgetPassword(tEmail);
      // Assert
      expect(result, tSuccessResponseOfTypeVoid);
      verify(() => mockAuthRemoteDataSource.forgetPassword(tEmail)).called(1);
    });

    test('should return NetworkFailure when data source fails', () async {
      // Arrange
      when(
        () => mockAuthRemoteDataSource.forgetPassword(tEmail),
      ).thenAnswer((_) async => tFailureResponseOfTypeVoid);
      // Act
      final result = await sut.forgetPassword(tEmail);
      // Assert
      expect(result, equals(tFailureResponseOfTypeVoid));
      verify(() => mockAuthRemoteDataSource.forgetPassword(tEmail)).called(1);
    });
  });

  group('googleSignIn', () {
    test('should call data source and return NetworkSuccess', () async {
      // Arrange
      when(
        () => mockAuthRemoteDataSource.googleSignIn(),
      ).thenAnswer((_) async => tSuccessResponseOfTypeUserEntity);
      // Act
      final result = await sut.googleSignIn();
      // Assert
      expect(result, tSuccessResponseOfTypeUserEntity);
      verify(() => mockAuthRemoteDataSource.googleSignIn()).called(1);
    });

    test('should return NetworkFailure when data source fails', () async {
      // Arrange
      when(
        () => mockAuthRemoteDataSource.googleSignIn(),
      ).thenAnswer((_) async => tFailureResponseOfTypeUserEntity);
      // Act
      final result = await sut.googleSignIn();
      // Assert
      expect(result, equals(tFailureResponseOfTypeUserEntity));
      verify(() => mockAuthRemoteDataSource.googleSignIn()).called(1);
    });
  });

  group('facebookSignIn', () {
    test('should call data source and return NetworkSuccess', () async {
      // Arrange
      when(
            () => mockAuthRemoteDataSource.facebookSignIn(),
      ).thenAnswer((_) async => tSuccessResponseOfTypeUserEntity);
      // Act
      final result = await sut.facebookSignIn();
      // Assert
      expect(result, tSuccessResponseOfTypeUserEntity);
      verify(() => mockAuthRemoteDataSource.facebookSignIn()).called(1);
    });

    test('should return NetworkFailure when data source fails', () async {
      // Arrange
      when(
            () => mockAuthRemoteDataSource.facebookSignIn(),
      ).thenAnswer((_) async => tFailureResponseOfTypeUserEntity);
      // Act
      final result = await sut.facebookSignIn();
      // Assert
      expect(result, equals(tFailureResponseOfTypeUserEntity));
      verify(() => mockAuthRemoteDataSource.facebookSignIn()).called(1);
    });
  });
}
