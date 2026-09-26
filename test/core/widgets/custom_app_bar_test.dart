import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/widgets/custom_app_bar.dart';
import 'package:fruit_hub/core/widgets/custom_arrow_back.dart';

import '../../helpers/test_widget_wrapper.dart';

void main() {
  group('CustomAppBar Widget Tests', () {
    testWidgets(
      'should render title correctly and hide back arrow by default',
      (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          createWidgetForTesting(
            child: const Scaffold(appBar: CustomAppBar(title: 'My Profile')),
          ),
        );
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('My Profile'), findsOneWidget);
        expect(find.byType(CustomArrowBack), findsNothing);
      },
    );

    testWidgets('should render CustomArrowBack and call onTap when tapped', (
      WidgetTester tester,
    ) async {
      // Arrange
      bool tapped = false;

      await tester.pumpWidget(
        createWidgetForTesting(
          child: Scaffold(
            appBar: CustomAppBar(
              title: 'Details',
              showArrowBack: true,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(CustomArrowBack), findsOneWidget);

      // Act
      await tester.tap(find.byType(CustomArrowBack));
      await tester.pumpAndSettle();

      // Assert
      expect(tapped, isTrue);
    });

    testWidgets('should render custom actions when provided', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        createWidgetForTesting(
          child: const Scaffold(
            appBar: CustomAppBar(
              title: 'Cart',
              actions: [Icon(Icons.more_vert, key: Key('more_action_icon'))],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byKey(const Key('more_action_icon')), findsOneWidget);
    });
  });
}
