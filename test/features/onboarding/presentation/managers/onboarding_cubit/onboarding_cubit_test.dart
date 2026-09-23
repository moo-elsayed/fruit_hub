import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/services/local_storage/app_preferences_service.dart';
import 'package:fruit_hub/features/onboarding/presentation/managers/onboarding_cubit/onboarding_cubit.dart';
import 'package:mocktail/mocktail.dart';

class MockAppPreferencesService extends Mock implements AppPreferencesService {}

void main() {
  late MockAppPreferencesService mockAppPreferencesService;
  late OnboardingCubit sut;

  setUp(() {
    mockAppPreferencesService = MockAppPreferencesService();
    sut = OnboardingCubit(mockAppPreferencesService);
  });

  tearDown(() {
    sut.close();
  });

  test('initial state should be OnboardingInitial', () {
    // Assert
    expect(sut.state, isA<OnboardingInitial>());
  });

  group('setFirstTime', () {
    blocTest<OnboardingCubit, OnboardingState>(
      'should call saveFirstTime on AppPreferencesService and emit [OnboardingNavigateToHome] when setFirstTime is called',
      build: () => sut,
      setUp: () {
        // Arrange
        when(() => mockAppPreferencesService.saveFirstTime())
            .thenAnswer((_) async {});
      },
      act: (cubit) async {
        // Act
        await cubit.setFirstTime();
      },
      expect: () => [isA<OnboardingNavigateToHome>()],
      verify: (_) {
        // Assert
        verify(() => mockAppPreferencesService.saveFirstTime()).called(1);
        verifyNoMoreInteractions(mockAppPreferencesService);
      },
    );
  });
}
