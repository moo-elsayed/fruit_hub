import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/features/checkout/presentation/widgets/map_compass_button.dart';

import '../../../../helpers/test_widget_wrapper.dart';

void main() {
  group('MapCompassButton Widget Tests', () {
    testWidgets('should render nothing when bearing is zero', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        createWidgetForTesting(
          child: Stack(
            children: [MapCompassButton(bearing: 0.0, onTap: () {})],
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert — returns SizedBox.shrink → no compass icon
      expect(find.byIcon(Icons.explore_rounded), findsNothing);
    });

    testWidgets('should render compass icon when bearing is non-zero', (
      tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        createWidgetForTesting(
          child: Stack(
            children: [MapCompassButton(bearing: 45.0, onTap: () {})],
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byIcon(Icons.explore_rounded), findsOneWidget);
    });

    testWidgets('should invoke onTap when compass button is tapped', (
      tester,
    ) async {
      // Arrange
      bool tapped = false;
      await tester.pumpWidget(
        createWidgetForTesting(
          child: Stack(
            children: [
              MapCompassButton(bearing: 90.0, onTap: () => tapped = true),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.byIcon(Icons.explore_rounded));
      await tester.pumpAndSettle();

      // Assert
      expect(tapped, isTrue);
    });

    testWidgets('should not render when bearing is within zero threshold', (
      tester,
    ) async {
      // Arrange & Act — bearing < 0.001
      await tester.pumpWidget(
        createWidgetForTesting(
          child: Stack(
            children: [MapCompassButton(bearing: 0.0005, onTap: () {})],
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byIcon(Icons.explore_rounded), findsNothing);
    });
  });
}
