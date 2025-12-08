import 'package:fruit_hub/features/checkout/domain/entities/address_entity.dart';
import 'package:fruit_hub/features/checkout/domain/entities/payment_option_entity.dart';
import '../../../../core/entities/cart_item_entity.dart';

class OrderEntity {
  OrderEntity({
    this.uid = '',
    this.products = const [],
    this.address = const AddressEntity(),
    this.paymentOption = const PaymentOptionEntity(),
  });

  final String uid;
  final List<CartItemEntity> products;
  final AddressEntity address;
  final PaymentOptionEntity paymentOption;


  double get totalPrice => products.fold(
    0,
    (previousValue, element) => previousValue + element.totalPrice,
  );
}
