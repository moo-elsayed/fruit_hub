import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/routing/routes.dart';
import 'package:fruit_hub/core/services/deep_link/deep_link_service.dart';
import 'package:fruit_hub/core/services/notifications/notification_router.dart';
import 'package:fruit_hub/features/main/presentation/managers/main_tab_notifier.dart';
import 'package:mocktail/mocktail.dart';

class MockAppLinks extends Mock implements AppLinks {}

class TestNavigatorObserver extends NavigatorObserver {
  final List<Route<dynamic>> pushedRoutes = [];

  Route<dynamic>? get lastPushedRoute =>
      pushedRoutes.isNotEmpty ? pushedRoutes.last : null;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    pushedRoutes.add(route);
  }
}

void main() {
  late MockAppLinks mockAppLinks;
  late StreamController<Uri> uriController;
  late DeepLinkService sut;
  late TestNavigatorObserver navObserver;

  setUp(() {
    mockAppLinks = MockAppLinks();
    uriController = StreamController<Uri>.broadcast();
    when(() => mockAppLinks.uriLinkStream)
        .thenAnswer((_) => uriController.stream);
    when(() => mockAppLinks.getInitialLink()).thenAnswer((_) async => null);

    sut = DeepLinkService(appLinks: mockAppLinks);

    DeepLinkService.isAppReady = true;
    DeepLinkService.pendingUri = null;
    MainTabNotifier.switchToTab(0);
    navObserver = TestNavigatorObserver();
  });

  tearDown(() {
    sut.dispose();
    uriController.close();
    DeepLinkService.isAppReady = true;
    DeepLinkService.pendingUri = null;
    MainTabNotifier.switchToTab(0);
  });

  Future<void> pumpTestApp(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: NotificationRouter.navigatorKey,
        navigatorObservers: [navObserver],
        routes: {
          Routes.productDetailsView: (context) => const SizedBox(),
          Routes.trackOrderView: (context) => const SizedBox(),
          Routes.searchView: (context) => const SizedBox(),
        },
        home: const Scaffold(body: Text('Home Screen')),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('DeepLinkService', () {
    group('Initialization and Lifecycle', () {
      test('should use default AppLinks instance when none is injected', () {
        // Arrange & Act
        final service = DeepLinkService();

        // Assert
        expect(service, isNotNull);
      });

      testWidgets(
        'should listen to uriLinkStream and handle incoming URIs when init is called',
        (tester) async {
          // Arrange
          await pumpTestApp(tester);
          await sut.init();

          // Act
          uriController.add(Uri.parse('fruithub://product/apple_stream'));
          await tester.pumpAndSettle();

          // Assert
          expect(
            navObserver.lastPushedRoute?.settings.name,
            equals(Routes.productDetailsView),
          );
          expect(
            navObserver.lastPushedRoute?.settings.arguments,
            equals('apple_stream'),
          );
        },
      );

      testWidgets(
        'should handle initial URI on cold launch when getInitialLink returns a URI',
        (tester) async {
          // Arrange
          await pumpTestApp(tester);
          when(() => mockAppLinks.getInitialLink()).thenAnswer(
            (_) async => Uri.parse('fruithub://product/banana_init'),
          );

          // Act
          await sut.init();
          await tester.pumpAndSettle();

          // Assert
          expect(
            navObserver.lastPushedRoute?.settings.name,
            equals(Routes.productDetailsView),
          );
          expect(
            navObserver.lastPushedRoute?.settings.arguments,
            equals('banana_init'),
          );
        },
      );

      testWidgets('should handle stream errors gracefully without throwing', (
        tester,
      ) async {
        // Arrange
        await pumpTestApp(tester);
        await sut.init();

        // Act & Assert
        expect(() {
          uriController.addError('Stream simulated error');
        }, returnsNormally);
        await tester.pumpAndSettle();
      });

      testWidgets(
        'should catch and handle getInitialLink exceptions gracefully without throwing',
        (tester) async {
          // Arrange
          await pumpTestApp(tester);
          when(() => mockAppLinks.getInitialLink())
              .thenThrow(Exception('Platform channel error'));

          // Act & Assert
          await expectLater(sut.init(), completes);
        },
      );
    });

    group('App Readiness & Pending Deep Link', () {
      testWidgets(
        'should store URI in pendingUri and not navigate when isAppReady is false',
        (tester) async {
          // Arrange
          await pumpTestApp(tester);
          DeepLinkService.isAppReady = false;
          final uri = Uri.parse('fruithub://order/ord_pending_1');

          // Act
          sut.handleUri(uri);
          await tester.pumpAndSettle();

          // Assert
          expect(DeepLinkService.pendingUri, equals(uri));
          expect(navObserver.pushedRoutes.length, equals(1)); // only home route
        },
      );

      testWidgets(
        'should dispatch pendingUri and clear it when markAppAsReady is called',
        (tester) async {
          // Arrange
          await pumpTestApp(tester);
          DeepLinkService.isAppReady = false;
          final uri = Uri.parse('fruithub://order/ord_pending_2');
          sut.handleUri(uri);
          expect(DeepLinkService.pendingUri, equals(uri));

          // Act
          DeepLinkService.markAppAsReady();
          await tester.pumpAndSettle();

          // Assert
          expect(DeepLinkService.isAppReady, isTrue);
          expect(DeepLinkService.pendingUri, isNull);
          expect(
            navObserver.lastPushedRoute?.settings.name,
            equals(Routes.trackOrderView),
          );
          expect(
            navObserver.lastPushedRoute?.settings.arguments,
            equals('ord_pending_2'),
          );
        },
      );

      testWidgets(
        'should do nothing when checkAndHandlePendingDeepLink is called and pendingUri is null',
        (tester) async {
          // Arrange
          await pumpTestApp(tester);
          DeepLinkService.isAppReady = true;
          DeepLinkService.pendingUri = null;

          // Act
          DeepLinkService.checkAndHandlePendingDeepLink();
          await tester.pumpAndSettle();

          // Assert
          expect(navObserver.pushedRoutes.length, equals(1));
        },
      );
    });

    group('Custom Scheme (fruithub://)', () {
      testWidgets(
        'should navigate to productDetailsView when host is product with path segment',
        (tester) async {
          // Arrange
          await pumpTestApp(tester);
          final uri = Uri.parse('fruithub://product/fruit_code_123');

          // Act
          sut.handleUri(uri);
          await tester.pumpAndSettle();

          // Assert
          expect(
            navObserver.lastPushedRoute?.settings.name,
            equals(Routes.productDetailsView),
          );
          expect(
            navObserver.lastPushedRoute?.settings.arguments,
            equals('fruit_code_123'),
          );
        },
      );

      testWidgets(
        'should navigate to productDetailsView when host is product with query parameter code',
        (tester) async {
          // Arrange
          await pumpTestApp(tester);
          final uri = Uri.parse('fruithub://product?code=fruit_code_456');

          // Act
          sut.handleUri(uri);
          await tester.pumpAndSettle();

          // Assert
          expect(
            navObserver.lastPushedRoute?.settings.name,
            equals(Routes.productDetailsView),
          );
          expect(
            navObserver.lastPushedRoute?.settings.arguments,
            equals('fruit_code_456'),
          );
        },
      );

      testWidgets(
        'should navigate to trackOrderView when host is order with path segment',
        (tester) async {
          // Arrange
          await pumpTestApp(tester);
          final uri = Uri.parse('fruithub://order/ord_abc_1');

          // Act
          sut.handleUri(uri);
          await tester.pumpAndSettle();

          // Assert
          expect(
            navObserver.lastPushedRoute?.settings.name,
            equals(Routes.trackOrderView),
          );
          expect(
            navObserver.lastPushedRoute?.settings.arguments,
            equals('ord_abc_1'),
          );
        },
      );

      testWidgets(
        'should navigate to trackOrderView when host is order with query parameter id',
        (tester) async {
          // Arrange
          await pumpTestApp(tester);
          final uri = Uri.parse('fruithub://order?id=ord_xyz_2');

          // Act
          sut.handleUri(uri);
          await tester.pumpAndSettle();

          // Assert
          expect(
            navObserver.lastPushedRoute?.settings.name,
            equals(Routes.trackOrderView),
          );
          expect(
            navObserver.lastPushedRoute?.settings.arguments,
            equals('ord_xyz_2'),
          );
        },
      );

      testWidgets(
        'should navigate to trackOrderView when host is order with query parameter orderId',
        (tester) async {
          // Arrange
          await pumpTestApp(tester);
          final uri = Uri.parse('fruithub://order?orderId=ord_qwe_3');

          // Act
          sut.handleUri(uri);
          await tester.pumpAndSettle();

          // Assert
          expect(
            navObserver.lastPushedRoute?.settings.name,
            equals(Routes.trackOrderView),
          );
          expect(
            navObserver.lastPushedRoute?.settings.arguments,
            equals('ord_qwe_3'),
          );
        },
      );

      testWidgets('should switch to cart tab (index 2) when host is cart', (
        tester,
      ) async {
        // Arrange
        await pumpTestApp(tester);
        final uri = Uri.parse('fruithub://cart');

        // Act
        sut.handleUri(uri);
        await tester.pumpAndSettle();

        // Assert
        expect(MainTabNotifier.currentTab.value, equals(2));
      });

      testWidgets(
        'should switch to favorites tab (index 1) when host is favorites',
        (tester) async {
          // Arrange
          await pumpTestApp(tester);
          final uri = Uri.parse('fruithub://favorites');

          // Act
          sut.handleUri(uri);
          await tester.pumpAndSettle();

          // Assert
          expect(MainTabNotifier.currentTab.value, equals(1));
        },
      );

      testWidgets(
        'should switch to profile tab (index 3) when host is profile',
        (tester) async {
          // Arrange
          await pumpTestApp(tester);
          final uri = Uri.parse('fruithub://profile');

          // Act
          sut.handleUri(uri);
          await tester.pumpAndSettle();

          // Assert
          expect(MainTabNotifier.currentTab.value, equals(3));
        },
      );

      testWidgets('should switch to home tab (index 0) when host is home', (
        tester,
      ) async {
        // Arrange
        await pumpTestApp(tester);
        MainTabNotifier.switchToTab(2);
        final uri = Uri.parse('fruithub://home');

        // Act
        sut.handleUri(uri);
        await tester.pumpAndSettle();

        // Assert
        expect(MainTabNotifier.currentTab.value, equals(0));
      });

      testWidgets('should navigate to searchView when host is search', (
        tester,
      ) async {
        // Arrange
        await pumpTestApp(tester);
        final uri = Uri.parse('fruithub://search');

        // Act
        sut.handleUri(uri);
        await tester.pumpAndSettle();

        // Assert
        expect(
          navObserver.lastPushedRoute?.settings.name,
          equals(Routes.searchView),
        );
      });
    });

    group('HTTPS Universal Links (https://fruithub.com/...)', () {
      testWidgets(
        'should navigate to productDetailsView when path segment is product with code',
        (tester) async {
          // Arrange
          await pumpTestApp(tester);
          final uri = Uri.parse('https://fruithub.com/product/mango_universal');

          // Act
          sut.handleUri(uri);
          await tester.pumpAndSettle();

          // Assert
          expect(
            navObserver.lastPushedRoute?.settings.name,
            equals(Routes.productDetailsView),
          );
          expect(
            navObserver.lastPushedRoute?.settings.arguments,
            equals('mango_universal'),
          );
        },
      );

      testWidgets(
        'should navigate to trackOrderView when path segment is order with id',
        (tester) async {
          // Arrange
          await pumpTestApp(tester);
          final uri = Uri.parse('https://fruithub.com/order/ord_https_500');

          // Act
          sut.handleUri(uri);
          await tester.pumpAndSettle();

          // Assert
          expect(
            navObserver.lastPushedRoute?.settings.name,
            equals(Routes.trackOrderView),
          );
          expect(
            navObserver.lastPushedRoute?.settings.arguments,
            equals('ord_https_500'),
          );
        },
      );

      testWidgets('should switch to cart tab when universal link is /cart', (
        tester,
      ) async {
        // Arrange
        await pumpTestApp(tester);
        final uri = Uri.parse('https://fruithub.com/cart');

        // Act
        sut.handleUri(uri);
        await tester.pumpAndSettle();

        // Assert
        expect(MainTabNotifier.currentTab.value, equals(2));
      });

      testWidgets(
        'should switch to favorites tab when universal link is /favorites',
        (tester) async {
          // Arrange
          await pumpTestApp(tester);
          final uri = Uri.parse('https://fruithub.com/favorites');

          // Act
          sut.handleUri(uri);
          await tester.pumpAndSettle();

          // Assert
          expect(MainTabNotifier.currentTab.value, equals(1));
        },
      );

      testWidgets(
        'should switch to profile tab when universal link is /profile',
        (tester) async {
          // Arrange
          await pumpTestApp(tester);
          final uri = Uri.parse('https://fruithub.com/profile');

          // Act
          sut.handleUri(uri);
          await tester.pumpAndSettle();

          // Assert
          expect(MainTabNotifier.currentTab.value, equals(3));
        },
      );

      testWidgets('should switch to home tab when universal link is /home', (
        tester,
      ) async {
        // Arrange
        await pumpTestApp(tester);
        MainTabNotifier.switchToTab(3);
        final uri = Uri.parse('https://fruithub.com/home');

        // Act
        sut.handleUri(uri);
        await tester.pumpAndSettle();

        // Assert
        expect(MainTabNotifier.currentTab.value, equals(0));
      });

      testWidgets(
        'should navigate to searchView when universal link is /search',
        (tester) async {
          // Arrange
          await pumpTestApp(tester);
          final uri = Uri.parse('https://fruithub.com/search');

          // Act
          sut.handleUri(uri);
          await tester.pumpAndSettle();

          // Assert
          expect(
            navObserver.lastPushedRoute?.settings.name,
            equals(Routes.searchView),
          );
        },
      );
    });

    group('Unsupported or Malformed URIs', () {
      testWidgets('should not navigate when scheme is unsupported', (
        tester,
      ) async {
        // Arrange
        await pumpTestApp(tester);
        final uri = Uri.parse('customother://product/123');

        // Act
        sut.handleUri(uri);
        await tester.pumpAndSettle();

        // Assert
        expect(navObserver.pushedRoutes.length, equals(1));
      });

      testWidgets(
        'should not navigate when https host does not contain fruithub',
        (tester) async {
          // Arrange
          await pumpTestApp(tester);
          final uri = Uri.parse('https://external-example.com/product/123');

          // Act
          sut.handleUri(uri);
          await tester.pumpAndSettle();

          // Assert
          expect(navObserver.pushedRoutes.length, equals(1));
        },
      );

      testWidgets(
        'should not navigate when host is product but productCode is null or empty',
        (tester) async {
          // Arrange
          await pumpTestApp(tester);
          final uri = Uri.parse('fruithub://product');

          // Act
          sut.handleUri(uri);
          await tester.pumpAndSettle();

          // Assert
          expect(navObserver.pushedRoutes.length, equals(1));
        },
      );

      testWidgets(
        'should not navigate when host is order but orderId is null or empty',
        (tester) async {
          // Arrange
          await pumpTestApp(tester);
          final uri = Uri.parse('fruithub://order');

          // Act
          sut.handleUri(uri);
          await tester.pumpAndSettle();

          // Assert
          expect(navObserver.pushedRoutes.length, equals(1));
        },
      );
    });
  });
}
