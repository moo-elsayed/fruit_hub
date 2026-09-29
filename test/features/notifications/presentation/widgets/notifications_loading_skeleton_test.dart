import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/features/notifications/presentation/widgets/notification_item_widget.dart';
import 'package:fruit_hub/features/notifications/presentation/widgets/notifications_loading_skeleton.dart';

import '../../../../helpers/test_widget_wrapper.dart';

void main() {
  group('NotificationsLoadingSkeleton Widget Tests', () {
    testWidgets('should render Skeletonizer and dummy notification items', (
      tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        createWidgetForTesting(child: const NotificationsLoadingSkeleton()),
      );

      // Assert
      expect(
        find.byWidgetPredicate(
          (w) => w.runtimeType.toString().contains('Skeletonizer'),
        ),
        findsWidgets,
      );

      expect(find.byType(NotificationItemWidget), findsWidgets);
    });
  });
}
