import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fruit_hub/core/entities/order_entity.dart';
import 'package:fruit_hub/core/enums/order_status.dart';
import 'package:fruit_hub/core/enums/payment_method_type.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/features/checkout/data/models/address_model.dart';
import 'package:fruit_hub/features/checkout/domain/entities/address_entity.dart';
import 'package:fruit_hub/features/checkout/domain/entities/payment_option_entity.dart';

import 'order_item_model.dart';

class OrderModel {
  const OrderModel({
    required this.uId,
    required this.orderId,
    required this.totalPrice,
    required this.status,
    required this.paymentMethod,
    required this.shippingAddress,
    required this.orderItems,
    required this.date,
    this.docId = '',
  });

  factory OrderModel.fromEntity(OrderEntity order) => OrderModel(
    uId: order.uId,
    orderId: order.orderId,
    totalPrice: order.totalPrice,
    status: order.status,
    paymentMethod: order.paymentOption.type.databaseValue,
    shippingAddress: AddressModel.fromEntity(order.shippingAddress),
    orderItems: order.orderItems.isNotEmpty
        ? order.orderItems.map((e) => OrderItemModel.fromEntity(e)).toList()
        : order.products.map((e) => OrderItemModel.fromEntity(e)).toList(),
    date: order.date.isNotEmpty ? order.date : DateTime.now().toString(),
    docId: order.docId,
  );

  factory OrderModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return OrderModel.fromJson(data, docId: doc.id);
  }

  factory OrderModel.fromJson(Map<String, dynamic> json, {String docId = ''}) =>
      OrderModel(
        docId: docId.isNotEmpty ? docId : (json['docId'] as String? ?? ''),
        uId: json['uId'] as String? ?? '',
        orderId: (json['orderId'] as num?)?.toInt() ?? 0,
        totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
        status: OrderStatus.fromString(json['status'] as String?),
        paymentMethod: json['paymentMethod'] as String? ?? '',
        date: json['date'] as String? ?? '',
        shippingAddress: json['shippingAddress'] != null
            ? AddressModel.fromJson(
                Map<String, dynamic>.from(json['shippingAddress'] as Map),
              )
            : AddressModel.fromEntity(const AddressEntity()),
        orderItems: (json['orderItems'] as List<dynamic>? ?? [])
            .map(
              (item) => OrderItemModel.fromJson(
                Map<String, dynamic>.from(item as Map),
              ),
            )
            .toList(),
      );

  final String docId;
  final String uId;
  final int orderId;
  final double totalPrice;
  final OrderStatus status;
  final String paymentMethod;
  final AddressModel shippingAddress;
  final List<OrderItemModel> orderItems;
  final String date;

  PaymentMethodType get paymentType =>
      PaymentMethodType.fromString(paymentMethod);

  Map<String, dynamic> toJson() => {
    'uId': uId,
    'orderId': orderId,
    'totalPrice': totalPrice,
    'status': status.databaseValue,
    'paymentMethod': paymentMethod,
    'date': date,
    'shippingAddress': shippingAddress.toJson(),
    'orderItems': orderItems.map((e) => e.toJson()).toList(),
  };

  Map<String, dynamic> toPaypalTransaction() {
    final double subTotal = orderItems.fold(
      0.0,
      (totalSum, item) => totalSum + (item.price * item.quantity),
    );
    final double shippingCost = totalPrice - subTotal;
    return {
      'amount': {
        'total': totalPrice.toString(),
        'currency': 'USD',
        'details': {
          'subtotal': subTotal.toString(),
          'shipping': shippingCost.toString(),
          'shipping_discount': 0,
        },
      },
      'description': 'The payment transaction description.',
      'item_list': {
        'items': orderItems
            .map(
              (item) => {
                'name': item.name,
                'quantity': item.quantity,
                'price': item.price.toString(),
                'currency': 'USD',
              },
            )
            .toList(),
      },
      'shipping_address': {
        'recipient_name': shippingAddress.name,
        'line1': shippingAddress.streetName,
        'line2': shippingAddress.buildingNumber,
        'city': shippingAddress.city,
        'country_code': 'EG',
        'postal_code': '11111',
        'phone': shippingAddress.phone,
        'state': shippingAddress.city,
      },
    };
  }

  OrderEntity toEntity() {
    final pType = paymentType;
    final subtotal = orderItems.fold<double>(
      0.0,
      (totalSum, item) => totalSum + (item.price * item.quantity),
    );
    final shippingCost = (totalPrice > subtotal)
        ? (totalPrice - subtotal)
        : 0.0;

    return OrderEntity(
      docId: docId,
      uId: uId,
      orderId: orderId,
      totalPrice: totalPrice,
      status: status,
      paymentOption: PaymentOptionEntity(
        title: switch (pType) {
          PaymentMethodType.paypal => AppStrings.payByPaypal,
          PaymentMethodType.card => AppStrings.payByCreditCard,
          PaymentMethodType.cash => AppStrings.cashOnDelivery,
        },
        type: pType,
        shippingCost: shippingCost,
      ),
      date: date,
      shippingAddress: shippingAddress.toEntity(),
      orderItems: orderItems.map((e) => e.toEntity()).toList(),
    );
  }
}
