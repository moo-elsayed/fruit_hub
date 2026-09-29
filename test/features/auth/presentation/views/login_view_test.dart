import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/di.dart';
import 'package:fruit_hub/core/routing/routes.dart';
import 'package:fruit_hub/core/widgets/app_toasts.dart';
import 'package:fruit_hub/core/widgets/custom_app_bar.dart';
import 'package:fruit_hub/core/widgets/custom_material_button.dart';
import 'package:fruit_hub/core/widgets/text_form_field_helper.dart';
import 'package:fruit_hub/features/auth/presentation/args/login_args.dart';
import 'package:fruit_hub/features/auth/presentation/managers/signin_cubit/sign_in_cubit.dart';
import 'package:fruit_hub/features/auth/presentation/managers/social_sign_in_cubit/social_sign_in_cubit.dart';
import 'package:fruit_hub/features/auth/presentation/views/login_view.dart';
import 'package:fruit_hub/features/auth/presentation/widgets/auth_header_section.dart';
import 'package:fruit_hub/features/auth/presentation/widgets/auth_redirect_text.dart';
import 'package:fruit_hub/features/auth/presentation/widgets/social_auth_section.dart';
import 'package:mocktail/mocktail.dart';
import 'package:toastification/toastification.dart';

import '../../../../helpers/test_widget_wrapper.dart';

class MockSignInCubit extends MockCubit<SignInState> implements SignInCubit {}

class MockSocialSignInCubit extends MockCubit<SocialSignInState>
    implements SocialSignInCubit {}

void main() {
  late MockSignInCubit mockSignInCubit;
  late MockSocialSignInCubit mockSocialSignInCubit;
  late StreamController<SignInState> signInStateController;
  late StreamController<SocialSignInState> socialStateController;

  setUp(() {
    AppToast.isEnabled = false;
    signInStateController = StreamController<SignInState>.broadcast();
    socialStateController = StreamController<SocialSignInState>.broadcast();

    mockSignInCubit = MockSignInCubit();
    mockSocialSignInCubit = MockSocialSignInCubit();

    when(() => mockSignInCubit.state).thenReturn(SignInInitial());
    when(() => mockSignInCubit.stream)
        .thenAnswer((_) => signInStateController.stream);
    when(
      () => mockSignInCubit.signInWithEmailAndPassword(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async {});

    when(() => mockSocialSignInCubit.state).thenReturn(SocialSignInInitial());
    when(() => mockSocialSignInCubit.stream)
        .thenAnswer((_) => socialStateController.stream);
    when(() => mockSocialSignInCubit.googleSignIn()).thenAnswer((_) async {});
    when(() => mockSocialSignInCubit.facebookSignIn()).thenAnswer((_) async {});

    if (getIt.isRegistered<SignInCubit>()) {
      getIt.unregister<SignInCubit>();
    }
    if (getIt.isRegistered<SocialSignInCubit>()) {
      getIt.unregister<SocialSignInCubit>();
    }

    getIt.registerFactory<SignInCubit>(() => mockSignInCubit);
    getIt.registerFactory<SocialSignInCubit>(() => mockSocialSignInCubit);
  });

  tearDown(() {
    AppToast.isEnabled = true;
    signInStateController.close();
    socialStateController.close();

    if (getIt.isRegistered<SignInCubit>()) {
      getIt.unregister<SignInCubit>();
    }
    if (getIt.isRegistered<SocialSignInCubit>()) {
      getIt.unregister<SocialSignInCubit>();
    }
  });

  Widget buildTestWidget({
    LoginArgs? loginArgs,
    Map<String, WidgetBuilder>? routes,
  }) => createWidgetForTesting(
    withToastification: true,
    routes: routes,
    child: LoginView(loginArgs: loginArgs),
  );

  group('LoginView Widget Tests', () {
    testWidgets('should render all initial login UI components correctly', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(CustomAppBar), findsOneWidget);
      expect(find.text(AppStrings.login), findsWidgets);
      expect(find.byType(AuthHeaderSection), findsOneWidget);
      expect(find.text(AppStrings.welcome), findsOneWidget);
      expect(find.text(AppStrings.appTagline), findsOneWidget);
      expect(find.byType(TextFormFieldHelper), findsNWidgets(2));
      expect(find.text(AppStrings.forgotPassword), findsOneWidget);
      expect(find.byType(AuthRedirectText), findsOneWidget);
      expect(find.byType(SocialAuthSection), findsOneWidget);
    });

    testWidgets(
      'should populate email and password fields when loginArgs are provided',
      (WidgetTester tester) async {
        // Arrange
        final tArgs = LoginArgs(
          email: 'test@example.com',
          password: 'Password123!',
        );

        // Act
        await tester.pumpWidget(buildTestWidget(loginArgs: tArgs));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('test@example.com'), findsOneWidget);
        expect(find.text('Password123!'), findsOneWidget);
      },
    );

    testWidgets('should show validation errors when submitting empty form', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Act
      final loginButton = find.widgetWithText(
        CustomMaterialButton,
        AppStrings.login,
      );
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      // Assert
      verifyNever(
        () => mockSignInCubit.signInWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      );
    });

    testWidgets(
      'should call signInWithEmailAndPassword on cubit when valid credentials are submitted',
      (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Act
        final textFields = find.byType(TextFormFieldHelper);
        await tester.enterText(textFields.at(0), 'user@example.com');
        await tester.enterText(textFields.at(1), 'Password123!');
        await tester.pumpAndSettle();

        final loginButton = find.widgetWithText(
          CustomMaterialButton,
          AppStrings.login,
        );
        await tester.tap(loginButton);
        await tester.pumpAndSettle();

        // Assert
        verify(
          () => mockSignInCubit.signInWithEmailAndPassword(
            email: 'user@example.com',
            password: 'Password123!',
          ),
        ).called(1);
      },
    );

    testWidgets(
      'should navigate to mainView when SignInSuccess state is emitted',
      (WidgetTester tester) async {
        // Arrange
        var navigatedToMain = false;
        await tester.pumpWidget(
          buildTestWidget(
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
        signInStateController.add(SignInSuccess());
        await tester.pumpAndSettle();

        // Assert
        expect(navigatedToMain, isTrue);
      },
    );

    testWidgets(
      'should navigate to forgetPasswordView when forgot password is tapped',
      (WidgetTester tester) async {
        // Arrange
        var navigatedToForget = false;
        await tester.pumpWidget(
          buildTestWidget(
            routes: {
              Routes.forgetPasswordView: (_) {
                navigatedToForget = true;
                return const Scaffold(body: Text('Forget Password Screen'));
              },
            },
          ),
        );
        await tester.pumpAndSettle();

        // Act
        await tester.tap(find.text(AppStrings.forgotPassword));
        await tester.pumpAndSettle();

        // Assert
        expect(navigatedToForget, isTrue);
      },
    );

    testWidgets(
      'should navigate to registerView when AuthRedirectText is tapped',
      (WidgetTester tester) async {
        // Arrange
        var navigatedToRegister = false;
        await tester.pumpWidget(
          buildTestWidget(
            routes: {
              Routes.registerView: (_) {
                navigatedToRegister = true;
                return const Scaffold(body: Text('Register Screen'));
              },
            },
          ),
        );
        await tester.pumpAndSettle();

        // Act
        final authRedirect = find.byType(AuthRedirectText);
        final textWidget = tester.widget<Text>(
          find.descendant(of: authRedirect, matching: find.byType(Text)),
        );
        final rootSpan = textWidget.textSpan as TextSpan;
        final actionSpan = rootSpan.children![2] as TextSpan;
        final recognizer = actionSpan.recognizer as TapGestureRecognizer?;
        recognizer?.onTap?.call();
        await tester.pumpAndSettle();

        // Assert
        expect(navigatedToRegister, isTrue);
      },
    );

    testWidgets(
      'should show error toast with message when SignInFailure state is emitted',
      (WidgetTester tester) async {
        // Arrange
        AppToast.isEnabled = true;
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Act
        const errorMessage = 'فشل تسجيل الدخول';
        signInStateController.add(SignInFailure(errorMessage));
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
