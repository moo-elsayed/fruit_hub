import 'package:fruit_hub/core/network/network_response.dart';

import '../repo/notifications_repo.dart';

class MarkNotificationAsReadUseCase {
  const MarkNotificationAsReadUseCase(this._notificationsRepo);

  final NotificationsRepo _notificationsRepo;

  Future<NetworkResponse<void>> call(String notificationId) =>
      _notificationsRepo.markAsRead(notificationId);
}
