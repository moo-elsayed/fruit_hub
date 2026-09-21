import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/errors/failures.dart';
import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/features/auth/domain/use_cases/sign_out_use_case.dart';
import 'package:fruit_hub/features/auth/presentation/managers/signout_cubit/sign_out_cubit.dart';
import 'package:fruit_hub/features/auth/presentation/managers/user_info_cubit/user_info_cubit.dart';
import 'package:mocktail/mocktail.dart';

class MockSignOutUseCase extends Mock implements SignOutUseCase {}

class MockUserInfoCubit extends Mock implements UserInfoCubit {}

void main() {
  late MockSignOutUseCase mockUseCase;
  late MockUserInfoCubit mockUserInfoCubit;
  late SignOutCubit sut;

  const tErrorMessage = 'Sign out failed';
  const tServerFailure = ServerFailure(error: tErrorMessage);

  setUp(() {
    mockUseCase = MockSignOutUseCase();
    mockUserInfoCubit = MockUserInfoCubit();

    when(() => mockUserInfoCubit.clearUserLocally()).thenAnswer((_) async {});

    sut = SignOutCubit(mockUseCase, mockUserInfoCubit);
  });

  tearDown(() {
    sut.close();
  });

  test('initial state should be SignOutInitial', () {
    // Assert
    expect(sut.state, isA<SignOutInitial>());
  });

  group('signOut', () {
    blocTest<SignOutCubit, SignOutState>(
      'should emit [SignOutLoading, SignOutSuccess] and clear user locally when signOut succeeds',
      build: () => sut,
      setUp: () {
        // Arrange
        when(() => mockUseCase.call())
            .thenAnswer((_) async => const NetworkSuccess<void>());
      },
      act: (cubit) async {
        // Act
        await cubit.signOut();
      },
      expect: () => [isA<SignOutLoading>(), isA<SignOutSuccess>()],
      verify: (_) {
        // Assert
        verify(() => mockUseCase.call()).called(1);
        verify(() => mockUserInfoCubit.clearUserLocally()).called(1);
        verifyNoMoreInteractions(mockUseCase);
      },
    );

    blocTest<SignOutCubit, SignOutState>(
      'should emit [SignOutLoading, SignOutFailure] with correct error message and NOT clear user locally when signOut fails',
      build: () => sut,
      setUp: () {
        // Arrange
        when(
          () => mockUseCase.call(),
        ).thenAnswer((_) async => const NetworkFailure<void>(tServerFailure));
      },
      act: (cubit) async {
        // Act
        await cubit.signOut();
      },
      expect: () => [
        isA<SignOutLoading>(),
        isA<SignOutFailure>().having(
          (state) => state.errorMessage,
          'errorMessage',
          tErrorMessage,
        ),
      ],
      verify: (_) {
        // Assert
        verify(() => mockUseCase.call()).called(1);
        verifyNever(() => mockUserInfoCubit.clearUserLocally());
        verifyNoMoreInteractions(mockUseCase);
      },
    );
  });
}
