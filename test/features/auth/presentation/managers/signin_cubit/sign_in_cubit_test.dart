import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/errors/failures.dart';
import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/features/auth/domain/entities/user_entity.dart';
import 'package:fruit_hub/features/auth/domain/use_cases/sign_in_with_email_and_password_use_case.dart';
import 'package:fruit_hub/features/auth/presentation/managers/signin_cubit/sign_in_cubit.dart';
import 'package:fruit_hub/features/auth/presentation/managers/user_info_cubit/user_info_cubit.dart';
import 'package:mocktail/mocktail.dart';

class MockSignInWithEmailAndPasswordUseCase extends Mock
    implements SignInWithEmailAndPasswordUseCase {}

class MockUserInfoCubit extends Mock implements UserInfoCubit {}

class FakeUserEntity extends Fake implements UserEntity {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeUserEntity());
  });

  late MockSignInWithEmailAndPasswordUseCase mockUseCase;
  late MockUserInfoCubit mockUserInfoCubit;
  late SignInCubit sut;

  const tEmail = 'test@example.com';
  const tPassword = 'Password123';

  const tUserEntity = UserEntity(
    uid: 'uid_123',
    name: 'Test User',
    email: tEmail,
    phone: '01012345678',
    image: 'https://example.com/avatar.png',
    isVerified: true,
  );

  const tErrorMessage = 'Invalid email or password';
  const tServerFailure = ServerFailure(error: tErrorMessage);

  setUp(() {
    mockUseCase = MockSignInWithEmailAndPasswordUseCase();
    mockUserInfoCubit = MockUserInfoCubit();

    when(() => mockUserInfoCubit.saveUserLocally(any()))
        .thenAnswer((_) async {});

    sut = SignInCubit(mockUseCase, mockUserInfoCubit);
  });

  tearDown(() {
    sut.close();
  });

  test('initial state should be SignInInitial', () {
    // Assert
    expect(sut.state, isA<SignInInitial>());
  });

  group('signInWithEmailAndPassword', () {
    blocTest<SignInCubit, SignInState>(
      'should emit [SignInLoading, SignInSuccess] and save user locally when usecase returns NetworkSuccess with user data',
      build: () => sut,
      setUp: () {
        // Arrange
        when(() => mockUseCase.call(email: tEmail, password: tPassword))
            .thenAnswer((_) async => const NetworkSuccess(tUserEntity));
      },
      act: (cubit) async {
        // Act
        await cubit.signInWithEmailAndPassword(
          email: tEmail,
          password: tPassword,
        );
      },
      expect: () => [isA<SignInLoading>(), isA<SignInSuccess>()],
      verify: (_) {
        // Assert
        verify(() => mockUseCase.call(email: tEmail, password: tPassword))
            .called(1);
        verify(() => mockUserInfoCubit.saveUserLocally(tUserEntity)).called(1);
        verifyNoMoreInteractions(mockUseCase);
      },
    );

    blocTest<SignInCubit, SignInState>(
      'should emit [SignInLoading, SignInSuccess] and NOT save user locally when usecase returns NetworkSuccess with null data',
      build: () => sut,
      setUp: () {
        // Arrange
        when(() => mockUseCase.call(email: tEmail, password: tPassword))
            .thenAnswer((_) async => const NetworkSuccess<UserEntity>(null));
      },
      act: (cubit) async {
        // Act
        await cubit.signInWithEmailAndPassword(
          email: tEmail,
          password: tPassword,
        );
      },
      expect: () => [isA<SignInLoading>(), isA<SignInSuccess>()],
      verify: (_) {
        // Assert
        verify(() => mockUseCase.call(email: tEmail, password: tPassword))
            .called(1);
        verifyNever(() => mockUserInfoCubit.saveUserLocally(any()));
        verifyNoMoreInteractions(mockUseCase);
      },
    );

    blocTest<SignInCubit, SignInState>(
      'should emit [SignInLoading, SignInFailure] with correct error message and NOT save user locally when usecase returns NetworkFailure',
      build: () => sut,
      setUp: () {
        // Arrange
        when(() => mockUseCase.call(email: tEmail, password: tPassword))
            .thenAnswer((_) async => const NetworkFailure(tServerFailure));
      },
      act: (cubit) async {
        // Act
        await cubit.signInWithEmailAndPassword(
          email: tEmail,
          password: tPassword,
        );
      },
      expect: () => [
        isA<SignInLoading>(),
        isA<SignInFailure>().having(
          (state) => state.message,
          'message',
          tErrorMessage,
        ),
      ],
      verify: (_) {
        // Assert
        verify(() => mockUseCase.call(email: tEmail, password: tPassword))
            .called(1);
        verifyNever(() => mockUserInfoCubit.saveUserLocally(any()));
        verifyNoMoreInteractions(mockUseCase);
      },
    );
  });
}
