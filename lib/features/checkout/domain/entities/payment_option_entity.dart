import 'package:easy_localization/easy_localization.dart';
import 'package:fruit_hub/features/checkout/domain/entities/shipping_config_entity.dart';

class PaymentOptionEntity {
  const PaymentOptionEntity({this.option = '', this.shippingCost = 0});

  final String option;
  final double shippingCost;
}

List<PaymentOptionEntity> getPaymentOptions(
  ShippingConfigEntity shippingConfig,
) => [
  PaymentOptionEntity(option: "pay_by_paypal".tr()),
  PaymentOptionEntity(option: "pay_by_credit_card".tr()),
  PaymentOptionEntity(
    option: "cash_on_delivery".tr(),
    shippingCost: shippingConfig.shippingCost,
  ),
];
