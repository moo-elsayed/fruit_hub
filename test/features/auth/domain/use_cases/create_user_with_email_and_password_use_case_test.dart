import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/errors/failures.dart';
import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/features/auth/domain/entities/sign_up_input_entity.dart';
import 'package:fruit_hub/features/auth/domain/entities/user_entity.dart';
import 'package:fruit_hub/features/auth/domain/repo/auth_repo.dart';
import 'package:fruit_hub/features/auth/domain/use_cases/create_user_with_email_and_password_use_case.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepo extends Mock implements AuthRepo {}

class FakeSignUpInputEntity extends Fake implements SignUpInputEntity {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeSignUpInputEntity());
  });

  late MockAuthRepo mockAuthRepo;
  late CreateUserWithEmailAndPasswordUseCase sut;

  const tSignUpInputEntity = SignUpInputEntity(
    email: 'test@example.com',
    password: 'Password123',
    username: 'Test User',
    phone: '01012345678',
  );

  const tUserEntity = UserEntity(
    uid: 'uid_123',
    name: 'Test User',
    email: 'test@example.com',
    phone: '01012345678',
    image: 'https://example.com/avatar.png',
    isVerified: true,
  );

  const tServerFailure = ServerFailure(error: 'User creation failed');

  setUp(() {
    mockAuthRepo = MockAuthRepo();
    sut = CreateUserWithEmailAndPasswordUseCase(mockAuthRepo);
  });

  test(
    'should call createUserWithEmailAndPassword on AuthRepo with correct input and return NetworkSuccess<UserEntity>',
    () async {
      // Arrange
      when(
        () => mockAuthRepo.createUserWithEmailAndPassword(any()),
      ).thenAnswer((_) async => const NetworkSuccess(tUserEntity));

      // Act
      final result = await sut(tSignUpInputEntity);

      // Assert
      expect(result, isA<NetworkSuccess<UserEntity>>());
      final successResult = result as NetworkSuccess<UserEntity>;
      expect(successResult.data, tUserEntity);
      verify(
        () => mockAuthRepo.createUserWithEmailAndPassword(tSignUpInputEntity),
      ).called(1);
      verifyNoMoreInteractions(mockAuthRepo);
    },
  );

  test(
    'should return NetworkFailure when AuthRepo fails to create user',
    () async {
      // Arrange
      when(
        () => mockAuthRepo.createUserWithEmailAndPassword(any()),
      ).thenAnswer((_) async => const NetworkFailure(tServerFailure));

      // Act
      final result = await sut(tSignUpInputEntity);

      // Assert
      expect(result, isA<NetworkFailure<UserEntity>>());
      final failureResult = result as NetworkFailure<UserEntity>;
      expect(failureResult.failure, tServerFailure);
      expect(failureResult.error, tServerFailure.error);
      verify(
        () => mockAuthRepo.createUserWithEmailAndPassword(tSignUpInputEntity),
      ).called(1);
      verifyNoMoreInteractions(mockAuthRepo);
    },
  );
}
