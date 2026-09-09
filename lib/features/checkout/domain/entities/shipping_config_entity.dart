class ShippingConfigEntity {
  const ShippingConfigEntity({
    this.shippingCost = 0,
    this.freeShippingThreshold,
  });

  final double shippingCost;
  final double? freeShippingThreshold;

  bool isFreeShipping(double subtotal) =>
      freeShippingThreshold != null &&
      freeShippingThreshold! > 0 &&
      subtotal >= freeShippingThreshold!;

  double calculateShippingCost(double subtotal) =>
      isFreeShipping(subtotal) ? 0.0 : shippingCost;

  double remainingForFreeShipping(double subtotal) =>
      (freeShippingThreshold != null && freeShippingThreshold! > subtotal)
      ? (freeShippingThreshold! - subtotal)
      : 0.0;

  double progressRatio(double subtotal) {
    if (freeShippingThreshold == null || freeShippingThreshold! <= 0) {
      return 1.0;
    }
    return (subtotal / freeShippingThreshold!).clamp(0.0, 1.0);
  }
}
