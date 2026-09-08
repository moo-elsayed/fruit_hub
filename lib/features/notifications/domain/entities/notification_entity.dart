class NotificationEntity {
  const NotificationEntity({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.isRead,
    this.orderId,
    this.status,
    this.productCode,
    this.createdAt,
  });

  final String id;
  final String title;
  final String body;
  final String type;
  final bool isRead;
  final String? orderId;
  final String? status;
  final String? productCode;
  final DateTime? createdAt;
}
