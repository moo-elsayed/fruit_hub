import 'package:fruit_hub/core/entities/cart_item_entity.dart';
import 'package:fruit_hub/core/entities/order_item_entity.dart';

class OrderItemModel {
  const OrderItemModel({
    required this.name,
    required this.code,
    required this.imagePath,
    required this.price,
    required this.quantity,
  });

  factory OrderItemModel.fromCartItemEntity(CartItemEntity cartItem) =>
      OrderItemModel(
        code: cartItem.fruitEntity.code,
        name: cartItem.fruitEntity.name,
        imagePath: cartItem.fruitEntity.imagePath,
        price: cartItem.fruitEntity.price.toDouble(),
        quantity: cartItem.quantity,
      );

  factory OrderItemModel.fromEntity(dynamic entity) {
    if (entity is CartItemEntity) {
      return OrderItemModel.fromCartItemEntity(entity);
    } else if (entity is OrderItemEntity) {
      return OrderItemModel(
        name: entity.name,
        code: entity.code,
        imagePath: entity.imagePath,
        price: entity.price,
        quantity: entity.quantity,
      );
    }
    throw ArgumentError('Invalid entity type for OrderItemModel: $entity');
  }

  factory OrderItemModel.fromJson(Map<String, dynamic> json) => OrderItemModel(
    name: json['name'] as String? ?? '',
    code: json['code'] as String? ?? '',
    imagePath: (json['imageUrl'] ?? json['imagePath'] ?? '') as String,
    price: (json['price'] as num?)?.toDouble() ?? 0.0,
    quantity: (json['quantity'] as num?)?.toInt() ?? 0,
  );

  final String name;
  final String code;
  final String imagePath;
  final double price;
  final int quantity;

  Map<String, dynamic> toJson() => {
    'code': code,
    'name': name,
    'imageUrl': imagePath,
    'price': price,
    'quantity': quantity,
  };

  OrderItemEntity toEntity() => OrderItemEntity(
    name: name,
    code: code,
    imagePath: imagePath,
    price: price,
    quantity: quantity,
  );
}
