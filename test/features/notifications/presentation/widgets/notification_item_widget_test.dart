import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/enums/notification_type.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/routing/routes.dart';
import 'package:fruit_hub/features/main/presentation/managers/main_tab_notifier.dart';
import 'package:fruit_hub/features/notifications/domain/entities/notification_entity.dart';
import 'package:fruit_hub/features/notifications/presentation/widgets/notification_item_widget.dart';

import '../../../../helpers/test_widget_wrapper.dart';

void main() {
  final tDateTimeNow = DateTime.now();

  final tUnreadCartNotification = NotificationEntity(
    id: 'cart_1',
    title: 'Your cart is waiting',
    body: 'Complete your order now',
    type: NotificationType.cart,
    isRead: false,
    titleEn: 'Your cart is waiting',
    titleAr: 'سلتك في انتظارك',
    bodyEn: 'Complete your order now',
    bodyAr: 'أكمل طلبك الآن',
    createdAt: tDateTimeNow,
  );

  const tReadOrderNotification = NotificationEntity(
    id: 'order_1',
    title: 'Order Shipped',
    body: 'Your order #1001 is on the way',
    type: NotificationType.order,
    isRead: true,
    orderId: '1001',
  );

  const tReviewNotification = NotificationEntity(
    id: 'review_1',
    title: 'Review Product',
    body: 'How was your experience?',
    type: NotificationType.review,
    isRead: false,
    productCode: 'apple_01',
  );

  const tGeneralNotification = NotificationEntity(
    id: 'gen_1',
    title: 'Welcome',
    body: 'Welcome to Fruit Hub',
    type: NotificationType.general,
    isRead: true,
  );

  final defaultRoutes = <String, WidgetBuilder>{
    Routes.mainView: (_) => const Scaffold(body: Text('Main Screen')),
    Routes.trackOrderView: (context) {
      final args = ModalRoute.of(context)?.settings.arguments;
      return Scaffold(body: Text('Track Order: $args'));
    },
    Routes.productDetailsView: (context) {
      final args = ModalRoute.of(context)?.settings.arguments;
      return Scaffold(body: Text('Product Details: $args'));
    },
  };

  setUp(() {
    MainTabNotifier.currentTab.value = 0;
  });

  group('NotificationItemWidget Widget Tests', () {
    testWidgets(
      'should render localized title, body, and timestamp when provided',
      (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          createWidgetForTesting(
            routes: defaultRoutes,
            child: NotificationItemWidget(
              notification: tUnreadCartNotification,
              onTap: () {},
            ),
          ),
        );

        // Assert
        expect(find.text('Your cart is waiting'), findsOneWidget);
        expect(find.text('Complete your order now'), findsOneWidget);
        expect(find.text(AppStrings.justNow), findsOneWidget);
      },
    );

    testWidgets('should display unread dot indicator when isRead is false', (
      tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        createWidgetForTesting(
          routes: defaultRoutes,
          child: NotificationItemWidget(
            notification: tUnreadCartNotification,
            onTap: () {},
          ),
        ),
      );

      // Assert - unread dot is a circle container with no child
      final dotFinder = find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.child == null &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).shape == BoxShape.circle,
      );
      expect(dotFinder, findsOneWidget);
    });

    testWidgets('should not display unread dot indicator when isRead is true', (
      tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        createWidgetForTesting(
          routes: defaultRoutes,
          child: NotificationItemWidget(
            notification: tReadOrderNotification,
            onTap: () {},
          ),
        ),
      );

      // Assert
      final dotFinder = find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.child == null &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).shape == BoxShape.circle,
      );
      expect(dotFinder, findsNothing);
    });

    testWidgets('should call onTap callback when tapped', (tester) async {
      // Arrange
      bool tapped = false;
      await tester.pumpWidget(
        createWidgetForTesting(
          routes: defaultRoutes,
          child: NotificationItemWidget(
            notification: tGeneralNotification,
            onTap: () => tapped = true,
          ),
        ),
      );

      // Act
      await tester.tap(find.byType(NotificationItemWidget));
      await tester.pump();

      // Assert
      expect(tapped, isTrue);
    });

    testWidgets(
      'should navigate to trackOrderView when notification type is order',
      (tester) async {
        // Arrange
        await tester.pumpWidget(
          createWidgetForTesting(
            routes: defaultRoutes,
            child: NotificationItemWidget(
              notification: tReadOrderNotification,
              onTap: () {},
            ),
          ),
        );

        // Act
        await tester.tap(find.byType(NotificationItemWidget));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Track Order: 1001'), findsOneWidget);
      },
    );

    testWidgets('should switch to cart tab when notification type is cart', (
      tester,
    ) async {
      // Arrange
      expect(MainTabNotifier.currentTab.value, 0);

      await tester.pumpWidget(
        createWidgetForTesting(
          routes: defaultRoutes,
          child: NotificationItemWidget(
            notification: tUnreadCartNotification,
            onTap: () {},
          ),
        ),
      );

      // Act
      await tester.tap(find.byType(NotificationItemWidget));
      await tester.pumpAndSettle();

      // Assert
      expect(MainTabNotifier.currentTab.value, 2);
    });

    testWidgets(
      'should navigate to productDetailsView when notification type is review',
      (tester) async {
        // Arrange
        await tester.pumpWidget(
          createWidgetForTesting(
            routes: defaultRoutes,
            child: NotificationItemWidget(
              notification: tReviewNotification,
              onTap: () {},
            ),
          ),
        );

        // Act
        await tester.tap(find.byType(NotificationItemWidget));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Product Details: apple_01'), findsOneWidget);
      },
    );
  });
}
