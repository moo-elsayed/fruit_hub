import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/features/checkout/presentation/widgets/checkout_steps.dart';
import 'package:fruit_hub/features/checkout/presentation/widgets/custom_step_item.dart';

import '../../../../helpers/test_widget_wrapper.dart';

void main() {
  const tSteps = ['العنوان', 'الدفع', 'المراجعة'];

  void setWindowSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(375 * 3, 812 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  Widget buildTestWidget({
    required int currentIndex,
    List<String> steps = tSteps,
    ValueChanged<int>? onStepTapped,
  }) => createWidgetForTesting(
    child: CheckoutSteps(
      currentIndex: currentIndex,
      steps: steps,
      onStepTapped: onStepTapped,
    ),
  );

  group('CheckoutSteps Widget Tests', () {
    testWidgets('should render all step titles and CustomStepItem widgets', (
      tester,
    ) async {
      // Arrange
      setWindowSize(tester);

      // Act
      await tester.pumpWidget(buildTestWidget(currentIndex: 0));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(CustomStepItem), findsNWidgets(3));
      expect(find.text('العنوان'), findsOneWidget);
      expect(find.text('الدفع'), findsOneWidget);
      expect(find.text('المراجعة'), findsOneWidget);
    });

    testWidgets(
      'should trigger onStepTapped when tapping a previously completed step',
      (tester) async {
        // Arrange
        setWindowSize(tester);
        int? tappedIndex;
        await tester.pumpWidget(
          buildTestWidget(
            currentIndex: 2, // at step 2 (Review), step 0 and 1 are completed
            onStepTapped: (index) => tappedIndex = index,
          ),
        );
        await tester.pumpAndSettle();

        // Act - Tap on step 0 (Address)
        await tester.tap(find.text('العنوان'));
        await tester.pumpAndSettle();

        // Assert
        expect(tappedIndex, equals(0));

        // Act - Tap on step 1 (Payment)
        await tester.tap(find.text('الدفع'));
        await tester.pumpAndSettle();

        // Assert
        expect(tappedIndex, equals(1));
      },
    );

    testWidgets(
      'should NOT trigger onStepTapped when tapping current or upcoming steps',
      (tester) async {
        // Arrange
        setWindowSize(tester);
        int? tappedIndex;
        await tester.pumpWidget(
          buildTestWidget(
            currentIndex:
                1, // at step 1 (Payment), step 1 is current, step 2 is upcoming
            onStepTapped: (index) => tappedIndex = index,
          ),
        );
        await tester.pumpAndSettle();

        // Act - Tap on step 1 (current)
        await tester.tap(find.text('الدفع'));
        await tester.pumpAndSettle();

        // Assert
        expect(tappedIndex, isNull);

        // Act - Tap on step 2 (upcoming)
        await tester.tap(find.text('المراجعة'));
        await tester.pumpAndSettle();

        // Assert
        expect(tappedIndex, isNull);
      },
    );
  });
}
