import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/enums/order_status.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/theming/app_palette.dart';
import 'package:fruit_hub/features/orders/presentation/widgets/order_card_header.dart';
import 'package:fruit_hub/features/orders/presentation/widgets/order_header_badge.dart';

import '../../../../helpers/test_widget_wrapper.dart';

void main() {
  group('OrderCardHeader Widget Tests', () {
    testWidgets('should render order number and badge correctly', (
      tester,
    ) async {
      await tester.pumpWidget(
        createWidgetForTesting(
          child: const OrderCardHeader(
            orderId: 12345,
            date: '2026-09-28T12:00:00Z',
            status: OrderStatus.pending,
          ),
        ),
      );

      expect(find.text('${AppStrings.orderNumber} #12345'), findsOneWidget);
      expect(find.byType(OrderHeaderBadge), findsOneWidget);
      expect(find.text(OrderStatus.pending.getName), findsOneWidget);
      expect(find.byIcon(Icons.receipt_long_rounded), findsOneWidget);
    });

    testWidgets('should format valid date correctly', (tester) async {
      await tester.pumpWidget(
        createWidgetForTesting(
          child: const OrderCardHeader(
            orderId: 999,
            date: '2026-09-28T12:00:00Z',
            status: OrderStatus.shipped,
          ),
        ),
      );

      expect(find.text('28/09/2026'), findsOneWidget);
      expect(find.text(OrderStatus.shipped.getName), findsOneWidget);
    });

    testWidgets('should handle empty or fallback date gracefully', (
      tester,
    ) async {
      await tester.pumpWidget(
        createWidgetForTesting(
          child: const OrderCardHeader(
            orderId: 101,
            date: '',
            status: OrderStatus.delivered,
          ),
        ),
      );

      expect(find.text('${AppStrings.orderNumber} #101'), findsOneWidget);
      expect(find.text(OrderStatus.delivered.getName), findsOneWidget);
    });
  });

  group('OrderHeaderBadge Widget Tests', () {
    testWidgets('should render badge with label, icon and color', (
      tester,
    ) async {
      await tester.pumpWidget(
        createWidgetForTesting(
          child: const OrderHeaderBadge(
            label: 'Active',
            color: AppPalette.primaryGreen,
            icon: Icons.check,
            showDot: true,
          ),
        ),
      );

      expect(find.text('Active'), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);
    });
  });
}
