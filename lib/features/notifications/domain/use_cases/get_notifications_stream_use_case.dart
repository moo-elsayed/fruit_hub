import 'package:fruit_hub/core/network/network_response.dart';

import '../entities/notification_entity.dart';
import '../repo/notifications_repo.dart';

class GetNotificationsStreamUseCase {
  const GetNotificationsStreamUseCase(this._notificationsRepo);

  final NotificationsRepo _notificationsRepo;

  Stream<NetworkResponse<List<NotificationEntity>>> call() =>
      _notificationsRepo.getNotificationsStream();
}
