enum PaymentMethodType {
  paypal,
  card,
  cash;

  String get databaseValue => switch (this) {
    PaymentMethodType.paypal => 'paypal',
    PaymentMethodType.card => 'credit_card',
    PaymentMethodType.cash => 'cash_on_delivery',
  };

  static PaymentMethodType fromString(String? value) =>
      switch (value?.toLowerCase()) {
        'credit_card' || 'card' => PaymentMethodType.card,
        'cash_on_delivery' || 'cash' => PaymentMethodType.cash,
        _ => PaymentMethodType.paypal,
      };
}
