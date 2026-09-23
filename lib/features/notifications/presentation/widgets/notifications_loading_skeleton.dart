import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/enums/notification_type.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../domain/entities/notification_entity.dart';
import 'notification_item_widget.dart';

class NotificationsLoadingSkeleton extends StatelessWidget {
  const NotificationsLoadingSkeleton({super.key});

  static const _dummyNotification = NotificationEntity(
    id: 'dummy',
    title: 'إشعار بخصوص طلبك في الطريق',
    body: 'طلبك قيد التجهيز وسيتم شحنه في أسرع وقت ممكن للمعاينة',
    type: NotificationType.order,
    isRead: false,
  );

  @override
  Widget build(BuildContext context) => Skeletonizer(
    enabled: true,
    child: ListView.separated(
      itemCount: 6,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      separatorBuilder: (context, index) => SizedBox(height: 10.h),
      itemBuilder: (context, index) => NotificationItemWidget(
        key: ValueKey(index),
        notification: _dummyNotification,
        onTap: () {},
      ),
    ),
  );
}
