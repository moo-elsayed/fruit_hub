import '../../domain/entities/payment_input_entity.dart';

class PaymentInputModel {
  PaymentInputModel({
    required this.amount,
    required this.currency,
    this.customerId = '',
  });

  factory PaymentInputModel.fromEntity(PaymentInputEntity entity) =>
      PaymentInputModel(
        amount: entity.amount,
        customerId: entity.customerId,
        currency: entity.currency,
      );

  final double amount;
  final String currency;
  final String customerId;

  String get amountInCents => (amount * 100).toInt().toString();

  PaymentInputEntity toEntity() => PaymentInputEntity(
    amount: amount,
    customerId: customerId,
    currency: currency,
  );

  PaymentInputModel copyWith({
    double? amount,
    String? currency,
    String? customerId,
  }) => PaymentInputModel(
    amount: amount ?? this.amount,
    currency: currency ?? this.currency,
    customerId: customerId ?? this.customerId,
  );
}
