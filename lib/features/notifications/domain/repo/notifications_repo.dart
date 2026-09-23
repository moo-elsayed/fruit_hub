import 'package:fruit_hub/core/network/network_response.dart';

import '../entities/notification_entity.dart';

abstract class NotificationsRepo {
  Stream<NetworkResponse<List<NotificationEntity>>> getNotificationsStream();

  Future<NetworkResponse<void>> markAsRead(String notificationId);

  Future<NetworkResponse<void>> markAllAsRead();
}
