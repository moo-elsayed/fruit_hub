import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/helpers/functions.dart';
import 'package:fruit_hub/core/helpers/network_response.dart';
import 'package:fruit_hub/features/auth/domain/use_cases/forget_password_use_case.dart';
import 'package:fruit_hub/features/auth/presentation/managers/forget_password_cubit/forget_password_cubit.dart';
import 'package:mocktail/mocktail.dart';

class MockForgetPasswordUseCase extends Mock implements ForgetPasswordUseCase {}

void main() {
  late ForgetPasswordCubit sut;
  late MockForgetPasswordUseCase mockForgetPasswordUseCase;

  final tEmail = "email";
  final tSuccessResponseOfTypeVoid = const NetworkSuccess<void>();
  final tException = Exception('DataSource error');
  final tFailureResponseOfTypeVoid = NetworkFailure<void>(tException);
  final tErrorMessage = getErrorMessage(tFailureResponseOfTypeVoid);

  setUpAll(() {
    registerFallbackValue(const NetworkSuccess<void>());
    registerFallbackValue(NetworkFailure<void>(tException));
  });

  setUp(() {
    mockForgetPasswordUseCase = MockForgetPasswordUseCase();
    sut = ForgetPasswordCubit(mockForgetPasswordUseCase);
  });

  group('ForgetPasswordCubit', () {
    test('initial state should be ForgetPasswordInitial', () {
      expect(sut.state, isA<ForgetPasswordInitial>());
    });

    blocTest<ForgetPasswordCubit, ForgetPasswordState>(
      'emits [ForgetPasswordLoading, ForgetPasswordSuccess] when forgetPassword is successful',
      build: () => sut,
      setUp: () {
        when(
          () => mockForgetPasswordUseCase.call(tEmail),
        ).thenAnswer((_) async => tSuccessResponseOfTypeVoid);
      },
      act: (cubit) => cubit.forgetPassword(tEmail),
      expect: () => [
        isA<ForgetPasswordLoading>(),
        isA<ForgetPasswordSuccess>(),
      ],
      verify: (_) {
        verify(() => mockForgetPasswordUseCase.call(tEmail)).called(1);
        verifyNoMoreInteractions(mockForgetPasswordUseCase);
      },
    );

    blocTest<ForgetPasswordCubit, ForgetPasswordState>(
      'emits [ForgetPasswordLoading, ForgetPasswordFailure] when forgetPassword fails',
      build: () => sut,
      setUp: () {
        when(
          () => mockForgetPasswordUseCase.call(tEmail),
        ).thenAnswer((_) async => tFailureResponseOfTypeVoid);
      },
      act: (cubit) => cubit.forgetPassword(tEmail),
      expect: () => [
        isA<ForgetPasswordLoading>(),
        isA<ForgetPasswordFailure>().having(
          (f) => f.errorMessage,
          'message',
          tErrorMessage,
        ),
      ],
      verify: (_) {
        verify(() => mockForgetPasswordUseCase.call(tEmail)).called(1);
        verifyNoMoreInteractions(mockForgetPasswordUseCase);
      },
    );
  });
}
