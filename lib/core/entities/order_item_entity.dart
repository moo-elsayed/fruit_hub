import 'package:equatable/equatable.dart';

class OrderItemEntity extends Equatable {
  const OrderItemEntity({
    this.name = '',
    this.code = '',
    this.imagePath = '',
    this.price = 0.0,
    this.quantity = 0,
  });

  final String name;
  final String code;
  final String imagePath;
  final double price;
  final int quantity;

  double get totalPrice => price * quantity;

  @override
  List<Object?> get props => [name, code, imagePath, price, quantity];
}
