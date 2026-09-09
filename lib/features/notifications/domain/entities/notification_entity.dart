import 'package:fruit_hub/core/enums/notification_type.dart';

class NotificationEntity {
  const NotificationEntity({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.isRead,
    this.titleAr,
    this.titleEn,
    this.bodyAr,
    this.bodyEn,
    this.orderId,
    this.status,
    this.productCode,
    this.createdAt,
  });

  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final bool isRead;
  final String? titleAr;
  final String? titleEn;
  final String? bodyAr;
  final String? bodyEn;
  final String? orderId;
  final String? status;
  final String? productCode;
  final DateTime? createdAt;

  String localizedTitle(bool isArabic) =>
      isArabic ? (titleAr ?? title) : (titleEn ?? title);

  String localizedBody(bool isArabic) =>
      isArabic ? (bodyAr ?? body) : (bodyEn ?? body);
}
