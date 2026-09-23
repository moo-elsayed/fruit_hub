import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fruit_hub/core/network/network_response.dart';

import '../../../domain/entities/notification_entity.dart';
import '../../../domain/use_cases/get_notifications_stream_use_case.dart';
import '../../../domain/use_cases/mark_all_notifications_as_read_use_case.dart';
import '../../../domain/use_cases/mark_notification_as_read_use_case.dart';
import 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit({
    required this.getNotificationsStreamUseCase,
    required this.markNotificationAsReadUseCase,
    required this.markAllNotificationsAsReadUseCase,
  }) : super(const NotificationsInitial());

  final GetNotificationsStreamUseCase getNotificationsStreamUseCase;
  final MarkNotificationAsReadUseCase markNotificationAsReadUseCase;
  final MarkAllNotificationsAsReadUseCase markAllNotificationsAsReadUseCase;

  StreamSubscription<NetworkResponse<List<NotificationEntity>>>? _subscription;

  void initNotificationsStream() {
    _subscription?.cancel();
    emit(const NotificationsLoading());

    _subscription = getNotificationsStreamUseCase().listen(
      (response) {
        if (!isClosed) {
          switch (response) {
            case NetworkSuccess<List<NotificationEntity>>(:final data):
              emit(NotificationsSuccess(data ?? []));
            case NetworkFailure<List<NotificationEntity>>(:final error):
              emit(NotificationsFailure(error));
          }
        }
      },
      onError: (error) {
        if (!isClosed) {
          emit(NotificationsFailure(error.toString()));
        }
      },
    );
  }

  Future<void> markAsRead(String notificationId) =>
      markNotificationAsReadUseCase(notificationId);

  Future<void> markAllAsRead() => markAllNotificationsAsReadUseCase();

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
