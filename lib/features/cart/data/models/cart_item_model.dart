import 'package:fruit_hub/features/cart/domain/entities/cart_item_entity.dart';

import '../../../../core/entities/fruit_entity.dart';

class CartItemModel {
  CartItemModel({
    required this.fruitCode,
    required this.quantity,
    required this.price,
    required this.productName,
    required this.imageUrl,
  });

  final String fruitCode;
  final String productName;
  final String imageUrl;
  final int quantity;
  final double price;

  Map<String, dynamic> toJson() => {
    'fruitCode': fruitCode,
    'quantity': quantity,
    'price': price,
    'productName': productName,
    'imageUrl': imageUrl,
  };

  factory CartItemModel.fromJson(Map<String, dynamic> map) => CartItemModel(
    fruitCode: map['fruitCode'] as String,
    quantity: map['quantity'] as int,
    price: map['price'] as double,
    productName: map['productName'] as String,
    imageUrl: map['imageUrl'] as String,
  );

  factory CartItemModel.fromEntity(CartItemEntity cartItem) => CartItemModel(
    fruitCode: cartItem.fruitEntity.code,
    quantity: cartItem.quantity,
    price: cartItem.fruitEntity.price,
    productName: cartItem.fruitEntity.name,
    imageUrl: cartItem.fruitEntity.imagePath,
  );

  CartItemEntity toEntity() => CartItemEntity(
    quantity: quantity,
    fruitEntity: FruitEntity(
      code: fruitCode,
      name: productName,
      imagePath: imageUrl,
    ),
  );
}
