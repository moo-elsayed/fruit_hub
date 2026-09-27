import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/di.dart';
import 'package:fruit_hub/features/profile/presentation/managers/change_password_cubit/change_password_cubit.dart';
import 'package:fruit_hub/features/profile/presentation/widgets/change_password_bottom_sheet.dart';
import 'package:fruit_hub/features/profile/presentation/widgets/change_password_tile.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/test_widget_wrapper.dart';

class MockChangePasswordCubit extends MockCubit<ChangePasswordState>
    implements ChangePasswordCubit {}

void main() {
  late MockChangePasswordCubit mockChangePasswordCubit;

  setUp(() {
    mockChangePasswordCubit = MockChangePasswordCubit();
    when(() => mockChangePasswordCubit.state)
        .thenReturn(const ChangePasswordInitial());
    if (getIt.isRegistered<ChangePasswordCubit>()) {
      getIt.unregister<ChangePasswordCubit>();
    }
    getIt.registerLazySingleton<ChangePasswordCubit>(
      () => mockChangePasswordCubit,
    );
  });

  tearDown(() {
    getIt.reset();
  });

  group('ChangePasswordTile Widget Tests', () {
    testWidgets('should render icon, change password text and forward arrow', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        createWidgetForTesting(child: const ChangePasswordTile()),
      );
      await tester.pump();

      // Assert
      expect(find.byIcon(Icons.lock_reset_rounded), findsOneWidget);
      expect(find.text(AppStrings.changePassword), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward_ios_rounded), findsOneWidget);
    });

    testWidgets('should show ChangePasswordBottomSheet when tapped', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        createWidgetForTesting(child: const ChangePasswordTile()),
      );
      await tester.pump();

      // Act
      await tester.tap(find.byType(ChangePasswordTile));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(ChangePasswordBottomSheet), findsOneWidget);
    });
  });
}
