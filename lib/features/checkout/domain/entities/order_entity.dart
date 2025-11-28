import 'package:fruit_hub/features/checkout/domain/entities/address_entity.dart';
import 'package:fruit_hub/features/checkout/domain/entities/payment_option_entity.dart';
import '../../../../core/entities/cart_item_entity.dart';

class OrderEntity {
  OrderEntity({
    required this.products,
    required this.address,
    required this.paymentOption,
  });

  final List<CartItemEntity> products;
  final AddressEntity address;
  final PaymentOptionEntity paymentOption;
}
