import 'package:fruit_hub/core/entities/fruit_entity.dart';

class CartItemEntity {
  CartItemEntity({required this.fruitEntity, this.quantity = 0});

  final FruitEntity fruitEntity;
  int quantity;

  get totalPrice => fruitEntity.price * quantity;

  void increaseCount() => quantity++;

  void decreaseCount() {
    if (quantity > 1) {
      quantity--;
    }
  }
}
