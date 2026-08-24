enum PaymentMethodType {
  paypal,
  card,
  cash;

  String get databaseValue => switch (this) {
    PaymentMethodType.paypal => 'paypal',
    PaymentMethodType.card => 'credit_card',
    PaymentMethodType.cash => 'cash_on_delivery',
  };
}
