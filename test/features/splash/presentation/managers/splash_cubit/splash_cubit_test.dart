import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/services/local_storage/app_preferences_service.dart';
import 'package:fruit_hub/features/splash/presentation/managers/splash_cubit/splash_cubit.dart';
import 'package:mocktail/mocktail.dart';

class MockAppPreferencesService extends Mock implements AppPreferencesService {}

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

void main() {
  group('SplashCubit', () {
    late MockAppPreferencesService mockAppPreferencesService;
    late MockFirebaseAuth mockFirebaseAuth;
    late MockUser mockUser;
    late SplashCubit sut;

    setUp(() {
      mockAppPreferencesService = MockAppPreferencesService();
      mockFirebaseAuth = MockFirebaseAuth();
      mockUser = MockUser();
      sut = SplashCubit(
        mockAppPreferencesService,
        firebaseAuth: mockFirebaseAuth,
      );
    });

    tearDown(() {
      if (!sut.isClosed) {
        sut.close();
      }
    });

    test('initial state should be SplashInitial', () {
      // Assert
      expect(sut.state, isA<SplashInitial>());
    });

    group('checkAppStatus', () {
      blocTest<SplashCubit, SplashState>(
        'should emit [SplashNavigationState with SplashNavigation.onboarding] after delay when isFirstTime is true',
        setUp: () {
          when(() => mockAppPreferencesService.isFirstTime()).thenReturn(true);
        },
        build: () => sut,
        act: (cubit) => cubit.checkAppStatus(),
        wait: const Duration(milliseconds: 1500),
        expect: () => [
          isA<SplashNavigationState>().having(
            (s) => s.navigation,
            'navigation',
            SplashNavigation.onboarding,
          ),
        ],
        verify: (_) {
          verify(() => mockAppPreferencesService.isFirstTime()).called(1);
          verifyZeroInteractions(mockFirebaseAuth);
        },
      );

      blocTest<SplashCubit, SplashState>(
        'should emit [SplashNavigationState with SplashNavigation.home] after delay when isFirstTime is false and user is logged in',
        setUp: () {
          when(() => mockAppPreferencesService.isFirstTime()).thenReturn(false);
          when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);
        },
        build: () => sut,
        act: (cubit) => cubit.checkAppStatus(),
        wait: const Duration(milliseconds: 1500),
        expect: () => [
          isA<SplashNavigationState>().having(
            (s) => s.navigation,
            'navigation',
            SplashNavigation.home,
          ),
        ],
        verify: (_) {
          verify(() => mockAppPreferencesService.isFirstTime()).called(1);
          verify(() => mockFirebaseAuth.currentUser).called(1);
        },
      );

      blocTest<SplashCubit, SplashState>(
        'should emit [SplashNavigationState with SplashNavigation.login] after delay when isFirstTime is false and user is not logged in',
        setUp: () {
          when(() => mockAppPreferencesService.isFirstTime()).thenReturn(false);
          when(() => mockFirebaseAuth.currentUser).thenReturn(null);
        },
        build: () => sut,
        act: (cubit) => cubit.checkAppStatus(),
        wait: const Duration(milliseconds: 1500),
        expect: () => [
          isA<SplashNavigationState>().having(
            (s) => s.navigation,
            'navigation',
            SplashNavigation.login,
          ),
        ],
        verify: (_) {
          verify(() => mockAppPreferencesService.isFirstTime()).called(1);
          verify(() => mockFirebaseAuth.currentUser).called(1);
        },
      );

      test(
        'should not emit state when cubit is closed before delay completes',
        () async {
          // Arrange
          when(() => mockAppPreferencesService.isFirstTime()).thenReturn(true);

          // Act
          unawaited(sut.checkAppStatus());
          await sut.close();
          await Future.delayed(const Duration(milliseconds: 1600));

          // Assert
          expect(sut.state, isA<SplashInitial>());
          verifyNever(() => mockAppPreferencesService.isFirstTime());
        },
      );
    });
  });
}
