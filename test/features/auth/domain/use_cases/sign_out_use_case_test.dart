import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/helpers/functions.dart';
import 'package:fruit_hub/core/helpers/network_response.dart';
import 'package:fruit_hub/features/auth/domain/repo/auth_repo.dart';
import 'package:fruit_hub/features/auth/domain/use_cases/clear_user_session_use_case.dart';
import 'package:fruit_hub/features/auth/domain/use_cases/sign_out_use_case.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepo extends Mock implements AuthRepo {}

class MockClearUserSessionUseCase extends Mock
    implements ClearUserSessionUseCase {}

void main() {
  late SignOutUseCase sut;
  late MockClearUserSessionUseCase mockClearUserSessionUseCase;
  late MockAuthRepo mockAuthRepo;

  final tSuccessResponseOfTypeVoid = const NetworkSuccess<void>();
  final tException = Exception('DataSource error');
  final tFailureResponseOfTypeVoid = NetworkFailure<void>(tException);

  setUpAll(() {
    registerFallbackValue(const NetworkSuccess<void>());
    registerFallbackValue(NetworkFailure<void>(tException));
  });

  setUp(() {
    mockAuthRepo = MockAuthRepo();
    mockClearUserSessionUseCase = MockClearUserSessionUseCase();
    sut = SignOutUseCase(mockAuthRepo, mockClearUserSessionUseCase);
  });

  group('signOut UseCase', () {
    test(
      'should call [AuthRepo.signOut] and clear user session and return NetworkSuccess<void> when successful',
      () async {
        // Arrange
        when(
          () => mockAuthRepo.signOut(),
        ).thenAnswer((_) async => tSuccessResponseOfTypeVoid);
        when(
          () => mockClearUserSessionUseCase.call(),
        ).thenAnswer((_) async => Future.value());

        // Act
        final result = await sut.call();

        // Assert
        expect(result, tSuccessResponseOfTypeVoid);
        verify(() => mockAuthRepo.signOut()).called(1);
        verify(() => mockClearUserSessionUseCase.call()).called(1);
        verifyNoMoreInteractions(mockAuthRepo);
        verifyNoMoreInteractions(mockClearUserSessionUseCase);
      },
    );

    test(
      'should call [AuthRepo.signOut] and return NetworkFailure<void> when failed',
      () async {
        // Arrange
        when(
          () => mockAuthRepo.signOut(),
        ).thenAnswer((_) async => tFailureResponseOfTypeVoid);

        // Act
        final result = await sut.call();

        // Assert
        expect(result, tFailureResponseOfTypeVoid);
        verify(() => mockAuthRepo.signOut()).called(1);
        verifyNoMoreInteractions(mockAuthRepo);
        verifyNoMoreInteractions(mockClearUserSessionUseCase);
      },
    );

    test(
      'should return NetworkFailure<void> when clearUserSessionUseCase failed',
      () async {
        final saveException = Exception('Failed to save session');
        // Arrange
        when(
          () => mockAuthRepo.signOut(),
        ).thenAnswer((_) async => tSuccessResponseOfTypeVoid);

        when(
          () => mockClearUserSessionUseCase.call(),
        ).thenThrow(saveException);

        // Act
        final result = await sut.call();

        // Assert
        expect(result, isA<NetworkFailure<void>>());
        expect(getErrorMessage(result), "error_occurred_please_try_again");
        verify(() => mockAuthRepo.signOut()).called(1);
        verify(() => mockClearUserSessionUseCase.call()).called(1);
        verifyNoMoreInteractions(mockAuthRepo);
        verifyNoMoreInteractions(mockClearUserSessionUseCase);
      },
    );
  });
}
