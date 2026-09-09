import 'package:flutter/material.dart';

enum NotificationType {
  order,
  cart,
  review,
  general;

  String get value => switch (this) {
    NotificationType.order => 'order',
    NotificationType.cart => 'cart',
    NotificationType.review => 'review',
    NotificationType.general => 'general',
  };

  static NotificationType fromString(String? value) =>
      switch (value?.toLowerCase()) {
        'order' => NotificationType.order,
        'cart' => NotificationType.cart,
        'review' => NotificationType.review,
        _ => NotificationType.general,
      };

  IconData get icon => switch (this) {
    NotificationType.order => Icons.local_shipping_outlined,
    NotificationType.cart => Icons.shopping_cart_outlined,
    NotificationType.review => Icons.star_outline_rounded,
    NotificationType.general => Icons.notifications_none_rounded,
  };
}
