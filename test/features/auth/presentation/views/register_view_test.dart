import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/di.dart';
import 'package:fruit_hub/core/widgets/app_toasts.dart';
import 'package:fruit_hub/core/widgets/custom_app_bar.dart';
import 'package:fruit_hub/core/widgets/custom_material_button.dart';
import 'package:fruit_hub/core/widgets/custom_success_dialog.dart';
import 'package:fruit_hub/core/widgets/text_form_field_helper.dart';
import 'package:fruit_hub/features/auth/domain/entities/sign_up_input_entity.dart';
import 'package:fruit_hub/features/auth/presentation/managers/signup_cubit/sign_up_cubit.dart';
import 'package:fruit_hub/features/auth/presentation/views/register_view.dart';
import 'package:fruit_hub/features/auth/presentation/widgets/auth_header_section.dart';
import 'package:fruit_hub/features/auth/presentation/widgets/auth_redirect_text.dart';
import 'package:mocktail/mocktail.dart';
import 'package:toastification/toastification.dart';

import '../../../../helpers/test_widget_wrapper.dart';

class MockSignupCubit extends MockCubit<SignupState> implements SignupCubit {}

class FakeSignUpInputEntity extends Fake implements SignUpInputEntity {}

void main() {
  late MockSignupCubit mockSignupCubit;
  late StreamController<SignupState> signupStateController;

  setUpAll(() {
    registerFallbackValue(FakeSignUpInputEntity());
  });

  setUp(() {
    AppToast.isEnabled = false;
    signupStateController = StreamController<SignupState>.broadcast();
    mockSignupCubit = MockSignupCubit();

    when(() => mockSignupCubit.state).thenReturn(SignUpInitial());
    when(() => mockSignupCubit.stream)
        .thenAnswer((_) => signupStateController.stream);
    when(() => mockSignupCubit.createUserWithEmailAndPassword(any()))
        .thenAnswer((_) async {});

    if (getIt.isRegistered<SignupCubit>()) {
      getIt.unregister<SignupCubit>();
    }
    getIt.registerFactory<SignupCubit>(() => mockSignupCubit);
  });

  tearDown(() {
    AppToast.isEnabled = true;
    signupStateController.close();
    if (getIt.isRegistered<SignupCubit>()) {
      getIt.unregister<SignupCubit>();
    }
  });

  Widget buildTestWidget() => createWidgetForTesting(
    withToastification: true,
    child: const RegisterView(),
  );

  group('RegisterView Widget Tests', () {
    testWidgets(
      'should render all initial registration UI components correctly',
      (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(CustomAppBar), findsOneWidget);
        expect(find.text(AppStrings.newAccount), findsWidgets);
        expect(find.byType(AuthHeaderSection), findsOneWidget);
        expect(find.text(AppStrings.appTagline), findsOneWidget);
        expect(find.byType(TextFormFieldHelper), findsNWidgets(4));
        expect(
          find.widgetWithText(CustomMaterialButton, AppStrings.register),
          findsOneWidget,
        );
        expect(find.byType(AuthRedirectText), findsOneWidget);
      },
    );

    testWidgets(
      'should not call createUserWithEmailAndPassword when form validation fails',
      (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Act
        final registerButton = find.widgetWithText(
          CustomMaterialButton,
          AppStrings.register,
        );
        await tester.ensureVisible(registerButton);
        await tester.tap(registerButton);
        await tester.pumpAndSettle();

        // Assert
        verifyNever(
          () => mockSignupCubit.createUserWithEmailAndPassword(any()),
        );
      },
    );

    testWidgets(
      'should call createUserWithEmailAndPassword on cubit when form is valid',
      (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Act
        final textFields = find.byType(TextFormFieldHelper);
        await tester.enterText(textFields.at(0), 'محمد أحمد');
        await tester.enterText(textFields.at(1), 'user@example.com');
        await tester.enterText(textFields.at(2), '01012345678');
        await tester.enterText(textFields.at(3), 'Password123!');
        await tester.pumpAndSettle();

        final registerButton = find.widgetWithText(
          CustomMaterialButton,
          AppStrings.register,
        );
        await tester.ensureVisible(registerButton);
        await tester.tap(registerButton);
        await tester.pumpAndSettle();

        // Assert
        verify(
          () => mockSignupCubit.createUserWithEmailAndPassword(
            any(
              that: isA<SignUpInputEntity>()
                  .having((e) => e.username, 'username', 'محمد أحمد')
                  .having((e) => e.email, 'email', 'user@example.com')
                  .having((e) => e.phone, 'phone', '01012345678')
                  .having((e) => e.password, 'password', 'Password123!'),
            ),
          ),
        ).called(1);
      },
    );

    testWidgets(
      'should show CustomSuccessDialog when SignUpSuccess state is emitted',
      (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Act
        signupStateController.add(SignUpSuccess());
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(CustomSuccessDialog), findsOneWidget);
        expect(find.text(AppStrings.emailSentToVerify), findsOneWidget);
      },
    );

    testWidgets(
      'should show error toast with message when SignUpFailure state is emitted',
      (WidgetTester tester) async {
        // Arrange
        AppToast.isEnabled = true;
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Act
        const errorMessage = 'فشل إنشاء الحساب';
        signupStateController.add(SignUpFailure(errorMessage));
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
      'should trigger pop when AuthRedirectText login action is tapped',
      (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(buildTestWidget());
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
        expect(find.byType(RegisterView), findsNothing);
      },
    );
  });
}
