import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/features/cart/presentation/widgets/cart_header_badge.dart';

import '../../../../helpers/test_widget_wrapper.dart';

void main() {
  group('CartHeaderBadge Widget Tests', () {
    testWidgets('should render count, products text, and bag icon correctly', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        createWidgetForTesting(child: const CartHeaderBadge(count: 4)),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('4 ${AppStrings.products}'), findsOneWidget);
      expect(find.byIcon(Icons.shopping_bag_outlined), findsOneWidget);
    });
  });
}
