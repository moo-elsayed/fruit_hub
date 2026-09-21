import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/errors/failures.dart';
import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/features/auth/domain/entities/user_entity.dart';
import 'package:fruit_hub/features/auth/domain/use_cases/facebook_sign_in_use_case.dart';
import 'package:fruit_hub/features/auth/domain/use_cases/google_sign_in_use_case.dart';
import 'package:fruit_hub/features/auth/presentation/managers/social_sign_in_cubit/social_sign_in_cubit.dart';
import 'package:fruit_hub/features/auth/presentation/managers/user_info_cubit/user_info_cubit.dart';
import 'package:mocktail/mocktail.dart';

class MockGoogleSignInUseCase extends Mock implements GoogleSignInUseCase {}

class MockFacebookSignInUseCase extends Mock implements FacebookSignInUseCase {}

class MockUserInfoCubit extends Mock implements UserInfoCubit {}

class FakeUserEntity extends Fake implements UserEntity {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeUserEntity());
  });

  late MockGoogleSignInUseCase mockGoogleUseCase;
  late MockFacebookSignInUseCase mockFacebookUseCase;
  late MockUserInfoCubit mockUserInfoCubit;
  late SocialSignInCubit sut;

  const tUserEntity = UserEntity(
    uid: 'social_uid_123',
    name: 'Social User',
    email: 'social@example.com',
    phone: '01012345678',
    image: 'https://example.com/avatar.png',
    isVerified: true,
  );

  const tErrorMessage = 'Sign in cancelled';
  const tServerFailure = ServerFailure(error: tErrorMessage);

  setUp(() {
    mockGoogleUseCase = MockGoogleSignInUseCase();
    mockFacebookUseCase = MockFacebookSignInUseCase();
    mockUserInfoCubit = MockUserInfoCubit();

    when(() => mockUserInfoCubit.saveUserLocally(any()))
        .thenAnswer((_) async {});

    sut = SocialSignInCubit(
      mockGoogleUseCase,
      mockFacebookUseCase,
      mockUserInfoCubit,
    );
  });

  tearDown(() {
    sut.close();
  });

  test('initial state should be SocialSignInInitial', () {
    // Assert
    expect(sut.state, isA<SocialSignInInitial>());
  });

  group('googleSignIn', () {
    blocTest<SocialSignInCubit, SocialSignInState>(
      'should emit [GoogleLoading, GoogleSuccess] and save user locally when googleSignIn succeeds with user data',
      build: () => sut,
      setUp: () {
        // Arrange
        when(() => mockGoogleUseCase.call())
            .thenAnswer((_) async => const NetworkSuccess(tUserEntity));
      },
      act: (cubit) async {
        // Act
        await cubit.googleSignIn();
      },
      expect: () => [isA<GoogleLoading>(), isA<GoogleSuccess>()],
      verify: (_) {
        // Assert
        verify(() => mockGoogleUseCase.call()).called(1);
        verify(() => mockUserInfoCubit.saveUserLocally(tUserEntity)).called(1);
        verifyNoMoreInteractions(mockGoogleUseCase);
      },
    );

    blocTest<SocialSignInCubit, SocialSignInState>(
      'should emit [GoogleLoading, GoogleSuccess] and NOT save user locally when googleSignIn returns NetworkSuccess with null data',
      build: () => sut,
      setUp: () {
        // Arrange
        when(() => mockGoogleUseCase.call())
            .thenAnswer((_) async => const NetworkSuccess<UserEntity>(null));
      },
      act: (cubit) async {
        // Act
        await cubit.googleSignIn();
      },
      expect: () => [isA<GoogleLoading>(), isA<GoogleSuccess>()],
      verify: (_) {
        // Assert
        verify(() => mockGoogleUseCase.call()).called(1);
        verifyNever(() => mockUserInfoCubit.saveUserLocally(any()));
        verifyNoMoreInteractions(mockGoogleUseCase);
      },
    );

    blocTest<SocialSignInCubit, SocialSignInState>(
      'should emit [GoogleLoading, GoogleFailure] with correct error message and NOT save user locally when googleSignIn returns NetworkFailure',
      build: () => sut,
      setUp: () {
        // Arrange
        when(() => mockGoogleUseCase.call())
            .thenAnswer((_) async => const NetworkFailure(tServerFailure));
      },
      act: (cubit) async {
        // Act
        await cubit.googleSignIn();
      },
      expect: () => [
        isA<GoogleLoading>(),
        isA<GoogleFailure>().having(
          (state) => state.message,
          'message',
          tErrorMessage,
        ),
      ],
      verify: (_) {
        // Assert
        verify(() => mockGoogleUseCase.call()).called(1);
        verifyNever(() => mockUserInfoCubit.saveUserLocally(any()));
        verifyNoMoreInteractions(mockGoogleUseCase);
      },
    );
  });

  group('facebookSignIn', () {
    blocTest<SocialSignInCubit, SocialSignInState>(
      'should emit [FacebookLoading, FacebookSuccess] and save user locally when facebookSignIn succeeds with user data',
      build: () => sut,
      setUp: () {
        // Arrange
        when(() => mockFacebookUseCase.call())
            .thenAnswer((_) async => const NetworkSuccess(tUserEntity));
      },
      act: (cubit) async {
        // Act
        await cubit.facebookSignIn();
      },
      expect: () => [isA<FacebookLoading>(), isA<FacebookSuccess>()],
      verify: (_) {
        // Assert
        verify(() => mockFacebookUseCase.call()).called(1);
        verify(() => mockUserInfoCubit.saveUserLocally(tUserEntity)).called(1);
        verifyNoMoreInteractions(mockFacebookUseCase);
      },
    );

    blocTest<SocialSignInCubit, SocialSignInState>(
      'should emit [FacebookLoading, FacebookSuccess] and NOT save user locally when facebookSignIn returns NetworkSuccess with null data',
      build: () => sut,
      setUp: () {
        // Arrange
        when(() => mockFacebookUseCase.call())
            .thenAnswer((_) async => const NetworkSuccess<UserEntity>(null));
      },
      act: (cubit) async {
        // Act
        await cubit.facebookSignIn();
      },
      expect: () => [isA<FacebookLoading>(), isA<FacebookSuccess>()],
      verify: (_) {
        // Assert
        verify(() => mockFacebookUseCase.call()).called(1);
        verifyNever(() => mockUserInfoCubit.saveUserLocally(any()));
        verifyNoMoreInteractions(mockFacebookUseCase);
      },
    );

    blocTest<SocialSignInCubit, SocialSignInState>(
      'should emit [FacebookLoading, FacebookFailure] with correct error message and NOT save user locally when facebookSignIn returns NetworkFailure',
      build: () => sut,
      setUp: () {
        // Arrange
        when(() => mockFacebookUseCase.call())
            .thenAnswer((_) async => const NetworkFailure(tServerFailure));
      },
      act: (cubit) async {
        // Act
        await cubit.facebookSignIn();
      },
      expect: () => [
        isA<FacebookLoading>(),
        isA<FacebookFailure>().having(
          (state) => state.message,
          'message',
          tErrorMessage,
        ),
      ],
      verify: (_) {
        // Assert
        verify(() => mockFacebookUseCase.call()).called(1);
        verifyNever(() => mockUserInfoCubit.saveUserLocally(any()));
        verifyNoMoreInteractions(mockFacebookUseCase);
      },
    );
  });
}
