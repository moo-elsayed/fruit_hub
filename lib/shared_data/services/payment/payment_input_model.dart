import '../../../core/services/payment/payment_input_entity.dart';

class PaymentInputModel {
  PaymentInputModel({
    required this.amount,
    required this.currency,
    required this.customerId,
  });

  final double amount;
  final String currency;
  final String customerId;

  factory PaymentInputModel.fromEntity(PaymentInputEntity entity) =>
      PaymentInputModel(
        amount: entity.amount,
        customerId: entity.customerId,
        currency: entity.currency,
      );

  PaymentInputEntity toEntity() => PaymentInputEntity(
    amount: amount,
    customerId: customerId,
    currency: currency,
  );

  PaymentInputModel copyWith({
    double? amount,
    String? currency,
    String? customerId,
  }) {
    return PaymentInputModel(
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      customerId: customerId ?? this.customerId,
    );
  }
}
