import 'package:easy_localization/easy_localization.dart';

class PaymentOptionEntity {
  PaymentOptionEntity({required this.option, required this.shippingCost});

  final String option;
  final double shippingCost;
}

List<PaymentOptionEntity> get paymentOptions => [
  PaymentOptionEntity(option: "pay_by_paypal".tr(), shippingCost: 0),
  PaymentOptionEntity(option: "pay_by_credit_card".tr(), shippingCost: 0),
  PaymentOptionEntity(option: "cash_on_delivery".tr(), shippingCost: 40),
];
