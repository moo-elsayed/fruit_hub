import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/features/checkout/presentation/widgets/receipt_info_row.dart';

import '../../../../helpers/test_widget_wrapper.dart';

void main() {
  group('ReceiptInfoRow Widget Tests', () {
    testWidgets('should render icon, label and value', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        createWidgetForTesting(
          child: const ReceiptInfoRow(
            icon: Icons.payment_rounded,
            label: 'Payment',
            value: 'PayPal',
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byIcon(Icons.payment_rounded), findsOneWidget);
      expect(find.text('Payment'), findsOneWidget);
      expect(find.text('PayPal'), findsOneWidget);
    });
  });
}
