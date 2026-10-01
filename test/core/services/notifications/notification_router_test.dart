import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/enums/notification_type.dart';
import 'package:fruit_hub/core/routing/routes.dart';
import 'package:fruit_hub/core/services/notifications/notification_router.dart';
import 'package:fruit_hub/features/main/presentation/managers/main_tab_notifier.dart';

class TestNavigatorObserver extends NavigatorObserver {
  final List<Route<dynamic>> pushedRoutes = [];

  Route<dynamic>? get lastPushedRoute =>
      pushedRoutes.isNotEmpty ? pushedRoutes.last : null;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    pushedRoutes.add(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null) {
      pushedRoutes.add(newRoute);
    }
  }
}

void main() {
  late TestNavigatorObserver navObserver;

  setUp(() {
    NotificationRouter.isAppReady = true;
    NotificationRouter.pendingPayload = null;
    MainTabNotifier.switchToTab(0);
    navObserver = TestNavigatorObserver();
  });

  tearDown(() {
    NotificationRouter.isAppReady = true;
    NotificationRouter.pendingPayload = null;
    MainTabNotifier.switchToTab(0);
  });

  Future<void> pumpTestApp(
    WidgetTester tester, {
    Map<String, WidgetBuilder>? additionalRoutes,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: NotificationRouter.navigatorKey,
        navigatorObservers: [navObserver],
        routes: {
          Routes.productDetailsView: (context) => const SizedBox(),
          Routes.trackOrderView: (context) => const SizedBox(),
          Routes.mainView: (context) => const SizedBox(),
          '/dummy': (context) => const SizedBox(),
          ...?additionalRoutes,
        },
        home: const Scaffold(body: Text('Home Screen')),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('NotificationRouter', () {
    group('App Readiness & Pending Payload', () {
      testWidgets(
        'should store payload in pendingPayload and not navigate when isAppReady is false',
        (tester) async {
          // Arrange
          await pumpTestApp(tester);
          NotificationRouter.isAppReady = false;
          const payload = {'orderId': 'order_123'};

          // Act
          NotificationRouter.handleNotificationNavigation(payload);
          await tester.pumpAndSettle();

          // Assert
          expect(NotificationRouter.pendingPayload, equals(payload));
          expect(navObserver.pushedRoutes.length, equals(1)); // only home route
        },
      );

      testWidgets(
        'should dispatch pendingPayload and clear it when markAppAsReady is called',
        (tester) async {
          // Arrange
          await pumpTestApp(tester);
          NotificationRouter.isAppReady = false;
          const payload = {'orderId': 'order_456'};
          NotificationRouter.handleNotificationNavigation(payload);
          expect(NotificationRouter.pendingPayload, equals(payload));

          // Act
          NotificationRouter.markAppAsReady();
          await tester.pumpAndSettle();

          // Assert
          expect(NotificationRouter.isAppReady, isTrue);
          expect(NotificationRouter.pendingPayload, isNull);
          expect(
            navObserver.lastPushedRoute?.settings.name,
            equals(Routes.trackOrderView),
          );
          expect(
            navObserver.lastPushedRoute?.settings.arguments,
            equals('order_456'),
          );
        },
      );

      testWidgets(
        'should do nothing when checkAndHandlePendingNotification is called but pendingPayload is null',
        (tester) async {
          // Arrange
          await pumpTestApp(tester);
          NotificationRouter.isAppReady = true;
          NotificationRouter.pendingPayload = null;

          // Act
          NotificationRouter.checkAndHandlePendingNotification();
          await tester.pumpAndSettle();

          // Assert
          expect(navObserver.pushedRoutes.length, equals(1));
        },
      );
    });

    group('Empty & Null Payloads', () {
      testWidgets('should do nothing when payload is null', (tester) async {
        // Arrange
        await pumpTestApp(tester);

        // Act
        NotificationRouter.handleNotificationNavigation(null);
        await tester.pumpAndSettle();

        // Assert
        expect(navObserver.pushedRoutes.length, equals(1));
      });

      testWidgets('should do nothing when payload is an empty map', (
        tester,
      ) async {
        // Arrange
        await pumpTestApp(tester);

        // Act
        NotificationRouter.handleNotificationNavigation(<String, dynamic>{});
        await tester.pumpAndSettle();

        // Assert
        expect(navObserver.pushedRoutes.length, equals(1));
      });

      testWidgets('should do nothing when payload is empty whitespace string', (
        tester,
      ) async {
        // Arrange
        await pumpTestApp(tester);

        // Act
        NotificationRouter.handleNotificationNavigation('   ');
        await tester.pumpAndSettle();

        // Assert
        expect(navObserver.pushedRoutes.length, equals(1));
      });
    });

    group('Order Navigation', () {
      testWidgets(
        'should navigate to trackOrderView when payload contains orderId map key',
        (tester) async {
          // Arrange
          await pumpTestApp(tester);
          final payload = {'orderId': 'ord_001'};

          // Act
          NotificationRouter.handleNotificationNavigation(payload);
          await tester.pumpAndSettle();

          // Assert
          expect(
            navObserver.lastPushedRoute?.settings.name,
            equals(Routes.trackOrderView),
          );
          expect(
            navObserver.lastPushedRoute?.settings.arguments,
            equals('ord_001'),
          );
        },
      );

      testWidgets(
        'should navigate to trackOrderView when payload contains order_id snake_case key',
        (tester) async {
          // Arrange
          await pumpTestApp(tester);
          final payload = {'order_id': 'ord_002'};

          // Act
          NotificationRouter.handleNotificationNavigation(payload);
          await tester.pumpAndSettle();

          // Assert
          expect(
            navObserver.lastPushedRoute?.settings.name,
            equals(Routes.trackOrderView),
          );
          expect(
            navObserver.lastPushedRoute?.settings.arguments,
            equals('ord_002'),
          );
        },
      );

      testWidgets(
        'should parse JSON string payload and navigate to trackOrderView',
        (tester) async {
          // Arrange
          await pumpTestApp(tester);
          final jsonString = jsonEncode({'orderId': 'ord_json_003'});

          // Act
          NotificationRouter.handleNotificationNavigation(jsonString);
          await tester.pumpAndSettle();

          // Assert
          expect(
            navObserver.lastPushedRoute?.settings.name,
            equals(Routes.trackOrderView),
          );
          expect(
            navObserver.lastPushedRoute?.settings.arguments,
            equals('ord_json_003'),
          );
        },
      );
    });

    group('Product Details Navigation', () {
      testWidgets(
        'should navigate to productDetailsView when payload contains productCode',
        (tester) async {
          // Arrange
          await pumpTestApp(tester);
          final payload = {'productCode': 'prod_apple'};

          // Act
          NotificationRouter.handleNotificationNavigation(payload);
          await tester.pumpAndSettle();

          // Assert
          expect(
            navObserver.lastPushedRoute?.settings.name,
            equals(Routes.productDetailsView),
          );
          expect(
            navObserver.lastPushedRoute?.settings.arguments,
            equals('prod_apple'),
          );
        },
      );

      testWidgets(
        'should navigate to productDetailsView when payload contains product_code',
        (tester) async {
          // Arrange
          await pumpTestApp(tester);
          final payload = {'product_code': 'prod_mango'};

          // Act
          NotificationRouter.handleNotificationNavigation(payload);
          await tester.pumpAndSettle();

          // Assert
          expect(
            navObserver.lastPushedRoute?.settings.name,
            equals(Routes.productDetailsView),
          );
          expect(
            navObserver.lastPushedRoute?.settings.arguments,
            equals('prod_mango'),
          );
        },
      );
    });

    group('Cart Reminder Navigation', () {
      testWidgets(
        'should switch to tab 2 and pop to first route when type is cart and canPop is true',
        (tester) async {
          // Arrange
          await pumpTestApp(tester);
          NotificationRouter.navigatorKey.currentState!.pushNamed('/dummy');
          await tester.pumpAndSettle();
          expect(
            NotificationRouter.navigatorKey.currentState!.canPop(),
            isTrue,
          );

          final payload = {'type': NotificationType.cart.name};

          // Act
          NotificationRouter.handleNotificationNavigation(payload);
          await tester.pumpAndSettle();

          // Assert
          expect(MainTabNotifier.currentTab.value, equals(2));
          expect(
            NotificationRouter.navigatorKey.currentState!.canPop(),
            isFalse,
          );
        },
      );

      testWidgets(
        'should switch to tab 2 and pushReplacementNamed mainView when type is cart and canPop is false',
        (tester) async {
          // Arrange
          await pumpTestApp(tester);
          expect(
            NotificationRouter.navigatorKey.currentState!.canPop(),
            isFalse,
          );

          final payload = {'type': 'cart'};

          // Act
          NotificationRouter.handleNotificationNavigation(payload);
          await tester.pumpAndSettle();

          // Assert
          expect(MainTabNotifier.currentTab.value, equals(2));
          expect(
            navObserver.lastPushedRoute?.settings.name,
            equals(Routes.mainView),
          );
          expect(navObserver.lastPushedRoute?.settings.arguments, equals(2));
        },
      );
    });

    group('Fallback ID Navigation', () {
      testWidgets(
        'should navigate to productDetailsView when id is present and type is review',
        (tester) async {
          // Arrange
          await pumpTestApp(tester);
          final payload = {'id': 'review_prod_1', 'type': 'review'};

          // Act
          NotificationRouter.handleNotificationNavigation(payload);
          await tester.pumpAndSettle();

          // Assert
          expect(
            navObserver.lastPushedRoute?.settings.name,
            equals(Routes.productDetailsView),
          );
          expect(
            navObserver.lastPushedRoute?.settings.arguments,
            equals('review_prod_1'),
          );
        },
      );

      testWidgets(
        'should navigate to trackOrderView when id is present and type is not review',
        (tester) async {
          // Arrange
          await pumpTestApp(tester);
          final payload = {'id': 'order_fallback_7'};

          // Act
          NotificationRouter.handleNotificationNavigation(payload);
          await tester.pumpAndSettle();

          // Assert
          expect(
            navObserver.lastPushedRoute?.settings.name,
            equals(Routes.trackOrderView),
          );
          expect(
            navObserver.lastPushedRoute?.settings.arguments,
            equals('order_fallback_7'),
          );
        },
      );

      testWidgets(
        'should navigate to trackOrderView with plain string id when payload is a plain non-json string',
        (tester) async {
          // Arrange
          await pumpTestApp(tester);
          const plainId = 'plain_string_id_99';

          // Act
          NotificationRouter.handleNotificationNavigation(plainId);
          await tester.pumpAndSettle();

          // Assert
          expect(
            navObserver.lastPushedRoute?.settings.name,
            equals(Routes.trackOrderView),
          );
          expect(
            navObserver.lastPushedRoute?.settings.arguments,
            equals('plain_string_id_99'),
          );
        },
      );

      testWidgets(
        'should fallback to id map when string payload starts with brace but is invalid JSON',
        (tester) async {
          // Arrange
          await pumpTestApp(tester);
          const malformedJsonString = '{invalid_json_content';

          // Act
          NotificationRouter.handleNotificationNavigation(malformedJsonString);
          await tester.pumpAndSettle();

          // Assert
          expect(
            navObserver.lastPushedRoute?.settings.name,
            equals(Routes.trackOrderView),
          );
          expect(
            navObserver.lastPushedRoute?.settings.arguments,
            equals(malformedJsonString),
          );
        },
      );

      testWidgets(
        'should handle generic Map payload correctly and navigate to trackOrderView',
        (tester) async {
          // Arrange
          await pumpTestApp(tester);
          final Map<dynamic, dynamic> genericMap = {'orderId': 'generic_ord_1'};

          // Act
          NotificationRouter.handleNotificationNavigation(genericMap);
          await tester.pumpAndSettle();

          // Assert
          expect(
            navObserver.lastPushedRoute?.settings.name,
            equals(Routes.trackOrderView),
          );
          expect(
            navObserver.lastPushedRoute?.settings.arguments,
            equals('generic_ord_1'),
          );
        },
      );
    });
  });
}
