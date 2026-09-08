import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../domain/entities/notification_entity.dart';
import '../managers/notifications_cubit/notifications_cubit.dart';
import 'notification_item_widget.dart';

class NotificationsListView extends StatelessWidget {
  const NotificationsListView({super.key, required this.notifications});

  final List<NotificationEntity> notifications;

  @override
  Widget build(BuildContext context) => ListView.separated(
    physics: const BouncingScrollPhysics(),
    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
    itemCount: notifications.length,
    separatorBuilder: (context, index) => SizedBox(height: 10.h),
    itemBuilder: (context, index) {
      final notification = notifications[index];
      return NotificationItemWidget(
        key: ValueKey(notification.id),
        notification: notification,
        onTap: () =>
            context.read<NotificationsCubit>().markAsRead(notification.id),
      );
    },
  );
}
