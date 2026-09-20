import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/errors/failures.dart';
import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/features/auth/domain/repo/auth_repo.dart';
import 'package:fruit_hub/features/auth/domain/use_cases/forget_password_use_case.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepo extends Mock implements AuthRepo {}

void main() {
  late MockAuthRepo mockAuthRepo;
  late ForgetPasswordUseCase sut;

  const tEmail = 'test@example.com';
  const tServerFailure = ServerFailure(error: 'User not found for that email');

  setUp(() {
    mockAuthRepo = MockAuthRepo();
    sut = ForgetPasswordUseCase(mockAuthRepo);
  });

  test(
    'should call forgetPassword on AuthRepo with email and return NetworkSuccess<void>',
    () async {
      // Arrange
      when(
        () => mockAuthRepo.forgetPassword(tEmail),
      ).thenAnswer((_) async => const NetworkSuccess<void>());

      // Act
      final result = await sut(tEmail);

      // Assert
      expect(result, isA<NetworkSuccess<void>>());
      verify(() => mockAuthRepo.forgetPassword(tEmail)).called(1);
      verifyNoMoreInteractions(mockAuthRepo);
    },
  );

  test(
    'should return NetworkFailure when AuthRepo fails to send reset email',
    () async {
      // Arrange
      when(
        () => mockAuthRepo.forgetPassword(tEmail),
      ).thenAnswer((_) async => const NetworkFailure<void>(tServerFailure));

      // Act
      final result = await sut(tEmail);

      // Assert
      expect(result, isA<NetworkFailure<void>>());
      final failureResult = result as NetworkFailure<void>;
      expect(failureResult.failure, tServerFailure);
      expect(failureResult.error, tServerFailure.error);
      verify(() => mockAuthRepo.forgetPassword(tEmail)).called(1);
      verifyNoMoreInteractions(mockAuthRepo);
    },
  );
}
