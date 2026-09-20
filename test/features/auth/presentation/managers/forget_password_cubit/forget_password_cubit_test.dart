import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/errors/failures.dart';
import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/features/auth/domain/use_cases/forget_password_use_case.dart';
import 'package:fruit_hub/features/auth/presentation/managers/forget_password_cubit/forget_password_cubit.dart';
import 'package:mocktail/mocktail.dart';

class MockForgetPasswordUseCase extends Mock implements ForgetPasswordUseCase {}

void main() {
  late MockForgetPasswordUseCase mockUseCase;
  late ForgetPasswordCubit sut;

  const tEmail = 'test@example.com';
  const tErrorMessage = 'No user found for that email';
  const tServerFailure = ServerFailure(error: tErrorMessage);

  setUp(() {
    mockUseCase = MockForgetPasswordUseCase();
    sut = ForgetPasswordCubit(mockUseCase);
  });

  tearDown(() {
    sut.close();
  });

  test('initial state should be ForgetPasswordInitial', () {
    // Assert
    expect(sut.state, isA<ForgetPasswordInitial>());
  });

  group('forgetPassword', () {
    blocTest<ForgetPasswordCubit, ForgetPasswordState>(
      'should emit [ForgetPasswordLoading, ForgetPasswordSuccess] when use case returns NetworkSuccess',
      build: () => sut,
      setUp: () {
        // Arrange
        when(() => mockUseCase.call(tEmail))
            .thenAnswer((_) async => const NetworkSuccess<void>());
      },
      act: (cubit) async {
        // Act
        await cubit.forgetPassword(tEmail);
      },
      expect: () => [
        isA<ForgetPasswordLoading>(),
        isA<ForgetPasswordSuccess>(),
      ],
      verify: (_) {
        // Assert
        verify(() => mockUseCase.call(tEmail)).called(1);
        verifyNoMoreInteractions(mockUseCase);
      },
    );

    blocTest<ForgetPasswordCubit, ForgetPasswordState>(
      'should emit [ForgetPasswordLoading, ForgetPasswordFailure] with correct error message when use case returns NetworkFailure',
      build: () => sut,
      setUp: () {
        // Arrange
        when(
          () => mockUseCase.call(tEmail),
        ).thenAnswer((_) async => const NetworkFailure<void>(tServerFailure));
      },
      act: (cubit) async {
        // Act
        await cubit.forgetPassword(tEmail);
      },
      expect: () => [
        isA<ForgetPasswordLoading>(),
        isA<ForgetPasswordFailure>().having(
          (state) => state.errorMessage,
          'errorMessage',
          tErrorMessage,
        ),
      ],
      verify: (_) {
        // Assert
        verify(() => mockUseCase.call(tEmail)).called(1);
        verifyNoMoreInteractions(mockUseCase);
      },
    );
  });
}
