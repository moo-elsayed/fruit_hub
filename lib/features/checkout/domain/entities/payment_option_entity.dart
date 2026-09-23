import 'package:equatable/equatable.dart';
import 'package:fruit_hub/core/enums/payment_method_type.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/features/checkout/domain/entities/shipping_config_entity.dart';

class PaymentOptionEntity extends Equatable {
  const PaymentOptionEntity({
    this.title = '',
    this.type = PaymentMethodType.paypal,
    this.shippingCost = 0,
  });

  final String title;
  final PaymentMethodType type;
  final double shippingCost;

  @override
  List<Object?> get props => [title, type, shippingCost];
}

List<PaymentOptionEntity> getPaymentOptions([
  ShippingConfigEntity? shippingConfig,
  double subtotal = 0,
]) => [
  PaymentOptionEntity(title: AppStrings.payByPaypal, type: .paypal),
  PaymentOptionEntity(title: AppStrings.payByCreditCard, type: .card),
  PaymentOptionEntity(
    title: AppStrings.cashOnDelivery,
    type: .cash,
    shippingCost: shippingConfig?.calculateShippingCost(subtotal) ?? 0,
  ),
];
