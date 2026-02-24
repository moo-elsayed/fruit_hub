import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/helpers/network_response.dart';
import 'package:fruit_hub/features/auth/domain/repo/auth_repo.dart';
import 'package:fruit_hub/features/auth/domain/use_cases/forget_password_use_case.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepo extends Mock implements AuthRepo {}

void main() {
  late ForgetPasswordUseCase sut;
  late MockAuthRepo mockAuthRepo;

  final tEmail = "email";
  final tSuccessResponseOfTypeVoid = const NetworkSuccess<void>();
  final tException = Exception('DataSource error');
  final tFailureResponseOfTypeVoid = NetworkFailure<void>(tException);

  setUpAll(() {
    registerFallbackValue(const NetworkSuccess<void>());
    registerFallbackValue(NetworkFailure<void>(tException));
  });

  setUp(() {
    mockAuthRepo = MockAuthRepo();
    sut = ForgetPasswordUseCase(mockAuthRepo);
  });

  group('forgetPassword UseCase', () {
    test(
      'should call [AuthRepo.forgetPassword] and return NetworkSuccess<void> when successful',
      () async {
        // Arrange
        when(
          () => mockAuthRepo.forgetPassword(tEmail),
        ).thenAnswer((_) async => tSuccessResponseOfTypeVoid);

        // Act
        final result = await sut.call(tEmail);

        // Assert
        expect(result, tSuccessResponseOfTypeVoid);
        verify(() => mockAuthRepo.forgetPassword(tEmail)).called(1);
        verifyNoMoreInteractions(mockAuthRepo);
      },
    );

    test(
      'should call [AuthRepo.forgetPassword] and return NetworkFailure<void> when failed',
      () async {
        // Arrange
        when(
          () => mockAuthRepo.forgetPassword(tEmail),
        ).thenAnswer((_) async => tFailureResponseOfTypeVoid);

        // Act
        final result = await sut.call(tEmail);

        // Assert
        expect(result, tFailureResponseOfTypeVoid);
        verify(() => mockAuthRepo.forgetPassword(tEmail)).called(1);
        verifyNoMoreInteractions(mockAuthRepo);
      },
    );
  });
}
