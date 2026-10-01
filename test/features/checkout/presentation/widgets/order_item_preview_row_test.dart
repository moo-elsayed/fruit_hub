import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/entities/cart_item_entity.dart';
import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/widgets/custom_network_image.dart';
import 'package:fruit_hub/core/widgets/custom_price_text.dart';
import 'package:fruit_hub/core/widgets/quantity_badge.dart';
import 'package:fruit_hub/features/checkout/presentation/widgets/order_item_preview_row.dart';

import '../../../../helpers/test_widget_wrapper.dart';

void main() {
  void setWindowSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(375 * 3, 812 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  group('OrderItemPreviewRow Widget Tests', () {
    testWidgets(
      'should render fruit name, quantity badge, price and network image',
      (tester) async {
        // Arrange
        setWindowSize(tester);
        const tFruit = FruitEntity(
          name: 'تفاح',
          price: 20.0,
          imagePath: 'https://example.com/apple.png',
        );
        const tItem = CartItemEntity(fruitEntity: tFruit, quantity: 3);

        // Act
        await tester.pumpWidget(
          createWidgetForTesting(
            child: const OrderItemPreviewRow(item: tItem),
          ),
        );
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('تفاح'), findsOneWidget);
        expect(find.text('x3'), findsOneWidget);
        expect(find.byType(CustomPriceText), findsOneWidget);
        expect(find.byType(CustomNetworkImage), findsOneWidget);
        expect(find.byType(QuantityBadge), findsOneWidget);

        final imageWidget = tester.widget<CustomNetworkImage>(
          find.byType(CustomNetworkImage),
        );
        expect(imageWidget.image, equals('https://example.com/apple.png'));
        expect(imageWidget.fit, equals(BoxFit.contain));

        final priceWidget = tester.widget<CustomPriceText>(
          find.byType(CustomPriceText),
        );
        expect(priceWidget.price, equals(60.0));
      },
    );

    testWidgets(
      'should correctly calculate and display total price based on fruit price and quantity',
      (tester) async {
        // Arrange
        setWindowSize(tester);
        const tFruit = FruitEntity(name: 'مانجو', price: 35.5);
        const tItem = CartItemEntity(fruitEntity: tFruit, quantity: 2);

        // Act
        await tester.pumpWidget(
          createWidgetForTesting(
            child: const OrderItemPreviewRow(item: tItem),
          ),
        );
        await tester.pumpAndSettle();

        // Assert
        final priceWidget = tester.widget<CustomPriceText>(
          find.byType(CustomPriceText),
        );
        expect(priceWidget.price, equals(71.0));

        final richTextFinder = find.descendant(
          of: find.byType(CustomPriceText),
          matching: find.byType(RichText),
        );
        final richText = tester.widget<RichText>(richTextFinder);
        expect(richText.text.toPlainText(), contains('71'));
        expect(richText.text.toPlainText(), contains(AppStrings.pounds));
        expect(find.text('x2'), findsOneWidget);
      },
    );

    testWidgets('should render image container with rounded corners', (
      tester,
    ) async {
      // Arrange
      setWindowSize(tester);
      const tFruit = FruitEntity(name: 'برتقال', price: 15.0);
      const tItem = CartItemEntity(fruitEntity: tFruit, quantity: 1);

      // Act
      await tester.pumpWidget(
        createWidgetForTesting(
          child: const OrderItemPreviewRow(item: tItem),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      final containerFinder = find.byType(Container).first;
      final container = tester.widget<Container>(containerFinder);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.borderRadius, equals(BorderRadius.circular(8.r)));
    });
  });
}
