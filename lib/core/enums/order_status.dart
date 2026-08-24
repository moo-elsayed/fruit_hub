enum OrderStatus {
  pending,
  processing,
  shipped,
  delivered,
  cancelled;

  String get databaseValue => switch (this) {
    OrderStatus.pending => 'pending',
    OrderStatus.processing => 'processing',
    OrderStatus.shipped => 'shipped',
    OrderStatus.delivered => 'delivered',
    OrderStatus.cancelled => 'cancelled',
  };
}
