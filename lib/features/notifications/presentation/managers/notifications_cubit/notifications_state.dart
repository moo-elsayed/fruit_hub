import '../../../domain/entities/notification_entity.dart';

sealed class NotificationsState {
  const NotificationsState();
}

class NotificationsInitial extends NotificationsState {
  const NotificationsInitial();
}

class NotificationsLoading extends NotificationsState {
  const NotificationsLoading();
}

class NotificationsSuccess extends NotificationsState {
  const NotificationsSuccess(this.notifications);

  final List<NotificationEntity> notifications;

  int get unreadCount => notifications.where((n) => !n.isRead).length;
}

class NotificationsFailure extends NotificationsState {
  const NotificationsFailure(this.errorMessage);

  final String errorMessage;
}
