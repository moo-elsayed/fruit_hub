import 'package:flutter/material.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/theming/app_palette.dart';

enum OrderStatus {
  pending,
  processing,
  shipped,
  delivered,
  cancelled;

  String get databaseValue => switch (this) {
    OrderStatus.pending => 'pending',
    OrderStatus.processing => 'processing',
    OrderStatus.shipped => 'shipped',
    OrderStatus.delivered => 'delivered',
    OrderStatus.cancelled => 'cancelled',
  };

  static OrderStatus fromString(String? value) =>
      switch (value?.toLowerCase()) {
        'processing' => OrderStatus.processing,
        'shipped' => OrderStatus.shipped,
        'delivered' => OrderStatus.delivered,
        'cancelled' => OrderStatus.cancelled,
        _ => OrderStatus.pending,
      };

  String get getName => switch (this) {
    OrderStatus.pending => AppStrings.orderPlaced,
    OrderStatus.processing => AppStrings.orderPreparing,
    OrderStatus.shipped => AppStrings.orderOnTheWay,
    OrderStatus.delivered => AppStrings.orderDelivered,
    OrderStatus.cancelled => AppStrings.orderCancelled,
  };

  Color get color => switch (this) {
    OrderStatus.pending => AppPalette.secondaryOrange,
    OrderStatus.processing => AppPalette.info,
    OrderStatus.shipped => AppPalette.primaryGreen,
    OrderStatus.delivered => AppPalette.accentGreen,
    OrderStatus.cancelled => AppPalette.error,
  };

  Color get containerColor => color.withValues(alpha: 0.1);

  int get stepIndex => switch (this) {
    OrderStatus.pending => 0,
    OrderStatus.processing => 1,
    OrderStatus.shipped => 2,
    OrderStatus.delivered => 3,
    OrderStatus.cancelled => -1,
  };
}
