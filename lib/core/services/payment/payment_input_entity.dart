class PaymentInputEntity {
  PaymentInputEntity({
    this.amount = 0,
    this.currency = '',
    this.customerId = '',
  });

  final double amount;
  final String currency;
  final String customerId;

  String get amountInCents => (amount * 100).toInt().toString();
}
