import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/helpers/functions.dart';
import 'package:fruit_hub/core/helpers/network_response.dart';
import 'package:fruit_hub/features/auth/domain/entities/user_entity.dart';
import 'package:fruit_hub/features/auth/domain/use_cases/facebook_sign_in_use_case.dart';
import 'package:fruit_hub/features/auth/domain/use_cases/google_sign_in_use_case.dart';
import 'package:fruit_hub/features/auth/presentation/managers/social_sign_in_cubit/social_sign_in_cubit.dart';
import 'package:mocktail/mocktail.dart';

class MockGoogleSignInUseCase extends Mock implements GoogleSignInUseCase {}

class MockFacebookSignInUseCase extends Mock implements FacebookSignInUseCase {}

void main() {
  late SocialSignInCubit sut;
  late MockGoogleSignInUseCase mockGoogleSignInUseCase;
  late MockFacebookSignInUseCase mockFacebookSignInUseCase;

  final tUserEntity = const UserEntity(name: 'Test User');
  final tSuccessResponseOfTypeUserEntity = NetworkSuccess<UserEntity>(
    tUserEntity,
  );
  final tException = Exception('DataSource error');
  final tFailureResponseOfTypeUserEntity = NetworkFailure<UserEntity>(
    tException,
  );
  final tErrorMessage = getErrorMessage(tFailureResponseOfTypeUserEntity);

  setUp(() {
    mockGoogleSignInUseCase = MockGoogleSignInUseCase();
    mockFacebookSignInUseCase = MockFacebookSignInUseCase();
    sut = SocialSignInCubit(mockGoogleSignInUseCase, mockFacebookSignInUseCase);
  });

  group('socialSignIn', () {
    test('initial state should be SocialSignInInitial', () {
      expect(sut.state, isA<SocialSignInInitial>());
    });
    group('googleSignIn', () {
      blocTest<SocialSignInCubit, SocialSignInState>(
        'emits [GoogleLoading, GoogleSuccess] when sign in is successful',
        build: () => sut,
        setUp: () {
          when(
            () => mockGoogleSignInUseCase.call(),
          ).thenAnswer((_) async => tSuccessResponseOfTypeUserEntity);
        },
        act: (cubit) => cubit.googleSignIn(),
        expect: () => [isA<GoogleLoading>(), isA<GoogleSuccess>()],
        verify: (_) {
          verify(() => mockGoogleSignInUseCase.call()).called(1);
          verifyNoMoreInteractions(mockGoogleSignInUseCase);
        },
      );

      blocTest<SocialSignInCubit, SocialSignInState>(
        'emits [GoogleLoading, GoogleFailure] when sign in fails',
        build: () => sut,
        setUp: () {
          when(
            () => mockGoogleSignInUseCase.call(),
          ).thenAnswer((_) async => tFailureResponseOfTypeUserEntity);
        },
        act: (cubit) => cubit.googleSignIn(),
        expect: () => [
          isA<GoogleLoading>(),
          isA<GoogleFailure>().having(
            (f) => f.message,
            'message',
            tErrorMessage,
          ),
        ],
        verify: (_) {
          verify(() => mockGoogleSignInUseCase.call()).called(1);
          verifyNoMoreInteractions(mockGoogleSignInUseCase);
        },
      );
    });

    group('facebookSignIn', () {
      blocTest<SocialSignInCubit, SocialSignInState>(
        'emits [FacebookLoading, FacebookSuccess] when sign in is successful',
        build: () => sut,
        setUp: () {
          when(
            () => mockFacebookSignInUseCase.call(),
          ).thenAnswer((_) async => tSuccessResponseOfTypeUserEntity);
        },
        act: (cubit) => cubit.facebookSignIn(),
        expect: () => [isA<FacebookLoading>(), isA<FacebookSuccess>()],
        verify: (_) {
          verify(() => mockFacebookSignInUseCase.call()).called(1);
          verifyNoMoreInteractions(mockFacebookSignInUseCase);
        },
      );

      blocTest<SocialSignInCubit, SocialSignInState>(
        'emits [FacebookLoading, FacebookFailure] when sign in fails',
        build: () => sut,
        setUp: () {
          when(
            () => mockFacebookSignInUseCase.call(),
          ).thenAnswer((_) async => tFailureResponseOfTypeUserEntity);
        },
        act: (cubit) => cubit.facebookSignIn(),
        expect: () => [
          isA<FacebookLoading>(),
          isA<FacebookFailure>().having(
            (f) => f.message,
            'message',
            tErrorMessage,
          ),
        ],
        verify: (_) {
          verify(() => mockFacebookSignInUseCase.call()).called(1);
          verifyNoMoreInteractions(mockFacebookSignInUseCase);
        },
      );
    });
  });
}
