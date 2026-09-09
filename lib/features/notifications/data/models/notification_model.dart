import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fruit_hub/core/enums/notification_type.dart';

import '../../domain/entities/notification_entity.dart';

class NotificationModel {
  const NotificationModel({
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

  factory NotificationModel.fromFirestore(
    Map<String, dynamic> json,
    String docId,
  ) {
    final rawCreatedAt = json['createdAt'];
    DateTime? parsedDate;
    if (rawCreatedAt is Timestamp) {
      parsedDate = rawCreatedAt.toDate();
    } else if (rawCreatedAt is String) {
      parsedDate = DateTime.tryParse(rawCreatedAt);
    }

    // Bilingual fields (new documents). Old documents fall back to single title/body.
    final titleAr = json['titleAr'] as String?;
    final titleEn = json['titleEn'] as String?;
    final bodyAr = json['bodyAr'] as String?;
    final bodyEn = json['bodyEn'] as String?;
    final legacyTitle = json['title'] as String? ?? '';
    final legacyBody = json['body'] as String? ?? '';

    return NotificationModel(
      id: docId,
      title: legacyTitle,
      body: legacyBody,
      titleAr: titleAr,
      titleEn: titleEn,
      bodyAr: bodyAr,
      bodyEn: bodyEn,
      type: NotificationType.fromString(json['type'] as String?),
      isRead: json['isRead'] as bool? ?? false,
      orderId: json['orderId']?.toString(),
      status: json['status'] as String?,
      productCode: json['productCode'] as String?,
      createdAt: parsedDate,
    );
  }

  final String id;
  final String title;
  final String body;
  final String? titleAr;
  final String? titleEn;
  final String? bodyAr;
  final String? bodyEn;
  final NotificationType type;
  final bool isRead;
  final String? orderId;
  final String? status;
  final String? productCode;
  final DateTime? createdAt;

  Map<String, dynamic> toJson() => {
    'title': title,
    'body': body,
    if (titleAr != null) 'titleAr': titleAr,
    if (titleEn != null) 'titleEn': titleEn,
    if (bodyAr != null) 'bodyAr': bodyAr,
    if (bodyEn != null) 'bodyEn': bodyEn,
    'type': type.value,
    'isRead': isRead,
    if (orderId != null) 'orderId': orderId,
    if (status != null) 'status': status,
    if (productCode != null) 'productCode': productCode,
    if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
  };

  NotificationEntity toEntity() => NotificationEntity(
    id: id,
    title: title,
    body: body,
    titleAr: titleAr,
    titleEn: titleEn,
    bodyAr: bodyAr,
    bodyEn: bodyEn,
    type: type,
    isRead: isRead,
    orderId: orderId,
    status: status,
    productCode: productCode,
    createdAt: createdAt,
  );
}
