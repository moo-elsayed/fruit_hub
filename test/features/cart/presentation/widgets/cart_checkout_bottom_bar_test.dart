import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/entities/cart_item_entity.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/routing/routes.dart';
import 'package:fruit_hub/core/widgets/custom_material_button.dart';
import 'package:fruit_hub/core/widgets/custom_price_text.dart';
import 'package:fruit_hub/features/cart/presentation/widgets/cart_checkout_bottom_bar.dart';

import '../../../../helpers/test_widget_wrapper.dart';

void main() {
  group('CartCheckoutBottomBar Widget Tests', () {
    testWidgets(
      'should render total label, custom price, and checkout button',
      (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          createWidgetForTesting(
            child: const CartCheckoutBottomBar(cartItems: [], totalPrice: 350),
          ),
        );
        await tester.pumpAndSettle();

        // Assert
        expect(find.text(AppStrings.total), findsOneWidget);
        expect(find.byType(CustomPriceText), findsOneWidget);
        expect(find.text(AppStrings.checkout), findsOneWidget);
        expect(find.byType(CustomMaterialButton), findsOneWidget);
      },
    );

    testWidgets(
      'should navigate to checkoutView with cartItems when checkout button is tapped',
      (WidgetTester tester) async {
        // Arrange
        Object? capturedArguments;
        final dummyItems = <CartItemEntity>[];

        await tester.pumpWidget(
          createWidgetForTesting(
            onGenerateRoute: (settings) {
              if (settings.name == Routes.checkoutView) {
                capturedArguments = settings.arguments;
                return MaterialPageRoute(
                  builder: (_) => const Scaffold(body: Text('Checkout Screen')),
                );
              }
              return null;
            },
            child: CartCheckoutBottomBar(
              cartItems: dummyItems,
              totalPrice: 150,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Act
        await tester.tap(find.text(AppStrings.checkout));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Checkout Screen'), findsOneWidget);
        expect(capturedArguments, same(dummyItems));
      },
    );
  });
}
