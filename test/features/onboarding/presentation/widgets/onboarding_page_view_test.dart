import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/features/onboarding/domain/entities/onboarding_entity.dart';
import 'package:fruit_hub/features/onboarding/presentation/managers/onboarding_cubit/onboarding_cubit.dart';
import 'package:fruit_hub/features/onboarding/presentation/widgets/onboarding_page_view.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/test_widget_wrapper.dart';

class MockOnboardingCubit extends MockCubit<OnboardingState>
    implements OnboardingCubit {}

void main() {
  late MockOnboardingCubit mockOnboardingCubit;

  setUp(() {
    mockOnboardingCubit = MockOnboardingCubit();
    when(() => mockOnboardingCubit.state).thenReturn(OnboardingInitial());
  });

  group('OnboardingPageView Widget Tests', () {
    testWidgets(
      'should render first slide and trigger onPageChanged when swiped',
      (WidgetTester tester) async {
        // Arrange
        tester.view.physicalSize = const Size(375 * 3, 812 * 3);
        tester.view.devicePixelRatio = 3.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        int? changedIndex;

        await tester.pumpWidget(
          createWidgetForTesting(
            child: BlocProvider<OnboardingCubit>.value(
              value: mockOnboardingCubit,
              child: Column(
                children: [
                  OnboardingPageView(
                    slides: onboardingSlides,
                    onPageChanged: (index) => changedIndex = index,
                  ),
                ],
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(PageView), findsOneWidget);

        // Act: swipe left (to page 1)
        await tester.drag(find.byType(PageView), const Offset(-400, 0));
        await tester.pumpAndSettle();

        // Assert
        expect(changedIndex, equals(1));
      },
    );
  });
}
