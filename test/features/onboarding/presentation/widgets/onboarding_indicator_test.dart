import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/features/onboarding/presentation/widgets/onboarding_indicator.dart';

import '../../../../helpers/test_widget_wrapper.dart';

void main() {
  group('OnboardingIndicator Widget Tests', () {
    testWidgets('should render correct number of indicator dots', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        createWidgetForTesting(
          child: const OnboardingIndicator(currentIndex: 0, length: 3),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(AnimatedContainer), findsNWidgets(3));
    });

    testWidgets(
      'should style dots according to active state based on currentIndex',
      (WidgetTester tester) async {
        // Arrange
        late BuildContext capturedContext;
        await tester.pumpWidget(
          createWidgetForTesting(
            child: Builder(
              builder: (context) {
                capturedContext = context;
                return const OnboardingIndicator(currentIndex: 1, length: 3);
              },
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Act & Assert
        final containers = tester
            .widgetList<AnimatedContainer>(find.byType(AnimatedContainer))
            .toList();

        expect(containers.length, equals(3));

        final activeDecoration0 = containers[0].decoration as BoxDecoration;
        final activeDecoration1 = containers[1].decoration as BoxDecoration;
        final inactiveDecoration2 = containers[2].decoration as BoxDecoration;

        expect(activeDecoration0.color, equals(capturedContext.colors.primary));
        expect(activeDecoration1.color, equals(capturedContext.colors.primary));
        expect(
          inactiveDecoration2.color,
          equals(capturedContext.colors.tagConfirmedBg),
        );
      },
    );
  });
}
