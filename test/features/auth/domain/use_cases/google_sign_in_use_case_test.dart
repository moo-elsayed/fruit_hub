import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/errors/failures.dart';
import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/features/auth/domain/entities/user_entity.dart';
import 'package:fruit_hub/features/auth/domain/repo/auth_repo.dart';
import 'package:fruit_hub/features/auth/domain/use_cases/google_sign_in_use_case.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepo extends Mock implements AuthRepo {}

void main() {
  late MockAuthRepo mockAuthRepo;
  late GoogleSignInUseCase sut;

  const tUserEntity = UserEntity(
    uid: 'google_uid_123',
    name: 'Google User',
    email: 'google@example.com',
    phone: '01012345678',
    image: 'https://example.com/google_avatar.png',
    isVerified: true,
  );

  const tServerFailure = ServerFailure(error: 'Google sign in cancelled');

  setUp(() {
    mockAuthRepo = MockAuthRepo();
    sut = GoogleSignInUseCase(mockAuthRepo);
  });

  test('should call googleSignIn on AuthRepo and return NetworkSuccess<UserEntity>', () async {
    // Arrange
    when(() => mockAuthRepo.googleSignIn())
        .thenAnswer((_) async => const NetworkSuccess(tUserEntity));

    // Act
    final result = await sut();

    // Assert
    expect(result, isA<NetworkSuccess<UserEntity>>());
    final successResult = result as NetworkSuccess<UserEntity>;
    expect(successResult.data, tUserEntity);
    verify(() => mockAuthRepo.googleSignIn()).called(1);
    verifyNoMoreInteractions(mockAuthRepo);
  });

  test(
    'should return NetworkFailure when AuthRepo fails during googleSignIn',
    () async {
      // Arrange
      when(() => mockAuthRepo.googleSignIn())
          .thenAnswer((_) async => const NetworkFailure(tServerFailure));

      // Act
      final result = await sut();

      // Assert
      expect(result, isA<NetworkFailure<UserEntity>>());
      final failureResult = result as NetworkFailure<UserEntity>;
      expect(failureResult.failure, tServerFailure);
      expect(failureResult.error, tServerFailure.error);
      verify(() => mockAuthRepo.googleSignIn()).called(1);
      verifyNoMoreInteractions(mockAuthRepo);
    },
  );
}
