import 'package:fruit_hub/core/network/network_response.dart';

import '../repo/notifications_repo.dart';

class MarkAllNotificationsAsReadUseCase {
  const MarkAllNotificationsAsReadUseCase(this._notificationsRepo);

  final NotificationsRepo _notificationsRepo;

  Future<NetworkResponse<void>> call() => _notificationsRepo.markAllAsRead();
}
