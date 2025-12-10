import 'package:fruit_hub/features/checkout/domain/entities/order_entity.dart';
import 'address_model.dart';
import 'order_item_model.dart';

class OrderModel {
  OrderModel({
    required this.uId,
    required this.orderId,
    required this.totalPrice,
    required this.status,
    required this.paymentMethod,
    required this.shippingAddress,
    required this.orderItems,
    required this.date,
  });

  final String uId;
  final int orderId;
  final double totalPrice;
  final String status;
  final String paymentMethod;
  final AddressModel shippingAddress;
  final List<OrderItemModel> orderItems;
  final String date;

  factory OrderModel.fromEntity(OrderEntity order) => OrderModel(
    uId: order.uid,
    orderId: order.orderId,
    totalPrice: order.totalPrice + order.paymentOption.shippingCost,
    status: 'Pending',
    paymentMethod: order.paymentOption.option,
    shippingAddress: AddressModel.fromEntity(order.address),
    orderItems: order.products
        .map((e) => OrderItemModel.fromEntity(e))
        .toList(),
    date: DateTime.now().toString(),
  );

  Map<String, dynamic> toJson() => {
    'uId': uId,
    'orderId': orderId,
    'totalPrice': totalPrice,
    'status': status,
    'paymentMethod': paymentMethod,
    'date': date,
    'shippingAddress': shippingAddress.toJson(),
    'orderItems': orderItems.map((e) => e.toJson()).toList(),
  };

  Map<String, dynamic> toPaypalTransaction() {
    double subTotal = orderItems.fold(
      0,
      (sum, item) => sum + (item.price * item.quantity),
    );
    double shippingCost = totalPrice - subTotal;
    return {
      "amount": {
        "total": totalPrice.toString(),
        "currency": "USD",
        "details": {
          "subtotal": subTotal.toString(),
          "shipping": shippingCost.toString(),
          "shipping_discount": 0,
        },
      },
      "description": "The payment transaction description.",
      "item_list": {
        "items": orderItems
            .map(
              (item) => {
                "name": item.name,
                "quantity": item.quantity,
                "price": item.price.toString(),
                "currency": "USD",
              },
            )
            .toList(),
      },
      "shipping_address": {
        "recipient_name": shippingAddress.name,
        "line1": shippingAddress.streetName,
        "line2": shippingAddress.buildingNumber,
        "city": shippingAddress.city,
        "country_code": "EG",
        "postal_code": "11111",
        "phone": shippingAddress.phone,
        "state": shippingAddress.city,
      },
    };
  }
}
