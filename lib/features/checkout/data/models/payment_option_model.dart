import 'package:fruit_hub/features/checkout/domain/entities/payment_option_entity.dart';

class PaymentOptionModel {
  PaymentOptionModel({required this.option, required this.shippingCost});

  final String option;
  final double shippingCost;

  factory PaymentOptionModel.fromEntity(PaymentOptionEntity entity) =>
      PaymentOptionModel(
        option: entity.title,
        shippingCost: entity.shippingCost,
      );

  PaymentOptionEntity toEntity() =>
      PaymentOptionEntity(title: option, shippingCost: shippingCost);

  Map<String, dynamic> toJson() => {
    'option': option,
    'shipping_cost': shippingCost,
  };
}
