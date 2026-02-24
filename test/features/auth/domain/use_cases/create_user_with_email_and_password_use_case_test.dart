import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/helpers/network_response.dart';
import 'package:fruit_hub/features/auth/domain/entities/user_entity.dart';
import 'package:fruit_hub/features/auth/domain/repo/auth_repo.dart';
import 'package:fruit_hub/features/auth/domain/use_cases/create_user_with_email_and_password_use_case.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepo extends Mock implements AuthRepo {}

void main() {
  late CreateUserWithEmailAndPasswordUseCase sut;
  late MockAuthRepo mockAuthRepo;

  setUp(() {
    mockAuthRepo = MockAuthRepo();
    sut = CreateUserWithEmailAndPasswordUseCase(mockAuthRepo);
  });

  final tEmail = "email";
  final tPassword = "password";
  final tUser = "user";
  const tUserEntity = UserEntity();
  final tException = Exception('DataSource error');
  final tSuccessResponseOfTypeUserEntity = const NetworkSuccess<UserEntity>(
    tUserEntity,
  );
  final tFailureResponseOfTypeUserEntity = NetworkFailure<UserEntity>(
    tException,
  );

  group('createUserWithEmailAndPassword UseCase', () {
    test("should create user with email and password", () async {
      // Arrange
      when(
        () => mockAuthRepo.createUserWithEmailAndPassword(
          username: tUser,
          email: tEmail,
          password: tPassword,
        ),
      ).thenAnswer((_) async => tSuccessResponseOfTypeUserEntity);
      // Act
      final result = await sut.call(
        username: tUser,
        email: tEmail,
        password: tPassword,
      );
      // Assert
      expect(result, equals(tSuccessResponseOfTypeUserEntity));
      verify(
        () => mockAuthRepo.createUserWithEmailAndPassword(
          username: tUser,
          email: tEmail,
          password: tPassword,
        ),
      ).called(1);
    });

    test("should return failure when creating user fails", () async {
      // Arrange
      when(
        () => mockAuthRepo.createUserWithEmailAndPassword(
          username: tUser,
          email: tEmail,
          password: tPassword,
        ),
      ).thenAnswer((_) async => tFailureResponseOfTypeUserEntity);
      // Act
      final result = await sut.call(
        username: tUser,
        email: tEmail,
        password: tPassword,
      );
      // Assert
      expect(result, equals(tFailureResponseOfTypeUserEntity));
      verify(
        () => mockAuthRepo.createUserWithEmailAndPassword(
          username: tUser,
          email: tEmail,
          password: tPassword,
        ),
      ).called(1);
    });
  });
}
