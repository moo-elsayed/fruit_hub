import 'package:easy_localization/easy_localization.dart';

class PaymentOptionEntity {
  PaymentOptionEntity({
    required this.title,
    this.subtitle,
    required this.price,
  });

  final String title;
  final String? subtitle;
  final double price;
}

List<PaymentOptionEntity> get paymentOptions => [
  PaymentOptionEntity(title: "payPal".tr(), price: 0),
  PaymentOptionEntity(title: "pay_by_visa".tr(), price: 0),
  PaymentOptionEntity(
    title: "cash_on_delivery".tr(),
    subtitle: "delivery_from_place".tr(),
    price: 40,
  ),
];
