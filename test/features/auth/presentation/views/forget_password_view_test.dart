import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/di.dart';
import 'package:fruit_hub/core/widgets/app_toasts.dart';
import 'package:fruit_hub/core/widgets/custom_app_bar.dart';
import 'package:fruit_hub/core/widgets/custom_arrow_back.dart';
import 'package:fruit_hub/core/widgets/custom_material_button.dart';
import 'package:fruit_hub/core/widgets/custom_success_dialog.dart';
import 'package:fruit_hub/core/widgets/text_form_field_helper.dart';
import 'package:fruit_hub/features/auth/presentation/managers/forget_password_cubit/forget_password_cubit.dart';
import 'package:fruit_hub/features/auth/presentation/views/forget_password_view.dart';
import 'package:fruit_hub/features/auth/presentation/widgets/auth_header_section.dart';
import 'package:mocktail/mocktail.dart';
import 'package:toastification/toastification.dart';

import '../../../../helpers/test_widget_wrapper.dart';

class MockForgetPasswordCubit extends MockCubit<ForgetPasswordState>
    implements ForgetPasswordCubit {}

void main() {
  late MockForgetPasswordCubit mockForgetPasswordCubit;
  late StreamController<ForgetPasswordState> stateController;

  setUp(() {
    AppToast.isEnabled = false;
    stateController = StreamController<ForgetPasswordState>.broadcast();
    mockForgetPasswordCubit = MockForgetPasswordCubit();

    when(() => mockForgetPasswordCubit.state)
        .thenReturn(ForgetPasswordInitial());
    when(() => mockForgetPasswordCubit.stream)
        .thenAnswer((_) => stateController.stream);
    when(() => mockForgetPasswordCubit.forgetPassword(any()))
        .thenAnswer((_) async {});

    if (getIt.isRegistered<ForgetPasswordCubit>()) {
      getIt.unregister<ForgetPasswordCubit>();
    }
    getIt.registerFactory<ForgetPasswordCubit>(() => mockForgetPasswordCubit);
  });

  tearDown(() {
    AppToast.isEnabled = true;
    stateController.close();
    if (getIt.isRegistered<ForgetPasswordCubit>()) {
      getIt.unregister<ForgetPasswordCubit>();
    }
  });

  Widget buildTestWidget() => createWidgetForTesting(
    withToastification: true,
    child: const ForgetPasswordView(),
  );

  group('ForgetPasswordView Widget Tests', () {
    testWidgets(
      'should render all initial forget password UI components correctly',
      (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(CustomAppBar), findsOneWidget);
        expect(find.text(AppStrings.passwordReset), findsWidgets);
        expect(find.byType(AuthHeaderSection), findsOneWidget);
        expect(find.text(AppStrings.sendEmailResetLink), findsOneWidget);
        expect(find.byType(TextFormFieldHelper), findsOneWidget);
        expect(
          find.widgetWithText(
            CustomMaterialButton,
            AppStrings.sendPasswordResetLink,
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'should not call forgetPassword on cubit when form is empty or invalid',
      (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Act
        final submitButton = find.widgetWithText(
          CustomMaterialButton,
          AppStrings.sendPasswordResetLink,
        );
        await tester.tap(submitButton);
        await tester.pumpAndSettle();

        // Assert
        verifyNever(() => mockForgetPasswordCubit.forgetPassword(any()));
      },
    );

    testWidgets(
      'should call forgetPassword on cubit with trimmed email when valid email is submitted',
      (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Act
        await tester.enterText(
          find.byType(TextFormFieldHelper),
          '  user@example.com  ',
        );
        await tester.pumpAndSettle();

        final submitButton = find.widgetWithText(
          CustomMaterialButton,
          AppStrings.sendPasswordResetLink,
        );
        await tester.tap(submitButton);
        await tester.pumpAndSettle();

        // Assert
        verify(() => mockForgetPasswordCubit.forgetPassword('user@example.com'))
            .called(1);
      },
    );

    testWidgets(
      'should show CustomSuccessDialog when ForgetPasswordSuccess state is emitted',
      (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Act
        stateController.add(ForgetPasswordSuccess());
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(CustomSuccessDialog), findsOneWidget);
        expect(find.text(AppStrings.emailSentToReset), findsOneWidget);
      },
    );

    testWidgets(
      'should show error toast with message when ForgetPasswordFailure state is emitted',
      (WidgetTester tester) async {
        // Arrange
        AppToast.isEnabled = true;
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Act
        const errorMessage = 'لم يتم العثور على البريد';
        stateController.add(ForgetPasswordFailure(errorMessage));
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
      'should pop screen when CustomArrowBack in CustomAppBar is tapped',
      (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Act
        await tester.tap(find.byType(CustomArrowBack));
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(ForgetPasswordView), findsNothing);
      },
    );
  });
}
