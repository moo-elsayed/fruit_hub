import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/helpers/functions.dart';
import 'package:fruit_hub/core/helpers/network_response.dart';
import 'package:fruit_hub/features/auth/domain/entities/user_entity.dart';
import 'package:fruit_hub/features/auth/domain/use_cases/sign_in_with_email_and_password_use_case.dart';
import 'package:fruit_hub/features/auth/presentation/managers/signin_cubit/sign_in_cubit.dart';
import 'package:mocktail/mocktail.dart';

class MockSignInWithEmailAndPasswordUseCase extends Mock
    implements SignInWithEmailAndPasswordUseCase {}

void main() {
  late SignInCubit sut;
  late MockSignInWithEmailAndPasswordUseCase mockSignInWithEmailAndPassword;

  final tEmail = "email";
  final tPassword = "password";
  final tUserEntity = UserEntity(name: 'Test User', email: tEmail);
  final tSuccessResponseOfTypeUserEntity = NetworkSuccess<UserEntity>(
    tUserEntity,
  );
  final tException = Exception('DataSource error');
  final tFailureResponseOfTypeUserEntity = NetworkFailure<UserEntity>(
    tException,
  );
  final tErrorMessage = getErrorMessage(tFailureResponseOfTypeUserEntity);

  setUp(() {
    mockSignInWithEmailAndPassword = MockSignInWithEmailAndPasswordUseCase();
    sut = SignInCubit(mockSignInWithEmailAndPassword);
  });

  group('SignInCubit', () {
    test('initial state should be SignInInitial', () {
      expect(sut.state, isA<SignInInitial>());
    });

    blocTest<SignInCubit, SignInState>(
      'emits [SignInLoading, SignInSuccess] when sign in is successful',
      build: () => sut,
      setUp: () {
        when(
          () => mockSignInWithEmailAndPassword.call(
            password: tPassword,
            email: tEmail,
          ),
        ).thenAnswer((_) async => tSuccessResponseOfTypeUserEntity);
      },
      act: (cubit) =>
          cubit.signInWithEmailAndPassword(email: tEmail, password: tPassword),
      expect: () => [isA<SignInLoading>(), isA<SignInSuccess>()],
      verify: (_) {
        verify(
          () => mockSignInWithEmailAndPassword.call(
            password: tPassword,
            email: tEmail,
          ),
        ).called(1);
        verifyNoMoreInteractions(mockSignInWithEmailAndPassword);
      },
    );

    blocTest<SignInCubit, SignInState>(
      'emits [SignInLoading, SignInFailure] when sign in fails',
      build: () => sut,
      setUp: () {
        when(
          () => mockSignInWithEmailAndPassword.call(
            password: tPassword,
            email: tEmail,
          ),
        ).thenAnswer((_) async => tFailureResponseOfTypeUserEntity);
      },
      act: (cubit) =>
          cubit.signInWithEmailAndPassword(email: tEmail, password: tPassword),
      expect: () => [
        isA<SignInLoading>(),
        isA<SignInFailure>().having((s) => s.message, 'message', tErrorMessage),
      ],
      verify: (_) {
        verify(
          () => mockSignInWithEmailAndPassword.call(
            password: tPassword,
            email: tEmail,
          ),
        ).called(1);
        verifyNoMoreInteractions(mockSignInWithEmailAndPassword);
      },
    );
  });
}
