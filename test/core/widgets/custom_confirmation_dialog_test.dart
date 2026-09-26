import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/widgets/custom_confirmation_dialog.dart';
import 'package:fruit_hub/core/widgets/custom_material_button.dart';

import '../../helpers/test_widget_wrapper.dart';

void main() {
  group('CustomConfirmationDialog Widget Tests', () {
    testWidgets('should render title, subtitle, and buttons correctly', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        createWidgetForTesting(
          child: CustomConfirmationDialog(
            title: 'Delete Item',
            subtitle: 'Are you sure you want to delete this fruit?',
            textConfirmButton: 'Delete',
            textCancelButton: 'Keep',
            onConfirm: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Delete Item'), findsOneWidget);
      expect(
        find.text('Are you sure you want to delete this fruit?'),
        findsOneWidget,
      );
      expect(find.text('Delete'), findsOneWidget);
      expect(find.text('Keep'), findsOneWidget);
      expect(find.byType(CustomMaterialButton), findsNWidgets(2));
    });

    testWidgets('should trigger onConfirm when confirm button is tapped', (
      WidgetTester tester,
    ) async {
      // Arrange
      bool confirmed = false;

      await tester.pumpWidget(
        createWidgetForTesting(
          child: CustomConfirmationDialog(
            title: 'Confirm Action',
            textConfirmButton: 'Confirm',
            onConfirm: () => confirmed = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      // Assert
      expect(confirmed, isTrue);
    });

    testWidgets('should trigger onCancel when cancel button is tapped', (
      WidgetTester tester,
    ) async {
      // Arrange
      bool cancelled = false;

      await tester.pumpWidget(
        createWidgetForTesting(
          child: CustomConfirmationDialog(
            title: 'Discard Changes',
            textConfirmButton: 'Discard',
            textCancelButton: 'Cancel',
            onConfirm: () {},
            onCancel: () => cancelled = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Assert
      expect(cancelled, isTrue);
    });

    testWidgets(
      'should only render confirm button when showCancelButton is false',
      (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          createWidgetForTesting(
            child: CustomConfirmationDialog(
              title: 'Notice',
              textConfirmButton: 'OK',
              showCancelButton: false,
              onConfirm: () {},
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('OK'), findsOneWidget);
        expect(find.byType(CustomMaterialButton), findsOneWidget);
      },
    );
  });
}
