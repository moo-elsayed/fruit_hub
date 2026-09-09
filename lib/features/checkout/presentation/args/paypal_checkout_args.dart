import 'package:flutter/foundation.dart';
import 'package:fruit_hub/core/entities/order_entity.dart';

class PaypalCheckoutArgs {
  const PaypalCheckoutArgs({
    required this.orderEntity,
    required this.onSuccess,
    required this.onError,
    required this.onCancel,
  });

  final OrderEntity orderEntity;
  final ValueChanged<Map<dynamic, dynamic>> onSuccess;
  final ValueChanged<dynamic> onError;
  final VoidCallback onCancel;
}
