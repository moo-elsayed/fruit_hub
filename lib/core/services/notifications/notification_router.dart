import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fruit_hub/core/enums/notification_type.dart';
import 'package:fruit_hub/core/routing/routes.dart';

class NotificationRouter {
  NotificationRouter._();

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static bool isAppReady = false;
  static dynamic _pendingPayload;

  static void markAppAsReady() {
    isAppReady = true;
    checkAndHandlePendingNotification();
  }

  static void checkAndHandlePendingNotification() {
    if (_pendingPayload != null && isAppReady) {
      final payload = _pendingPayload;
      _pendingPayload = null;
      handleNotificationNavigation(payload);
    }
  }

  static void handleNotificationNavigation(dynamic payload) {
    if (payload == null) return;

    if (!isAppReady) {
      debugPrint(
        'App layout not ready yet. Storing pending notification payload: $payload',
      );
      _pendingPayload = payload;
      return;
    }

    Map<String, dynamic> data = {};

    if (payload is Map<String, dynamic>) {
      data = payload;
    } else if (payload is String && payload.trim().isNotEmpty) {
      if (payload.trim().startsWith('{')) {
        try {
          final decoded = jsonDecode(payload);
          if (decoded is Map<String, dynamic>) {
            data = decoded;
          }
        } catch (_) {
          data = {'id': payload};
        }
      } else {
        data = {'id': payload};
      }
    } else if (payload is Map) {
      data = Map<String, dynamic>.from(payload);
    }

    if (data.isEmpty) return;

    final type = NotificationType.fromString(data['type']?.toString());
    final orderId = (data['orderId'] ?? data['order_id'])?.toString();
    final productCode = (data['productCode'] ?? data['product_code'])
        ?.toString();

    // 1. Order status notifications
    if (orderId != null && orderId.isNotEmpty) {
      _navigateTo(Routes.trackOrderView, arguments: orderId);
      return;
    }

    // 2. Review / Product notifications
    if (productCode != null && productCode.isNotEmpty) {
      _navigateTo(Routes.productDetailsView, arguments: productCode);
      return;
    }

    // 3. Cart reminders
    if (type == NotificationType.cart) {
      _navigateTo(Routes.mainView, arguments: 2);
      return;
    }

    // 4. Fallback ID if passed directly
    final id = data['id']?.toString();
    if (id != null && id.isNotEmpty) {
      if (type == NotificationType.review) {
        _navigateTo(Routes.productDetailsView, arguments: id);
      } else {
        _navigateTo(Routes.trackOrderView, arguments: id);
      }
    }
  }

  static void _navigateTo(String routeName, {Object? arguments}) {
    final state = navigatorKey.currentState;
    if (state != null) {
      state.pushNamed(routeName, arguments: arguments);
    }
  }
}
