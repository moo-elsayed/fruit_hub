import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:fruit_hub/core/routing/routes.dart';
import 'package:fruit_hub/core/services/notifications/notification_router.dart';
import 'package:fruit_hub/features/main/presentation/managers/main_tab_notifier.dart';

class DeepLinkService {
  DeepLinkService({AppLinks? appLinks}) : _appLinks = appLinks ?? AppLinks();

  final AppLinks _appLinks;
  StreamSubscription<Uri>? _sub;

  static bool isAppReady = false;

  @visibleForTesting
  static Uri? pendingUri;

  static void markAppAsReady() {
    isAppReady = true;
    checkAndHandlePendingDeepLink();
  }

  Future<void> init() async {
    // 1. Listen for background & foreground deep links
    _sub = _appLinks.uriLinkStream.listen(
      (uri) {
        handleUri(uri);
      },
      onError: (error) {
        debugPrint('Deep Link Stream Error: $error');
      },
    );

    // 2. Check initial deep link on cold launch
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        handleUri(initialUri);
      }
    } catch (e) {
      debugPrint('Deep Link Initial Link Error: $e');
    }
  }

  void handleUri(Uri uri) {
    debugPrint('Received Deep Link URI: $uri');
    if (!isAppReady) {
      debugPrint('App layout not ready yet. Storing pending deep link: $uri');
      pendingUri = uri;
      return;
    }

    navigate(uri);
  }

  static void checkAndHandlePendingDeepLink() {
    if (pendingUri != null && isAppReady) {
      final uri = pendingUri!;
      pendingUri = null;
      navigate(uri);
    }
  }

  static void navigate(Uri uri) {
    String? host;
    String? segment1;

    if (uri.scheme == 'fruithub') {
      host = uri.host.toLowerCase();
      if (uri.pathSegments.isNotEmpty) {
        segment1 = uri.pathSegments.first;
      }
    } else if (uri.scheme == 'https' || uri.scheme == 'http') {
      if (uri.host.toLowerCase().contains('fruithub')) {
        if (uri.pathSegments.isNotEmpty) {
          host = uri.pathSegments.first.toLowerCase();
        }
        if (uri.pathSegments.length > 1) {
          segment1 = uri.pathSegments[1];
        }
      }
    }

    if (host == null) return;

    // 1. Product details: fruithub://product/<fruitCode> or https://fruithub.com/product/<fruitCode>
    if (host == 'product') {
      final productCode = segment1 ?? uri.queryParameters['code'];

      if (productCode != null && productCode.isNotEmpty) {
        _navigateTo(Routes.productDetailsView, arguments: productCode);
      }
      return;
    }

    // 2. Order tracking: fruithub://order/<orderId> or https://fruithub.com/order/<orderId>
    if (host == 'order') {
      final orderId =
          segment1 ??
          (uri.queryParameters['id'] ?? uri.queryParameters['orderId']);

      if (orderId != null && orderId.isNotEmpty) {
        _navigateTo(Routes.trackOrderView, arguments: orderId);
      }
      return;
    }

    // 3. Tab switching
    if (host == 'cart') {
      _switchToTab(2);
      return;
    }

    if (host == 'favorites') {
      _switchToTab(1);
      return;
    }

    if (host == 'profile') {
      _switchToTab(3);
      return;
    }

    if (host == 'home') {
      _switchToTab(0);
      return;
    }

    // 4. Search view: fruithub://search or https://fruithub.com/search
    if (host == 'search') {
      _navigateTo(Routes.searchView);
      return;
    }
  }

  static void _switchToTab(int index) {
    MainTabNotifier.switchToTab(index);
    final state = NotificationRouter.navigatorKey.currentState;
    if (state != null && state.canPop()) {
      state.popUntil((route) => route.isFirst);
    }
  }

  static void _navigateTo(String routeName, {Object? arguments}) {
    final state = NotificationRouter.navigatorKey.currentState;
    if (state != null) {
      state.pushNamed(routeName, arguments: arguments);
    }
  }

  void dispose() {
    _sub?.cancel();
  }
}
