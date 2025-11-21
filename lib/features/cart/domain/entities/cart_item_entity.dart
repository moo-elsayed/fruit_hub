import 'package:equatable/equatable.dart';
import 'package:fruit_hub/core/entities/fruit_entity.dart';

class CartItemEntity extends Equatable {
  const CartItemEntity({required this.fruitEntity, this.quantity = 1});

  final FruitEntity fruitEntity;
  final int quantity;

  get totalPrice => fruitEntity.price * quantity;

  CartItemEntity copyWith({FruitEntity? fruitEntity, int? quantity}) =>
      CartItemEntity(
        fruitEntity: fruitEntity ?? this.fruitEntity,
        quantity: quantity ?? this.quantity,
      );

  @override
  List<Object?> get props => [fruitEntity, quantity];
}
