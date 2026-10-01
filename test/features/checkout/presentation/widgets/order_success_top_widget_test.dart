import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/features/checkout/presentation/widgets/order_success_top_widget.dart';

import '../../../../helpers/test_widget_wrapper.dart';

void main() {
  group('OrderSuccessTopWidget Tests', () {
    testWidgets('should render check_circle icon, success title, and thank you subtitle', (
      tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        createWidgetForTesting(child: const OrderSuccessTopWidget()),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
      expect(find.text(AppStrings.orderPlacedSuccessfully), findsOneWidget);
      expect(find.text(AppStrings.thankYouForYourOrder), findsOneWidget);
    });
  });
}
