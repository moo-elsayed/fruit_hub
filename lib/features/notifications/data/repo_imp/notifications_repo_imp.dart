import 'dart:async';

import 'package:fruit_hub/core/network/api_helper.dart';
import 'package:fruit_hub/core/network/network_response.dart';

import '../../domain/entities/notification_entity.dart';
import '../../domain/repo/notifications_repo.dart';
import '../data_sources/remote/notifications_remote_data_source.dart';

class NotificationsRepoImp implements NotificationsRepo {
  const NotificationsRepoImp(this._remoteDataSource);

  final NotificationsRemoteDataSource _remoteDataSource;

  @override
  Stream<NetworkResponse<List<NotificationEntity>>> getNotificationsStream() =>
      _remoteDataSource.getNotificationsStream().transform(
        StreamTransformer.fromHandlers(
          handleData: (models, sink) => sink.add(
            NetworkSuccess(models.map((model) => model.toEntity()).toList()),
          ),
          handleError: (error, _, sink) => sink.add(
            NetworkFailure<List<NotificationEntity>>(
              ApiHelper.failureFromException(error),
            ),
          ),
        ),
      );

  @override
  Future<NetworkResponse<void>> markAsRead(String notificationId) =>
      _remoteDataSource.markAsRead(notificationId);

  @override
  Future<NetworkResponse<void>> markAllAsRead() =>
      _remoteDataSource.markAllAsRead();
}
