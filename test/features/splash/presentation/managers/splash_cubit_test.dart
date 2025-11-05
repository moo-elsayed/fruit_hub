import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/services/local_storage/local_storage_service.dart';
import 'package:fruit_hub/features/splash/presentation/managers/splash_cubit/splash_cubit.dart';
import 'package:mocktail/mocktail.dart';

class MockLocalStorageService extends Mock implements LocalStorageService {}

void main() {
  late SplashCubit sut;
  late MockLocalStorageService mockLocalStorageService;

  setUp(() {
    mockLocalStorageService = MockLocalStorageService();
    sut = SplashCubit(mockLocalStorageService);
  });

  group('SplashCubit', () {
    test('initial state should be SplashInitial', () {
      expect(sut.state, isA<SplashInitial>());
    });

    group('checkAppStatus', () {
      blocTest<SplashCubit, SplashState>(
        'emits [SplashNavigateToOnboarding] when it is the first time',
        build: () => sut,
        setUp: () {
          when(() => mockLocalStorageService.getFirstTime()).thenReturn(true);
        },
        act: (cubit) => cubit.checkAppStatus(),
        expect: () => [isA<SplashNavigateToOnboarding>()],
        verify: (_) {
          verify(() => mockLocalStorageService.getFirstTime()).called(1);
          verifyNever(() => mockLocalStorageService.getLoggedIn());
        },
      );

      blocTest<SplashCubit, SplashState>(
        'emits [SplashNavigateToHome] when user is not first time and is logged in',
        build: () => sut,
        setUp: () {
          when(() => mockLocalStorageService.getFirstTime()).thenReturn(false);
          when(() => mockLocalStorageService.getLoggedIn()).thenReturn(true);
        },
        act: (cubit) => cubit.checkAppStatus(),
        expect: () => [isA<SplashNavigateToHome>()],
        verify: (_) {
          verify(() => mockLocalStorageService.getFirstTime()).called(1);
          verify(() => mockLocalStorageService.getLoggedIn()).called(1);
        },
      );

      blocTest<SplashCubit, SplashState>(
        'emits [SplashNavigateToLogin] when user is not first time and is logged out',
        build: () => sut,
        setUp: () {
          when(() => mockLocalStorageService.getFirstTime()).thenReturn(false);
          when(() => mockLocalStorageService.getLoggedIn()).thenReturn(false);
        },
        act: (cubit) => cubit.checkAppStatus(),
        expect: () => [isA<SplashNavigateToLogin>()],
        verify: (_) {
          verify(() => mockLocalStorageService.getFirstTime()).called(1);
          verify(() => mockLocalStorageService.getLoggedIn()).called(1);
        },
      );
    });
  });
}
