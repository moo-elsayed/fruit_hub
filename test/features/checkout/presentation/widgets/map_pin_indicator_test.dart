import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/features/checkout/presentation/widgets/map_pin_indicator.dart';

import '../../../../helpers/test_widget_wrapper.dart';

void main() {
  group('MapPinIndicator Widget Tests', () {
    testWidgets('should render location icon and two AnimatedContainers', (
      tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        createWidgetForTesting(
          child: const Stack(children: [MapPinIndicator()]),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byIcon(Icons.location_on_rounded), findsOneWidget);
      expect(find.byType(AnimatedContainer), findsNWidgets(2));
    });

    testWidgets(
      'should translate pin icon upward (non-zero Y) when isMoving is true',
      (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          createWidgetForTesting(
            child: const Stack(children: [MapPinIndicator(isMoving: true)]),
          ),
        );
        await tester.pumpAndSettle();

        // Assert — the first AnimatedContainer wraps the icon and has a non-zero transform
        final pinContainer = tester
            .widgetList<AnimatedContainer>(find.byType(AnimatedContainer))
            .first;
        final transform = pinContainer.transform;
        // Matrix4 translationValues(0, -Y, 0) → row 1, col 3 is the Y translation
        final yTranslation = transform?.storage[13] ?? 0.0;
        expect(yTranslation, isNonZero);
      },
    );

    testWidgets(
      'should have smaller shadow ellipse when isMoving is true vs false',
      (tester) async {
        // Arrange — pump with isMoving: false
        await tester.pumpWidget(
          createWidgetForTesting(
            child: const Stack(children: [MapPinIndicator(isMoving: false)]),
          ),
        );
        await tester.pumpAndSettle();

        final idleContainers = tester
            .widgetList<AnimatedContainer>(find.byType(AnimatedContainer))
            .toList();
        final idleShadow = idleContainers[1];

        // Act — rebuild with isMoving: true
        await tester.pumpWidget(
          createWidgetForTesting(
            child: const Stack(children: [MapPinIndicator(isMoving: true)]),
          ),
        );
        await tester.pumpAndSettle();

        final movingContainers = tester
            .widgetList<AnimatedContainer>(find.byType(AnimatedContainer))
            .toList();
        final movingShadow = movingContainers[1];

        // Assert — shadow is narrower when moving
        final idleWidth = (idleShadow.constraints?.maxWidth ?? 0);
        final movingWidth = (movingShadow.constraints?.maxWidth ?? 0);
        expect(movingWidth, lessThan(idleWidth));
      },
    );
  });
}
