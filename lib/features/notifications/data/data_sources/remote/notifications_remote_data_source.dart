import 'package:fruit_hub/core/network/network_response.dart';

import '../../models/notification_model.dart';

abstract class NotificationsRemoteDataSource {
  Stream<List<NotificationModel>> getNotificationsStream();

  Future<NetworkResponse<void>> markAsRead(String notificationId);

  Future<NetworkResponse<void>> markAllAsRead();
}
