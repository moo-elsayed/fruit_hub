import 'package:fruit_hub/core/network/network_response.dart';

import '../../domain/entities/notification_entity.dart';
import '../../domain/repo/notifications_repo.dart';
import '../data_sources/remote/notifications_remote_data_source.dart';

class NotificationsRepoImp implements NotificationsRepo {
  const NotificationsRepoImp(this._remoteDataSource);

  final NotificationsRemoteDataSource _remoteDataSource;

  @override
  Stream<List<NotificationEntity>> getNotificationsStream() => _remoteDataSource
      .getNotificationsStream()
      .map((models) => models.map((model) => model.toEntity()).toList());

  @override
  Future<NetworkResponse<void>> markAsRead(String notificationId) =>
      _remoteDataSource.markAsRead(notificationId);

  @override
  Future<NetworkResponse<void>> markAllAsRead() =>
      _remoteDataSource.markAllAsRead();
}
