import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/features/checkout/presentation/widgets/map_locate_me_button.dart';

import '../../../../helpers/test_widget_wrapper.dart';

void main() {
  group('MapLocateMeButton Widget Tests', () {
    testWidgets('should render my_location icon', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        createWidgetForTesting(
          child: Stack(children: [MapLocateMeButton(onTap: () {})]),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byIcon(Icons.my_location_rounded), findsOneWidget);
    });

    testWidgets('should invoke onTap callback when button is tapped', (
      tester,
    ) async {
      // Arrange
      bool tapped = false;
      await tester.pumpWidget(
        createWidgetForTesting(
          child: Stack(
            children: [MapLocateMeButton(onTap: () => tapped = true)],
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.byIcon(Icons.my_location_rounded));
      await tester.pumpAndSettle();

      // Assert
      expect(tapped, isTrue);
    });
  });
}
