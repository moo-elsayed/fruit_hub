import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/helpers/app_assets.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/routing/routes.dart';
import 'package:fruit_hub/features/onboarding/domain/entities/onboarding_entity.dart';
import 'package:fruit_hub/features/onboarding/presentation/managers/onboarding_cubit/onboarding_cubit.dart';
import 'package:fruit_hub/features/onboarding/presentation/widgets/page_view_item.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/test_widget_wrapper.dart';

class MockOnboardingCubit extends MockCubit<OnboardingState>
    implements OnboardingCubit {}

void main() {
  late MockOnboardingCubit mockOnboardingCubit;
  late StreamController<OnboardingState> stateController;

  const dummySlide = OnboardingEntity(
    backgroundImage: AppAssets.svgsPageViewItem1BackgroundImage,
    image: AppAssets.svgsPageViewItem1Image,
    title: 'مرحبًا بك في FruitHUB',
    description: 'اكتشف تجربة تسوق فريدة',
  );

  setUp(() {
    mockOnboardingCubit = MockOnboardingCubit();
    stateController = StreamController<OnboardingState>.broadcast();

    when(() => mockOnboardingCubit.state).thenReturn(OnboardingInitial());
    when(() => mockOnboardingCubit.stream)
        .thenAnswer((_) => stateController.stream);
    when(() => mockOnboardingCubit.setFirstTime()).thenAnswer((_) async {});
  });

  tearDown(() {
    stateController.close();
  });

  Widget buildTestWidget({
    required bool showSkip,
    Map<String, WidgetBuilder>? routes,
  }) => createWidgetForTesting(
    routes: routes,
    child: BlocProvider<OnboardingCubit>.value(
      value: mockOnboardingCubit,
      child: SingleChildScrollView(
        child: PageViewItem(slide: dummySlide, showSkip: showSkip),
      ),
    ),
  );

  group('PageViewItem Widget Tests', () {
    testWidgets('should render title, description, and svg images', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(buildTestWidget(showSkip: false));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('اكتشف تجربة تسوق فريدة'), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is SvgPicture &&
              widget.bytesLoader.toString().contains(
                dummySlide.backgroundImage,
              ),
        ),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is SvgPicture &&
              widget.bytesLoader.toString().contains(dummySlide.image),
        ),
        findsOneWidget,
      );
    });

    testWidgets(
      'should render skip button when showSkip is true and trigger setFirstTime on tap',
      (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(buildTestWidget(showSkip: true));
        await tester.pumpAndSettle();

        // Act & Assert
        expect(find.text(AppStrings.skip), findsOneWidget);
        await tester.tap(find.text(AppStrings.skip));
        await tester.pump();

        verify(() => mockOnboardingCubit.setFirstTime()).called(1);
      },
    );

    testWidgets('should not render skip button when showSkip is false', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(buildTestWidget(showSkip: false));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text(AppStrings.skip), findsNothing);
    });

    testWidgets(
      'should navigate to loginView when OnboardingNavigateToHome is emitted',
      (WidgetTester tester) async {
        // Arrange
        String? currentRoute;
        await tester.pumpWidget(
          buildTestWidget(
            showSkip: true,
            routes: {
              Routes.loginView: (_) {
                currentRoute = Routes.loginView;
                return const Scaffold(body: Text('Login View'));
              },
            },
          ),
        );
        await tester.pump();

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
