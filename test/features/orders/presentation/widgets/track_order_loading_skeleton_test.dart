import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/widgets/order_timeline_preview.dart';
import 'package:fruit_hub/features/orders/presentation/widgets/order_card_header.dart';
import 'package:fruit_hub/features/orders/presentation/widgets/order_customer_details.dart';
import 'package:fruit_hub/features/orders/presentation/widgets/order_financial_summary.dart';
import 'package:fruit_hub/features/orders/presentation/widgets/order_products_list.dart';
import 'package:fruit_hub/features/orders/presentation/widgets/track_order_loading_skeleton.dart';

import '../../../../helpers/test_widget_wrapper.dart';

void main() {
  group('TrackOrderLoadingSkeleton Widget Tests', () {
    testWidgets('should render Skeletonizer and dummy order components', (
      tester,
    ) async {
      await tester.pumpWidget(
        createWidgetForTesting(child: const TrackOrderLoadingSkeleton()),
      );

      expect(
        find.byWidgetPredicate(
          (w) => w.runtimeType.toString().contains('Skeletonizer'),
        ),
        findsWidgets,
      );
      expect(find.byType(OrderCardHeader), findsOneWidget);
      expect(find.byType(OrderTimelinePreview), findsOneWidget);
      expect(find.byType(OrderCustomerDetails), findsOneWidget);
      expect(find.byType(OrderProductsList), findsOneWidget);
      expect(find.byType(OrderFinancialSummary), findsOneWidget);
    });
  });
}
