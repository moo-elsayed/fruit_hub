import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/routing/routes.dart';
import 'package:fruit_hub/core/widgets/custom_material_button.dart';
import 'package:fruit_hub/features/auth/presentation/managers/signout_cubit/sign_out_cubit.dart';
import 'package:fruit_hub/features/profile/presentation/widgets/sign_out_button.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/test_widget_wrapper.dart';

class MockSignOutCubit extends MockCubit<SignOutState>
    implements SignOutCubit {}

void main() {
  late MockSignOutCubit mockSignOutCubit;
  late StreamController<SignOutState> stateController;

  setUp(() {
    mockSignOutCubit = MockSignOutCubit();
    stateController = StreamController<SignOutState>.broadcast();
    when(() => mockSignOutCubit.state).thenReturn(SignOutInitial());
    whenListen(
      mockSignOutCubit,
      stateController.stream,
      initialState: SignOutInitial(),
    );
    when(() => mockSignOutCubit.signOut()).thenAnswer((_) async {});
  });

  tearDown(() {
    stateController.close();
  });

  Widget buildTestWidget({Map<String, WidgetBuilder>? routes}) =>
      BlocProvider<SignOutCubit>.value(
        value: mockSignOutCubit,
        child: const SignOutButton(),
      );

  group('SignOutButton Widget Tests', () {
    testWidgets('should render sign out button with AppStrings.signOut text', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(createWidgetForTesting(child: buildTestWidget()));
      await tester.pump();

      // Assert
      expect(find.byType(CustomMaterialButton), findsOneWidget);
      expect(find.text(AppStrings.signOut), findsOneWidget);
    });

    testWidgets('should show confirmation dialog when tapped', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(createWidgetForTesting(child: buildTestWidget()));
      await tester.pump();

      await tester.tap(find.text(AppStrings.signOut));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text(AppStrings.logOutConfirmation), findsOneWidget);
      expect(find.text(AppStrings.ok), findsOneWidget);
      expect(find.text(AppStrings.cancel), findsOneWidget);
    });

    testWidgets(
      'should call signOut on SignOutCubit when user confirms logout dialog',
      (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(
          createWidgetForTesting(child: buildTestWidget()),
        );
        await tester.pump();

        await tester.tap(find.text(AppStrings.signOut));
        await tester.pumpAndSettle();

        // Tap OK on the confirmation dialog
        await tester.tap(find.text(AppStrings.ok));
        await tester.pumpAndSettle();

        // Assert
        verify(() => mockSignOutCubit.signOut()).called(1);
      },
    );

    testWidgets(
      'should dismiss dialog without signing out when Cancel is pressed',
      (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(
          createWidgetForTesting(child: buildTestWidget()),
        );
        await tester.pump();

        await tester.tap(find.text(AppStrings.signOut));
        await tester.pumpAndSettle();

        // Tap Cancel
        await tester.tap(find.text(AppStrings.cancel));
        await tester.pumpAndSettle();

        // Assert
        verifyNever(() => mockSignOutCubit.signOut());
        expect(find.text(AppStrings.logOutConfirmation), findsNothing);
      },
    );

    testWidgets(
      'should navigate to loginView when SignOutSuccess state is emitted',
      (WidgetTester tester) async {
        // Arrange
        var navigatedToLogin = false;

        // Act
        await tester.pumpWidget(
          createWidgetForTesting(
            child: buildTestWidget(),
            routes: {
              Routes.loginView: (context) {
                navigatedToLogin = true;
                return const Scaffold(body: Text('Login View'));
              },
            },
          ),
        );
        await tester.pump();

        // Emit SignOutSuccess
        stateController.add(SignOutSuccess());
        await tester.pump();
        await tester.pump(const Duration(seconds: 4));

        // Assert
        expect(navigatedToLogin, isTrue);
      },
    );
  });
}
