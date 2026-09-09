import '../../../../core/helpers/backend_endpoints.dart';
import '../../domain/entities/shipping_config_entity.dart';

class ShippingConfigModel {
  ShippingConfigModel({required this.shippingCost, this.freeShippingThreshold});

  factory ShippingConfigModel.fromJson(
    Map<String, dynamic> json,
  ) => ShippingConfigModel(
    shippingCost:
        (json[BackendEndpoints.shippingCostField] as num?)?.toDouble() ?? 0.0,
    freeShippingThreshold:
        (json[BackendEndpoints.freeShippingThresholdField] as num?)?.toDouble(),
  );

  factory ShippingConfigModel.fromEntity(ShippingConfigEntity entity) =>
      ShippingConfigModel(
        shippingCost: entity.shippingCost,
        freeShippingThreshold: entity.freeShippingThreshold,
      );

  final double shippingCost;
  final double? freeShippingThreshold;

  Map<String, dynamic> toJson() => {
    BackendEndpoints.shippingCostField: shippingCost,
    if (freeShippingThreshold != null)
      BackendEndpoints.freeShippingThresholdField: freeShippingThreshold,
  };

  ShippingConfigEntity toEntity() => ShippingConfigEntity(
    shippingCost: shippingCost,
    freeShippingThreshold: freeShippingThreshold,
  );
}
