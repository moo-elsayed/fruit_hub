import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/notification_entity.dart';

class NotificationModel {
  const NotificationModel({
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

    return NotificationModel(
      id: docId,
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      type: json['type'] as String? ?? '',
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
  final String type;
  final bool isRead;
  final String? orderId;
  final String? status;
  final String? productCode;
  final DateTime? createdAt;

  Map<String, dynamic> toJson() => {
    'title': title,
    'body': body,
    'type': type,
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
    type: type,
    isRead: isRead,
    orderId: orderId,
    status: status,
    productCode: productCode,
    createdAt: createdAt,
  );
}
