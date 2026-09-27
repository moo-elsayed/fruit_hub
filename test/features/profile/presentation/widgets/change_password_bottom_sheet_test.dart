import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/widgets/app_toasts.dart';
import 'package:fruit_hub/core/widgets/custom_bottom_sheet_handle.dart';
import 'package:fruit_hub/core/widgets/custom_material_button.dart';
import 'package:fruit_hub/core/widgets/text_form_field_helper.dart';
import 'package:fruit_hub/features/profile/presentation/managers/change_password_cubit/change_password_cubit.dart';
import 'package:fruit_hub/features/profile/presentation/widgets/change_password_bottom_sheet.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/test_widget_wrapper.dart';

class MockChangePasswordCubit extends MockCubit<ChangePasswordState>
    implements ChangePasswordCubit {}

void main() {
  late MockChangePasswordCubit mockChangePasswordCubit;
  late StreamController<ChangePasswordState> stateController;

  setUp(() {
    AppToast.isEnabled = false;
    mockChangePasswordCubit = MockChangePasswordCubit();
    stateController = StreamController<ChangePasswordState>.broadcast();

    when(() => mockChangePasswordCubit.state)
        .thenReturn(const ChangePasswordInitial());
    whenListen(
      mockChangePasswordCubit,
      stateController.stream,
      initialState: const ChangePasswordInitial(),
    );
  });

  tearDown(() {
    AppToast.isEnabled = true;
    stateController.close();
  });

  Widget buildTestWidget() => BlocProvider<ChangePasswordCubit>.value(
    value: mockChangePasswordCubit,
    child: const Scaffold(body: ChangePasswordBottomSheet()),
  );

  group('ChangePasswordBottomSheet Widget Tests', () {
    testWidgets(
      'should render handle, title, 3 password fields, and submit button',
      (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          createWidgetForTesting(child: buildTestWidget()),
        );
        await tester.pump();

        // Assert
        expect(find.byType(CustomBottomSheetHandle), findsOneWidget);
        expect(find.text(AppStrings.changePassword), findsOneWidget);
        expect(find.text(AppStrings.currentPassword), findsOneWidget);
        expect(find.text(AppStrings.newPassword), findsOneWidget);
        expect(find.text(AppStrings.confirmNewPassword), findsOneWidget);
        expect(find.text(AppStrings.saveChanges), findsOneWidget);
      },
    );

    testWidgets(
      'should show validation errors when fields are empty on submit',
      (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(
          createWidgetForTesting(child: buildTestWidget()),
        );
        await tester.pump();

        // Act
        await tester.tap(find.text(AppStrings.saveChanges));
        await tester.pump();

        // Assert
        expect(
          find.text(AppStrings.currentPasswordCannotBeEmpty),
          findsOneWidget,
        );
        expect(find.text(AppStrings.passwordCannotBeEmpty), findsNWidgets(2));
        verifyNever(
          () => mockChangePasswordCubit.changePassword(
            currentPassword: any(named: 'currentPassword'),
            newPassword: any(named: 'newPassword'),
          ),
        );
      },
    );

    testWidgets(
      'should show validation error when new and confirm passwords do not match',
      (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(
          createWidgetForTesting(child: buildTestWidget()),
        );
        await tester.pump();

        // Act
        final fields = find.byType(TextFormFieldHelper);
        await tester.enterText(fields.at(0), 'OldPass123!');
        await tester.enterText(fields.at(1), 'NewPass123!');
        await tester.enterText(fields.at(2), 'DifferentPass123!');
        await tester.pump();

        await tester.tap(find.text(AppStrings.saveChanges));
        await tester.pump();

        // Assert
        expect(
          find.text(AppStrings.confirmPasswordMustMatchThePassword),
          findsOneWidget,
        );
        verifyNever(
          () => mockChangePasswordCubit.changePassword(
            currentPassword: any(named: 'currentPassword'),
            newPassword: any(named: 'newPassword'),
          ),
        );
      },
    );

    testWidgets('should call changePassword when form validation succeeds', (
      WidgetTester tester,
    ) async {
      // Arrange
      when(
        () => mockChangePasswordCubit.changePassword(
          currentPassword: any(named: 'currentPassword'),
          newPassword: any(named: 'newPassword'),
        ),
      ).thenAnswer((_) async {});

      await tester.pumpWidget(createWidgetForTesting(child: buildTestWidget()));
      await tester.pump();

      // Act
      final fields = find.byType(TextFormFieldHelper);
      await tester.enterText(fields.at(0), 'OldPass123!');
      await tester.enterText(fields.at(1), 'NewPass123!');
      await tester.enterText(fields.at(2), 'NewPass123!');
      await tester.pump();

      await tester.tap(find.text(AppStrings.saveChanges));
      await tester.pump();

      // Assert
      verify(
        () => mockChangePasswordCubit.changePassword(
          currentPassword: 'OldPass123!',
          newPassword: 'NewPass123!',
        ),
      ).called(1);
    });

    testWidgets(
      'should show button loading state when state is ChangePasswordLoading',
      (WidgetTester tester) async {
        // Arrange
        when(() => mockChangePasswordCubit.state)
            .thenReturn(const ChangePasswordLoading());

        // Act
        await tester.pumpWidget(
          createWidgetForTesting(child: buildTestWidget()),
        );
        await tester.pump();

        // Assert
        final button = tester.widget<CustomMaterialButton>(
          find.byType(CustomMaterialButton),
        );
        expect(button.isLoading, isTrue);
      },
    );

    testWidgets(
      'should pop bottom sheet when ChangePasswordSuccess is emitted',
      (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(
          createWidgetForTesting(
            child: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showModalBottomSheet(
                  context: context,
                  builder: (_) => BlocProvider<ChangePasswordCubit>.value(
                    value: mockChangePasswordCubit,
                    child: const ChangePasswordBottomSheet(),
                  ),
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        expect(find.byType(ChangePasswordBottomSheet), findsOneWidget);

        // Act
        stateController.add(const ChangePasswordSuccess());
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(ChangePasswordBottomSheet), findsNothing);
      },
    );

    testWidgets('should remain open when ChangePasswordFailure is emitted', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(createWidgetForTesting(child: buildTestWidget()));
      await tester.pump();

      // Act
      stateController.add(
        const ChangePasswordFailure('كلمة المرور الحالية غير صحيحة'),
      );
      await tester.pump();

      // Assert
      expect(find.byType(ChangePasswordBottomSheet), findsOneWidget);
    });
  });
}
