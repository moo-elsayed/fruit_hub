import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/entities/order_item_entity.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/widgets/custom_price_text.dart';
import 'package:fruit_hub/features/orders/presentation/widgets/order_product_card.dart';
import 'package:fruit_hub/features/orders/presentation/widgets/order_products_list.dart';

import '../../../../helpers/test_widget_wrapper.dart';

void main() {
  const tProduct1 = OrderItemEntity(
    name: 'فراولة طازجة',
    price: 35.0,
    quantity: 3,
    code: 'str_101',
    imagePath: 'https://example.com/strawberry.png',
  );

  const tProduct2 = OrderItemEntity(
    name: 'موز إكوادوري',
    price: 25.0,
    quantity: 2,
    code: '',
  );

  group('OrderProductCard Widget Tests', () {
    testWidgets(
      'should render product name, quantity, price and code when code is present',
      (tester) async {
        await tester.pumpWidget(
          createWidgetForTesting(
            child: const OrderProductCard(product: tProduct1),
          ),
        );

        expect(find.text('فراولة طازجة'), findsOneWidget);
        expect(find.text('x3'), findsOneWidget);
        expect(find.text('${AppStrings.codeLabel}str_101'), findsOneWidget);
        expect(find.byType(CustomPriceText), findsOneWidget);
      },
    );

    testWidgets('should omit code text when code is empty', (tester) async {
      await tester.pumpWidget(
        createWidgetForTesting(
          child: const OrderProductCard(product: tProduct2),
        ),
      );

      expect(find.text('موز إكوادوري'), findsOneWidget);
      expect(find.text('x2'), findsOneWidget);
      expect(find.textContaining(AppStrings.codeLabel), findsNothing);
    });
  });

  group('OrderProductsList Widget Tests', () {
    testWidgets(
      'should render count badge and products list when initially expanded',
      (tester) async {
        await tester.pumpWidget(
          createWidgetForTesting(
            child: const SingleChildScrollView(
              child: OrderProductsList(
                products: [tProduct1, tProduct2],
                initiallyExpanded: true,
              ),
            ),
          ),
        );

        expect(find.text(AppStrings.orderedItems), findsOneWidget);
        expect(find.text('2'), findsOneWidget);
        expect(find.byType(OrderProductCard), findsNWidgets(2));
        expect(find.text('فراولة طازجة'), findsOneWidget);
        expect(find.text('موز إكوادوري'), findsOneWidget);
      },
    );

    testWidgets('should expand and collapse when header is tapped', (
      tester,
    ) async {
      await tester.pumpWidget(
        createWidgetForTesting(
          child: const SingleChildScrollView(
            child: OrderProductsList(
              products: [tProduct1],
              initiallyExpanded: true,
            ),
          ),
        ),
      );

      // Initially expanded
      expect(find.text('فراولة طازجة'), findsOneWidget);

      // Tap header to collapse
      await tester.tap(find.text(AppStrings.orderedItems));
      await tester.pumpAndSettle();

      // Verify collapsed state
      final collapsedTransition = tester.widget<SizeTransition>(
        find.byType(SizeTransition),
      );
      expect(collapsedTransition.sizeFactor.value, equals(0.0));
      expect(tester.getSize(find.byType(SizeTransition)).height, equals(0.0));

      // Tap header to expand again
      await tester.tap(find.text(AppStrings.orderedItems));
      await tester.pumpAndSettle();

      // Verify expanded state
      final expandedTransition = tester.widget<SizeTransition>(
        find.byType(SizeTransition),
      );
      expect(expandedTransition.sizeFactor.value, equals(1.0));
      expect(
        tester.getSize(find.byType(SizeTransition)).height,
        greaterThan(0.0),
      );
      expect(find.text('فراولة طازجة'), findsOneWidget);
    });
  });
}
