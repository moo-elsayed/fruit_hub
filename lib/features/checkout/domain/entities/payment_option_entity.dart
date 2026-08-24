import 'package:fruit_hub/core/enums/payment_method_type.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/features/checkout/domain/entities/shipping_config_entity.dart';

class PaymentOptionEntity {
  const PaymentOptionEntity({
    this.title = '',
    this.type = .paypal,
    this.shippingCost = 0,
  });

  final String title;
  final PaymentMethodType type;
  final double shippingCost;
}

List<PaymentOptionEntity> getPaymentOptions(
  ShippingConfigEntity shippingConfig,
) => [
  PaymentOptionEntity(title: AppStrings.payByPaypal, type: .paypal),
  PaymentOptionEntity(title: AppStrings.payByCreditCard, type: .card),
  PaymentOptionEntity(
    title: AppStrings.cashOnDelivery,
    type: .cash,
    shippingCost: shippingConfig.shippingCost,
  ),
];
