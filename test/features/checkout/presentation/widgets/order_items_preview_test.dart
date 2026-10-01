import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/entities/cart_item_entity.dart';
import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/features/checkout/presentation/widgets/order_item_preview_row.dart';
import 'package:fruit_hub/features/checkout/presentation/widgets/order_items_preview.dart';

import '../../../../helpers/test_widget_wrapper.dart';

void main() {
  const tFruit1 = FruitEntity(name: 'Apple', price: 25.0);
  const tFruit2 = FruitEntity(name: 'Mango', price: 30.0);

  const tItems = [
    CartItemEntity(fruitEntity: tFruit1, quantity: 2),
    CartItemEntity(fruitEntity: tFruit2, quantity: 1),
  ];

  void setWindowSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(375 * 3, 812 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  group('OrderItemsPreview Widget Tests', () {
    testWidgets('should render SizedBox.shrink when products list is empty', (
      tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        createWidgetForTesting(
          child: const OrderItemsPreview(products: []),
        ),
      );
      await tester.pumpAndSettle();

      // Assert — nothing meaningful rendered
      expect(find.byType(OrderItemPreviewRow), findsNothing);
      expect(find.text(AppStrings.orderedItems), findsNothing);
    });

    testWidgets('should render orderedItems label and count badge', (
      tester,
    ) async {
      // Arrange
      setWindowSize(tester);

      // Act
      await tester.pumpWidget(
        createWidgetForTesting(
          child: const SingleChildScrollView(
            child: OrderItemsPreview(products: tItems),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text(AppStrings.orderedItems), findsOneWidget);
      expect(find.text('${tItems.length}'), findsOneWidget);
    });

    testWidgets(
      'should render one OrderItemPreviewRow per product',
      (tester) async {
        // Arrange
        setWindowSize(tester);

        // Act
        await tester.pumpWidget(
          createWidgetForTesting(
            child: const SingleChildScrollView(
              child: OrderItemsPreview(products: tItems),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(OrderItemPreviewRow), findsNWidgets(tItems.length));
        expect(find.text('Apple'), findsOneWidget);
        expect(find.text('Mango'), findsOneWidget);
      },
    );
  });
}
