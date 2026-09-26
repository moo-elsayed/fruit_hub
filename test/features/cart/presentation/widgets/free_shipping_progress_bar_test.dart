import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/features/cart/presentation/widgets/free_shipping_progress_bar.dart';
import 'package:fruit_hub/features/checkout/domain/entities/shipping_config_entity.dart';

import '../../../../helpers/test_widget_wrapper.dart';

void main() {
  group('FreeShippingProgressBar Widget Tests', () {
    testWidgets(
      'should render SizedBox.shrink when config is null or threshold is invalid',
      (WidgetTester tester) async {
        // Arrange & Act - Null config
        await tester.pumpWidget(
          createWidgetForTesting(
            child: const FreeShippingProgressBar(
              shippingConfig: null,
              totalPrice: 100,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(LinearProgressIndicator), findsNothing);

        // Arrange & Act - Zero threshold
        await tester.pumpWidget(
          createWidgetForTesting(
            child: const FreeShippingProgressBar(
              shippingConfig: ShippingConfigEntity(freeShippingThreshold: 0),
              totalPrice: 100,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(LinearProgressIndicator), findsNothing);
      },
    );

    testWidgets(
      'should render remaining amount and local shipping icon when subtotal is below threshold',
      (WidgetTester tester) async {
        // Arrange
        const config = ShippingConfigEntity(freeShippingThreshold: 200);
        const totalPrice = 120;
        final remaining = (200 - 120).toDouble();

        // Act
        await tester.pumpWidget(
          createWidgetForTesting(
            child: const FreeShippingProgressBar(
              shippingConfig: config,
              totalPrice: totalPrice,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Assert
        final expectedText = AppStrings.addAmountMoreForFreeShipping(
          '${remaining.formattedPrice} ${AppStrings.pounds}',
        );
        expect(find.text(expectedText), findsOneWidget);
        expect(find.byIcon(Icons.local_shipping_outlined), findsOneWidget);
        expect(find.byIcon(Icons.check_circle_rounded), findsNothing);

        final progressIndicator = tester.widget<LinearProgressIndicator>(
          find.byType(LinearProgressIndicator),
        );
        expect(progressIndicator.value, equals(120 / 200));
      },
    );

    testWidgets(
      'should render congratulations message and check icon when free shipping threshold is reached',
      (WidgetTester tester) async {
        // Arrange
        const config = ShippingConfigEntity(freeShippingThreshold: 200);
        const totalPrice = 250;

        // Act
        await tester.pumpWidget(
          createWidgetForTesting(
            child: const FreeShippingProgressBar(
              shippingConfig: config,
              totalPrice: totalPrice,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Assert
        expect(
          find.text(AppStrings.congratulationsFreeShipping),
          findsOneWidget,
        );
        expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
        expect(find.byIcon(Icons.local_shipping_outlined), findsNothing);

        final progressIndicator = tester.widget<LinearProgressIndicator>(
          find.byType(LinearProgressIndicator),
        );
        expect(progressIndicator.value, equals(1.0));
      },
    );
  });
}
