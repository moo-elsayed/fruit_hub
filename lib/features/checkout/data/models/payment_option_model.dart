import 'package:fruit_hub/features/checkout/domain/entities/payment_option_entity.dart';

class PaymentOptionModel {
  PaymentOptionModel({required this.option, required this.shippingCost});

  final String option;
  final double shippingCost;

  factory PaymentOptionModel.fromEntity(PaymentOptionEntity entity) =>
      PaymentOptionModel(
        option: entity.option,
        shippingCost: entity.shippingCost,
      );

  PaymentOptionEntity toEntity() =>
      PaymentOptionEntity(option: option, shippingCost: shippingCost);

  Map<String, dynamic> toJson() => {
    'option': option,
    'shipping_cost': shippingCost,
  };
}
