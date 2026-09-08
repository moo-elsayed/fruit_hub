import 'package:equatable/equatable.dart';
import 'package:fruit_hub/core/entities/cart_item_entity.dart';
import 'package:fruit_hub/core/entities/order_item_entity.dart';
import 'package:fruit_hub/core/enums/order_status.dart';
import 'package:fruit_hub/core/enums/payment_method_type.dart';
import 'package:fruit_hub/features/checkout/domain/entities/address_entity.dart';
import 'package:fruit_hub/features/checkout/domain/entities/payment_option_entity.dart';

class OrderEntity extends Equatable {
  const OrderEntity({
    this.docId = '',
    this.uId = '',
    this.orderId = 0,
    this.totalPrice = 0.0,
    this.status = OrderStatus.pending,
    this.paymentOption = const PaymentOptionEntity(),
    this.date = '',
    this.shippingAddress = const AddressEntity(),
    this.orderItems = const [],
    this.cartItems = const [],
  });

  factory OrderEntity.fromCheckout({
    String uid = '',
    int orderId = 0,
    AddressEntity address = const AddressEntity(),
    PaymentOptionEntity paymentOption = const PaymentOptionEntity(),
    List<CartItemEntity> products = const [],
  }) {
    final items = products.map((e) => e.toOrderItemEntity()).toList();
    final subtotal = items.fold<double>(0.0, (s, i) => s + i.totalPrice);
    return OrderEntity(
      uId: uid,
      orderId: orderId,
      shippingAddress: address,
      paymentOption: paymentOption,
      cartItems: products,
      orderItems: items,
      totalPrice: subtotal + paymentOption.shippingCost,
    );
  }

  final String docId;
  final String uId;
  final int orderId;
  final double totalPrice;
  final OrderStatus status;
  final PaymentOptionEntity paymentOption;
  final String date;
  final AddressEntity shippingAddress;
  final List<OrderItemEntity> orderItems;
  final List<CartItemEntity> cartItems;

  // Compatibility aliases
  String get uid => uId;
  AddressEntity get address => shippingAddress;
  List<CartItemEntity> get products => cartItems;

  double get subtotal => orderItems.isNotEmpty
      ? orderItems.fold<double>(
          0.0,
          (totalSum, item) => totalSum + item.totalPrice,
        )
      : cartItems.fold<double>(
          0.0,
          (totalSum, item) => totalSum + item.totalPrice,
        );

  bool get canCancel => status == OrderStatus.pending;

  PaymentMethodType get paymentType => paymentOption.type;

  OrderEntity copyWith({
    String? docId,
    String? uId,
    int? orderId,
    double? totalPrice,
    OrderStatus? status,
    PaymentOptionEntity? paymentOption,
    String? date,
    AddressEntity? shippingAddress,
    List<OrderItemEntity>? orderItems,
    List<CartItemEntity>? cartItems,
  }) => OrderEntity(
    docId: docId ?? this.docId,
    uId: uId ?? this.uId,
    orderId: orderId ?? this.orderId,
    totalPrice: totalPrice ?? this.totalPrice,
    status: status ?? this.status,
    paymentOption: paymentOption ?? this.paymentOption,
    date: date ?? this.date,
    shippingAddress: shippingAddress ?? this.shippingAddress,
    orderItems: orderItems ?? this.orderItems,
    cartItems: cartItems ?? this.cartItems,
  );

  @override
  List<Object?> get props => [
    docId,
    uId,
    orderId,
    totalPrice,
    status,
    paymentOption,
    date,
    shippingAddress,
    orderItems,
    cartItems,
  ];
}
