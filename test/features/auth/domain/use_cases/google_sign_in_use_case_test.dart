import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/helpers/functions.dart';
import 'package:fruit_hub/core/helpers/network_response.dart';
import 'package:fruit_hub/features/auth/domain/entities/user_entity.dart';
import 'package:fruit_hub/features/auth/domain/repo/auth_repo.dart';
import 'package:fruit_hub/features/auth/domain/use_cases/google_sign_in_use_case.dart';
import 'package:fruit_hub/features/auth/domain/use_cases/save_user_session_use_case.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepo extends Mock implements AuthRepo {}

class MockSaveUserSessionUseCase extends Mock
    implements SaveUserSessionUseCase {}

class FakeUserEntity extends Fake implements UserEntity {}

void main() {
  late GoogleSignInUseCase sut;
  late MockAuthRepo mockAuthRepo;
  late MockSaveUserSessionUseCase mockSaveUserSessionUseCase;

  const tUserEntity = UserEntity(uid: '123', name: 'Google User');
  final tException = Exception('Repo error');
  final tSuccessResponseOfTypeUserEntity = const NetworkSuccess<UserEntity>(
    tUserEntity,
  );
  final tFailureResponseOfTypeUserEntity = NetworkFailure<UserEntity>(
    tException,
  );

  setUpAll(() {
    registerFallbackValue(FakeUserEntity());
  });

  setUp(() {
    mockAuthRepo = MockAuthRepo();
    mockSaveUserSessionUseCase = MockSaveUserSessionUseCase();
    sut = GoogleSignInUseCase(mockAuthRepo, mockSaveUserSessionUseCase);
    when(
      () => mockSaveUserSessionUseCase.call(any()),
    ).thenAnswer((_) async => Future.value());
  });

  group('GoogleSignIn UseCase', () {
    test(
      'should return NetworkSuccess AND call SaveUserSessionUseCase on success',
      () async {
        // Arrange
        when(
          () => mockAuthRepo.googleSignIn(),
        ).thenAnswer((_) async => tSuccessResponseOfTypeUserEntity);

        // Act
        final result = await sut.call();

        // Assert
        expect(result, equals(tSuccessResponseOfTypeUserEntity));
        verify(() => mockAuthRepo.googleSignIn()).called(1);
        verify(() => mockSaveUserSessionUseCase.call(tUserEntity)).called(1);
      },
    );

    test(
      'should return NetworkFailure AND NOT call SaveUserSessionUseCase on failure',
      () async {
        // Arrange
        when(
          () => mockAuthRepo.googleSignIn(),
        ).thenAnswer((_) async => tFailureResponseOfTypeUserEntity);

        // Act
        final result = await sut.call();

        // Assert
        expect(result, equals(tFailureResponseOfTypeUserEntity));
        verify(() => mockAuthRepo.googleSignIn()).called(1);
        verifyNever(() => mockSaveUserSessionUseCase.call(tUserEntity));
      },
    );

    test('should throw exception if SaveUserSessionUseCase fails', () async {
      // Arrange
      final saveException = Exception('Failed to save session');
      when(
        () => mockAuthRepo.googleSignIn(),
      ).thenAnswer((_) async => tSuccessResponseOfTypeUserEntity);
      when(
        () => mockSaveUserSessionUseCase.call(any()),
      ).thenThrow(saveException);

      // Act
      final result = await sut.call();

      // Assert
      expect(result, isA<NetworkFailure<UserEntity>>());
      expect(getErrorMessage(result), "error_occurred_please_try_again");
    });
  });
}
