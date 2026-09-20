import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/errors/failures.dart';
import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/features/auth/domain/entities/user_entity.dart';
import 'package:fruit_hub/features/auth/domain/repo/auth_repo.dart';
import 'package:fruit_hub/features/auth/domain/use_cases/sign_in_with_email_and_password_use_case.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepo extends Mock implements AuthRepo {}

void main() {
  late MockAuthRepo mockAuthRepo;
  late SignInWithEmailAndPasswordUseCase sut;

  const tEmail = 'test@example.com';
  const tPassword = 'Password123';

  const tUserEntity = UserEntity(
    uid: 'uid_123',
    name: 'Test User',
    email: tEmail,
    phone: '01012345678',
    image: 'https://example.com/avatar.png',
    isVerified: true,
  );

  const tServerFailure = ServerFailure(error: 'Invalid credentials');

  setUp(() {
    mockAuthRepo = MockAuthRepo();
    sut = SignInWithEmailAndPasswordUseCase(mockAuthRepo);
  });

  test(
    'should forward email and password to AuthRepo and return NetworkSuccess<UserEntity>',
    () async {
      // Arrange
      when(
        () => mockAuthRepo.signInWithEmailAndPassword(
          email: tEmail,
          password: tPassword,
        ),
      ).thenAnswer((_) async => const NetworkSuccess(tUserEntity));

      // Act
      final result = await sut(email: tEmail, password: tPassword);

      // Assert
      expect(result, isA<NetworkSuccess<UserEntity>>());
      final successResult = result as NetworkSuccess<UserEntity>;
      expect(successResult.data, tUserEntity);
      verify(
        () => mockAuthRepo.signInWithEmailAndPassword(
          email: tEmail,
          password: tPassword,
        ),
      ).called(1);
      verifyNoMoreInteractions(mockAuthRepo);
    },
  );

  test('should return NetworkFailure when AuthRepo fails to sign in', () async {
    // Arrange
    when(
      () => mockAuthRepo.signInWithEmailAndPassword(
        email: tEmail,
        password: tPassword,
      ),
    ).thenAnswer((_) async => const NetworkFailure(tServerFailure));

    // Act
    final result = await sut(email: tEmail, password: tPassword);

    // Assert
    expect(result, isA<NetworkFailure<UserEntity>>());
    final failureResult = result as NetworkFailure<UserEntity>;
    expect(failureResult.failure, tServerFailure);
    expect(failureResult.error, tServerFailure.error);
    verify(
      () => mockAuthRepo.signInWithEmailAndPassword(
        email: tEmail,
        password: tPassword,
      ),
    ).called(1);
    verifyNoMoreInteractions(mockAuthRepo);
  });
}
