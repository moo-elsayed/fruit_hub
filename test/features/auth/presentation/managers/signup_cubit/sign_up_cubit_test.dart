import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/errors/failures.dart';
import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/features/auth/domain/entities/sign_up_input_entity.dart';
import 'package:fruit_hub/features/auth/domain/entities/user_entity.dart';
import 'package:fruit_hub/features/auth/domain/use_cases/create_user_with_email_and_password_use_case.dart';
import 'package:fruit_hub/features/auth/presentation/managers/signup_cubit/sign_up_cubit.dart';
import 'package:mocktail/mocktail.dart';

class MockCreateUserWithEmailAndPasswordUseCase extends Mock
    implements CreateUserWithEmailAndPasswordUseCase {}

class FakeSignUpInputEntity extends Fake implements SignUpInputEntity {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeSignUpInputEntity());
  });

  late MockCreateUserWithEmailAndPasswordUseCase mockUseCase;
  late SignupCubit sut;

  const tSignUpInputEntity = SignUpInputEntity(
    email: 'test@example.com',
    password: 'Password123',
    username: 'Test User',
    phone: '01012345678',
  );

  const tUserEntity = UserEntity(
    uid: 'uid_123',
    name: 'Test User',
    email: 'test@example.com',
    phone: '01012345678',
    image: 'https://example.com/avatar.png',
    isVerified: true,
  );

  const tErrorMessage = 'Email already in use';
  const tServerFailure = ServerFailure(error: tErrorMessage);

  setUp(() {
    mockUseCase = MockCreateUserWithEmailAndPasswordUseCase();
    sut = SignupCubit(mockUseCase);
  });

  tearDown(() {
    sut.close();
  });

  test('initial state should be SignUpInitial', () {
    // Assert
    expect(sut.state, isA<SignUpInitial>());
  });

  group('createUserWithEmailAndPassword', () {
    blocTest<SignupCubit, SignupState>(
      'should emit [SignUpLoading, SignUpSuccess] when use case returns NetworkSuccess',
      build: () => sut,
      setUp: () {
        // Arrange
        when(() => mockUseCase.call(any()))
            .thenAnswer((_) async => const NetworkSuccess(tUserEntity));
      },
      act: (cubit) async {
        // Act
        await cubit.createUserWithEmailAndPassword(tSignUpInputEntity);
      },
      expect: () => [isA<SignUpLoading>(), isA<SignUpSuccess>()],
      verify: (_) {
        // Assert
        verify(() => mockUseCase.call(tSignUpInputEntity)).called(1);
        verifyNoMoreInteractions(mockUseCase);
      },
    );

    blocTest<SignupCubit, SignupState>(
      'should emit [SignUpLoading, SignUpFailure] with correct error message when use case returns NetworkFailure',
      build: () => sut,
      setUp: () {
        // Arrange
        when(() => mockUseCase.call(any()))
            .thenAnswer((_) async => const NetworkFailure(tServerFailure));
      },
      act: (cubit) async {
        // Act
        await cubit.createUserWithEmailAndPassword(tSignUpInputEntity);
      },
      expect: () => [
        isA<SignUpLoading>(),
        isA<SignUpFailure>().having(
          (state) => state.message,
          'message',
          tErrorMessage,
        ),
      ],
      verify: (_) {
        // Assert
        verify(() => mockUseCase.call(tSignUpInputEntity)).called(1);
        verifyNoMoreInteractions(mockUseCase);
      },
    );
  });
}
