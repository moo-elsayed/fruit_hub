import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/di.dart';
import 'package:fruit_hub/core/routing/routes.dart';
import 'package:fruit_hub/core/widgets/custom_material_button.dart';
import 'package:fruit_hub/features/onboarding/presentation/managers/onboarding_cubit/onboarding_cubit.dart';
import 'package:fruit_hub/features/onboarding/presentation/views/onboarding_view.dart';
import 'package:fruit_hub/features/onboarding/presentation/widgets/onboarding_indicator.dart';
import 'package:fruit_hub/features/onboarding/presentation/widgets/onboarding_page_view.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/test_widget_wrapper.dart';

class MockOnboardingCubit extends MockCubit<OnboardingState>
    implements OnboardingCubit {}

void main() {
  late MockOnboardingCubit mockOnboardingCubit;
  late StreamController<OnboardingState> stateController;

  setUp(() {
    mockOnboardingCubit = MockOnboardingCubit();
    stateController = StreamController<OnboardingState>.broadcast();

    when(() => mockOnboardingCubit.state).thenReturn(OnboardingInitial());
    when(() => mockOnboardingCubit.stream)
        .thenAnswer((_) => stateController.stream);
    when(() => mockOnboardingCubit.setFirstTime()).thenAnswer((_) async {});

    if (getIt.isRegistered<OnboardingCubit>()) {
      getIt.unregister<OnboardingCubit>();
    }
    getIt.registerFactory<OnboardingCubit>(() => mockOnboardingCubit);
  });

  tearDown(() {
    stateController.close();
    if (getIt.isRegistered<OnboardingCubit>()) {
      getIt.unregister<OnboardingCubit>();
    }
  });

  Widget buildTestWidget({Map<String, WidgetBuilder>? routes}) =>
      createWidgetForTesting(routes: routes, child: const OnboardingView());

  group('OnboardingView Widget Tests', () {
    testWidgets(
      'should render first slide and indicator without start now button initially',
      (WidgetTester tester) async {
        // Arrange
        tester.view.physicalSize = const Size(375 * 3, 812 * 3);
        tester.view.devicePixelRatio = 3.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        // Act
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(OnboardingPageView), findsOneWidget);
        expect(find.byType(OnboardingIndicator), findsOneWidget);

        final visibility = tester.widget<Visibility>(find.byType(Visibility));
        expect(visibility.visible, isFalse);
        expect(find.text(AppStrings.startNow), findsNothing);
      },
    );

    testWidgets(
      'should show start now button when scrolled to the last slide',
      (WidgetTester tester) async {
        // Arrange
        tester.view.physicalSize = const Size(375 * 3, 812 * 3);
        tester.view.devicePixelRatio = 3.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Act: swipe left to page 2 (index 1)
        await tester.drag(find.byType(PageView), const Offset(-400, 0));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text(AppStrings.startNow), findsOneWidget);
        expect(find.byType(CustomMaterialButton), findsOneWidget);
      },
    );

    testWidgets(
      'should trigger setFirstTime when start now button is tapped on last slide',
      (WidgetTester tester) async {
        // Arrange
        tester.view.physicalSize = const Size(375 * 3, 812 * 3);
        tester.view.devicePixelRatio = 3.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Act: scroll to last slide
        await tester.drag(find.byType(PageView), const Offset(-400, 0));
        await tester.pumpAndSettle();

        // Act: tap start now button
        await tester.tap(find.text(AppStrings.startNow));
        await tester.pump();

        // Assert
        verify(() => mockOnboardingCubit.setFirstTime()).called(1);
      },
    );

    testWidgets(
      'should navigate to loginView when OnboardingNavigateToHome is emitted',
      (WidgetTester tester) async {
        // Arrange
        tester.view.physicalSize = const Size(375 * 3, 812 * 3);
        tester.view.devicePixelRatio = 3.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        String? currentRoute;
        await tester.pumpWidget(
          buildTestWidget(
            routes: {
              Routes.loginView: (_) {
                currentRoute = Routes.loginView;
                return const Scaffold(body: Text('Login View'));
              },
            },
          ),
        );
        await tester.pumpAndSettle();

        // Swipe to last slide to activate the BlocListener inside visibility
        await tester.drag(find.byType(PageView), const Offset(-400, 0));
        await tester.pumpAndSettle();

        // Act
        stateController.add(OnboardingNavigateToHome());
        await tester.pumpAndSettle();

        // Assert
        expect(currentRoute, equals(Routes.loginView));
        expect(find.text('Login View'), findsOneWidget);
      },
    );
  });
}
