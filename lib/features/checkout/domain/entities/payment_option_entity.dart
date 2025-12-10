import 'package:easy_localization/easy_localization.dart';
import 'package:fruit_hub/features/checkout/domain/entities/shipping_config_entity.dart';

enum PaymentMethodType { paypal, card, cash }

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
  PaymentOptionEntity(title: "pay_by_paypal".tr(), type: .paypal),
  PaymentOptionEntity(title: "pay_by_credit_card".tr(), type: .card),
  PaymentOptionEntity(
    title: "cash_on_delivery".tr(),
    type: .cash,
    shippingCost: shippingConfig.shippingCost,
  ),
];
