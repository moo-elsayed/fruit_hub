import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/errors/failures.dart';
import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/features/profile/domain/use_cases/change_password_use_case.dart';
import 'package:fruit_hub/features/profile/presentation/managers/change_password_cubit/change_password_cubit.dart';
import 'package:mocktail/mocktail.dart';

class MockChangePasswordUseCase extends Mock implements ChangePasswordUseCase {}

void main() {
  late MockChangePasswordUseCase mockChangePasswordUseCase;
  late ChangePasswordCubit sut;

  const tCurrentPassword = 'OldPassword123!';
  const tNewPassword = 'NewPassword456!';
  const tErrorMessage = 'Incorrect current password';
  const tServerFailure = ServerFailure(error: tErrorMessage);

  setUp(() {
    mockChangePasswordUseCase = MockChangePasswordUseCase();
    sut = ChangePasswordCubit(mockChangePasswordUseCase);
  });

  tearDown(() {
    sut.close();
  });

  test('initial state should be ChangePasswordInitial', () {
    // Assert
    expect(sut.state, equals(const ChangePasswordInitial()));
  });

  group('changePassword', () {
    blocTest<ChangePasswordCubit, ChangePasswordState>(
      'should emit [ChangePasswordLoading, ChangePasswordSuccess] when use case returns NetworkSuccess',
      setUp: () {
        when(
          () => mockChangePasswordUseCase(
            currentPassword: any(named: 'currentPassword'),
            newPassword: any(named: 'newPassword'),
          ),
        ).thenAnswer((_) async => const NetworkSuccess(null));
      },
      build: () => sut,
      act:
          (cubit) => cubit.changePassword(
            currentPassword: tCurrentPassword,
            newPassword: tNewPassword,
          ),
      expect:
          () => [
            const ChangePasswordLoading(),
            const ChangePasswordSuccess(),
          ],
      verify: (_) {
        verify(
          () => mockChangePasswordUseCase(
            currentPassword: tCurrentPassword,
            newPassword: tNewPassword,
          ),
        ).called(1);
      },
    );

    blocTest<ChangePasswordCubit, ChangePasswordState>(
      'should emit [ChangePasswordLoading, ChangePasswordFailure] with error message when use case returns NetworkFailure',
      setUp: () {
        when(
          () => mockChangePasswordUseCase(
            currentPassword: any(named: 'currentPassword'),
            newPassword: any(named: 'newPassword'),
          ),
        ).thenAnswer((_) async => const NetworkFailure(tServerFailure));
      },
      build: () => sut,
      act:
          (cubit) => cubit.changePassword(
            currentPassword: tCurrentPassword,
            newPassword: tNewPassword,
          ),
      expect:
          () => [
            const ChangePasswordLoading(),
            const ChangePasswordFailure(tErrorMessage),
          ],
      verify: (_) {
        verify(
          () => mockChangePasswordUseCase(
            currentPassword: tCurrentPassword,
            newPassword: tNewPassword,
          ),
        ).called(1);
      },
    );
  });
}
