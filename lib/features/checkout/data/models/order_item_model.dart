import '../../../../core/entities/cart_item_entity.dart';

class OrderItemModel {
  OrderItemModel({
    required this.code,
    required this.name,
    required this.imagePath,
    required this.price,
    required this.quantity,
  });

  final String code;
  final String name;
  final String imagePath;
  final double price;
  final int quantity;

  factory OrderItemModel.fromEntity(CartItemEntity cartItem) => OrderItemModel(
    code: cartItem.fruitEntity.code,
    name: cartItem.fruitEntity.name,
    imagePath: cartItem.fruitEntity.imagePath,
    price: cartItem.fruitEntity.price.toDouble(),
    quantity: cartItem.quantity,
  );

  Map<String, dynamic> toJson() => {
    'code': code,
    'name': name,
    'imageUrl': imagePath,
    'price': price,
    'quantity': quantity,
  };
}
