import '../../domain/entities/shipping_config_entity.dart';

class ShippingConfigModel {
  ShippingConfigModel({required this.shippingCost});

  final double shippingCost;

  factory ShippingConfigModel.fromJson(Map<String, dynamic> json) =>
      ShippingConfigModel(shippingCost: json["shipping_cost"].toDouble());

  factory ShippingConfigModel.fromEntity(ShippingConfigEntity entity) =>
      ShippingConfigModel(shippingCost: entity.shippingCost);

  Map<String, dynamic> toJson() => {"shipping_cost": shippingCost};

  ShippingConfigEntity toEntity() =>
      ShippingConfigEntity(shippingCost: shippingCost);
}
