import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/services/local_storage/app_preferences_service.dart';
import 'package:fruit_hub/features/onboarding/presentation/managers/onboarding_cubit/onboarding_cubit.dart';
import 'package:mocktail/mocktail.dart';

class MockLocalStorageService extends Mock implements AppPreferencesManager {}

void main() {
  late OnboardingCubit sut;
  late MockLocalStorageService mockLocalStorageService;

  setUp(() {
    mockLocalStorageService = MockLocalStorageService();
    sut = OnboardingCubit(mockLocalStorageService);
  });

  group('OnboardingCubit', () {
    test('initial state should be OnboardingInitial', () {
      expect(sut.state, isA<OnboardingInitial>());
    });

    blocTest<OnboardingCubit, OnboardingState>(
      'emits [OnboardingNavigateToHome] when we set first time',
      build: () => sut,
      setUp: () {
        when(
          () => mockLocalStorageService.setFirstTime(false),
        ).thenAnswer((_) async {});
      },
      act: (cubit) => cubit.setFirstTime(false),
      expect: () => [isA<OnboardingNavigateToHome>()],
      verify: (_) {
        verify(() => mockLocalStorageService.setFirstTime(false)).called(1);
      },
    );
  });
}
