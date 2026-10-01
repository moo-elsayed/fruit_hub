import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/enums/step_item_state.dart';
import 'package:fruit_hub/features/checkout/presentation/widgets/custom_step_item.dart';

import '../../../../helpers/test_widget_wrapper.dart';

void main() {
  Widget buildTestWidget({
    required StepItemState state,
    int stepNumber = 1,
    String stepText = 'العنوان',
  }) => createWidgetForTesting(
    child: CustomStepItem(
      state: state,
      stepNumber: stepNumber,
      stepText: stepText,
    ),
  );

  group('CustomStepItem Widget Tests', () {
    testWidgets(
      'should render StepCurrentBadge with step number when state is current',
      (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          buildTestWidget(
            state: StepItemState.current,
            stepNumber: 1,
            stepText: 'العنوان',
          ),
        );
        await tester.pumpAndSettle();

        // Assert
        expect(find.byKey(const ValueKey('current')), findsOneWidget);
        expect(find.text('1'), findsOneWidget);
        expect(find.text('العنوان'), findsOneWidget);
        expect(find.byType(SvgPicture), findsNothing);
      },
    );

    testWidgets('should render StepCompletedIcon when state is completed', (
      tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        buildTestWidget(
          state: StepItemState.completed,
          stepNumber: 1,
          stepText: 'العنوان',
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byKey(const ValueKey('completed')), findsOneWidget);
      expect(find.byType(SvgPicture), findsOneWidget);
      expect(find.text('العنوان'), findsOneWidget);
    });

    testWidgets(
      'should render StepUpcomingBadge with step number when state is upcoming',
      (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          buildTestWidget(
            state: StepItemState.upcoming,
            stepNumber: 3,
            stepText: 'المراجعة',
          ),
        );
        await tester.pumpAndSettle();

        // Assert
        expect(find.byKey(const ValueKey('upcoming')), findsOneWidget);
        expect(find.text('3'), findsOneWidget);
        expect(find.text('المراجعة'), findsOneWidget);
        expect(find.byType(SvgPicture), findsNothing);
      },
    );
  });
}
