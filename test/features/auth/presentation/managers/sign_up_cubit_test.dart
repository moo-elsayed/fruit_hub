import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/helpers/functions.dart';
import 'package:fruit_hub/core/helpers/network_response.dart';
import 'package:fruit_hub/features/auth/domain/entities/user_entity.dart';
import 'package:fruit_hub/features/auth/domain/use_cases/create_user_with_email_and_password_use_case.dart';
import 'package:fruit_hub/features/auth/presentation/managers/signup_cubit/sign_up_cubit.dart';
import 'package:mocktail/mocktail.dart';

class MockCreateUserWithEmailAndPasswordUseCase extends Mock
    implements CreateUserWithEmailAndPasswordUseCase {}

void main() {
  late SignupCubit sut;
  late MockCreateUserWithEmailAndPasswordUseCase
  mockCreateUserWithEmailAndPasswordUseCase;

  final tEmail = "email";
  final tPassword = "password";
  final tUserName = "userName";
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
    mockCreateUserWithEmailAndPasswordUseCase =
        MockCreateUserWithEmailAndPasswordUseCase();
    sut = SignupCubit(mockCreateUserWithEmailAndPasswordUseCase);
  });

  group('SignupCubit', () {
    test('initial state should be SignUpInitial', () {
      expect(sut.state, isA<SignUpInitial>());
    });

    blocTest<SignupCubit, SignupState>(
      'emits [SignInLoading, SignInSuccess] when sign in is successful',
      build: () => sut,
      setUp: () {
        when(
          () => mockCreateUserWithEmailAndPasswordUseCase.call(
            password: tPassword,
            email: tEmail,
            username: tUserName,
          ),
        ).thenAnswer((_) async => tSuccessResponseOfTypeUserEntity);
      },
      act: (cubit) => cubit.createUserWithEmailAndPassword(
        email: tEmail,
        password: tPassword,
        username: tUserName,
      ),
      expect: () => [isA<SignUpLoading>(), isA<SignUpSuccess>()],
      verify: (_) {
        verify(
          () => mockCreateUserWithEmailAndPasswordUseCase.call(
            password: tPassword,
            email: tEmail,
            username: tUserName,
          ),
        ).called(1);
        verifyNoMoreInteractions(mockCreateUserWithEmailAndPasswordUseCase);
      },
    );

    blocTest<SignupCubit, SignupState>(
      'emits [SignUpLoading, SignUpFailure] when sign up fails',
      build: () => sut,
      act: (cubit) => cubit.createUserWithEmailAndPassword(
        email: tEmail,
        password: tPassword,
        username: tUserName,
      ),
      setUp: () {
        when(
          () => mockCreateUserWithEmailAndPasswordUseCase.call(
            password: tPassword,
            email: tEmail,
            username: tUserName,
          ),
        ).thenAnswer((_) async => tFailureResponseOfTypeUserEntity);
      },
      expect: () => [
        isA<SignUpLoading>(),
        isA<SignUpFailure>().having((s) => s.message, 'message', tErrorMessage),
      ],
      verify: (_) {
        verify(
          () => mockCreateUserWithEmailAndPasswordUseCase.call(
            password: tPassword,
            email: tEmail,
            username: tUserName,
          ),
        ).called(1);
        verifyNoMoreInteractions(mockCreateUserWithEmailAndPasswordUseCase);
      },
    );
  });
}
