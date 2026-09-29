import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/routing/routes.dart';
import 'package:fruit_hub/core/widgets/app_toasts.dart';
import 'package:fruit_hub/core/widgets/custom_material_button.dart';
import 'package:fruit_hub/features/auth/presentation/managers/social_sign_in_cubit/social_sign_in_cubit.dart';
import 'package:fruit_hub/features/auth/presentation/widgets/or_divider.dart';
import 'package:fruit_hub/features/auth/presentation/widgets/social_auth_section.dart';
import 'package:mocktail/mocktail.dart';
import 'package:toastification/toastification.dart';

import '../../../../helpers/test_widget_wrapper.dart';

class MockSocialSignInCubit extends MockCubit<SocialSignInState>
    implements SocialSignInCubit {}

void main() {
  late MockSocialSignInCubit mockSocialSignInCubit;
  late StreamController<SocialSignInState> stateController;

  setUp(() {
    AppToast.isEnabled = false;
    stateController = StreamController<SocialSignInState>.broadcast();
    mockSocialSignInCubit = MockSocialSignInCubit();

    when(() => mockSocialSignInCubit.state).thenReturn(SocialSignInInitial());
    when(() => mockSocialSignInCubit.stream)
        .thenAnswer((_) => stateController.stream);
    when(() => mockSocialSignInCubit.googleSignIn()).thenAnswer((_) async {});
    when(() => mockSocialSignInCubit.facebookSignIn()).thenAnswer((_) async {});
  });

  tearDown(() {
    AppToast.isEnabled = true;
    stateController.close();
  });

  Widget buildWidget({Map<String, WidgetBuilder>? routes}) =>
      createWidgetForTesting(
        withToastification: true,
        routes: routes,
        child: BlocProvider<SocialSignInCubit>.value(
          value: mockSocialSignInCubit,
          child: const SocialAuthSection(),
        ),
      );

  group('SocialAuthSection Widget Tests', () {
    testWidgets('should render OrDivider, Google button, and Facebook button', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(OrDivider), findsOneWidget);
      expect(find.text(AppStrings.signInWithGoogle), findsOneWidget);
      expect(find.text(AppStrings.signInWithFacebook), findsOneWidget);
      expect(find.byType(CustomMaterialButton), findsNWidgets(2));
    });

    testWidgets(
      'should trigger googleSignIn on cubit when Google button is tapped',
      (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(buildWidget());
        await tester.pumpAndSettle();

        // Act
        await tester.tap(find.text(AppStrings.signInWithGoogle));
        await tester.pump();

        // Assert
        verify(() => mockSocialSignInCubit.googleSignIn()).called(1);
      },
    );

    testWidgets(
      'should trigger facebookSignIn on cubit when Facebook button is tapped',
      (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(buildWidget());
        await tester.pumpAndSettle();

        // Act
        await tester.tap(find.text(AppStrings.signInWithFacebook));
        await tester.pump();

        // Assert
        verify(() => mockSocialSignInCubit.facebookSignIn()).called(1);
      },
    );

    testWidgets(
      'should show loading indicator on Google button when GoogleLoading is emitted',
      (WidgetTester tester) async {
        // Arrange
        when(() => mockSocialSignInCubit.state).thenReturn(GoogleLoading());
        await tester.pumpWidget(buildWidget());
        await tester.pump();

        // Assert
        final googleButton = tester.widget<CustomMaterialButton>(
          find.byWidgetPredicate(
            (w) =>
                w is CustomMaterialButton &&
                w.text == AppStrings.signInWithGoogle,
          ),
        );
        expect(googleButton.isLoading, isTrue);
      },
    );

    testWidgets(
      'should show loading indicator on Facebook button when FacebookLoading is emitted',
      (WidgetTester tester) async {
        // Arrange
        when(() => mockSocialSignInCubit.state).thenReturn(FacebookLoading());
        await tester.pumpWidget(buildWidget());
        await tester.pump();

        // Assert
        final facebookButton = tester.widget<CustomMaterialButton>(
          find.byWidgetPredicate(
            (w) =>
                w is CustomMaterialButton &&
                w.text == AppStrings.signInWithFacebook,
          ),
        );
        expect(facebookButton.isLoading, isTrue);
      },
    );

    testWidgets(
      'should navigate to mainView when GoogleSuccess state is emitted',
      (WidgetTester tester) async {
        // Arrange
        var navigatedToMain = false;
        await tester.pumpWidget(
          buildWidget(
            routes: {
              Routes.mainView: (_) {
                navigatedToMain = true;
                return const Scaffold(body: Text('Main Screen'));
              },
            },
          ),
        );
        await tester.pumpAndSettle();

        // Act
        stateController.add(GoogleSuccess());
        await tester.pumpAndSettle();

        // Assert
        expect(navigatedToMain, isTrue);
      },
    );

    testWidgets(
      'should navigate to mainView when FacebookSuccess state is emitted',
      (WidgetTester tester) async {
        // Arrange
        var navigatedToMain = false;
        await tester.pumpWidget(
          buildWidget(
            routes: {
              Routes.mainView: (_) {
                navigatedToMain = true;
                return const Scaffold(body: Text('Main Screen'));
              },
            },
          ),
        );
        await tester.pumpAndSettle();

        // Act
        stateController.add(FacebookSuccess());
        await tester.pumpAndSettle();

        // Assert
        expect(navigatedToMain, isTrue);
      },
    );

    testWidgets(
      'should show error toast with message when GoogleFailure state is emitted',
      (WidgetTester tester) async {
        // Arrange
        AppToast.isEnabled = true;
        await tester.pumpWidget(buildWidget());
        await tester.pumpAndSettle();

        // Act
        const errorMessage = 'حدث خطأ أثناء تسجيل الدخول بجوجل';
        stateController.add(GoogleFailure(errorMessage));
        await tester.pump();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 700));

        // Assert
        expect(find.text(errorMessage, skipOffstage: false), findsOneWidget);

        toastification.dismissAll();
        await tester.pump(const Duration(seconds: 4));
      },
    );

    testWidgets(
      'should show error toast with message when FacebookFailure state is emitted',
      (WidgetTester tester) async {
        // Arrange
        AppToast.isEnabled = true;
        await tester.pumpWidget(buildWidget());
        await tester.pumpAndSettle();

        // Act
        const errorMessage = 'حدث خطأ أثناء تسجيل الدخول بفيسبوك';
        stateController.add(FacebookFailure(errorMessage));
        await tester.pump();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 700));

        // Assert
        expect(find.text(errorMessage, skipOffstage: false), findsOneWidget);

        toastification.dismissAll();
        await tester.pump(const Duration(seconds: 4));
      },
    );
  });
}
