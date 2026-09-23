import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/errors/failures.dart';
import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/features/profile/domain/repo/profile_repo.dart';
import 'package:fruit_hub/features/profile/domain/use_cases/change_password_use_case.dart';
import 'package:mocktail/mocktail.dart';

class MockProfileRepo extends Mock implements ProfileRepo {}

void main() {
  late MockProfileRepo mockProfileRepo;
  late ChangePasswordUseCase sut;

  const tServerFailure = ServerFailure(error: 'Failed to change password');
  const tCurrentPassword = 'OldPassword123!';
  const tNewPassword = 'NewPassword456!';

  setUp(() {
    mockProfileRepo = MockProfileRepo();
    sut = ChangePasswordUseCase(mockProfileRepo);
  });

  test('should call changePassword on ProfileRepo with correct currentPassword and newPassword and return NetworkSuccess<void>', () async {
    // Arrange
    when(
      () => mockProfileRepo.changePassword(
        currentPassword: any(named: 'currentPassword'),
        newPassword: any(named: 'newPassword'),
      ),
    ).thenAnswer((_) async => const NetworkSuccess(null));

    // Act
    final result = await sut(
      currentPassword: tCurrentPassword,
      newPassword: tNewPassword,
    );

    // Assert
    expect(result, isA<NetworkSuccess<void>>());
    verify(
      () => mockProfileRepo.changePassword(
        currentPassword: tCurrentPassword,
        newPassword: tNewPassword,
      ),
    ).called(1);
  });

  test(
    'should return NetworkFailure when ProfileRepo fails during changePassword',
    () async {
      // Arrange
      when(
        () => mockProfileRepo.changePassword(
          currentPassword: any(named: 'currentPassword'),
          newPassword: any(named: 'newPassword'),
        ),
      ).thenAnswer((_) async => const NetworkFailure(tServerFailure));

      // Act
      final result = await sut(
        currentPassword: tCurrentPassword,
        newPassword: tNewPassword,
      );

      // Assert
      expect(result, isA<NetworkFailure<void>>());
      final actualFailure = (result as NetworkFailure<void>).failure;
      expect(actualFailure, equals(tServerFailure));

      verify(
        () => mockProfileRepo.changePassword(
          currentPassword: tCurrentPassword,
          newPassword: tNewPassword,
        ),
      ).called(1);
    },
  );
}
